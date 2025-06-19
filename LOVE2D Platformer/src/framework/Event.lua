Event = Class:extend()

----------------------------------------------------------------------------------

function Event:new(input, key, callback, pollType, context)
    self.input = input       -- Input object (keyboard/gamepad)
    self.key = key           -- Key / Button / Axis that trigger this event
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
