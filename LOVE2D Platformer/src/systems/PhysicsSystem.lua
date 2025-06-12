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
        local mv = entity.movement
        local rb = entity.rigidbody
        rb.gravityScale = (rb.groundGravity / GRAVITY) * rb.gravityMultiplier

        -- Get velocity from RigidbodyComponent
        mv.velocity.y = rb.velocity.y

        -- Skip gravity calculations this frame, so currentlyJumping doesn't turn off
        -- This makes sure you can't do the coyote time double jump bug
        if not mv.desiredJump then
            self:calculateGravity(mv, rb, dt)
        end
    end
    
    for _, entity in ipairs(self.pool) do
        local mv = entity.movement
        local rb = entity.rigidbody
        local tf = entity.transform
        local cl = entity.collider
        -- Apply Movement
        tf.posX = tf.posX + rb.velocity.x * dt
        -- Apply Gravity
        rb.velocity.y = rb.velocity.y - GRAVITY * dt * rb.gravityScale
        tf.posY = tf.posY + rb.velocity.y

        -- Change velocity by collision normal
        if mv.onFloor then
            mv.airJumps = mv.maxAirJumps
            local newPosX = tf.posX + cl.offsetX
            local newPosY = tf.posY + cl.offsetY
            local actualX, actualY, cols, len = BumpWorld:check(entity, newPosX, newPosY, self.filter)
            for i=1, len do
                local col = cols[i]
                local nx = col.normal.x
                local ny = col.normal.y
                local vx = rb.velocity.x
                local vy = rb.velocity.y
                if (ny < 0 and vy > 0) or (ny > 0 and vy < 0) then
                    vy = -vy * rb.bounciness
                end
                rb.velocity.x = vx
                rb.velocity.y = vy
            end
        end
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
