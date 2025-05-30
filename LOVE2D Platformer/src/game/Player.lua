local Player = Class:extend()

----------------------------------------------------------------------------------
---
-- local maxJump = -math.sqrt(2 * GRAVITY * 3.3 * CELL_SIZE)
-- local minJump = -math.sqrt(2 * GRAVITY * 0.65 * CELL_SIZE)
local spriteSheet = SpriteSheets.player
local grid = Anim8.newGrid(32, 32, spriteSheet:getWidth(), spriteSheet:getHeight())
----------------------------------------------------------------------------------

function Player:new()
    Log:debug("Player created!")
    self.visible = true
    self.state = "idleRight"
    self.entity = ECS.entity(World)
                    :give("transform", 0, 0)
                    :give("rigidbody", 130.0, 1.13)
                    :give("collider", 12, 19, false)
    self.trans = self.entity.transform
    self.rb = self.entity.rigidbody
    self.col = self.entity.collider
    -- self.stateList = {
    --     idleState = PlayerIdleState(),
    --     walkState = PlayerWalkState(),
    -- }
end

----------------------------------------------------------------------------------

function Player:init()
    Log:debug("Player initialized!")

    self:initAnimations()
end

----------------------------------------------------------------------------------

function Player:exit()
    Log:debug("Player destroyed!")
end

----------------------------------------------------------------------------------

function Player:update(dt)
    -- Apply Animation
    self:updateAnimation(dt)
end

----------------------------------------------------------------------------------
--- HANDLE EVENTS ----------------------------------------------------------------
----------------------------------------------------------------------------------
-- Update the current state in the future --
-- On an AnimationSystem in the future with a component
-- .........................................
function Player:moveLeft(dt)
    self.trans.toMove = true
    self.trans.posX = self.trans.posX + self.rb.speedX * dt * -1
    self.direction = -1
    if self.col.onFloor then
        self.state = "walkLeft"
    end
end

function Player:moveRight(dt)
    self.trans.toMove = true
    self.trans.posX = self.trans.posX + self.rb.speedX * dt
    self.direction = 1
    if self.col.onFloor then
        self.state = "walkRight"
    end
end

----------------------------------------------------------------------------------

function Player:moveJump(dt)
    self.trans.toMove = true
    if self.col.onFloor then
        self.rb.speedY = self.rb.jumpForce
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
--- HANDLE ANIMATIONS ------------------------------------------------------------
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
    self.animation:draw(spriteSheet, self.entity.transform.posX, self.entity.transform.posY, nil, 1, 1, 8, 8)
    -- Move to DebugSystem
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", self.trans.posX, self.trans.posY, self.col.width, self.col.height)
end

----------------------------------------------------------------------------------
return Player
----------------------------------------------------------------------------------