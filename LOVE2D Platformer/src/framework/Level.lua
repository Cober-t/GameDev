Level = Class:extend()

function Level:new(tileMap)
    self.tileMap = tileMap
    self.visible = true
    self.layers = {
        [LVL_LAYER_WORLD]      = tileMap.layers[LVL_LAYER_WORLD],
        [LVL_LAYER_BG]         = tileMap.layers[LVL_LAYER_BG],
        [LVL_LAYER_COLLISIONS] = tileMap.layers[LVL_LAYER_COLLISIONS],
    }
end

function Level:init()
    -- override
end

function Level:update(dt)
    -- override
end

function Level:draw()
    -- override
end
