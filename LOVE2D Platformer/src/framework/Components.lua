
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
    e.jumpForce = 10.0
    e.jumpBufferCounter = 0.0
    e.coyoteTime = 0.35            -- How long should coyote time last?
    e.coyoteTimeCounter = 0.0
    e.jumpHeight = 0.4             -- Maximum jump height
    e.jumpCutOff = 4.0             -- Gravity multiplier when you let go of jump
    e.jumpBuffer = 0.15            -- How far from ground should we cache your jump?
    e.maxAirJumps = 1              -- How many times can you jump in the air?
    e.timeToJumpApex = 0.35         -- How long it takes to reach that height before coming back down
    -- Jump Options (states)
    e.onFloor = false
    e.pressingJump = false
    e.canJumpAgain = false
    e.currentlyJumping = false
    e.desiredJump = false
    e.variableJumpHeight = true    -- Should the character drop when you let go of jump?

    e.canMove = true
end)

----------------------------------------------------------------------------------

ECS.component("rigidbody", function(e, fallSpeed)
    -- Movement
    e.velocity = { x=0.0, y=0.0 }
    e.bounciness = 0.0
    e.maxSpeed = 175.0             -- Maximum movement speed
    e.maxAcceleration = 900.0      -- How fast to reach max speed
    e.maxDecceleration = 900.0     -- How fast to stop after letting go
    e.maxTurnSpeed = 900.0         -- How fast to stop when changing direction
    e.maxAirAcceleration = 2000.0   -- How fast to reach max speed when in mid-air
    e.maxAirDecceleration = 350.0  -- How fast to stop in mid-air when no direction is used
    e.maxAirTurnSpeed = 2000.0      -- How fast to stop when changing direction when in mid-air
    e.friction = 0.0               -- Friction to apply against movement on stick
    -- Jump
    e.gravityScale = 1.0
    e.groundGravity = 1.0
    e.gravityMultiplier = 1.0
    e.defaultGravityScale = 1.0
    e.fallSpeedLimit = 100.0          -- The fastest speed the character can fall
    e.upwardMovementMultiplier = 1.0 -- Gravity multiplier to apply when going up
    e.downwardMovementMultiplier = 0.75 -- Gravity multiplier to apply when coming down
end)

----------------------------------------------------------------------------------

ECS.component("collider", function(e, offX, offY, w, h, isTrigger)
    e.offsetX = offX
    e.offsetY = offY
    e.width = w
    e.height = h
    e.isTrigger = isTrigger
end)

----------------------------------------------------------------------------------

-- ECS.component("animation", function(e, visible)
--     e.visible = visible
-- end)

----------------------------------------------------------------------------------
