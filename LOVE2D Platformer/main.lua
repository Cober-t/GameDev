require 'src/Dependencies'

StateMachine  = GameStateMachine({
        [GAME_STATES.START] = function() return StartState() end,
        [GAME_STATES.PLAY]  = function() return PlayState()  end,
        [GAME_STATES.PAUSE] = function() return PauseState() end,
    })

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

    StateMachine:start(GAME_STATES.PLAY)
end

----------------------------------------------------------------------------------

function love.keypressed(key, scancode, isrepeat)
    EventDispatcher:keypressed(key, scancode, isrepeat)
    -- Restart the level
    if key == "r" then StateMachine:change(GAME_STATES.PLAY) end
end

----------------------------------------------------------------------------------

function love.keyreleased(key)
    EventDispatcher:keyreleased(key)
end

----------------------------------------------------------------------------------

function love.gamepadpressed(joystick, button)
    EventDispatcher:gamepadpressed(joystick, button)
end

----------------------------------------------------------------------------------

function love.gamepadreleased(joystick, button)
    EventDispatcher:gamepadreleased(joystick, button)
end

----------------------------------------------------------------------------------

function love.resize(w, h)
    Push:resize(w, h)
end

----------------------------------------------------------------------------------

function love.update(dt)
    EventDispatcher:update()
    -- Fixed physics calculations, for decouple game logic from framerate
    accumulator = accumulator + dt
    while accumulator >= fixedDeltaTime do
        StateMachine:update(fixedDeltaTime)
        World:emit("update", fixedDeltaTime)
        accumulator = accumulator - fixedDeltaTime
    end   
end

----------------------------------------------------------------------------------

function love.draw()
    Push:start()
        StateMachine:draw()
        -- World:emit("draw") --minmap
    Push:finish()
end

----------------------------------------------------------------------------------
