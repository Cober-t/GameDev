CollisionSystem = ECS.system( {pool = {"transform", "collider"} , -- Debug
                               secondPool = {"transform", "movement", "rigidbody", "collider" }})

----------------------------------------------------------------------------------

function CollisionSystem:init()
    Log:debug("CollisionSystem CREATES " .. #self.pool .. " colliders!")
    self.activeColliders = {}
    for _, entity in ipairs(self.pool) do
        entity.collider.active = false
        BumpWorld:add(entity,
                    entity.transform.posX + entity.collider.offsetX,
                    entity.transform.posY + entity.collider.offsetY,
                    entity.collider.width,
                    entity.collider.height)
    end
end

----------------------------------------------------------------------------------

function CollisionSystem:update(dt)
    -- Iterate over all Entities that are going to move
    for i, entity in ipairs(self.secondPool) do
        local newPosX = entity.transform.posX + entity.collider.offsetX
        local newPosY = entity.transform.posY + entity.collider.offsetY
        local actualX, actualY, cols, len = BumpWorld:move(entity, newPosX, newPosY,
                                function(item, other) return other.collider.type end)
        
        -- Update the current entity position
        entity.transform.posX = actualX - entity.collider.offsetX
        entity.transform.posY = actualY - entity.collider.offsetY
        entity.movement.onFloor = false
        entity.movement.onWall = false
        
        -- Resect collision info
        for entt, _ in pairs(self.activeColliders) do
            entt.collider.active = false
        end
        -- Update moving entity collider info
        entity.collider.active = len ~= 0
        if entity.collider.active and not self.activeColliders[entity] then
            -- TODO: Call OnCollisionEnter
            self.activeColliders[entity] = true
        end
        
        for i=1, len do
            local col = cols[i]
            col.other.collider.active = true
            -- If we collide with a trigger we dont want to stop our movement
            if col.other.collider.type ~= "cross" then 
                if col.normal.y < 0  then entity.movement.onFloor = true end
                if col.normal.x ~= 0 then entity.movement.onWall  = true end
            end
            -- Check for new colliders
            if not self.activeColliders[col.other] then
                self.activeColliders[col.other] = true
            end
            -- Handle collisions
            self:handleCollisions(col.item, col.other, col)
        end
        
        -- Check for unactive colldiers
        for entt, active in pairs(self.activeColliders) do 
            if not entt.collider.active then
                -- TODO: Call OnCollisionExit
                self.activeColliders[entt] = nil
            end
        end
        
    end
end

----------------------------------------------------------------------------------

function CollisionSystem:handleCollisions(item, other, collision)
    -- TODO: Call OnCollisionUpdate
    if other.collider.type == "cross" then 
        item.collider:triggerFunction()
    end
end

----------------------------------------------------------------------------------

function CollisionSystem:collisionFilter(item, other)
    -- if item.collider.type == "slide" and other.collider.type == "cross" then
        -- in the future...
    -- end
    return other.collider.type
end

----------------------------------------------------------------------------------

function CollisionSystem:exit()
    local items, len = BumpWorld:getItems()
    Log:debug("CollisionSystem DESTROY " .. #items .. " colliders!")
    for _, entity in ipairs(items) do
        BumpWorld:remove(entity)
    end
end

----------------------------------------------------------------------------------

-- DebugSystem
local function getCellRect(cx,cy)
  local cellSize = BumpWorld.cellSize
  local l,t = BumpWorld:toWorld(cx,cy)
  return l,t,cellSize,cellSize
end

----------------------------------------------------------------------------------

function CollisionSystem:draw()
    -- DebugSystem
    if not DEBUG then return end

    -- Draw active processing areas
    for cy, row in pairs(BumpWorld.rows) do
        for cx, cell in pairs(row) do
            local l,t,w,h = getCellRect(cx,cy)
            local intensity = (cell.itemCount * 16 + 16) / 255
            love.graphics.setColor(1,1,1,0.3)
            love.graphics.rectangle('fill', l,t,w,h)
            love.graphics.setColor(1,1,1,0.04)
            love.graphics.rectangle('line', l,t,w,h)
        end
    end

    -- Draw inactive colliders
    for _, entity in ipairs(self.pool) do
        local x, y, w, h = BumpWorld:getRect(entity)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.rectangle("line", x, y, w, h)
    end

    -- Draw active colliders
    for entity, _ in pairs(self.activeColliders) do
        if entity.collider.type == "cross" then
            love.graphics.setColor(0, 1, 0, 1)
        else
            love.graphics.setColor(1, 0, 0, 1)
        end
        local x, y, w, h = BumpWorld:getRect(entity)
        love.graphics.rectangle("line", x, y, w, h)
    end
    love.graphics.setColor(1, 1, 1, 1)
end
