local Input = Class:extend()

----------------------------------------------------------------------------------

function Input:new(type, key, active)
    self.type = type -- 'keyboard', 'gamepad', 'gamepad_axis'
    self.key = key   -- the specific key/button/axis
    self.isPressed = false
    self.wasPressed = false
    self.isReleased = false
    self.isActive = active -- tracks if this input is currently active
end

----------------------------------------------------------------------------------
-- Abstract method (to be overridden)
function Input:checkPressed()
    Log:error("checkPressed must be implemented by subclass")
end

----------------------------------------------------------------------------------

function Input:update()
    self.wasPressed = self.isPressed
    if self.isActive then
        self:checkPressed()
    end
    self.isReleased = self.wasPressed and not self.isPressed
end

----------------------------------------------------------------------------------

function Input:activate()
    self.isActive = true
end

----------------------------------------------------------------------------------

function Input:deactivate()
    self.isActive = false
    self.isPressed = false
    self.wasPressed = false
    self.isReleased = false
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
    KeyboardInput.super.new(self, 'keyboard', key, false)
end

----------------------------------------------------------------------------------

function KeyboardInput:checkPressed()
    self.isPressed = love.keyboard.isDown(self.key)
end

----------------------------------------------------------------------------------
-- Gamepad Input class
GamepadInput = Input:extend()

----------------------------------------------------------------------------------

function GamepadInput:new(button, joystickID)
    GamepadInput.super.new(self, GAMEPAD, button, false)
    self.joystickID = joystickID or 1
    self.joystick = love.joystick.getJoysticks()[self.joystickID]
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
-- Gamepad Axis Input class - NEW!
GamepadAxisInput = Input:extend()

----------------------------------------------------------------------------------

function GamepadAxisInput:new(axis, joystickID, threshold, direction)
    GamepadAxisInput.super.new(self, GAMEPAD_AXIS, axis, true) -- Axis events are always active
    self.joystickID = joystickID or 1
    self.joystick = love.joystick.getJoysticks()[self.joystickID]
    self.threshold = threshold or 0.3 -- Deadzone threshold (0.0 to 1.0)
    self.direction = direction or "any" -- "positive", "negative", or "any"
    self.value = 0 -- Current axis value
    self.previousValue = 0 -- Previous axis value for change detection
end

----------------------------------------------------------------------------------

function GamepadAxisInput:checkPressed()
    if self.joystick then
        self.previousValue = self.value
        self.value = self.joystick:getGamepadAxis(self.key)
        
        -- Check if axis is beyond threshold in the specified direction
        local beyondThreshold = false
        
        if self.direction == "positive" then
            beyondThreshold = self.value > self.threshold
        elseif self.direction == "negative" then
            beyondThreshold = self.value < -self.threshold
        else -- "any"
            beyondThreshold = math.abs(self.value) > self.threshold
        end
        
        self.isPressed = beyondThreshold
    else
        self.isPressed = false
        self.value = 0
        self.previousValue = 0
    end
end

----------------------------------------------------------------------------------

-- Additional methods for axis inputs
function GamepadAxisInput:getValue()
    return self.value
end

----------------------------------------------------------------------------------

function GamepadAxisInput:getPreviousValue()
    return self.previousValue
end

----------------------------------------------------------------------------------

function GamepadAxisInput:getDelta()
    return self.value - self.previousValue
end

----------------------------------------------------------------------------------

function GamepadAxisInput:setThreshold(threshold)
    self.threshold = math.max(0, math.min(1, threshold))
end

----------------------------------------------------------------------------------

function GamepadAxisInput:setDirection(direction)
    if direction == "positive" or direction == "negative" or direction == "any" then
        self.direction = direction
    else
        Log:error("Invalid direction: " .. tostring(direction) .. ". Use 'positive', 'negative', or 'any'")
    end
end

----------------------------------------------------------------------------------
-- Check if axis just crossed threshold
function GamepadAxisInput:justPressed()
    self.wasPressed = math.abs(self.previousValue) > self.threshold
    self.isPressed = math.abs(self.value) > self.threshold
    return self.isPressed and not self.wasPressed
end

----------------------------------------------------------------------------------
-- Check if axis just returned to deadzone
function GamepadAxisInput:justReleased()
    self.wasPressed = math.abs(self.previousValue) > self.threshold
    self.isPressed = math.abs(self.value) > self.threshold
    return not self.isPressed and self.wasPressed
end

----------------------------------------------------------------------------------
