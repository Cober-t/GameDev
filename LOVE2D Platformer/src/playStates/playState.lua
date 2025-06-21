PlayState = GameStateMachine:extend()
Player = require "src/game/player"
Camera = require "src/game/camera"
Level1 = require "src/game/level1"

----------------------------------------------------------------------------------

function PlayState:new()
    Log:debug("PlayState created!")
end

----------------------------------------------------------------------------------

function PlayState:enter()
    self.player = Player()
    self.level1 = Level1()
    self.camera = Camera(self.level1)
    self:setupInputEvents()
    Log:debug("PlayState initialize!")

    StateMachine:enableEvents()
    Log:debug("PlayState ENABLE events!")

    self.level1:init()
    self.player:init()
    self.camera:setTarget(self.player.entity)

    -- Test: Start player position
    local posY =  self.level1.tileMap.height * self.level1.tileMap.tileheight - love.graphics.getHeight()/2
    self.player.entity.transform.posY = posY
    
    World:emit("init")
end

----------------------------------------------------------------------------------

function PlayState:exit()
    self.level1:exit()
    self.player:exit()
    StateMachine:disableEvents()
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
    
    -- KEYBOARD --
    EventDispatcher:createEvent( 
                KEYBOARD, { Key.left, Key.a },
                function() self.player:moveLeft() end,
                POLL_TYPE.IS_HELD, GAME_STATES.PLAY)
    EventDispatcher:createEvent( 
                KEYBOARD, { Key.right, Key.d },
                function() self.player:moveRight() end,
                POLL_TYPE.IS_HELD, GAME_STATES.PLAY)
    EventDispatcher:createEvent( 
                KEYBOARD, { Key.left, Key.a, Key.right, Key.d },
                function() self.player:idle() end,
                POLL_TYPE.JUST_RELEASED, GAME_STATES.PLAY)
    EventDispatcher:createEvent( 
                KEYBOARD, { Key.up, Key.space },
                function() self.player:moveJump() end,
                POLL_TYPE.JUST_PRESSED, GAME_STATES.PLAY)
    EventDispatcher:createEvent( 
                KEYBOARD, { Key.up, Key.space },
                function() self.player:releaseJump() end,
                POLL_TYPE.JUST_RELEASED, GAME_STATES.PLAY)
    EventDispatcher:createEvent( 
                KEYBOARD, { Key.escape },
                function() love.event.quit() end,
                POLL_TYPE.IS_HELD, GAME_STATES.PLAY)

    EventDispatcher:createEvent( 
                KEYBOARD, { Key.q },
                function() StateMachine:change(GAME_STATES.PAUSE) end,
                POLL_TYPE.JUST_PRESSED, GAME_STATES.PLAY)

    -- GAMEPAD--
    EventDispatcher:createEvent( 
                GAMEPAD, { Button.dpleft },
                function() self.player:moveLeft() end,
                POLL_TYPE.IS_HELD, GAME_STATES.PLAY)
    EventDispatcher:createEvent( 
                GAMEPAD, { Button.dpright },
                function() self.player:moveRight() end,
                POLL_TYPE.IS_HELD, GAME_STATES.PLAY)
    EventDispatcher:createEvent( 
                GAMEPAD, { Button.dpleft, Button.dpright },
                function() self.player:idle() end,
                POLL_TYPE.JUST_RELEASED, GAME_STATES.PLAY)
    EventDispatcher:createEvent( 
                GAMEPAD, { Button.dpup, Button.a_btn },
                function() self.player:moveJump() end,
                POLL_TYPE.JUST_PRESSED, GAME_STATES.PLAY)    
    EventDispatcher:createEvent( 
                GAMEPAD, { Button.dpup, Button.a_btn },
                function() self.player:releaseJump() end,
                POLL_TYPE.JUST_RELEASED, GAME_STATES.PLAY)
    EventDispatcher:createEvent( 
                GAMEPAD, { Button.rightshoulder, Button.leftshoulder },
                function() love.event.quit() end,
                POLL_TYPE.IS_HELD, GAME_STATES.PLAY)

    -- AXIS --
    EventDispatcher:createEvent(
            GAMEPAD_AXIS, { AXIS.LEFT_X }, 
            function() self.player:moveLeft() end,
            POLL_TYPE.IS_HELD, GAME_STATES.PLAY, 0.2, "negative")
    EventDispatcher:createEvent(
            GAMEPAD_AXIS, { AXIS.LEFT_X }, 
            function() self.player:moveRight() end,
            POLL_TYPE.IS_HELD, GAME_STATES.PLAY, 0.2, "positive")
    EventDispatcher:createEvent(
            GAMEPAD_AXIS, { AXIS.LEFT_X }, 
            function() self.player:idle() end,
            POLL_TYPE.JUST_RELEASED, GAME_STATES.PLAY, 0.2, "any" )

    Log:debug("CREATED EVENTS: "..EventDispatcher:getEventsCount())
end

----------------------------------------------------------------------------------
