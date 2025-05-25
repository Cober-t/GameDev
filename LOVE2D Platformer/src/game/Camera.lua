Camera = Class:extend()

function Camera:new(level)
    self.camera = HumCamera()
    self.camera:zoom(CAM_ZOOM)
    self.currentLevel = level
    self.target = nil
end

function Camera:setTarget(target)
    if self.target == nil then self.target = target end
    self.camera:lookAt(target.x, target.y)
end

function Camera:update(target, dt)
    self.camera:lockPosition(target.x, target.y, self.camera.smooth.damped(225 * dt))

    -- Camera limit
    local leftLimit   = love.graphics.getWidth() / (2 * CAM_ZOOM)
    local topLimit    = love.graphics.getHeight()/ (2 * CAM_ZOOM)
    -- If its a tiled map and not a full image
    local rightLimit  = self.currentLevel.tileMap.width  * self.currentLevel.tileMap.tilewidth
    local bottomLimit = self.currentLevel.tileMap.height * self.currentLevel.tileMap.tileheight
    if self.camera.x < leftLimit   then self.camera.x = leftLimit   end
    if self.camera.y < topLimit    then self.camera.y = topLimit    end
    if self.camera.x > rightLimit  then self.camera.x = rightLimit  end
    if self.camera.y > bottomLimit then self.camera.y = bottomLimit end
end

function Camera:draw(player)

    -- if gameMap.layers["Ground"] then
    --     for i, obj in pairs(gameMap.layers["Ground"].objects) do
    --         local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
    --         wall:setType("static")
    --         table.insert(ground, wall)
    --     end
    -- end

    self.camera:attach()
        self.currentLevel:draw()
        player:draw()
    self.camera:detach()
end