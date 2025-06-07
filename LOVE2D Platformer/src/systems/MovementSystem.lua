MovementSystem = ECS.system({ pool = {"transform", "rigidbody", "movement", "collider"} })


----------------------------------------------------------------------------------

function MovementSystem:update(dt)

    for _, entity in ipairs(self.pool) do
        if not entity.movement.canMove then
            ::continue:: 
        end
        entity.movement.pressingKey = entity.movement.direction ~= 0
        entity.movement.desiredVelocity.x = entity.movement.direction * math.max(entity.rigidbody.maxSpeed - entity.rigidbody.friction, 0.0);
        entity.movement.velocity = entity.rigidbody.velocity
        
        -- Movement
        if entity.movement.useAcceleration then
            self:runWithAcceleration(entity.movement, entity.rigidbody, entity.collider, dt)
        else
            if self.col.onFloor then
                self:runWithoutAcceleration(entity.movement, dt)
            else
                self:runWithAcceleration(entity.movement, entity.rigidbody, entity.collider, dt)
            end
        end

        -- Jump
    end
end

----------------------------------------------------------------------------------

local function signum(number)
   return (number > 0 and 1) or (number == 0 and 0) or -1
end

function MovementSystem:runWithAcceleration(mv, rb, col, dt)
    -- Set our acceleration, deceleration, and turn speed stats, based on whether we're on the ground on in the air
    mv.acceleration = col.onFloor and rb.maxAcceleration  or rb.maxAirAcceleration
    mv.deceleration = col.onFloor and rb.maxDecceleration or rb.maxAirDecceleration
    mv.turnSpeed    = col.onFloor and rb.maxTurnSpeed     or rb.maxAirTurnSpeed 
 
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
