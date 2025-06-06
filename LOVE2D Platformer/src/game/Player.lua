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

    -- Aux variable calculations
    self.desiredVelocity = { x=0.0,  y=0.0 }
    self.direction = 0
    self.lastDirection = 1
    self.velocity = { x=0.0,  y=0.0 }
    self.maxSpeedChange = 0.0
    self.acceleration = 0.0
    self.deceleration = 0.0
    self.turnSpeed = 0.0

    -- When false, the charcter will skip acceleration and deceleration and instantly move and stop
    self.useAcceleration = true
    
    self.canMove = true
    self.pressingKey = true
end

----------------------------------------------------------------------------------

function Player:init()
    Log:debug("Player initialized!")
    if BumpWorld:hasItem(self.entity) then
        BumpWorld:update(self.entity, self.trans.posX + self.col.offsetX
                                    , self.trans.posY + self.col.offsetY)
    end
    self.rb.speedY = 0
    self.col.onFloor = false
end

----------------------------------------------------------------------------------

function Player:exit()
    Log:debug("Player destroyed!")
end

----------------------------------------------------------------------------------

function Player:update(dt)
    -- Update Movement
    -- ..
    self.pressingKey = self.direction ~= 0
    self.desiredVelocity.x = self.direction * math.max(self.rb.maxSpeed - self.rb.friction, 0.0);
    self.velocity = self.rb.velocity
    
    if self.useAcceleration then
        self:runWithAcceleration(dt)
    else
        if self.col.onFloor then
            self:runWithoutAcceleration(dt)
        else
            self:runWithAcceleration(dt)
        end
    end
    


    -- Update Jump
    -- ..
    

    -- Apply Animation
    self:updateAnimation(dt)
end

----------------------------------------------------------------------------------

local function signum(number)
   if number > 0 then
      return 1
   elseif number < 0 then
      return -1
   else
      return 0
   end
end
function Player:runWithAcceleration(dt)
    -- Set our acceleration, deceleration, and turn speed stats, based on whether we're on the ground on in the air
    self.acceleration = self.col.onFloor and self.rb.maxAcceleration  or self.rb.maxAirAcceleration
    self.deceleration = self.col.onFloor and self.rb.maxDecceleration or self.rb.maxAirDecceleration
    self.turnSpeed    = self.col.onFloor and self.rb.maxTurnSpeed     or self.rb.maxAirTurnSpeed 

    if self.pressingKey then
        -- If the sign (i.e. positive or negative) of our input direction doesn't match our movement, it means we're turning around and so should use the turn speed stat.
        if signum(self.direction) ~= signum(self.velocity.x) then
            self.maxSpeedChange = self.turnSpeed * dt
        else
            -- If they match, it means we're simply running along and so should use the acceleration stat
            self.maxSpeedChange = self.acceleration * dt
        end
    else
        -- And if we're not pressing a direction at all, use the deceleration stat
        self.maxSpeedChange = self.deceleration * dt;
    end
end

----------------------------------------------------------------------------------

function Player:runWithoutAcceleration(dt)
    -- If we're not using acceleration and deceleration, just send our desired velocity (direction * max speed) to the Rigidbody
    self.velocity.x = self.desiredVelocity.x;
    self.rb.velocity = self.velocity;
end

----------------------------------------------------------------------------------
--- HANDLE EVENTS ----------------------------------------------------------------
----------------------------------------------------------------------------------
-- Update the current state in the future --
-- On an AnimationSystem in the future with a component
-- .........................................
function Player:moveLeft(dt)
    self.mv.speedX = 130 * -1
    self.direction = -1
    self.lastDirection = self.direction
    if self.col.onFloor then
        self.state = "walkLeft"
    else
        self.state = "jumpLeft"
    end
end

----------------------------------------------------------------------------------

function Player:moveRight(dt)
    self.mv.speedX = 130
    self.direction = 1
    self.lastDirection = self.direction
    if self.col.onFloor then
        self.state = "walkRight"
    else
        self.state = "jumpRight"
    end
end

----------------------------------------------------------------------------------

function Player:moveJump(dt)
    if not self.col.onFloor then return end
    -- self.col.onFloor = false
    self.mv.speedY = self.mv.jumpForce * -1
    if self.lastDirection == -1 then
        self.state = "jumpLeft"
    else
        self.state = "jumpRight"
    end
end

----------------------------------------------------------------------------------

function Player:idle(dt)
    self.direction = 0
    self.mv.speedX = 0 -- To neutralize inertia on jump
    if not self.col.onFloor then return end
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
    self.animations.jumpRight = Anim8.newAnimation(grid(3, 6),     animSpeed)
    self.animations.idleLeft = self.animations.idleRight:clone():flipH()
    self.animations.walkLeft = self.animations.walkRight:clone():flipH()
    self.animations.jumpLeft = self.animations.jumpRight:clone():flipH()
    self.animation = self.animations[self.state]
end

----------------------------------------------------------------------------------

function Player:updateAnimation(dt)
    if self.direction == 0 and self.col.onFloor then
        --self.mv.speedX = 0
        if self.lastDirection == -1 then
            self.state = "idleLeft"
        else
            self.state = "idleRight"
        end
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