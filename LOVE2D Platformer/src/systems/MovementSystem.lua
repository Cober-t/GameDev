MovementSystem = ECS.system({ pool = {"transform", "rigidbody", "movement"} })


----------------------------------------------------------------------------------

-- Maps a number from one range to another
function map(x, in_min, in_max, out_min, out_max)
	return out_min + (x - in_min)*(out_max - out_min)/(in_max - in_min)
end

----------------------------------------------------------------------------------

function MovementSystem:update(dt)

    for _, entity in ipairs(self.pool) do
        if not entity.movement.canMove then
            ::continue:: 
        end
        entity.movement.pressingKey = entity.movement.direction ~= 0
        entity.movement.desiredVelocity.x = entity.movement.direction * math.max(entity.rigidbody.maxSpeed - entity.rigidbody.friction, 0.0)
        entity.movement.velocity = entity.rigidbody.velocity
        
        -- Movement ------------------------------------------------------------------------------
        if entity.movement.useAcceleration then
            self:runWithAcceleration(entity.movement, entity.rigidbody, dt)
        else
            if self.col.onFloor then
                self:runWithoutAcceleration(entity.movement, dt)
            else
                self:runWithAcceleration(entity.movement, entity.rigidbody, dt)
            end
        end

        -- Jump ---------------------------------------------------------------------------------
        -- Jump Buffer allows us to queue up a jump, which will play when we next hit the ground
        if entity.movement.jumpBuffer > 0 then
            -- Instead of immediately turning off "desireJump", start counting up...
            -- All the while, the DoAJump function will repeatedly be fired off
            if entity.movement.desiredJump then

                entity.movement.jumpBufferCounter = entity.movement.jumpBufferCounter + dt

                if entity.movement.jumpBufferCounter > entity.movement.jumpBuffer then
                    -- If time exceeds the jump buffer, turn off "desireJump"
                    entity.movement.desiredJump = false;
                    entity.movement.jumpBufferCounter = 0;
                end
            end
        end

        -- Variable jump force. Calculate target jump height based on hold time
        if entity.movement.variableJumpHeight then            
            entity.movement.jumpHoldTime = entity.movement.pressingJump and (entity.movement.jumpHoldTime + dt) or 0.0

            -- Optional: Calculate jump cut-off height for debugging/UI purposes
            if entity.movement.currentlyJumping and entity.movement.pressingJump then
                local holdTime = entity.movement.jumpHoldTime
                local minHoldTime = entity.movement.minJumpHoldTime
                local maxHoldTime = entity.movement.maxJumpHoldTime
                local minJumpHeight = entity.movement.minJumpHeight
                local maxJumpHeight = entity.movement.maxJumpHeight
                
                -- Clamp hold time to valid range
                holdTime = math.max(minHoldTime, math.min(holdTime, maxHoldTime))
                entity.movement.jumpCutOff = map(holdTime, minHoldTime, maxHoldTime, minJumpHeight, maxJumpHeight)
            end
        end

        -- If we're not on the ground and we're not currently jumping, that means we've stepped off the edge of a platform.
        -- So, start the coyote time counter...
        if not entity.movement.currentlyJumping and not entity.movement.onFloor then
            entity.movement.coyoteTimeCounter = entity.movement.coyoteTimeCounter + dt;
        else
            -- Reset it when we touch the ground, or jump
            entity.movement.coyoteTimeCounter = 0
        end
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
    if math.abs(difference) <= stepSpeed then
        -- If we're close enough, just return the target
        return target
    else
        -- Move towards the target by maxDelta amount
        if difference > 0 then
            return current + stepSpeed
        else
            return current - stepSpeed
        end
    end
end

----------------------------------------------------------------------------------

function MovementSystem:runWithoutAcceleration(mv, dt)
    -- If we're not using acceleration and deceleration, just send our desired velocity (direction * max speed) to the Rigidbody
    mv.velocity.x = mv.desiredVelocity.x
    mv.rb.velocity.x = mv.velocity.x
end

----------------------------------------------------------------------------------
