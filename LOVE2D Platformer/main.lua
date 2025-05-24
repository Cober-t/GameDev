_G.love = require("love")

player = {}
CamZoom = 4
function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.window.setVSync = true
    anim8 = require 'libraries/anim8/anim8' -- Animation utility
    sti = require 'libraries/sti'           -- Level importer from Tiled
    humCamera = require 'libraries/hump/camera'-- Camera utility from HUMP
    wf = require "libraries/windfield"

    gameMap = sti("assets/maps/testLevel.lua")

    world = wf.newWorld(0, 10000)
    -- Test
    ground = {}
    if gameMap.layers["Ground"] then
        for i, obj in pairs(gameMap.layers["Ground"].objects) do
            local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            wall:setType("static")
            table.insert(ground, wall)
        end
    end

    player:initAnimations()

    -- Put the player on the floor for this level
    player.y = gameMap.height * gameMap.tileheight - love.graphics.getHeight()/2 + 150
    player.collider = world:newRectangleCollider(200, player.y, 8, 12)
    player.collider:setFixedRotation(true)

    camera = humCamera()
    camera:zoom(CamZoom)
    camera:lookAt(player.x, player.y)
end

function player:initAnimations()
    self.x = 300
    self.y = 0
    self.direction = 1
    self.speed = 130.0
    self.spriteSheet = love.graphics.newImage("assets/sprites/knight.png")
    self.grid = anim8.newGrid(32, 32, self.spriteSheet:getWidth(), self.spriteSheet:getHeight())

    local animSpeed = 0.1
    self.animations = {}
    self.animations.idleRight = anim8.newAnimation(self.grid('1-4', 1), animSpeed * 3)
    self.animations.walkRight = anim8.newAnimation(self.grid('1-8', 3), animSpeed)
    self.animations.jumpRight = anim8.newAnimation(self.grid(4, 6), animSpeed)
    self.animations.idleLeft = self.animations.idleRight:clone():flipH()
    self.animations.walkLeft = self.animations.walkRight:clone():flipH()
    self.animations.jumpLeft = self.animations.jumpRight:clone():flipH()
end


-- function love.keypressed(key)
-- end


function love.update(dt)
    local vx = 0
    local vy = 0
    local state = ""
    if love.keyboard.isDown("left") then
        vx = player.speed * -1
        player.direction = -1
        state = "walkLeft"
    elseif love.keyboard.isDown("right") then
        vx = player.speed
        player.direction = 1
        state = "walkRight"
    elseif love.keyboard.isDown("space") then
        vy = player.speed * -1
        player.collider:applyLinearImpulse(0, -50)
        if player.direction == -1 then state = "jumpLeft" else state = "jumpRight" end
    elseif love.keyboard.isDown("escape") then
        love.event.quit()
    elseif player.direction == -1 then state = "idleLeft" else state = "idleRight" end

    -- Apply Animation
    player.state = state
    player.animation = player.animations[player.state]
    player.animation:update(dt)

    camera:lockPosition(player.x, player.y, humCamera.smooth.damped(175 * dt))
    -- camera.x = math.floor(camera.x)
    -- camera.y = math.floor(camera.y)

    -- Apply Physics
    world:update(dt)
    player.x = player.collider:getX() - 8
    player.y = player.collider:getY() - 13
    player.collider:setLinearVelocity(vx, vy)

    -- Camera limit
    local leftLimit   = love.graphics.getWidth() / (2 * CamZoom)
    local topLimit    = love.graphics.getHeight()/ (2 * CamZoom)
    local rightLimit  = gameMap.width * gameMap.tilewidth
    local bottomLimit = gameMap.height* gameMap.tileheight
    if camera.x < leftLimit   then camera.x = leftLimit   end
    if camera.y < topLimit    then camera.y = topLimit    end
    if camera.x > rightLimit  then camera.x = rightLimit  end
    if camera.y > bottomLimit then camera.y = bottomLimit end
end

function love.draw()
    camera:attach()
        gameMap:drawLayer(gameMap.layers["Background"])
        gameMap:drawLayer(gameMap.layers["World"])
        player.animation:draw(player.spriteSheet, player.x, player.y, nil, 1, 1, 8, 8)
        -- world:draw()
    camera:detach()

    -- Draw HUD
    love.graphics.print("FPS: "..tostring(love.timer.getFPS()).." -- State: "..player.state)
end
