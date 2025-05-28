require 'src/Dependencies'


CurrentState  = GameStateMachine {
        ['start'] = function() return StartState() end,
        ['play']  = function() return PlayState()  end,
        ['pause'] = function() return PauseState() end,
    }

function love.load()

    Log:setLevel(LogLevel.DEBUG)
    Log:enableFileLogging("my_log_game.log")
    Push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true,
        canvas = false
    })

    CurrentState:change('play')
end

function love.keypressed(key)
    if key == "r" then -- Restart the level
        CurrentState:change('play')
    end
end

function love.resize(w, h)
    Push:resize(w, h)
end


function love.update(dt)

    CurrentState:update(dt)
end


function love.draw()
    Push:start()
        CurrentState:draw()
    Push:finish()
end
