

require 'src/Dependencies'


local player = Player(300, 0)
local level = Level1(LevelMaps.first)
local camera = Camera(level)


function love.load()
    -- Test
    -- ground = {}
    -- if gameMap.layers["Ground"] then
    --     for i, obj in pairs(gameMap.layers["Ground"].objects) do
    --         local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
    --         wall:setType("static")
    --         table.insert(ground, wall)
    --     end
    -- end

    Push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true,
        canvas = false
    })

    sceneStates = GameStateMachine {
        start = function() return StartState() end,
        play  = function() return PlayState() end
    }
    sceneStates:change('start')

    -- Put the player on the floor for this level
    local posY =  level.tileMap.height * level.tileMap.tileheight - love.graphics.getHeight()/2 + 150
    player.y = posY

    camera:setTarget(player)
end


function love.resize(w, h)
    Push:resize(w, h)
end

-- function love.keypressed(key)
--     if key == 'escape' then
--         love.event.quit()
--     end

--     love.keyboard.keysPressed[key] = true
-- end

-- function love.keyboard.wasPressed(key)
--     return love.keyboard.keysPressed[key]
-- end

-- function love.update(dt)
--     gStateMachine:update(dt)

--     love.keyboard.keysPressed = {}
-- end


function love.update(dt)
    player:update(dt)

    sceneStates.update(dt)
    camera:update(player, dt)
end

function love.draw()

    Push:start()
        sceneStates:draw()
        camera:draw(level, player)
    -- gStateMachine:render()
    Push:finish()
    -- Draw HUD
    love.graphics.print("FPS: "..tostring(love.timer.getFPS()).." -- State: "..player.state)
end
