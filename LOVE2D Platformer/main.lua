_G.love = require("love")

player = {}
function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.physics.setMeter(32)
    world = love.physics.newWorld(0, 0)
    anim8 = require 'libraries/anim8/anim8' -- Animation utility
    sti = require 'libraries/sti'           -- Level importer from Tiled
    humCamera = require 'libraries/hump/camera'-- Camera utility from HUMP
    camera = humCamera()

    gameMap = sti("assets/maps/testLevel.lua", { "box2d" })
    gameMap:box2d_init(world)

    player:initAnimations()
    -- background = love.graphics.newImage("assets/sprites/world_tileset.png")
end

function player:initAnimations()
    self.x = 0
    self.y = 0
    self.direction = 1
    self.speed = 200.0
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


function love.update(dt)
    local state = ""
    if love.keyboard.isDown("left") then
        player.x = player.x - dt * player.speed
        player.direction = -1
        state = "walkLeft"
    elseif love.keyboard.isDown("right") then
        player.x = player.x + dt * player.speed
        player.direction = 1
        state = "walkRight"
    -- elseif love.keyboard.isDown("space") then
    --     player.y = player.y + dt * player.speed
    --     if player.direction == -1 then state = "jumpLeft" else state = "jumpRight" end
    elseif love.keyboard.isDown("escape") then
        love.event.quit()
    elseif player.direction == -1 then state = "idleLeft" else state = "idleRight" end

    player.state = state
    player.animation = player.animations[player.state]
    player.animation:update(dt)

    local leftLimit = love.graphics.getWidth()
    local topLimit = love.graphics.getHeight()
    local rightLimit = gameMap.width * gameMap.tilewidth
    local bottomLimit = gameMap.height * gameMap.tileheight
    -- camera:lookAt(player.x, player.y - bottomLimit - topLimit/2)
    camera:lookAt(player.x, player.y)

    if camera.x < leftLimit / 2 then
        camera.x = leftLimit /2
    end
    if camera.y < topLimit / 2 then
        camera.y = topLimit / 2
    end
    if camera.x > rightLimit - leftLimit / 2 then
        camera.x = rightLimit - leftLimit /2
    end
    if camera.y > bottomLimit - topLimit / 2 then
        camera.y = bottomLimit - topLimit /2
    end
end

function love.draw()
    local scale = 5
    camera:attach()
        gameMap:drawLayer(gameMap.layers["Background"])
        gameMap:drawLayer(gameMap.layers["World"])
        player.animation:draw(player.spriteSheet, player.x, player.y, nil, scale, scale, 8, 8)
    camera:detach()

    -- Draw HUD
    love.graphics.print(player.state)
end
