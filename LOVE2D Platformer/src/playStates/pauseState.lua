PauseState = GameStateMachine:extend()

function PauseState:new()
    Log:info("Pause State created!")
    self.events = {}
end

function PauseState:draw()
end

function PauseState:update(dt)
end

function PauseState:enter()
end

function PauseState:exit()
end
