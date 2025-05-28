local Player = Class:extend()

----------------------------------------------------------------------------------
---
local maxJump = -math.sqrt(2 * GRAVITY * 3.3 * CELL_SIZE)
-- local minJump = -math.sqrt(2 * GRAVITY * 0.65 * CELL_SIZE)
local spriteSheet = SpriteSheets.player
local grid = Anim8.newGrid(32, 32, spriteSheet:getWidth(), spriteSheet:getHeight())

----------------------------------------------------------------------------------

function Player:new(initX, initY)
    self.x = initX
    self.y = initY
    -- self.entity = Entity()
    self.visible = true
    self.direction = 1
    self.onFloor = false
    self.speed = 130.0
    self.state = "idleRight"
    self.stateList = {
        idleState = PlayerIdleState(),
        walkState = PlayerWalkState(),
    }
end

----------------------------------------------------------------------------------

function Player:init()
    Log:debug("Player created!")
    self:initAnimations()
end

----------------------------------------------------------------------------------

function Player:exit()
    Log:debug("Player destroyed!")
end

----------------------------------------------------------------------------------

function Player:update(dt)

    self.y = self.y + (GRAVITY * dt)

    -- update player collider to the new pos
    -- assert(BumpWorld:hasItem(self))
    if not BumpWorld:hasItem(self) then return end
    local actualX, actualY, cols, len = BumpWorld:move(self, self.x, self.y)
    self.x = actualX
    self.y = actualY

    -- TODO: Check collision type (On a CollisionSystem in the future with a component)
    self.onFloor = len > 0
    -- if self.onFloor then
    --     print(self.onFloor)
    -- end
    -- ....

    -- Apply Animation
    self:updateAnimation(dt)
end

----------------------------------------------------------------------------------
--- HANDLING EVENTS --------------------------------------------------------------
----------------------------------------------------------------------------------
-- Update the current state in the future --
-- On a AnimationSystem in the future with a component
-- .........................................
function Player:moveLeft(dt)
    self.x = self.x + self.speed * dt * -1
    self.direction = -1
    self.state = "walkLeft"
end

function Player:moveRight(dt)
    self.x = self.x + self.speed * dt
    self.direction = 1
    self.state = "walkRight"
end

----------------------------------------------------------------------------------

function Player:moveJump(dt)
    if self.onFloor then
        self.y = -1
        if self.direction == -1 then
            self.state = "jumpLeft"
        else
            self.state = "jumpRight"
        end
    end
end

----------------------------------------------------------------------------------

function Player:idle(dt)
     if self.direction == -1 then
        self.state = "idleLeft"
    else
        self.state = "idleRight"
    end
end

----------------------------------------------------------------------------------
--- HANDLING ANIMATIONS ----------------------------------------------------------
----------------------------------------------------------------------------------

function Player:initAnimations() -- On a AnimationSystem in the future with a component
    local animSpeed = 0.1
    self.animations = {}
    self.animations.idleRight = Anim8.newAnimation(grid('1-4', 1), animSpeed * 3)
    self.animations.walkRight = Anim8.newAnimation(grid('1-8', 3), animSpeed)
    self.animations.jumpRight = Anim8.newAnimation(grid(4, 6),     animSpeed)
    self.animations.idleLeft = self.animations.idleRight:clone():flipH()
    self.animations.walkLeft = self.animations.walkRight:clone():flipH()
    self.animations.jumpLeft = self.animations.jumpRight:clone():flipH()
    self.animation = self.animations[self.state]
end

----------------------------------------------------------------------------------

function Player:updateAnimation(dt)
    self.animation = self.animations[self.state]
    self.animation:update(dt)
end

----------------------------------------------------------------------------------

function Player:draw()
    self.animation:draw(spriteSheet, self.x, self.y, nil, 1, 1, 8, 8)
end

----------------------------------------------------------------------------------
return Player
----------------------------------------------------------------------------------