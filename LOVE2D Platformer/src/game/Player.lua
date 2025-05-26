Player = Class:extend()

local maxJump = -math.sqrt(2 * GRAVITY * 3.3 * CELL_SIZE)
-- local minJump = -math.sqrt(2 * GRAVITY * 0.65 * CELL_SIZE)
local jumpPressed = false
local spriteSheet = SpriteSheets.player
local grid = Anim8.newGrid(32, 32, spriteSheet:getWidth(), spriteSheet:getHeight())

function Player:new(initX, initY)
    self.x = initX
    self.y = initY
    -- self.entity = Entity()
    self.visible = true
    self.direction = 1
    self.speed = 130.0
    self.stateList = {
        idleState = PlayerIdleState(),
        walkState = PlayerWalkState(),
    }

    self.initAnimations(self)
end

function Player:update(dt)

    -- Update the current state in the future -- 
    -- .........................................
    local vx = 0
    local vy = 0
    if love.keyboard.isDown("left") then
        self.x = self.x + self.speed * dt * -1
        self.direction = -1
        self.state = "walkLeft"
    elseif love.keyboard.isDown("right") then
        self.x = self.x + self.speed * dt
        self.direction = 1
        self.state = "walkRight"
    end
    if love.keyboard.isDown("space") then
        jumpPressed = true
        -- player.collider:applyLinearImpulse(0, -50)
        if self.direction == -1 then self.state = "jumpLeft" else self.state = "jumpRight" end
    end
    if love.keyboard.isDown("escape") then
        love.event.quit()
    end
    if self.direction == -1 then
        self.state = "idleLeft"
    else
        self.state = "idleRight"
    end

    -- if jumpPressed and love.keyboard.isDown("space") == false then
    --     jumpPressed = false
    --     self.y = minJump
    -- end
    if jumpPressed and love.keyboard.isDown("space") then
        jumpPressed = false
        print(maxJump * dt * -1 * 5)
        self.y = self.y - maxJump * dt * -1 * 5
    end
    -- .........................................


    -- Apply Animation
    self:updateAnimation(dt)
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

function Player:updateAnimation(dt)
    self.animation = self.animations[self.state]
    self.animation:update(dt)
end

function Player:draw()
    self.animation:draw(spriteSheet, self.x, self.y, nil, 1, 1, 8, 8)
end