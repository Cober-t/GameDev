
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
    -- Movement
    e.desiredVelocity = { x=0.0,  y=0.0 }
    e.direction = 0
    e.lastDirection = 1
    e.velocity = { x=0.0,  y=0.0 }
    e.maxSpeedChange = 0.0
    e.acceleration = 0.0
    e.deceleration = 0.0
    e.turnSpeed = 0.0
    e.pressingKey = true
    e.direction = 0
    -- Jump
    e.jumpForce = jumpForce
    -- Options
    e.useAcceleration = true
end)

----------------------------------------------------------------------------------

ECS.component("rigidbody", function(e, fallSpeed)
    e.gravity = 500
    e.velocity = { x=0.0, y=0.0 }
    --e.fallSpeed = fallSpeed
    e.maxSpeed = 150.0             -- Maximum movement speed
    e.maxAcceleration = 220.0      -- How fast to reach max speed
    e.maxDecceleration = 750.0     -- How fast to stop after letting go
    e.maxTurnSpeed = 500.0         -- How fast to stop when changing direction
    e.maxAirAcceleration = 500.0   -- How fast to reach max speed when in mid-air
    e.maxAirDecceleration = 350.0  -- How fast to stop in mid-air when no direction is used
    e.maxAirTurnSpeed = 500.0      -- How fast to stop when changing direction when in mid-air
    e.friction = 0.0               -- Friction to apply against movement on stick
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
