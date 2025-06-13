PhysicsSystem = ECS.system({ pool = {"transform", "rigidbody", "collider"},
                             secondPool = {"transform", "rigidbody", "movement", "collider"} })

----------------------------------------------------------------------------------

function PhysicsSystem:init()
    Log:debug("PhysicsSystem INIT " .. #self.secondPool .. " entities!")
    for _, entity in ipairs(self.secondPool) do 
        entity.rigidbody.groundGravity = (-2.0 * entity.movement.jumpHeight) / math.pow(entity.movement.timeToJumpApex, 2)
    end

    self.accumulator = 0
    self.fixedDeltaTime = FIXED_DT
end

----------------------------------------------------------------------------------

function PhysicsSystem:update(dt)
    
    -- Fixed physics calculations, for decouple game logic from framerate
    self.accumulator = self.accumulator + dt
    while self.accumulator >= self.fixedDeltaTime do

        -- Calculate gravity for jumping entities
        for _, entity in ipairs(self.secondPool) do
            local mv = entity.movement
            local rb = entity.rigidbody
            rb.gravityScale = (rb.groundGravity / GRAVITY) * rb.gravityMultiplier
    
            -- Get velocity from RigidbodyComponent
            mv.velocity.y = rb.velocity.y
    
            if not mv.desiredJump then
                self:calculateGravity(mv, rb, self.fixedDeltaTime)
            end
        end

        -- Move bodies and calculate states
        for _, entity in ipairs(self.pool) do
            local mv = entity.movement
            local rb = entity.rigidbody
            local tf = entity.transform
            local cl = entity.collider
            -- Apply Movement
            tf.posX = tf.posX + rb.velocity.x * self.fixedDeltaTime
            
            -- Last gravity calculations
            -- If falling limit the Y variable within the bounds of the speed limit, for the terminal velocity option
            rb.velocity.y = rb.velocity.y - GRAVITY * self.fixedDeltaTime * rb.gravityScale
            if rb.velocity.y > 0.01 then
                rb.velocity.y = rb.velocity.y > mv.fallSpeedLimit and mv.fallSpeedLimit or rb.velocity.y
            end
            -- Apply Gravity
            tf.posY = tf.posY + rb.velocity.y

            -- Change velocity and states by collision normal
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

        self.accumulator = self.accumulator - self.fixedDeltaTime
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
            -- If we're not using variable jump height
            -- Variable Jump is calculated on MovementSystem
            if not mv.variableJumpHeight then
                rb.gravityMultiplier = mv.upwardMovementMultiplier
            end
        end
    -- Else if going down...
    elseif rb.velocity.y > 0.01 then
        if mv.onFloor then
            --Don't change it if Kit is stood on something (such as a moving platform)
            rb.gravityMultiplier = rb.defaultGravityScale
        else
            -- Otherwise, apply the downward gravity multiplier as Kit comes back to Earth
            rb.gravityMultiplier = mv.downwardMovementMultiplier
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
                mv.jumpMinimumReached = false
            end
        end
        
        rb.gravityMultiplier = rb.defaultGravityScale
    end

    -- Set the character's Rigidbody's velocity
    rb.velocity.y = mv.velocity.y
end

----------------------------------------------------------------------------------
