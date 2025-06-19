EventDispatcher = Class:extend()

function EventDispatcher:new()
    Log:debug("EventDispatcher created!")
    self.inputs = {}        -- All registered inputs
    self.events = {}        -- All registered events
    self.lookupKeys  = {}   -- Lookup keys list for inputs/events quick access
    self.keyToLookupMap = {}-- Map keys to theis lookup keys for quick access
    self.activeInputs = {}  -- Tracks which inputs are currently active
end

----------------------------------------------------------------------------------

function EventDispatcher:getOrCreateInput(inputType, inputKey, pollType, context, joystickID)
    local lookupKey = inputType .. ":" .. inputKey .. ":" .. (joystickID or "") .. ":" .. pollType

    if self.inputs[lookupKey] then return end
    local input
    if inputType == KEYBOARD then
        input = KeyboardInput(inputKey)
    elseif inputType == GAMEPAD then
        input = GamepadInput(inputKey, joystickID)
    else
        Log:error("Unknown input type: " .. inputType)
    end

    self.inputs[lookupKey] = input
    self.lookupKeys[#self.lookupKeys + 1] = lookupKey

    -- Save a list of lookupkeys for a key, because a key can have more than one event
    if not self.keyToLookupMap[inputKey] then
        -- Create an empty table first 
        self.keyToLookupMap[inputKey] = {}
    end
    table.insert(self.keyToLookupMap[inputKey], lookupKey)

    return lookupKey
end

----------------------------------------------------------------------------------

function EventDispatcher:createEvent(inputType, key, callback, pollType, context)
    local lookupKey = self:getOrCreateInput(inputType, key, pollType, context)
    local newEvent = Event(self.inputs[lookupKey], key, callback, pollType, context)

    if newEvent then
        if not self.events[lookupKey] then
            self.events[lookupKey] = newEvent
        else
            self.events[lookupKey].callback = callback
        end
    else
        Log:error(inputType.." event couldn be created! : "..lookupKey)
    end
    return newEvent
end

----------------------------------------------------------------------------------

function EventDispatcher:keypressed(key, scancode, isrepeat)
    if not self.keyToLookupMap[key] or isrepeat then return end -- Ignore key repeats

    -- Activate all inputs associated with this key
    for _, lookupKey in ipairs(self.keyToLookupMap[key]) do
        local input = self.inputs[lookupKey]
        if input and input.type == KEYBOARD then
            input:activate()
            self.activeInputs[lookupKey] = true
        end
    end
end

----------------------------------------------------------------------------------

function EventDispatcher:keyreleased(key)
    if not self.keyToLookupMap[key] then return end
    
    -- Activate all inputs associated with this key
    for _, lookupKey in ipairs(self.keyToLookupMap[key]) do
        local input = self.inputs[lookupKey]
        if input and input.type == KEYBOARD then
            self.activeInputs[lookupKey] = false
        end
    end
end

----------------------------------------------------------------------------------

function EventDispatcher:gamepadpressed(joystick, button)
    local joystickID = nil
    local joysticks = love.joystick.getJoysticks()
    for i, stick in ipairs(joysticks) do
        if stick == joystick then
            joystickID = i
            break
        end
    end

    if joystickID and self.keyToLookupMap[button] then
        for _, lookupKey in ipairs(self.keyToLookupMap[button]) do
            local input = self.inputs[lookupKey]
            if input and input.type == GAMEPAD and input.joystickID == joystickID then
                input:activate()
                self.activeInputs[lookupKey] = true
            end
        end
    end
end

----------------------------------------------------------------------------------

function EventDispatcher:gamepadreleased(joystick, button)
    local joystickID = nil
    local joysticks = love.joystick.getJoysticks()
    for i, stick in ipairs(joysticks) do
        if stick == joystick then
            joystickID = i
            break
        end
    end

    if joystickID and self.keyToLookupMap[button] then
        for _, lookupKey in ipairs(self.keyToLookupMap[button]) do
            local input = self.inputs[lookupKey]
            if input and input.type == GAMEPAD and input.joystickID == joystickID then
                self.activeInputs[lookupKey] = false
            end
        end
    end
end

----------------------------------------------------------------------------------

function EventDispatcher:removeAllContextEvents(context)
    for i = #self.lookupKeys, 1, -1 do
        local lookupKey = self.lookupKeys[i]        
        local event = self.events[lookupKey]
        if event and event.context == context then
            -- Clean up key mapping
            if self.keyToLookupMap[event.key] then
                for j, mappedKey in ipairs(self.keyToLookupMap[event.key]) do
                    if mappedKey == lookupKey then
                        table.remove(self.keyToLookupMap[event.key], i)
                        break
                    end
                end
            end

            self.activeInputs[lookupKey] = nil

            table.remove(self.lookupKeys, i)
            self.events[lookupKey] = nil
            self.inputs[lookupKey] = nil
            return
        end
    end
end

----------------------------------------------------------------------------------

function EventDispatcher:removeEvent(key, pollType, context)
    for i = #self.lookupKeys, 1, -1 do
        local lookupKey = self.lookupKeys[i]
        local event = self.events[lookupKey]
        if event and event.key == key and event.pollType == pollType and event.context == context then
            -- Clean up key mapping
            if self.keyToLookupMap[key] then
                for j, mappedKey in ipairs(self.keyToLookupMap[key]) do
                    if mappedKey == lookupKey then
                        table.remove(self.keyToLookupMap[key], j)
                        break
                    end
                end
            end
            
            self.activeInputs[lookupKey] = nil
            
            table.remove(self.lookupKeys, i)
            self.events[lookupKey] = nil
            self.inputs[lookupKey] = nil
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

function EventDispatcher:update()
    -- Only update active inputs
    for lookupKey, _ in pairs(self.activeInputs) do
        if self.inputs[lookupKey] then
            self.inputs[lookupKey]:update()
        end
    end
    
    -- Poll events for active inputs
    for lookupKey, _ in pairs(self.activeInputs) do
        if self.events[lookupKey] then
            self.events[lookupKey]:poll()
        end
    end

    -- Cleanup inactive inputs
    for lookupKey, isActive in pairs(self.activeInputs) do
        if self.inputs[lookupKey] and isActive == false then
            self.inputs[lookupKey]:deactivate()
            self.activeInputs[lookupKey] = nil
        end
    end
end

----------------------------------------------------------------------------------

function EventDispatcher:getEventsCount()
    return(#self.lookupKeys)
end

----------------------------------------------------------------------------------

function EventDispatcher:getActiveInputsCount()
    local count = 0
    for _ in pairs(self.activeInputs) do count = count + 1 end
    return count
end

----------------------------------------------------------------------------------

function EventDispatcher:clear()
    self.events = {}
    self.inputs = {}
    self.lookupKeys = {}
    self.activeInputs = {}
    self.keyToLookupMap = {}
end

----------------------------------------------------------------------------------
