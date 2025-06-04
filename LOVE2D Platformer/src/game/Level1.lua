local Level1 = Level:extend()

----------------------------------------------------------------------------------

function Level1:new()
    self.super.new(self, LevelMaps.first)
    Log:debug("Level1 creation!")
    self.colliders = {}
    if self.layers["Ground"] then
        for i, obj in pairs(self.layers["Ground"].objects) do
            table.insert(self.colliders, ECS.entity(World)
                        :give("transform", obj.x, obj.y)
                        :give("collider", 0, 0, obj.width, obj.height))
        end
    end
end

----------------------------------------------------------------------------------

function Level1:init()
    Log:debug("Level1 initialize!")
    -- Add level to the world
end

----------------------------------------------------------------------------------

function Level1:exit()
    Log:debug("Level1 destroyed!")
end

----------------------------------------------------------------------------------

function Level1:update(dt)
    -- ...
end

----------------------------------------------------------------------------------

function Level1:draw()
    self.tileMap:drawLayer(self.layers[LVL_LAYER_BG])
    self.tileMap:drawLayer(self.layers[LVL_LAYER_WORLD])
end

----------------------------------------------------------------------------------
return Level1
----------------------------------------------------------------------------------
