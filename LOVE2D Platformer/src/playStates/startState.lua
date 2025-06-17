StartState = GameStateMachine:extend()

----------------------------------------------------------------------------------

function StartState:new()
    Log:debug("StartState created!")
    self:setupInputEvents()
end

----------------------------------------------------------------------------------

function StartState:draw()
end

----------------------------------------------------------------------------------

function StartState:update(dt)
    EventDispatcher:update()
end

----------------------------------------------------------------------------------

function StartState:enter()
    self:enableEvents()
    Log:debug("StartState initialize!")
end

----------------------------------------------------------------------------------

function StartState:exit()
    self:disableEvents()
    Log:debug("StartState destroyed!")
end

----------------------------------------------------------------------------------
--- HANDLE EVENTS ----------------------------------------------------------------
----------------------------------------------------------------------------------
function StartState:setupInputEvents()
    Log:debug("Setting up events on PauseState")
end

----------------------------------------------------------------------------------
