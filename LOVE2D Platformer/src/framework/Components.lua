
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
    -- Movement (necessary for calculations)
    e.desiredVelocity = { x=0.0,  y=0.0 }
    e.direction = 0
    e.lastDirection = 1
    e.velocity = { x=0.0,  y=0.0 }
    e.maxSpeedChange = 0.0
    e.acceleration = 0.0
    e.deceleration = 0.0
    e.turnSpeed = 0.0
    -- Movement Options (states)
    e.pressingKey = true
    e.direction = 0
    e.useAcceleration = true
    -- Jump (necessary for calculations)
    e.jumpForce = 230.0
    e.jumpBufferCounter = 0.0
    e.coyoteTimeCounter = 0.0
    e.jumpHeight = 7.3              -- Maximum jump height
    e.jumpCutOff = 0.0              -- Gravity multiplier when you let go of jump
    e.jumpBuffer = 0.15             -- How far from ground should we cache your jump?
    e.variablejumpHeight = 0.0      -- Should the character drop when you let go of jump?
    e.timeToJumpApex = 1.0          -- How long it takes to reach that height before coming back down
    e.maxAirJumps = 0               -- How many times can you jump in the air?
    e.coyoteTime = 0.15             -- How long should coyote time last?
    -- Jump Options (states)
    e.pressingJump = false
    e.onGround = false
    e.currentlyJumping = false
    e.desiredJump = false
    e.canJumpAgain = false

    e.canMove = true
end)

----------------------------------------------------------------------------------

ECS.component("rigidbody", function(e, fallSpeed)
    -- Movement
    e.velocity = { x=0.0, y=0.0 }
    e.bounciness = 0.0
    e.maxSpeed = 150.0             -- Maximum movement speed
    e.maxAcceleration = 220.0      -- How fast to reach max speed
    e.maxDecceleration = 750.0     -- How fast to stop after letting go
    e.maxTurnSpeed = 500.0         -- How fast to stop when changing direction
    e.maxAirAcceleration = 500.0   -- How fast to reach max speed when in mid-air
    e.maxAirDecceleration = 350.0  -- How fast to stop in mid-air when no direction is used
    e.maxAirTurnSpeed = 500.0      -- How fast to stop when changing direction when in mid-air
    e.friction = 0.0               -- Friction to apply against movement on stick
    -- Jump
    e.gravityScale = 1.0
    e.gravityMultiplier = 1.0
    e.defaultGravityScale = 1.0
    e.speedLimit = 0.0              -- The fastest speed the character can fall
    e.upwardMovementMultiplier= 1.0 -- Gravity multiplier to apply when going up
    e.downwardMovementMultiplier = 6.17 -- Gravity multiplier to apply when coming down
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
