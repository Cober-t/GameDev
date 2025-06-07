PhysicsSystem = ECS.system({ pool = {"transform", "rigidbody", "collider"} })

----------------------------------------------------------------------------------

function PhysicsSystem:update(dt)
    
    for _, entity in ipairs(self.pool) do 

        -- Set physics
        local newGravity = (-2.0 * entity.movement.jumpHeight) / math.pow(entity.movement.timeToJumpApex, 2)
        entity.rigidbody.gravityScale = (newGravity / GRAVITY) * entity.rigidbody.gravityMultiplier
        local finalGravity = math.sqrt(-2.0 * GRAVITY * entity.rigidbody.gravityScale * entity.movement.jumpHeight)

        
        -- Apply Gravity
        entity.rigidbody.velocity.y = entity.rigidbody.velocity.y + GRAVITY * dt
        entity.transform.posY = entity.transform.posY + entity.rigidbody.velocity.y * dt
        
        -- Apply Movement
        entity.transform.posX = entity.transform.posX + entity.rigidbody.velocity.x * dt

        -- Change velocity by collision normal
        if entity.collider.onFloor then
            local actualX, actualY, cols, len = BumpWorld:check(entity, entity.transform.posY, entity.transform.posY, self.filter)
            for i=1, len do
                local col = cols[i]
                local nx = col.normal.x
                local ny = col.normal.y
                local vx = entity.rigidbody.velocity.x
                local vy = entity.rigidbody.velocity.y
                -- if (nx < 0 and vx > 0) or (nx > 0 and vx < 0) then
                --     vx = -vx * bounciness
                -- end
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
