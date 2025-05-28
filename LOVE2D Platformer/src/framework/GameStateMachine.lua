GameStateMachine = Class:extend()

----------------------------------------------------------------------------------

function GameStateMachine:new(states)
	Log:debug("GameStateMachine created!")
	self.empty = {
		draw   = function()   end,
		update = function(dt) end,
		enter  = function()   end,
		exit   = function()   end
	}
	self.states = states or {} -- [name] -> [function that returns states]
	self.current = self.empty
	self.events = {}
end

----------------------------------------------------------------------------------

function GameStateMachine:change(stateName)
	assert(self.states[stateName]) -- state must exist!
	self.current:exit()
	self.current = self.states[stateName]()
	self.current:enter()
	Log:debug("State changing to "..stateName.."!")
end

----------------------------------------------------------------------------------

function GameStateMachine:draw()
	self.current:draw()
end

----------------------------------------------------------------------------------

function GameStateMachine:update(dt)
	self.current:update(dt)
end

----------------------------------------------------------------------------------

function GameStateMachine:enter()
	self:enableEvents()
end

----------------------------------------------------------------------------------

function GameStateMachine:exit()
	self:disableEvents()
end

----------------------------------------------------------------------------------

function GameStateMachine:addKeyboardEvent(key, callback, pollType)
    local event = EventDispatcher:createKeyboardEvent(key, callback, self, pollType)
    self.events[#self.events + 1] = event
    return event
end

----------------------------------------------------------------------------------

function GameStateMachine:addGamepadEvent(button, callback, joystickId, pollType)
    local event = EventDispatcher:createGamepadEvent(button, callback, self, joystickId, pollType)
    self.events[#self.events + 1] = event
    return event
end

----------------------------------------------------------------------------------

function GameStateMachine:removeAllEvents()
    for _, event in ipairs(self.events) do
        EventDispatcher:removeEvent(event)
    end
    self.events = {}
end

----------------------------------------------------------------------------------

function GameStateMachine:enableEvents()
    for _, event in ipairs(self.events) do
        event:enable()
    end
end

----------------------------------------------------------------------------------

function GameStateMachine:disableEvents()
    for _, event in ipairs(self.events) do
        event:disable()
    end
end

----------------------------------------------------------------------------------

function GameStateMachine:setupInputEvents()
end

----------------------------------------------------------------------------------
