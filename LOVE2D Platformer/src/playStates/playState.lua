PlayState = GameStateMachine:extend()

-- Require only in the game on the future
require "src/game/player"
require "src/game/camera"
require "src/game/level1"

-- Levels for the PlayState
local levels = {
    level1 = Level1()
}

local player = Player(300, 0)
local camera = Camera(levels.level1)
local currentLevel

function PlayState:new()
    Log:info("Play State created!")
    self.events = {}
    self:setupInputEvents()
end

function PlayState:enter()
    -- Instantiate level
    currentLevel = levels.level1
    currentLevel:init()

    -- Create player
    -- Put the player on the floor for this level
    local posY =  levels.level1.tileMap.height * levels.level1.tileMap.tileheight - love.graphics.getHeight()/2 + 150
    player.y = posY
    BumpWorld:add(player, player.x, player.y, 12, 19)

    camera:setTarget(player)
end


function PlayState:exit()
end

function PlayState:update(dt)
    player:update(dt)
    camera:update(player, dt)

    EventDispatcher:update()
end

function PlayState:draw()
    camera:draw(levels.level1, player)
    -- Draw HUD or DebugSystem
    love.graphics.print("FPS: "..tostring(love.timer.getFPS()).." -- State: "..player.state)
end


-- Handle Events for this GameState--
function PlayState:setupInputEvents()
    -- Movement events - these use the game state context to access the player
    self:addKeyboardEvent('a', function(context, input)
        context:movePlayer()
    end)
end

function PlayState:movePlayer()
    Log:debug("A PRESSED: MOVE PLAYER EVENT TRIGGER")
    -- self.player:move(love.timer.getDelta())
end
