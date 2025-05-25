local Level = Class:extend()


function Level:new(tileMap)
    self.tileMap = tileMap
    self.layers = {
        [LVL_LAYER_WORLD] = { order = 0, instance = tileMap.layers[LVL_LAYER_WORLD] },
        [LVL_LAYER_BG]    = { order = 1, instance = tileMap.layers[LVL_LAYER_BG]    },
    }

end

return Level