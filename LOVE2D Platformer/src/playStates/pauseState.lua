PauseState = GameStateMachine:extend()

----------------------------------------------------------------------------------

function PauseState:new()
    Log:debug("PauseState created!")
end


----------------------------------------------------------------------------------

function PauseState:enter()
    self:setupInputEvents()
    StateMachine:enableEvents()
    Log:debug("PauseState initialize!")
end

----------------------------------------------------------------------------------

function PauseState:exit()
    StateMachine:disableEvents()
    Log:debug("PauseState destroyed!")
end

----------------------------------------------------------------------------------

function PauseState:update(dt)
    EventDispatcher:update()
end

----------------------------------------------------------------------------------

function PauseState:draw()
end

----------------------------------------------------------------------------------
--- HANDLE EVENTS ----------------------------------------------------------------
----------------------------------------------------------------------------------
function PauseState:setupInputEvents()
    Log:debug("Setting up events on PauseState")

    StateMachine:addEvent( { Key.e }, 
                function() StateMachine:change(GAME_STATES.PLAY) end, 
                POLL_TYPE.JUST_PRESSED)
end

----------------------------------------------------------------------------------
