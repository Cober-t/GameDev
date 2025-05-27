-- Event class - represents a single input event that can be polled
local Event = Class:extend()

function Event:new(input, callback, context)
    self.input = input       -- Input object (keyboard/gamepad)
    self.callback = callback -- Function to call when event triggers
    self.context = context   -- Optional context object (self reference)
    self.enabled = true
end

function Event:poll()
    if not self.enabled then return end

    if self.input:justPressed() then
        if self.context then
            self.callback(self.context, self.input)
        else
            self.callback(self.input)
        end
    end
end

function Event:enable()
    self.enabled = true
end

function Event:disable()
    self.enabled = false
end

-- Event Dispatcher - manages input polling and event registration
EventDispatcher = Class:extend()

function EventDispatcher:new()
    Log:info("EventDispatcher created!")
    self.inputs = {}        -- All registered inputs
    self.events = {}        -- All registered events
    self.inputLookup = {}   -- Quick lookup for inputs by key
end

function EventDispatcher:getOrCreateInput(inputType, inputKey, joystickId)
    local lookupKey = inputType .. ":" .. inputKey .. ":" .. (joystickId or "")

    if not self.inputLookup[lookupKey] then
        local input
        if inputType == KEYBOARD then
            input = KeyboardInput(inputKey)
        elseif inputType == GAMEPAD then
            input = GamepadInput(inputKey, joystickId)
        else
            error("Unknown input type: " .. inputType)
        end

        self.inputs[#self.inputs + 1] = input
        self.inputLookup[lookupKey] = input
    end

    return self.inputLookup[lookupKey]
end

function EventDispatcher:createKeyboardEvent(key, callback, context)
    local input = self:getOrCreateInput(KEYBOARD, key)
    local event = Event(input, callback, context)
    self.events[#self.events + 1] = event
    return event
end

function EventDispatcher:createGamepadEvent(button, callback, context, joystickId)
    local input = self:getOrCreateInput(GAMEPAD, button, joystickId)
    local event = Event(input, callback, context)
    self.events[#self.events + 1] = event
    return event
end

function EventDispatcher:removeEvent(event)
    for i = #self.events, 1, -1 do
        if self.events[i] == event then
            table.remove(self.events, i)
            break
        end
    end
end

function EventDispatcher:update()
    -- Update all inputs first
    for _, input in ipairs(self.inputs) do
        input:update()
    end

    -- Poll all events
    for _, event in ipairs(self.events) do
        event:poll()
    end
end

function EventDispatcher:clear()
    self.events = {}
end