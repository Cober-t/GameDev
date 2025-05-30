PhysicsSystem = ECS.system({ pool = {"transform", "rigidbody"} })

----------------------------------------------------------------------------------

function PhysicsSystem:update(dt)
    for _, entity in ipairs(self.pool) do

        if entity.rigidbody.speedY ~= 0 then
            entity.transform.posY = entity.transform.posY + entity.rigidbody.speedY * dt
            entity.rigidbody.speedY = math.max(entity.rigidbody.speedY - GRAVITY * dt, -GRAVITY*dt)
        end

        if entity.collider.onFloor then
            entity.collider.speedY = 0
        end
        -- print(entity.rigidbody.speedY)
    end
end

----------------------------------------------------------------------------------
