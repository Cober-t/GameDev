PhysicsSystem = ECS.system({ pool = {"transform", "rigidbody", "collider"},
                             secondPool = {"transform", "rigidbody", "movement", "collider"} })

----------------------------------------------------------------------------------

function PhysicsSystem:init()
    for _, entity in ipairs(self.secondPool) do 
        entity.rigidbody.groundGravity = (-2.0 * entity.movement.jumpHeight) / math.pow(entity.movement.timeToJumpApex, 2)
    end
end

----------------------------------------------------------------------------------

function PhysicsSystem:update(dt)
    
    -- Calculate gravity for jumping entities
    for _, entity in ipairs(self.secondPool) do

        entity.rigidbody.gravityScale = (entity.rigidbody.groundGravity / GRAVITY) * entity.rigidbody.gravityMultiplier
        
        -- Get velocity from RigidbodyComponent
        entity.movement.velocity.y = entity.rigidbody.velocity.y
        -- Keep trying to do a jump, for as long as desiredJump is true
        if entity.movement.desiredJump then
            self:doAJump(entity.movement, entity.rigidbody)
            entity.rigidbody.velocity.y = entity.movement.velocity.y
            
            -- Skip gravity calculations this frame, so currentlyJumping doesn't turn off
            -- This makes sure you can't do the coyote time double jump bug
        else
            self:calculateGravity(entity.movement, entity.rigidbody, dt)
        end
    end
    
    for _, entity in ipairs(self.pool) do
        -- Apply Movement
        entity.transform.posX = entity.transform.posX + entity.rigidbody.velocity.x * dt
        -- Apply Gravity
        entity.rigidbody.velocity.y = entity.rigidbody.velocity.y - GRAVITY * dt * entity.rigidbody.gravityScale
        entity.transform.posY = entity.transform.posY + entity.rigidbody.velocity.y

        -- Change velocity by collision normal
        if entity.movement.onFloor then
            local newPosX = entity.transform.posX + entity.collider.offsetX
            local newPosY = entity.transform.posY + entity.collider.offsetY
            local actualX, actualY, cols, len = BumpWorld:check(entity, newPosX, newPosY, self.filter)
            for i=1, len do
                local col = cols[i]
                local nx = col.normal.x
                local ny = col.normal.y
                local vx = entity.rigidbody.velocity.x
                local vy = entity.rigidbody.velocity.y
                if (ny < 0 and vy > 0) or (ny > 0 and vy < 0) then
                    vy = -vy * entity.rigidbody.bounciness
                end
                entity.rigidbody.velocity.x = vx
                entity.rigidbody.velocity.y = vy
            end
        end
    end
end

----------------------------------------------------------------------------------

function PhysicsSystem:doAJump(mv, rb)
    --Create the jump, provided we are on the ground, in coyote time, or have a double jump available
    if mv.onFloor or (mv.coyoteTimeCounter > 0.03 and mv.coyoteTimeCounter < mv.coyoteTime) or mv.canJumpAgain then
        mv.desiredJump = false
        mv.jumpBufferCounter = 0.0
        mv.coyoteTimeCounter = 0.0

        -- If we have double jump on, allow us to jump again (but only once)
        mv.canJumpAgain = (mv.maxAirJumps == 1 and mv.canJumpAgain == false)

        -- Determine the power of the jump, based on our gravity and stats
        mv.jumpForce = math.sqrt(-2.0 * GRAVITY * (rb.groundGravity / GRAVITY) * mv.jumpHeight)

        -- If the Player is moving up or down when she jumps (such as when doing a double jump), change the jumpForce;
        -- This will ensure the jump is the exact same strength, no matter your velocity.
        if mv.velocity.y < 0.0 then
            mv.jumpForce = math.max(mv.jumpForce + mv.velocity.y, 0.0)
        elseif mv.velocity.y > 0.0 then
            -- mv.jumpForce = mv.jumpForce - math.abs(rb.velocity.y) Force Down in the future
            -- TODO: Or apply a multy to reduce impulse on second jump
            mv.jumpForce = mv.jumpForce + math.abs(rb.velocity.y) * 0.85
        end

        -- Apply the new jumpForce to the velocity. It will be sent to the Rigidbody in FixedUpdate;
        mv.velocity.y = mv.velocity.y - mv.jumpForce
        mv.currentlyJumping = true

        -- Initialize variable jump height tracking
        if mv.variableJumpHeight then
            mv.jumpStartTime = love.timer.getTime() -- Track when jump started
            mv.jumpMinimumMet = false -- Track if minimum jump time has passed
        end

        -- if juice != nil then
        --     -- Apply the jumping effects on the juice script
        --     juice.jumpEffects();
        -- end
    end

    if mv.jumpBuffer == 0 then
        -- If we don't have a jump buffer, then turn off desiredJump immediately after hitting jumping
        mv.desiredJump = false;
    end
end

----------------------------------------------------------------------------------

function PhysicsSystem:calculateGravity(mv, rb, dt)
    -- We change the character's gravity based on her Y direction

    -- If the Player is going up...
    if rb.velocity.y < -0.01 then
        if mv.onFloor then
            -- Don't change it if Kit is stood on something (such as a moving platform)
            rb.gravityMultiplier = rb.defaultGravityScale;
        else
            -- If we're using variable jump height...)
            if mv.variableJumpHeight then
                self:handleVariableJumpHeight(mv, rb, dt)
            else
                rb.gravityMultiplier = rb.upwardMovementMultiplier
            end
        end
    -- Else if going down...
    elseif rb.velocity.y > 0.01 then
        if mv.onFloor then
            --Don't change it if Kit is stood on something (such as a moving platform)
            rb.gravityMultiplier = rb.defaultGravityScale
        else
            -- Otherwise, apply the downward gravity multiplier as Kit comes back to Earth
            rb.gravityMultiplier = rb.downwardMovementMultiplier
            -- Reset jump state when falling
            if mv.variableJumpHeight and mv.currentlyJumping then
                mv.currentlyJumping = false
            end
        end
    else
        --Else not moving vertically at all
        if mv.onFloor then
            mv.currentlyJumping = false
            if mv.variableJumpHeight then
                mv.jumpMinimumMet = false
            end
        end
        
        rb.gravityMultiplier = rb.defaultGravityScale
    end

    -- Set the character's Rigidbody's velocity
    -- But clamp the Y variable within the bounds of the speed limit, for the terminal velocity assist option
    rb.velocity.y = math.min(math.max(-rb.fallSpeedLimit, mv.velocity.y), 100.0)
end


----------------------------------------------------------------------------------

function PhysicsSystem:handleVariableJumpHeight(mv, rb, dt)
    -- Only apply variable jump logic if we're currently jumping and moving upward
    if not mv.currentlyJumping then
        rb.gravityMultiplier = rb.upwardMovementMultiplier
        return
    end
    
    -- Calculate how long we've been jumping
    local currentTime = love.timer.getTime()
    local jumpDuration = currentTime - mv.jumpStartTime
    
    -- Check if minimum jump time has been met
    if jumpDuration >= mv.minJumpHoldTime then
        mv.jumpMinimumMet = true
    end
    
    -- Determine gravity based on jump button state and timing
    if mv.pressingJump then
        -- Still holding jump button
        if jumpDuration < mv.maxJumpHoldTime then
            -- Within max hold time - use light gravity for higher jumps
            rb.gravityMultiplier = mv.jumpHoldGravityMultiplier or (rb.upwardMovementMultiplier * 0.6)
        else
            -- Exceeded max hold time - switch to normal upward gravity
            rb.gravityMultiplier = rb.upwardMovementMultiplier
        end
    else
        -- Jump button released
        if mv.jumpMinimumMet then
            -- Minimum time met - can use heavy gravity for jump cut
            rb.gravityMultiplier = mv.jumpReleaseGravityMultiplier or (rb.upwardMovementMultiplier * 1.8)
        else
            -- Still in minimum time - use light gravity to ensure minimum jump height
            rb.gravityMultiplier = mv.jumpHoldGravityMultiplier or (rb.upwardMovementMultiplier * 0.6)
        end
    end
    
    -- Optional: Add extra floatiness near the peak
    if mv.enablePeakFloatiness and math.abs(rb.velocity.y) < mv.peakVelocityThreshold then
        rb.gravityMultiplier = rb.gravityMultiplier * mv.peakGravityMultiplier
    end
end

----------------------------------------------------------------------------------
