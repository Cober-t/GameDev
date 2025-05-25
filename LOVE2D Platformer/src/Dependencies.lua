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
ECS = require "libraries/ecs/tiny"
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
Level = require "src/level"

require "src/game/player"
require "src/game/level1"
require "src/game/camera"
require "src/systems/input"
