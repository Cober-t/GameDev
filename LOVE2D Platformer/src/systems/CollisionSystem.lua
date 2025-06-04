CollisionSystem = ECS.system({ pool = {"transform", "collider"} ,
                               secondPool = {"transform", "movement", "collider", }})

----------------------------------------------------------------------------------

function CollisionSystem:init()

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
    -- Iterate over all Entities that thçis System acts on
    for i, entity in ipairs(self.secondPool) do
        local newPosX = entity.transform.posX
        local newPosY = entity.transform.posY
        local actualX, actualY, cols, len = BumpWorld:move(entity, newPosX, newPosY)

        -- Update the current entity position
        entity.transform.posX = actualX
        entity.transform.posY = actualY
        entity.collider.onFloor = false
        -- Check if is onFloor
        for i=1, len do
            local col = cols[i]
            if col.normal.y < 0 then entity.collider.onFloor = true end
        end
    end
end

----------------------------------------------------------------------------------

function CollisionSystem:exit()
    for _, entity in ipairs(self.pool) do
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

    -- for cy, row in pairs(BumpWorld.rows) do
    --     for cx, cell in pairs(row) do
    --         local l,t,w,h = getCellRect(cx,cy)
    --         local intensity = (cell.itemCount * 16 + 16) / 255
    --         love.graphics.setColor(1,1,1,0.3)
    --         love.graphics.rectangle('fill', l,t,w,h)
    --         love.graphics.setColor(1,1,1,0.04)
    --         love.graphics.rectangle('line', l,t,w,h)
    --     end
    -- end

    love.graphics.setColor(1, 1, 1, 1)
    for _, entity in ipairs(self.pool) do
        local x, y, w, h = BumpWorld:getRect(entity)
        if entity.collider.active then
            love.graphics.setColor(1, 0, 0, 1)
        else
            love.graphics.setColor(1, 1, 1, 1)
        end
        love.graphics.rectangle("line",x,y, w, h)
    end
end
