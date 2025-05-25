

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

    -- Put the player on the floor for this level
    local posY =  level.tileMap.height * level.tileMap.tileheight - love.graphics.getHeight()/2 + 150
    player.y = posY

    camera:setTarget(player)
end

function love.update(dt)
    local vx = 0
    local vy = 0
    local state = ""
    if love.keyboard.isDown("left") then
        player.x = player.x + player.speed * dt * -1
        player.direction = -1
        state = "walkLeft"
    elseif love.keyboard.isDown("right") then
        player.x = player.x + player.speed * dt
        player.direction = 1
        state = "walkRight"
    elseif love.keyboard.isDown("space") then
        vy = player.speed * -1
        -- player.collider:applyLinearImpulse(0, -50)
        if player.direction == -1 then state = "jumpLeft" else state = "jumpRight" end
    elseif love.keyboard.isDown("escape") then
        love.event.quit()
    elseif player.direction == -1 then state = "idleLeft" else state = "idleRight" end

    -- Apply Animation
    player:updateAnimation(state, dt)
    camera:update(player, dt)
end

function love.draw()
    camera:draw(player)

    -- Draw HUD
    love.graphics.print("FPS: "..tostring(love.timer.getFPS()).." -- State: "..player.state)
end
