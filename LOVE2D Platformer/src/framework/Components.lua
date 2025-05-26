
ECS.component("transform", function(e, x, y, rot, scX, scY)
    e.position = {}
    e.position.x = x
    e.position.y = y
    e.rotation = rot
    e.scale = {}
    e.scale.x = scX
    e.scale.y = scY
end)


ECS.component("velocity", function(e, x, y)
    e.x = x
    e.y = y
end)

ECS.component("rigidbody", function(e, fric, rest, sp)
    e.friccion = fric
    e.restitution = rest
    e.speed= sp
    e.velocity = 0
end)

ECS.component("collider", function(e, w, h, isTrigger)
    e.width = w
    e.height = h
    e.trigger = isTrigger
end)

-- Defining Systems
local MoveSystem = ECS.system({
    pool = {"transform", "velocity"}
})
-- function MoveSystem:update(dt)
--     for _, e in ipairs(self.pool) do
--         e.position.x = e.position.x + e.velocity.x * dt
--         e.position.y = e.position.y + e.velocity.y * dt
--     end
-- end

local PhysicsSystem = ECS.system({
    pool = {"transform", "rigidbody", "collider"}
})

-- Add the Systems
-- world:addSystems(MoveSystem, DrawSystem)


-- This Entity will be rendered on the screen, and move to the right at 100 pixels a second
-- local entity_1 = Concord.entity(world)
-- :give("transform", 100, 100)
-- :give("velocity", 100, 0)
-- :give("drawable")


-- Emit the events
-- function love.update(dt)
--     world:emit("update", dt)
-- end

-- function love.draw()
--     world:emit("draw")
-- end