PlayState = GameStateMachine:extend()

----------------------------------------------------------------------------------

function PlayState:new()
    Log:debug("PlayState created!")
    self.events = {}
    self:setupInputEvents()

    self.accumulator = 0
    self.fixedDeltaTime = FIXED_DT
end

----------------------------------------------------------------------------------

function PlayState:enter()
    self:enableEvents()

    Log:debug("PlayState initialize!")
    -- Handle global
    -- Level1:init()
    Player:init()

    local posY =  Level1.tileMap.height * Level1.tileMap.tileheight - love.graphics.getHeight()/2
    Player.trans.posY = posY

    Camera:setTarget(Player.entity)
end

----------------------------------------------------------------------------------

function PlayState:exit()
    Log:debug("PlayState destroyed!")
    -- Handle global
    -- Level1:exit()
    -- Player:exit()
    self:disableEvents()
end

----------------------------------------------------------------------------------

function PlayState:update(dt)
    -- Fixed camera update and player animations, for decouple render updates from framerate
    self.accumulator = self.accumulator + dt
    while self.accumulator >= self.fixedDeltaTime do
        Camera:update(Player)
        Player:update(self.fixedDeltaTime)
        self.accumulator = self.accumulator - self.fixedDeltaTime
    end

    EventDispatcher:update()
end

----------------------------------------------------------------------------------

function PlayState:draw()
    Camera:draw(Level1, Player)

    -- Draw HUD or DebugSystem
    -- love.graphics.print("FPS: "..tostring(love.timer.getFPS()).." -- State: "..Player.state)
    love.graphics.print("Floor: "..tostring(Player.entity.movement.onFloor).." -- "..
                        "Wall: "..tostring(Player.entity.movement.onWall).." -- "..
                        "FrameRate: "..love.timer.getFPS())
end

----------------------------------------------------------------------------------
--- HANDLE EVENTS ----------------------------------------------------------------
----------------------------------------------------------------------------------
-- Handle Events for this GameState--
function PlayState:setupInputEvents()
    Log:debug("Setting up events on PlayState")
    -- Movement events - these use the game state context to access the player
    self.events.left = self:addKeyboardEvent('left', function(context, input)
            Player:moveLeft(love.timer.getDelta())
    end, POLL_TYPE.IS_HELD)

    self.events.right = self:addKeyboardEvent('right', function(context, input)
            Player:moveRight(love.timer.getDelta())
    end, POLL_TYPE.IS_HELD)

    self.events.idleLeft = self:addKeyboardEvent('left', function(context, input)
            Player:idle()
    end, POLL_TYPE.JUST_RELEASED)

    self.events.idleRight = self:addKeyboardEvent('right', function(context, input)
            Player:idle()
    end, POLL_TYPE.JUST_RELEASED)

    self.events.jump = self:addKeyboardEvent('space', function(context, input)
            Player:moveJump(love.timer.getDelta())
    end, POLL_TYPE.JUST_PRESSED)

    self.events.jump = self:addKeyboardEvent('space', function(context, input)
            Player:releaseJump()
    end, POLL_TYPE.JUST_RELEASED)

    self.events.quit = self:addKeyboardEvent('escape', function(context, input)
            love.event.quit()
    end, POLL_TYPE.IS_HELD)

    self.events.changeStartState = self:addKeyboardEvent("q", function(context, input)
        context:changeToPauseState()
    end, POLL_TYPE.JUST_PRESSED)
end

----------------------------------------------------------------------------------

function PlayState:changeToPauseState()
    CurrentState:change("pause")
end

----------------------------------------------------------------------------------
