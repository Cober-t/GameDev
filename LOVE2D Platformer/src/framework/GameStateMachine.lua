GameStateMachine = Class:extend()

function GameStateMachine:new(states)
	self.empty = {
		draw   = function() end,
		update = function() end,
		enter  = function() end,
		exit   = function() end
	}
	self.states = states or {} -- [name] -> [function that returns states]
	self.current = self.empty
end

function GameStateMachine:change(stateName, enterParams)
	assert(self.states[stateName]) -- state must exist!
	self.current:exit()
	self.current = self.states[stateName]()
	-- self.current:enter(enterParams)
end

function GameStateMachine:draw()
end

function GameStateMachine:update(dt)
end

function GameStateMachine:enter()
end

function GameStateMachine:exit()
end

