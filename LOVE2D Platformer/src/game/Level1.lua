Level1 = Level:extend()

function Level1:new(tileMap)
    self.super.new(self, tileMap)
end

function Level1:draw()
    self.tileMap:drawLayer(self.layers[LVL_LAYER_BG].instance)
    self.tileMap:drawLayer(self.layers[LVL_LAYER_WORLD].instance)
end

-- levels.level1 = Level1()
