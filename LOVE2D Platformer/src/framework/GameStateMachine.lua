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
	self.currentStateKey = nil
	-- self.events = {}
end

----------------------------------------------------------------------------------

function GameStateMachine:start(stateName, params)
	assert(self.states[stateName]) -- state must exist!
	self.currentStateKey = stateName
	self.current = self.states[stateName]()
	self.current:enter(params)
	Log:debug("State starting "..stateName.."!")
end

----------------------------------------------------------------------------------

function GameStateMachine:change(stateName, params)
	assert(self.states[stateName]) -- state must exist!
	self.current:exit()
	self.currentStateKey = stateName
	self.current = self.states[stateName]()
	self.current:enter(params)
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

function GameStateMachine:addEvent(keys, callback, pollType)
	assert(#keys > 0)
	for _, key in ipairs(keys) do
		if INPUTS[key] and INPUTS[key].INPUT_TYPE == KEYBOARD then
			GameStateMachine:addKeyboardEvent(key, callback, pollType, self.currentStateKey)

		elseif INPUTS[key] and INPUTS[key].INPUT_TYPE == GAMEPAD then
			local joystickID = INPUTS[key].JOYSTICK_ID and INPUTS[key].JOYSTICK_ID or 0
			GameStateMachine:addGamepadEvent(key, callback, pollType, joystickID, self.currentStateKey)
		end
	end
	return nil
end

----------------------------------------------------------------------------------

function GameStateMachine:addKeyboardEvent(key, callback, pollType, context)
    return EventDispatcher:createKeyboardEvent(key, callback, pollType, context)
end

----------------------------------------------------------------------------------

function GameStateMachine:addGamepadEvent(button, callback, pollType, joystickId, context)
    return EventDispatcher:createGamepadEvent(button, callback, pollType, joystickId, context)
end

----------------------------------------------------------------------------------

function GameStateMachine:removeAllEvents()
	Log:info("REMOVE ALL "..self.currentStateKey.." EVENTS")
	EventDispatcher:removeAllContextEvents(self.currentStateKey)
end

----------------------------------------------------------------------------------

function GameStateMachine:removeEvent(event, pollType, context)
	EventDispatcher:removeEvent(event, pollType, context)
end


----------------------------------------------------------------------------------

function GameStateMachine:enableEvents()
	EventDispatcher:enableEvents(self.currentStateKey)
end

----------------------------------------------------------------------------------

function GameStateMachine:disableEvents()
    EventDispatcher:disableEvents(self.currentStateKey)
end

----------------------------------------------------------------------------------
