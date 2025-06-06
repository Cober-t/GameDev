PhysicsSystem = ECS.system({ pool = {"transform", "rigidbody", "movement", "collider"} })

----------------------------------------------------------------------------------

function PhysicsSystem:update(dt)
    
    for _, entity in ipairs(self.pool) do 
        entity.movement.speedY = entity.movement.speedY + entity.rigidbody.gravity * dt
        entity.transform.posY = entity.transform.posY + entity.movement.speedY * dt
        
        entity.transform.posX = entity.transform.posX + entity.movement.speedX * dt

        -- Change velocity by collision normal
        if entity.collider.onFloor then
            local actualX, actualY, cols, len = BumpWorld:check(entity, entity.transform.posY, entity.transform.posY, self.filter)
            for i=1, len do
                local col = cols[i]
                local bounciness = 0.0
                local nx = col.normal.x
                local ny = col.normal.y
                local vx = entity.rigidbody.velocity.x
                local vy = entity.movement.speedY
                if (nx < 0 and vx > 0) or (nx > 0 and vx < 0) then
                    vx = -vx * bounciness
                end
                if (ny < 0 and vy > 0) or (ny > 0 and vy < 0) then
                    vy = -vy * bounciness
                end
                entity.rigidbody.velocity.x = vx
                entity.movement.speedY = vy
            end
        end
    end
end

----------------------------------------------------------------------------------
