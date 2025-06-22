local Killzone = Killzone:extend()

----------------------------------------------------------------------------------

function Killzone:new()
    Log:debug("Killzone initialize!")
end

----------------------------------------------------------------------------------

function Killzone:init()
    Log:debug("Killzone ADDED to the World!")
    self.colliders = {}
    if self.layers[LVL_LAYER_KILLZONE] then
        for i, obj in pairs(self.layers[LVL_LAYER_KILLZONE].objects) do
            table.insert(self.colliders, ECS.entity(World)
                        :give("transform", obj.x, obj.y)
                        :give("collider", 0, 0, obj.width, obj.height, "cross"))
        end
    end
end

----------------------------------------------------------------------------------

function Killzone:exit()
    Log:debug("Killzone DESTROYED from the World!")
    for _, entity in ipairs(self.colliders) do
        World:removeEntity(entity)
    end
    self.colliders = nil
end

----------------------------------------------------------------------------------

function Killzone:onTriggerEnter(collision)
    return
end


----------------------------------------------------------------------------------

function Killzone:onTriggerExit(collision)
    return
end

----------------------------------------------------------------------------------
return Killzone
----------------------------------------------------------------------------------
