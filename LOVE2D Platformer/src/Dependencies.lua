-- LOVE2D --
_G.love = require("love")

-- LIBRARIES --
Anim8 = require 'libraries/anim8/anim8'     -- Animation utility
Sti = require 'libraries/sti'               -- Level importer from Tiled
HumCamera = require 'libraries/hump/camera' -- Camera utility from HUMP
-- Class = require 'libraries/hump/Class'      -- Class utility from HUMP
Bump = require "libraries/bump/bump"
Push = require "libraries/push/push"
Class = require "libraries/class/classic"
ECS = require "libraries/concord"
-- knife = require "libraries/knife"


-- ASSETS --
love.graphics.setDefaultFilter("nearest", "nearest")

SpriteSheets = {
    player = love.graphics.newImage("assets/sprites/knight.png"),
}

LevelMaps = {
    first = Sti("assets/maps/testLevel.lua"),
}

-- GAME CODE --
require "src/constants"
require "src/framework/logger"
Log = Logger()


require "src/framework/level"
require "src/framework/entity"
require "src/framework/baseEntityState"
require "src/framework/gameStateMachine"
require "src/framework/components"
require "src/framework/input"
require "src/framework/event"


require "src/entities/playerStates/playerIdleState"
require "src/entities/playerStates/playerWalkState"

require "src/playStates/startState"
require "src/playStates/playState"
require "src/playStates/pauseState"
require "src/systems/physics"

-- GLOBALS --
-- Abstract to CollisionSystem and ECS System
-- Apply only to the entities with a certain components
local world = ECS.world()
BumpWorld = Bump.newWorld(CELL_SIZE)
EventDispatcher = EventDispatcher()