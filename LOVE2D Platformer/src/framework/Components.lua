
----------------------------------------------------------------------------------

ECS.component("transform", function(e, x, y)
    e.posX = x
    e.posY = y
    e.rot = 0
    e.scaleX = 1
    e.scaleY = 1
end)

----------------------------------------------------------------------------------

ECS.component("rigidbody", function(e, jumpForce, fallSpeed)
    e.speedX = 130
    e.speedY = 1
    e.jumpForce = jumpForce * -1
    e.fallSpeed = fallSpeed
    e.onFloor = false
end)

----------------------------------------------------------------------------------

ECS.component("collider", function(e, w, h, isTrigger)
    e.width = w
    e.height = h
    e.isTrigger = isTrigger
end)

----------------------------------------------------------------------------------

-- ECS.component("animation", function(e, visible)
--     e.visible = visible
-- end)

----------------------------------------------------------------------------------
