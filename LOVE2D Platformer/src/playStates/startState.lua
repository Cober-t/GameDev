StartState = GameStateMachine:extend()

----------------------------------------------------------------------------------

function StartState:new()
    Log:debug("StartState created!")
    self.highlighted = 2
    self:setupInputEvents()
end

----------------------------------------------------------------------------------

function StartState:enter()
    EventDispatcher:enableEvents()
    Log:debug("StartState initialize!")
end

----------------------------------------------------------------------------------

function StartState:exit()
    EventDispatcher:disableEvents()
    Log:debug("StartState destroyed!")
end

----------------------------------------------------------------------------------

function StartState:update(dt)

end

----------------------------------------------------------------------------------

function StartState:draw()
    local backgroundWidth  = SpriteSheets.background:getWidth()
    local backgroundHeight = SpriteSheets.background:getHeight()

    -- Stretch background to the virtual screen sizes
    -- Coordinates X, Y -- Rotation -- Scale Factor X, Y
    love.graphics.draw(SpriteSheets.background, 0, 0,  0,
            VIRTUAL_WIDTH / (backgroundWidth - 1), VIRTUAL_HEIGHT / (backgroundHeight - 1))

    -- Title
    love.graphics.setFont(Fonts.large)
    love.graphics.printf("BREAKOUT", 0, VIRTUAL_HEIGHT / 3, VIRTUAL_WIDTH, 'center')
    
    -- Instructions
    love.graphics.setFont(Fonts.medium)

    -- if we're highlighting 1, render that option blue
    if self.highlighted == 1 then
        love.graphics.setColor(103/255, 1, 1, 1)
    end
    love.graphics.printf("START", 0, VIRTUAL_HEIGHT / 2 + 70, VIRTUAL_WIDTH, 'center')

    -- reset the color
    love.graphics.setColor(1, 1, 1, 1)

    -- render option 2 blue if we're highlighting that one
    if self.highlighted == 2 then
        love.graphics.setColor(103/255, 1, 1, 1)
    end
    love.graphics.printf("SETTINGS", 0, VIRTUAL_HEIGHT / 2 + 90, VIRTUAL_WIDTH, 'center')

    love.graphics.setColor(1, 1, 1, 1)

    -- render option 2 blue if we're highlighting that one
    if self.highlighted == 3 then
        love.graphics.setColor(103/255, 1, 1, 1)
    end
    love.graphics.printf("QUIT", 0, VIRTUAL_HEIGHT / 2 + 110, VIRTUAL_WIDTH, 'center')

    love.graphics.setColor(1, 1, 1, 1)
end

----------------------------------------------------------------------------------
--- HANDLE EVENTS ----------------------------------------------------------------
----------------------------------------------------------------------------------
function StartState:setupInputEvents()
    Log:debug("Setting up events on StartState")

    -- KEYBOARD --
    EventDispatcher:createEvent( 
            KEYBOARD, { Key.down, Key.right },
            function()  self.highlighted = self.highlighted >= 3 and 1 or self.highlighted + 1 end,
            POLL_TYPE.JUST_PRESSED)
    EventDispatcher:createEvent( 
            KEYBOARD, { Key.up, Key.left },
            function()  self.highlighted = self.highlighted <= 1 and 3 or self.highlighted - 1 end,
            POLL_TYPE.JUST_PRESSED)

    -- GAMEPAD --
    EventDispatcher:createEvent( 
            GAMEPAD, { Button.dpdown, Button.dpright },
            function()  self.highlighted = self.highlighted >= 3 and 1 or self.highlighted + 1 end,
            POLL_TYPE.JUST_PRESSED)
    EventDispatcher:createEvent( 
            GAMEPAD, { Button.dpup, Button.dpleft },
            function()  self.highlighted = self.highlighted <= 1 and 3 or self.highlighted - 1 end,
            POLL_TYPE.JUST_PRESSED)
    
    -- AXIS --
    EventDispatcher:createEvent( 
            GAMEPAD_AXIS, { AXIS.LEFT_Y, AXIS.LEFT_X, AXIS.RIGHT_Y, AXIS.RIGHT_X },
            function() self.highlighted = self.highlighted >= 3 and 1 or self.highlighted + 1 end,
            POLL_TYPE.JUST_PRESSED, 0.8, "positive")
    EventDispatcher:createEvent( 
            GAMEPAD_AXIS, { AXIS.LEFT_Y, AXIS.LEFT_X, AXIS.RIGHT_Y, AXIS.RIGHT_X },
            function() self.highlighted = self.highlighted <= 1 and 3 or self.highlighted - 1 end,
            POLL_TYPE.JUST_PRESSED, 0.8, "negative")
    
    EventDispatcher:createEvent( 
            KEYBOARD, { Key.space, Key.enter },
            function()
                if self.highlighted == 1 then
                    StateMachine:change(GAME_STATES.PLAY)
                elseif self.highlighted == 2 then
                    StateMachine:change(GAME_STATES.PAUSE)
                elseif self.highlighted == 3 then
                    love.event.quit()
                end
            end,
            POLL_TYPE.JUST_PRESSED)

    EventDispatcher:createEvent( 
            GAMEPAD, { Button.a_btn },
            function()
                if self.highlighted == 1 then
                    StateMachine:change(GAME_STATES.PLAY)
                elseif self.highlighted == 2 then
                    StateMachine:change(GAME_STATES.PAUSE)
                elseif self.highlighted == 3 then
                    love.event.quit()
                end
            end,
            POLL_TYPE.JUST_PRESSED)
end

----------------------------------------------------------------------------------
