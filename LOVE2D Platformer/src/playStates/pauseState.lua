PauseState = GameStateMachine:extend()

----------------------------------------------------------------------------------

function PauseState:new()
    Log:debug("PauseState created!")
    self.events = {}
    self:setupInputEvents()
end

----------------------------------------------------------------------------------

function PauseState:update(dt)
    EventDispatcher:update()
end

----------------------------------------------------------------------------------

function PauseState:enter()
    self:enableEvents()
    Log:debug("PauseState initialize!")
end

----------------------------------------------------------------------------------

function PauseState:exit()
    self:disableEvents()
    Log:debug("PauseState destroyed!")
end

----------------------------------------------------------------------------------

function PauseState:draw()
end

----------------------------------------------------------------------------------
--- HANDLE EVENTS ----------------------------------------------------------------
----------------------------------------------------------------------------------
function PauseState:setupInputEvents()
    Log:debug("Setting up events on PauseState")
    self.events.changeStartState = self:addEvent( {Key.e }, function(context, input)
        CurrentState:change("play")
    end, POLL_TYPE.JUST_PRESSED)
end

----------------------------------------------------------------------------------
