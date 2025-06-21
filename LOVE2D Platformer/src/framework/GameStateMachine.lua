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

function GameStateMachine:enableEvents()
	EventDispatcher:enableEvents(self.currentStateKey)
end

----------------------------------------------------------------------------------

function GameStateMachine:disableEvents()
    EventDispatcher:disableEvents(self.currentStateKey)
end

----------------------------------------------------------------------------------
