local Camera = Class:extend()

----------------------------------------------------------------------------------

function Camera:new(level)
    self.nativeCam = HumCamera()
    self.nativeCam:zoom(CAM_ZOOM)
    self.currentLevel = level
    self.target = nil
    self.drawList = nil
    self.enabled = true
    self.dampSpeed = 200.0
end

----------------------------------------------------------------------------------

function Camera:setTarget(target)
    if self.target == nil then self.target = target end
    self.nativeCam.x = target.transform.posX
    self.nativeCam.y = target.transform.posY
end

function lerp(a,b,dt) return a + (b-a) * dt end
----------------------------------------------------------------------------------

function Camera:update(dt)
    if self.enabled and self.target then
        self.nativeCam.x = lerp(self.nativeCam.x, self.target.transform.posX, 5.0 * dt)
        self.nativeCam.y = lerp(self.nativeCam.y, self.target.transform.posY, 5.0 * dt)
    end

    -- Camera limit
    local leftLimit   = love.graphics.getWidth() / (2 * CAM_ZOOM)
    local topLimit    = love.graphics.getHeight()/ (2 * CAM_ZOOM)
    -- If its a tiled map and not a full image
    local rightLimit  = self.currentLevel.tileMap.width  * self.currentLevel.tileMap.tilewidth  - VIRTUAL_WIDTH/(2*CAM_ZOOM)
    local bottomLimit = self.currentLevel.tileMap.height * self.currentLevel.tileMap.tileheight - VIRTUAL_HEIGHT/(2*CAM_ZOOM)
    if self.nativeCam.x < leftLimit   then self.nativeCam.x = leftLimit   end
    if self.nativeCam.y < topLimit    then self.nativeCam.y = topLimit    end
    if self.nativeCam.x > rightLimit  then self.nativeCam.x = rightLimit  end
    if self.nativeCam.y > bottomLimit then self.nativeCam.y = bottomLimit end

end

----------------------------------------------------------------------------------

function Camera:draw(...)
    -- Send to RenderSystem
    self.nativeCam:attach()
        for index, sceneElem in ipairs({...}) do
            if sceneElem.draw and sceneElem.visible then
                sceneElem:draw()
            end
        end
        
        if DEBUG then World:emit("draw") end
    self.nativeCam:detach()
end

----------------------------------------------------------------------------------
return Camera
----------------------------------------------------------------------------------