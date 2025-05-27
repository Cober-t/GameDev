require 'src/Dependencies'

-- Abstract to CollisionSystem and ECS System
-- Apply only to the entities with a certain components
local world = ECS.world()
BumpWorld = Bump.newWorld(CELL_SIZE)


local currentState

function love.load()

    Push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true,
        canvas = false
    })

    currentState  = GameStateMachine {
        ['start'] = function() return StartState() end,
        ['play']  = function() return PlayState()  end,
        ['pause'] = function() return PauseState() end,
    }
    currentState:change('play')
end


function love.resize(w, h)
    Push:resize(w, h)
end

function love.keypressed(key)
    -- currentState:change('start')
    -- if key == 'escape' then
    --     love.event.quit()
    -- end

    -- love.keyboard.keysPressed[key] = true
end
function love.keyreleased(key)
    -- print("RELEASED: "..key)
    -- if key == 'escape' then
    --     love.event.quit()
    -- end
    -- love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
    -- return love.keyboard.keysPressed[key]
end

-- function love.update(dt)
--     gStateMachine:update(dt)

--     love.keyboard.keysPressed = {}
-- end


function love.update(dt)
    currentState:update(dt)
end

function love.draw()

    Push:start()
        currentState:draw()
    Push:finish()
end
