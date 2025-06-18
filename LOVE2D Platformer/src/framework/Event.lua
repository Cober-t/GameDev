-- Event class - represents a single input event that can be polled
local Event = Class:extend()

----------------------------------------------------------------------------------

function Event:new(input, key, callback, pollType, context)
    self.input = input       -- Input object (keyboard/gamepad)
    self.key = key
    self.callback = callback -- Function to call when event triggers
    self.pollType = pollType or POLL_TYPE.JUST_PRESSED -- Default to justPressed
    self.enabled = true
    self.context = context
end

----------------------------------------------------------------------------------

function Event:poll()
    
    if not self.enabled then return end

    local shouldTrigger = false

    -- Check the appropriate condition based on poll type
    if self.pollType == POLL_TYPE.JUST_PRESSED then
        shouldTrigger = self.input:justPressed()
    elseif self.pollType == POLL_TYPE.JUST_RELEASED then
        shouldTrigger = self.input:justReleased()
    elseif self.pollType == POLL_TYPE.IS_HELD then
        shouldTrigger = self.input:isHeld()
    end

    if shouldTrigger then self.callback() end
end

----------------------------------------------------------------------------------

function Event:enable()
    self.enabled = true
end

----------------------------------------------------------------------------------

function Event:disable()
    self.enabled = false
end

----------------------------------------------------------------------------------

function Event:setPollType(pollType)
    self.pollType = pollType
end

----------------------------------------------------------------------------------
-- Event Dispatcher - manages input polling and event registration
EventDispatcher = Class:extend()

function EventDispatcher:new()
    Log:debug("EventDispatcher created!")
    self.inputs = {}        -- All registered inputs
    self.events = {}        -- All registered events
    self.lookupKeys  = {}   -- Quick lookup for inputs and events
end

----------------------------------------------------------------------------------

function EventDispatcher:getOrCreateInput(inputType, inputKey, pollType, context, joystickId)
    local lookupKey = inputType .. ":" .. inputKey .. ":" .. (joystickId or "") .. ":" .. pollType

    if not self.inputs[lookupKey] then
        local input
        if inputType == KEYBOARD then
            input = KeyboardInput(inputKey)
        elseif inputType == GAMEPAD then
            input = GamepadInput(inputKey, joystickId)
        else
            Log:error("Unknown input type: " .. inputType)
        end

        self.inputs[lookupKey] = input
        self.lookupKeys[#self.lookupKeys + 1] = lookupKey
    end

    return lookupKey
end

----------------------------------------------------------------------------------

function EventDispatcher:createKeyboardEvent(key, callback, pollType, context)
    local lookupKey = self:getOrCreateInput(KEYBOARD, key, pollType, context)
    local newEvent = Event(self.inputs[lookupKey], key, callback, pollType, context)

    if newEvent then
        if not self.events[lookupKey] then
            self.events[lookupKey] = newEvent
        else
            self.events[lookupKey].callback = callback
        end
    else
        Log:error("KEYBOARD event couldn be created! : "..lookupKey)
    end
    return newEvent
end

----------------------------------------------------------------------------------

function EventDispatcher:createGamepadEvent(button, callback, pollType, joystickId, context)
    local lookupKey = self:getOrCreateInput(GAMEPAD, button, pollType, context, joystickId)
    local newEvent = Event(self.inputs[lookupKey], button, callback, pollType, context)

    if newEvent then
        if not self.events[lookupKey] then
            self.events[lookupKey] = newEvent
        else
            self.events[lookupKey].callback = callback
        end
    else
        Log:error("GAMEPAD event couldn be created! : "..lookupKey)
    end
    return newEvent
end


----------------------------------------------------------------------------------

function EventDispatcher:removeAllContextEvents(context)
    for _, lookupKey in ipairs(self.lookupKeys) do
        if self.events[lookupKey].context == context then
            self.lookupKeys[_] = nil
            self.events[lookupKey] = nil
            return
        end
    end
end

----------------------------------------------------------------------------------

function EventDispatcher:removeEvent(key, pollType, context)
    for _, lookupKey in ipairs(self.lookupKeys) do
        local event = self.events[lookupKey]
        if event.key == key and event.pollType == pollType and event.context == context then
            event = nil
            self.lookupKeys[_] = nil
            return
        end
    end
end

----------------------------------------------------------------------------------

function EventDispatcher:enableEvents(context)
    for _, lookupKey in ipairs(self.lookupKeys) do
        local event = self.events[lookupKey]
        if event and event.context == context then
            event:enable()
        end
    end
end


----------------------------------------------------------------------------------

function EventDispatcher:disableEvents(context)
    for _, lookupKey in ipairs(self.lookupKeys) do
        local event = self.events[lookupKey]
        if event and event.context == context then
            event:disable()
        end
    end
end

----------------------------------------------------------------------------------

function EventDispatcher:update(key, pollType)
    -- Update all inputs first
    for _, lookupKey in ipairs(self.lookupKeys) do
        if self.inputs[lookupKey].key == key then
            self.inputs[lookupKey]:update()
            self.events[lookupKey]:poll()
        end
    end
end

----------------------------------------------------------------------------------

function EventDispatcher:getEventsCount()
    return(#self.lookupKeys)
end

----------------------------------------------------------------------------------

function EventDispatcher:clear()
    self.events = {}
end

----------------------------------------------------------------------------------
