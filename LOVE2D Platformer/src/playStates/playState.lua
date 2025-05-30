PlayState = GameStateMachine:extend()

----------------------------------------------------------------------------------
--- Local values
-- Require only in the game on the future
local Player = require "src/game/player"
local Camera = require "src/game/camera"
local Level1 = require "src/game/level1"

----------------------------------------------------------------------------------

function PlayState:new()
    Log:debug("PlayState created!")
    self.events = {}
    self.player = Player()
    self:setupInputEvents()
end

----------------------------------------------------------------------------------

function PlayState:enter()
    self:enableEvents()

    Log:debug("PlayState initialize!")
    -- Instantiate level
    self.currentLevel = Level1()
    self.camera = Camera(self.currentLevel)
    self.currentLevel:init()
    self.player:init()

    -- TEST: Put the player on the floor for this level
    local posY =  self.currentLevel.tileMap.height * self.currentLevel.tileMap.tileheight - love.graphics.getHeight()/2 + 150
    self.player.entity.transform.posY = posY

    self.camera:setTarget(self.player.entity)
end

----------------------------------------------------------------------------------

function PlayState:exit()
    Log:debug("PlayState destroyed!")
    self.currentLevel:exit()
    self.player:exit()
    self:disableEvents()

    -- BumpWorld:remove(self.player) -- Moved to CollisionSystem exit
end

----------------------------------------------------------------------------------

function PlayState:update(dt)
    self.camera:update(self.player, dt)
    EventDispatcher:update()

    self.player:update(dt)
end

----------------------------------------------------------------------------------

function PlayState:draw()
    self.camera:draw(self.currentLevel, self.player)

    -- Draw HUD or DebugSystem
    love.graphics.print("FPS: "..tostring(love.timer.getFPS()).." -- State: "..self.player.state)
end

----------------------------------------------------------------------------------
--- HANDLE EVENTS ----------------------------------------------------------------
----------------------------------------------------------------------------------
-- Handle Events for this GameState--
function PlayState:setupInputEvents()
    Log:debug("Setting up events on PlayState")
    -- Movement events - these use the game state context to access the player
    self.events.left = self:addKeyboardEvent('left', function(context, input)
            context.player:moveLeft(love.timer.getDelta())
    end, POLL_TYPE.IS_HELD)

    self.events.right = self:addKeyboardEvent('right', function(context, input)
            context.player:moveRight(love.timer.getDelta())
    end, POLL_TYPE.IS_HELD)

    self.events.idleLeft = self:addKeyboardEvent('left', function(context, input)
            context.player:idle()
    end, POLL_TYPE.JUST_RELEASED)

    self.events.idleRight = self:addKeyboardEvent('right', function(context, input)
            context.player:idle()
    end, POLL_TYPE.JUST_RELEASED)

    self.events.jump = self:addKeyboardEvent('space', function(context, input)
            context.player:moveJump(love.timer.getDelta())
    end, POLL_TYPE.JUST_PRESSED)

    self.events.quit = self:addKeyboardEvent('escape', function(context, input)
            love.event.quit()
    end, POLL_TYPE.IS_HELD)

    self.events.changeStartState = self:addKeyboardEvent("q", function(context, input)
        context:changeToPauseState()
    end, POLL_TYPE.JUST_PRESSED)
end

----------------------------------------------------------------------------------

function PlayState:changeToPauseState()
    CurrentState:change("pause")
end

----------------------------------------------------------------------------------
