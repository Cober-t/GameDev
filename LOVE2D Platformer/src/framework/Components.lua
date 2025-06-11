
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
    e.coyoteTime = 0.085            -- How long should coyote time last?
    e.coyoteTimeCounter = 0.0
    e.jumpHeight = 0.4             -- Maximum jump height
    e.jumpCutOff = 0.5             -- Gravity multiplier when you let go of jump
    e.jumpBuffer = 0.15            -- How far from ground should we cache your jump?
    e.maxAirJumps = 1              -- How many times can you jump in the air?
    e.timeToJumpApex = 1.0        -- How long it takes to reach that height before coming back down
    e.jumpStartTime = 0.0
    e.jumpMinimumMet = false
    e.jumpHoldTime = 0.0           -- How long space has been held
    e.maxJumpHoldTime = 0.8        -- Maximum time to hold for full jump (adjust as needed)
    e.minJumpHoldTime = 0.1        -- Minimum hold time for shortest jump
    e.maxJumpHeight = 2.5          -- Minimum jump height in pixels
    e.minJumpHeight = 0.5          -- Minimum jump height in pixels
    e.peakVelocityThreshold = 50    -- Velocity threshold to consider "near peak"
    e.peakGravityMultiplier = 0.7   -- Reduce gravity near peak for floaty feel
    -- Jump Options (states)
    e.variableJumpHeight = true    -- Should the character drop when you let go of jump?
    e.onFloor = false
    e.pressingJump = false
    e.canJumpAgain = false
    e.currentlyJumping = false
    e.desiredJump = false
    e.enablePeakFloatiness = true

    e.canMove = true
end)

----------------------------------------------------------------------------------

ECS.component("rigidbody", function(e, fallSpeed)
    -- Movement
    e.velocity = { x=0.0, y=0.0 }
    e.bounciness = 0.0
    e.maxSpeed = 225.0             -- Maximum movement speed
    e.maxAcceleration = 900.0      -- How fast to reach max speed
    e.maxDecceleration = 900.0     -- How fast to stop after letting go
    e.maxTurnSpeed = 900.0         -- How fast to stop when changing direction
    e.maxAirAcceleration = 1000.0   -- How fast to reach max speed when in mid-air
    e.maxAirDecceleration = 900.0  -- How fast to stop in mid-air when no direction is used
    e.maxAirTurnSpeed = 700.0      -- How fast to stop when changing direction when in mid-air
    e.friction = 0.0               -- Friction to apply against movement on stick
    -- Jump
    e.gravityScale = 1.0
    e.groundGravity = 1.0
    e.gravityMultiplier = 1.0
    e.defaultGravityScale = 1.0
    e.fallSpeedLimit = 50.0          -- The fastest speed the character can fall
    e.upwardMovementMultiplier = 8.0 -- Gravity multiplier to apply when going up
    e.downwardMovementMultiplier = 5.0 -- Gravity multiplier to apply when coming down
      -- Variable jump height gravity multipliers
    e.jumpHoldGravityMultiplier = 2    -- Light gravity while holding jump
    e.jumpReleaseGravityMultiplier = 3.8 -- Heavy gravity when jump released
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
