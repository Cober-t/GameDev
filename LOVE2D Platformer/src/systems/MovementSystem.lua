MovementSystem = ECS.system({ pool = {"transform", "rigidbody", "movement"} })

----------------------------------------------------------------------------------

function MovementSystem:update(dt)

    for _, entity in ipairs(self.pool) do
        local mv = entity.movement
        local rb = entity.rigidbody

        if not mv.canMove then ::continue::  end
        mv.pressingKey = mv.direction ~= 0
        mv.desiredVelocity.x = mv.direction * math.max(rb.maxSpeed - rb.friction, 0.0)
        mv.velocity = rb.velocity
        
        -- Movement ------------------------------------------------------------------------------
        if mv.useAcceleration then
            self:runWithAcceleration(mv, rb, dt)
        else
            if self.col.onFloor then
                self:runWithoutAcceleration(mv, dt)
            else
                self:runWithAcceleration(mv, rb, dt)
            end
        end

        -- Jump ---------------------------------------------------------------------------------
        -- Jump Buffer allows us to queue up a jump, which will play when we next hit the ground
        self:calculateJumpBuffer(mv, dt)
        self:calculateVariableJump(mv, dt)
        self:calculateCoyoteTime(mv, dt)
        self:doAJump(mv, rb, dt)
    end
end

----------------------------------------------------------------------------------

local function signum(number)
   return (number > 0 and 1) or (number == 0 and 0) or -1
end

function MovementSystem:runWithAcceleration(mv, rb, dt)
    -- Set our acceleration, deceleration, and turn speed stats, based on whether we're on the ground on in the air
    mv.acceleration = mv.onFloor and rb.maxAcceleration  or rb.maxAirAcceleration
    mv.deceleration = mv.onFloor and rb.maxDecceleration or rb.maxAirDecceleration
    mv.turnSpeed    = mv.onFloor and rb.maxTurnSpeed     or rb.maxAirTurnSpeed 
 
    if mv.pressingKey then
        -- If the sign (i.e. positive or negative) of our input direction doesn't match our movement, it means we're turning around and so should use the turn speed stat.
        if signum(mv.direction) ~= signum(mv.velocity.x) then
            mv.maxSpeedChange = mv.turnSpeed * dt
        else
            -- If they match, it means we're simply running along and so should use the acceleration stat
            mv.maxSpeedChange = mv.acceleration * dt
        end
    else
        -- And if we're not pressing a direction at all, use the deceleration stat
        mv.maxSpeedChange = mv.deceleration * dt;
    end
    
    mv.velocity.x = self:moveTowards(mv.velocity.x, mv.desiredVelocity.x, mv.maxSpeedChange)
    rb.velocity.x = mv.velocity.x
end

----------------------------------------------------------------------------------

function MovementSystem:moveTowards(current, target, stepSpeed)
    local difference = target - current
    -- If we're close enough, just return the target
    if math.abs(difference) <= stepSpeed then return target end
    -- Move towards the target by maxDelta amount
    if difference > 0 then
        return current + stepSpeed
    else
        return current - stepSpeed
    end
end

----------------------------------------------------------------------------------

function MovementSystem:runWithoutAcceleration(mv, dt)
    -- If we're not using acceleration and deceleration, just send our desired velocity (direction * max speed) to the Rigidbody
    mv.velocity.x = mv.desiredVelocity.x
    mv.rb.velocity.x = mv.velocity.x
end

----------------------------------------------------------------------------------

function MovementSystem:calculateJumpBuffer(mv, dt)
    if mv.jumpBuffer <= 0 then return end
    -- Instead of immediately turning off "desireJump", start counting up...
    -- All the while, the DoAJump function will repeatedly be fired off
    if not mv.desiredJump then return end

    mv.jumpBufferCounter = mv.jumpBufferCounter + dt
    if mv.jumpBufferCounter > mv.jumpBuffer then
        -- If time exceeds the jump buffer, turn off "desireJump"
        mv.desiredJump = false;
        mv.jumpBufferCounter = 0;
    end
end

----------------------------------------------------------------------------------

function MovementSystem:calculateCoyoteTime(mv, dt)
    -- If we're not on the ground and we're not currently jumping,
    -- that means we've stepped off the edge of a platform. So, start the coyote time counter...
    if mv.onFloor then
        -- Reset it when we touch the ground, or jump
        mv.coyoteTimeCounter = 0.0
    else
        mv.coyoteTimeCounter = mv.coyoteTimeCounter + dt;
    end
end

----------------------------------------------------------------------------------

function MovementSystem:calculateVariableJump(mv, dt)
    -- Variable jump force. Calculate target jump height based on hold time
    if not mv.variableJumpHeight then return end

    mv.jumpHoldTime = mv.pressingJump and (mv.jumpHoldTime + dt) or 0.0
end

----------------------------------------------------------------------------------

function MovementSystem:doAJump(mv, rb, dt)
    -- Keep trying to do a jump, for as long as desiredJump is true
    if not mv.desiredJump then return end

    --Create the jump, provided we are on the ground, in coyote time, or have a double jump available
    if mv.onFloor or (mv.coyoteTimeCounter > 0.03 and mv.coyoteTimeCounter < mv.coyoteTime) or mv.airJumps > 0 then
        mv.desiredJump = false
        mv.jumpBufferCounter = 0.0

        -- If we have double jump on, allow us to jump again (but only once)
        if not mv.onFloor and mv.coyoteTimeCounter > mv.coyoteTime then
            mv.airJumps = mv.airJumps - 1
        end

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

    rb.velocity.y = mv.velocity.y
end
----------------------------------------------------------------------------------
