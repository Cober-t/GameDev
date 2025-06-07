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
                    :give("transform", 100, 0)      -- x, y
                    :give("movement", 230.0)        -- jumpForce
                    :give("rigidbody", 1.13)        -- fallSpeedMulti
                    :give("collider", 0, 0, 10, 15, false) -- offX, offY, w, h, trigger
    self.trans = self.entity.transform
    self.rb    = self.entity.rigidbody
    self.mv    = self.entity.movement
    self.col   = self.entity.collider
    -- self.stateList = {
    --     idleState = PlayerIdleState(),
    --     walkState = PlayerWalkState(),
    -- }
    self:initAnimations()
end

----------------------------------------------------------------------------------

function Player:init()
    Log:debug("Player initialized!")
    if BumpWorld:hasItem(self.entity) then
        BumpWorld:update(self.entity, 
                         self.trans.posX + self.col.offsetX,
                         self.trans.posY + self.col.offsetY)
    end
    self.rb.velocity.y = 0
    self.col.onFloor = false
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
    self.mv.direction = -1
    self.lastDirection = self.mv.direction
    self.state = self.col.onFloor and "walkLeft" or "jumpLeft"
end

----------------------------------------------------------------------------------

function Player:moveRight(dt)
    self.mv.direction = 1
    self.lastDirection = self.direction
    self.state = self.col.onFloor and "walkRight" or "jumpRight"
end

----------------------------------------------------------------------------------

function Player:moveJump(dt)
    if not self.col.onFloor then 
        return 
    end
    self.rb.velocity.y = self.mv.jumpForce * -1
    self.state = self.lastDirection == -1 and "jumpLeft" or "jumpRight"
end

----------------------------------------------------------------------------------

function Player:idle(dt)
    self.mv.direction = 0
    if not self.col.onFloor then return end
    self.state = self.mv.direction == -1 and "idleLeft" or "idleRight"
end

----------------------------------------------------------------------------------
--- HANDLE ANIMATIONS ------------------------------------------------------------
----------------------------------------------------------------------------------

function Player:initAnimations() -- On a AnimationSystem in the future with a component
    local animSpeed = 0.1
    self.animations = {}
    self.animations.idleRight = Anim8.newAnimation(grid('1-4', 1), animSpeed * 3)
    self.animations.walkRight = Anim8.newAnimation(grid('1-8', 3), animSpeed)
    self.animations.jumpRight = Anim8.newAnimation(grid(3, 6),     animSpeed)
    self.animations.idleLeft = self.animations.idleRight:clone():flipH()
    self.animations.walkLeft = self.animations.walkRight:clone():flipH()
    self.animations.jumpLeft = self.animations.jumpRight:clone():flipH()
    self.animation = self.animations[self.state]
end

----------------------------------------------------------------------------------

function Player:updateAnimation(dt)
    if self.mv.direction == 0 and self.col.onFloor then
        self.state = self.lastDirection == -1 and "idleLeft" or "idleRight"
    end
    self.animation = self.animations[self.state]
    self.animation:update(dt)
end

----------------------------------------------------------------------------------

function Player:draw()
    self.animation:draw(spriteSheet, self.entity.transform.posX, self.entity.transform.posY, nil, 1, 1, 8, 8)
end

----------------------------------------------------------------------------------
return Player
----------------------------------------------------------------------------------