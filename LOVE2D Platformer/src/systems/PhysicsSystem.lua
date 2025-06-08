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
            local actualX, actualY, cols, len = BumpWorld:check(entity, entity.transform.posY, entity.transform.posY, self.filter)
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
            mv.jumpForce = mv.jumpForce + math.abs(rb.velocity.y)
        end

        -- Apply the new jumpForce to the velocity. It will be sent to the Rigidbody in FixedUpdate;
        mv.velocity.y = mv.velocity.y - mv.jumpForce;
        mv.currentlyJumping = true;

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
                -- Apply upward multiplier if player is rising and holding jump
                if mv.pressingJump and mv.currentlyJumping then
                    rb.gravityMultiplier = rb.upwardMovementMultiplier
                else
                    -- But apply a special downward multiplier if the player lets go of jump
                    rb.gravityMultiplier = mv.jumpCutOff;
                end
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
        end
    else
        --Else not moving vertically at all
        if mv.onFloor then
            mv.currentlyJumping = false
        end
        
        rb.gravityMultiplier = rb.defaultGravityScale
    end

    -- Set the character's Rigidbody's velocity
    -- But clamp the Y variable within the bounds of the speed limit, for the terminal velocity assist option
    rb.velocity.y = math.min(math.max(-rb.fallSpeedLimit, mv.velocity.y), 100.0)
end

----------------------------------------------------------------------------------
