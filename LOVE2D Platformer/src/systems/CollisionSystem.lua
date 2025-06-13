CollisionSystem = ECS.system( {pool = {"transform", "collider"} ,
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
    
    self.accumulator = 0
    self.fixedDeltaTime = FIXED_DT
end

----------------------------------------------------------------------------------

function CollisionSystem:update(dt)
    self.accumulator = self.accumulator + dt

    while self.accumulator >= self.fixedDeltaTime do

        -- Iterate over all Entities that this System acts on
        for i, entity in ipairs(self.secondPool) do
            local newPosX = entity.transform.posX + entity.collider.offsetX
            local newPosY = entity.transform.posY + entity.collider.offsetY
            local actualX, actualY, cols, len = BumpWorld:move(entity, newPosX, newPosY)

            -- Update the current entity position
            entity.transform.posX = actualX - entity.collider.offsetX
            entity.transform.posY = actualY - entity.collider.offsetY
            entity.movement.onFloor = false
            entity.movement.onWall = false
            -- Check if is onFloor
            for i=1, len do
                local col = cols[i]
                if col.normal.y < 0  then entity.movement.onFloor = true end
                if col.normal.x ~= 0 then entity.movement.onWall  = true end
            end
        end
        self.accumulator = self.accumulator - self.fixedDeltaTime
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
