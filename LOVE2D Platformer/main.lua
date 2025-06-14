require 'src/Dependencies'

CurrentState  = GameStateMachine {
        ['start'] = function() return StartState() end,
        ['play']  = function() return PlayState()  end,
        ['pause'] = function() return PauseState() end,
    }

----------------------------------------------------------------------------------

accumulator = 0
fixedDeltaTime = FIXED_DT

function love.load()

    Log:setLevel(LogLevel.DEBUG)
    Log:enableFileLogging("my_log_game.log")
    Push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true,
        canvas = false
    })

    Log:debug("Creating Systems for the GAME")
    World:addSystems( MovementSystem, PhysicsSystem, CollisionSystem)

    CurrentState:change('play')
end

----------------------------------------------------------------------------------

function love.keypressed(key)
    if key == "r" then -- Restart the level
        Log:debug("RESTART invokated")
        CurrentState:change('play')
    end
end

----------------------------------------------------------------------------------

function love.resize(w, h)
    Push:resize(w, h)
end

----------------------------------------------------------------------------------

function love.update(dt)
    -- Fixed physics calculations, for decouple game logic from framerate
    accumulator = accumulator + dt
    while accumulator >= fixedDeltaTime do
        CurrentState:update(fixedDeltaTime)
        World:emit("update", fixedDeltaTime)
        accumulator = accumulator - fixedDeltaTime
    end   
end

----------------------------------------------------------------------------------

function love.draw()
    Push:start()
        CurrentState:draw()
        -- World:emit("draw") --minmap
    Push:finish()
end

----------------------------------------------------------------------------------
