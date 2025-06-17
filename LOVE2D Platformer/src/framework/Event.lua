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
    self.inputLookup = {}   -- Quick lookup for inputs by key
end

----------------------------------------------------------------------------------

function EventDispatcher:getOrCreateInput(inputType, inputKey, pollType, context, joystickId)
    local lookupKey = inputType .. ":" .. inputKey .. ":" .. (joystickId or "") .. ":" .. pollType .. ":" .. context

    if not self.inputLookup[lookupKey] then
        local input
        if inputType == KEYBOARD then
            input = KeyboardInput(inputKey)
        elseif inputType == GAMEPAD then
            input = GamepadInput(inputKey, joystickId)
        else
            Log:error("Unknown input type: " .. inputType)
        end

        self.inputs[#self.inputs + 1] = input
        self.inputLookup[lookupKey] = input
    end

    return self.inputLookup[lookupKey]
end

----------------------------------------------------------------------------------

function EventDispatcher:createKeyboardEvent(key, callback, pollType, context)
    local input = self:getOrCreateInput(KEYBOARD, key, pollType, context)
    local newEvent = Event(input, key, callback, pollType, context)
    
    if newEvent then
        -- TODO: Find a way to detect duplicated events
        for _, event in ipairs(self.events) do
            if event.input == newEvent.input then
                return newEvent
            end
        end
        
        self.events[#self.events + 1] = newEvent 
    else
        Log:error("KEYBOARD event couldn be created! : "..input)
    end
    return newEvent
end

----------------------------------------------------------------------------------

function EventDispatcher:createGamepadEvent(button, callback, pollType, joystickId, context)
    local input = self:getOrCreateInput(GAMEPAD, button, pollType, context, joystickId)
    local newEvent = Event(input, button, callback, pollType, context)

    if newEvent then
        -- TODO: Find a way to detect duplicated events
        for _, event in ipairs(self.events) do
            if event.input == newEvent.input then 
                return event
            end
        end
        self.events[#self.events + 1] = newEvent 
    else
        Log:error("GAMEPAD event couldn be created! : "..input)
    end
    return newEvent
end


----------------------------------------------------------------------------------

function EventDispatcher:removeAllContextEvents(context)
    for _, event in ipairs(self.events) do
        if event.context == context then
            table.remove(self.events, _)
            return
        end
    end
end

----------------------------------------------------------------------------------

function EventDispatcher:removeEvent(e, context)
    for _, event in ipairs(self.events) do
        if event == e and event.context == context then
            table.remove(self.events, _)
            return
        end
    end
end

----------------------------------------------------------------------------------

function EventDispatcher:enableEvents(context)
    for _, event in ipairs(self.events) do
        if event.context == context then
            event:enable()
        end
    end
end


----------------------------------------------------------------------------------

function EventDispatcher:disableEvents(context)
    for _, event in ipairs(self.events) do
        if event.context == context then
            event:disable()
        end
    end
end

----------------------------------------------------------------------------------

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

----------------------------------------------------------------------------------

function EventDispatcher:clear()
    self.events = {}
end

----------------------------------------------------------------------------------
