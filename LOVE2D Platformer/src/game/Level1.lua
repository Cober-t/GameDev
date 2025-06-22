local Level1 = Level:extend()

----------------------------------------------------------------------------------

function Level1:new()
    self.super.new(self, LevelMaps.first)
    Log:debug("Level1 initialize!")
end

----------------------------------------------------------------------------------

function Level1:init()
    Log:debug("Level1 ADDED to the World!")
    self.colliders = {}
    if self.layers[LVL_LAYER_COLLISIONS] then
        for i, obj in pairs(self.layers[LVL_LAYER_COLLISIONS].objects) do
            table.insert(self.colliders, ECS.entity(World)
                        :give("transform", obj.x, obj.y)
                        :give("collider", 0, 0, obj.width, obj.height))
        end
    end

    if self.layers[LVL_LAYER_KILLZONE] then
        for i, obj in pairs(self.layers[LVL_LAYER_KILLZONE].objects) do
            table.insert(self.colliders, ECS.entity(World)
                        :give("transform", obj.x, obj.y)
                        :give("collider", 0, 0, obj.width, obj.height, "cross", -- TODO: Relate entity type and collision type
                            function(entity) entity:exit() end))
        end
    end
end


----------------------------------------------------------------------------------

function Level1:killzoneFunction()
    Log:debug("PLAYER KILLED")
end

----------------------------------------------------------------------------------

function Level1:exit()
    Log:debug("Level1 DESTROYED from the World!")
    for _, entity in ipairs(self.colliders) do
        World:removeEntity(entity)
    end
    self.colliders = nil
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
