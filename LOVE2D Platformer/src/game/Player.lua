Player = Class:extend()

local spriteSheet = SpriteSheets.player
local grid = Anim8.newGrid(32, 32, spriteSheet:getWidth(), spriteSheet:getHeight())

function Player:new(initX, initY)
    self.x = initX
    self.y = initY
    self.direction = 1
    self.speed = 130.0
    self.initAnimations(self)
end

function Player:initAnimations()
    local animSpeed = 0.1
    self.animations = {}
    self.animations.idleRight = Anim8.newAnimation(grid('1-4', 1), animSpeed * 3)
    self.animations.walkRight = Anim8.newAnimation(grid('1-8', 3), animSpeed)
    self.animations.jumpRight = Anim8.newAnimation(grid(4, 6),     animSpeed)
    self.animations.idleLeft = self.animations.idleRight:clone():flipH()
    self.animations.walkLeft = self.animations.walkRight:clone():flipH()
    self.animations.jumpLeft = self.animations.jumpRight:clone():flipH()
end

function Player:updateAnimation(state, dt)
    self.state = state
    self.animation = self.animations[self.state]
    self.animation:update(dt)
end

function Player:draw()
    self.animation:draw(spriteSheet, self.x, self.y, nil, 1, 1, 8, 8)
end