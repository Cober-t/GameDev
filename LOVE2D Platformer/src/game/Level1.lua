Level1 = Level:extend()

function Level1:new()
    self.super.new(self, LevelMaps.first)
end

function Level1:init()
    -- Create level
    if self.layers["Ground"] then
        for i, obj in pairs(self.layers["Ground"].objects) do
            BumpWorld:add(obj, obj.x, obj.y, obj.width, obj.height)
        end
    end
end

function Level1:update(dt)
    -- ...
end

function Level1:draw()
    self.tileMap:drawLayer(self.layers[LVL_LAYER_BG])
    self.tileMap:drawLayer(self.layers[LVL_LAYER_WORLD])
end
