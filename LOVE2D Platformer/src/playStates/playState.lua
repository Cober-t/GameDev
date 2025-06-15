PlayState = GameStateMachine:extend()
Player = require "src/game/player"
Camera = require "src/game/camera"
Level1 = require "src/game/level1"

----------------------------------------------------------------------------------

function PlayState:new()
    Log:debug("PlayState created!")

    self.events = {}
    self.player = Player()
    self.level1 = Level1()
    self.camera = Camera(self.level1)
    self:setupInputEvents()
end

----------------------------------------------------------------------------------

function PlayState:enter()
    Log:debug("PlayState initialize!")

    self:enableEvents()
    Log:debug("PlayState ENABLE events!")

    -- Handle global
    self.level1:init()
    self.player:init()
    self.camera:setTarget(self.player.entity)

    local posY =  self.level1.tileMap.height * self.level1.tileMap.tileheight - love.graphics.getHeight()/2
    self.player.entity.transform.posY = posY
    
    World:emit("init")
end

----------------------------------------------------------------------------------

function PlayState:exit()
    
    self.level1:exit()
    self.player:exit()
    self:disableEvents()
    Log:debug("PlayState DISABLE events!")

    World:emit("exit")
    World:clear()
    Log:debug("World cleared!")
    Log:debug("PlayState exit!")
end

----------------------------------------------------------------------------------

function PlayState:update(dt)
    -- Fixed camera update and player animations, for decouple render updates from framerate
    self.camera:update(dt)
    self.player:update(dt)

    EventDispatcher:update()
end

----------------------------------------------------------------------------------

function PlayState:draw()
    self.camera:draw(self.level1, self.player)

    -- Draw HUD or DebugSystem
    -- love.graphics.print("FPS: "..tostring(love.timer.getFPS()).." -- State: "..Player.state)
    love.graphics.print("Floor: "..tostring(self.player.entity.movement.onFloor).." -- "..
                        "Wall: "..tostring(self.player.entity.movement.onWall).." -- "..
                        "FrameRate: "..love.timer.getFPS().." -- "..
                        "VelY: "..tostring(self.player.entity.rigidbody.velocity.y))
end

----------------------------------------------------------------------------------
--- HANDLE EVENTS ----------------------------------------------------------------
----------------------------------------------------------------------------------
-- Handle Events for this GameState--
function PlayState:setupInputEvents()
    Log:debug("Setting up events on PlayState")
    -- Movement events - these use the game state context to access the player
    self.events.left = self:addEvent( { Key.left, Key.a, Button.dpleft },
                function() self.player:moveLeft() end,
                POLL_TYPE.IS_HELD)

    self.events.right = self:addEvent( { Key.right, Key.d, Button.dpright },
                function() self.player:moveRight() end,
                POLL_TYPE.IS_HELD)

    self.events.idle = self:addEvent( { Key.left,  Key.a, Button.dpleft,
                                        Key.right, Key.d, Button.dpright },
                function() self.player:idle() end,
                POLL_TYPE.JUST_RELEASED)

    self.events.jump = self:addEvent( { Key.up,  Key.space, Button.dpup },
                function() self.player:moveJump() end,
                POLL_TYPE.JUST_PRESSED)

    self.events.jump = self:addEvent( { Key.up,  Key.space, Button.dpup },
                function() self.player:releaseJump() end,
                POLL_TYPE.JUST_RELEASED)

    self.events.quit = self:addEvent( { Key.escape },
                function(context, input) love.event.quit() end,
                POLL_TYPE.IS_HELD)

    self.events.changeStartState = self:addEvent( { Key.q },
                function(context, input) self:changeToPauseState() end,
                POLL_TYPE.JUST_PRESSED)
end

----------------------------------------------------------------------------------

function PlayState:changeToPauseState()
    CurrentState:change("pause")
end

----------------------------------------------------------------------------------
