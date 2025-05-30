CollisionSystem = ECS.system({ pool = {"transform", "rigidbody", "collider"} })

----------------------------------------------------------------------------------

function CollisionSystem:init()

    for _, entity in ipairs(self.pool) do
        BumpWorld:add(entity,
                      entity.transform.posX,
                      entity.transform.posY,
                      entity.collider.width,
                      entity.collider.height)
    end
end

----------------------------------------------------------------------------------

function CollisionSystem:update(dt)

    -- Iterate over all Entities that this System acts on
    for _, entity in ipairs(self.pool) do
        local actualX, actualY, cols, len = BumpWorld:move(entity, entity.transform.posX, entity.transform.posY)
        -- Update the current entity position
        entity.transform.posX = actualX
        entity.transform.posY = actualY
        -- TODO: Fix, see CollisionSystem
        -- onFloor is false because speedY and never try to fall to the ground
        entity.rigidbody.onFloor = len > 0 -- Check that the collision is with the "Ground"
    end
end

----------------------------------------------------------------------------------

function CollisionSystem:exit()
    for _, entity in ipairs(self.pool) do
        BumpWorld:remove(entity)
    end
end

----------------------------------------------------------------------------------
