local Input = Class:extend()

----------------------------------------------------------------------------------

function Input:new(type, key)
    self.type = type -- 'keyboard', 'gamepad'
    self.key = key   -- the specific key/button
    self.isPressed = false
    self.wasPressed = false
    self.isReleased = false
end

----------------------------------------------------------------------------------
-- Abstract method (to be overridden)
function Input:checkPressed()
    error("checkPressed must be implemented by subclass")
end

----------------------------------------------------------------------------------

function Input:update()
    self.wasPressed = self.isPressed
    self:checkPressed()
    self.isReleased = self.wasPressed and not self.isPressed
end

----------------------------------------------------------------------------------

function Input:justPressed()
    return self.isPressed and not self.wasPressed
end

----------------------------------------------------------------------------------

function Input:justReleased()
    return self.isReleased
end

----------------------------------------------------------------------------------

function Input:isHeld()
    return self.isPressed
end

----------------------------------------------------------------------------------
-- Keyboard Input class
KeyboardInput = Input:extend()

----------------------------------------------------------------------------------

function KeyboardInput:new(key)
    KeyboardInput.super.new(self, 'keyboard', key)
end

----------------------------------------------------------------------------------

function KeyboardInput:checkPressed()
    self.isPressed = love.keyboard.isDown(self.key)
end

----------------------------------------------------------------------------------
-- Gamepad Input class
GamepadInput = Input:extend()

----------------------------------------------------------------------------------

function GamepadInput:new(button, joystickId)
    GamepadInput.super.new(self, 'gamepad', button)
    self.joystickId = joystickId or 1
    self.joystick = love.joystick.getJoysticks()[self.joystickId]
end

----------------------------------------------------------------------------------

function GamepadInput:checkPressed()
    if self.joystick then
        self.isPressed = self.joystick:isGamepadDown(self.key)
    else
        self.isPressed = false
    end
end

----------------------------------------------------------------------------------
