require 'src/Dependencies'
-- Require only in the game on the future
Player = require "src/game/player"
Camera = require "src/game/camera"
Level1 = require "src/game/level1"
Player = Player()
Level1 = Level1()
Camera = Camera(Level1)

CurrentState  = GameStateMachine {
        ['start'] = function() return StartState() end,
        ['play']  = function() return PlayState()  end,
        ['pause'] = function() return PauseState() end,
    }

----------------------------------------------------------------------------------

function love.load()

    Log:setLevel(LogLevel.DEBUG)
    Log:enableFileLogging("my_log_game.log")
    Push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = false,
        resizable = true,
        canvas = false
    })

    World:addSystems( MovementSystem, PhysicsSystem, CollisionSystem )

    CurrentState:change('play')
    World:emit("init")
end

----------------------------------------------------------------------------------

function love.keypressed(key)
    if key == "r" then -- Restart the level
        CurrentState:change('play')
    end
end

----------------------------------------------------------------------------------

function love.resize(w, h)
    Push:resize(w, h)
end

----------------------------------------------------------------------------------

function love.update(dt)
    CurrentState:update(dt)
    
    -- Call systems methods
    World:emit("update", dt)
    -- World:emit("draw")
end

----------------------------------------------------------------------------------

function love.draw()
    Push:start()
        CurrentState:draw()
    Push:finish()
end

----------------------------------------------------------------------------------
