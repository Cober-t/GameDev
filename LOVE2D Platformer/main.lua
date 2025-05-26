require 'src/Dependencies'

local player = Player(300, 0)
local level = Level1(LevelMaps.first)
local camera = Camera(level)
local world = ECS.world()

local bumpWorld = Bump.newWorld(CELL_SIZE)

function love.load()



    -- Test
    if level.layers["Ground"] then
        for i, obj in pairs(level.layers["Ground"].objects) do
            bumpWorld:add(obj, obj.x, obj.y, obj.width, obj.height)
        end
    end

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
    bumpWorld:add(player, player.x, player.y, 12, 19)

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
    player.y = player.y + (GRAVITY * dt)

    -- update player collider to the new pos
    local actualX, actualY, cols, len = bumpWorld:move(player, player.x, player.y)
    player.x = actualX
    player.y = actualY
    -- check if for collisions
    -- ....


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
