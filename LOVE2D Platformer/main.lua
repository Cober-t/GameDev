_G.love = require("love")

player = {}
function love.load()
    anim8 = require 'libraries/anim8/anim8'
    love.graphics.setDefaultFilter("nearest", "nearest")
    -- anim8 = require 'libraries/tiled/tield'
    player:initAnimations()
    background = love.graphics.newImage("assets/sprites/world_tileset.png")
end

function player:initAnimations()
    self.x = 50
    self.y = 50
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
    elseif love.keyboard.isDown("escape") then
        love.event.quit()
    elseif player.direction == -1 then state = "idleLeft" else state = "idleRight" end

    player.state = state
    player.animation = player.animations[player.state]
    player.animation:update(dt)
end

function love.draw()
    local scale = 5
    love.graphics.print(player.state)
    player.animation:draw(player.spriteSheet, player.x, player.y, nil, scale, scale)
end