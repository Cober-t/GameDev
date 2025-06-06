
----------------------------------------------------------------------------------

ECS.component("transform", function(e, x, y)
    e.posX = x
    e.posY = y
    e.rot = 0
    e.scaleX = 1
    e.scaleY = 1
    e.toMove = false
end)

----------------------------------------------------------------------------------

ECS.component("movement", function(e, jumpForce)
    e.speedX = 0
    e.speedY = 0
    e.jumpForce = jumpForce
end)

----------------------------------------------------------------------------------

ECS.component("rigidbody", function(e, fallSpeed)
    e.gravity = 500
    e.velocity = { x=130.0, y=0.0 }
    --e.fallSpeed = fallSpeed
    e.maxSpeed = 10.0            -- Maximum movement speed
    e.maxAcceleration = 52.0     -- How fast to reach max speed
    e.maxDecceleration = 52.0    -- How fast to stop after letting go
    e.maxTurnSpeed = 80.0        -- How fast to stop when changing direction
    e.maxAirAcceleration = 0.0   -- How fast to reach max speed when in mid-air
    e.maxAirDecceleration = 0.0   -- How fast to stop in mid-air when no direction is used
    e.maxAirTurnSpeed = 80.0     -- How fast to stop when changing direction when in mid-air
    e.friction = 0.0             -- Friction to apply against movement on stick
end)

----------------------------------------------------------------------------------

ECS.component("collider", function(e, offX, offY, w, h, isTrigger)
    e.offsetX = offX
    e.offsetY = offY
    e.width = w
    e.height = h
    e.isTrigger = isTrigger
    e.onFloor = false
end)

----------------------------------------------------------------------------------

-- ECS.component("animation", function(e, visible)
--     e.visible = visible
-- end)

----------------------------------------------------------------------------------
