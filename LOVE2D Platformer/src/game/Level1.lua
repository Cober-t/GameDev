local Level1 = Level:extend()

----------------------------------------------------------------------------------

function Level1:new()
    self.super.new(self, LevelMaps.first)
    Log:debug("Level1 creation!")
    self.colliders = {}
end

----------------------------------------------------------------------------------

function Level1:init()
    Log:debug("Level1 initialize!")
    -- Add level to the world
    if self.layers["Ground"] then
        for i, obj in pairs(self.layers["Ground"].objects) do
            table.insert(self.colliders, ECS.entity(World)
                        :give("transform", obj.x, obj.y)
                        :give("collider", obj.width, obj.height))
        end
    end
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
    -- Move to DebugSystem
    love.graphics.setColor(1, 1, 1, 1)
    for i, collider in pairs(self.colliders) do
        love.graphics.rectangle("line",
                        collider.transform.posX,
                        collider.transform.posY,
                        collider.collider.width,
                        collider.collider.height)
    end
end

----------------------------------------------------------------------------------
return Level1
----------------------------------------------------------------------------------
