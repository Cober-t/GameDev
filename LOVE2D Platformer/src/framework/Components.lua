
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

ECS.component("rigidbody", function(e, jumpForce, fallSpeed)
    e.speedX = 130
    e.speedY = 1
    e.jumpForce = jumpForce * -1
    e.fallSpeed = fallSpeed
end)

----------------------------------------------------------------------------------

ECS.component("collider", function(e, w, h, isTrigger)
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
