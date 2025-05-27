-- Log levels
LogLevel = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4,
    FATAL = 5
}

-- Logger class
Logger = Class:extend()

function Logger:new()
    self.level = LogLevel.INFO  -- Default log level
    self.enableTimestamp = true -- Enable timestamps by default
    self.logToFile = false      -- Log to file
    self.logFile = nil          -- File handle
    self.logFileName = "game.log"

    -- Log level configurations
    self.levelConfig = {
        [LogLevel.DEBUG] = {
            name = "DEBUG",
            prefix = "[DEBUG]"
        },
        [LogLevel.INFO] = {
            name = "INFO",
            prefix = "[INFO] "
        },
        [LogLevel.WARN] = {
            name = "WARN",
            prefix = "[WARN] "
        },
        [LogLevel.ERROR] = {
            name = "ERROR",
            prefix = "[ERROR]"
        },
        [LogLevel.FATAL] = {
            name = "FATAL",
            prefix = "[FATAL]"
        }
    }
end

function Logger:setLevel(level)
    self.level = level
end

function Logger:enableFileLogging(filename)
    self.logToFile = true
    if filename then
        self.logFileName = filename
    end
    -- Open log file
    if self.logToFile then
        self.logFile = love.filesystem.newFile(self.logFileName)
        self.logFile:open("a") -- Append mode
    end
end

function Logger:disableFileLogging()
    self.logToFile = false
    if self.logFile then
        self.logFile:close()
        self.logFile = nil
    end
end

function Logger:setTimestamp(enabled)
    self.enableTimestamp = enabled
end

function Logger:formatMessage(level, message, ...)
    local config = self.levelConfig[level]
    if not config then
        config = self.levelConfig[LogLevel.INFO]
    end

    -- Format message with arguments
    local formattedMessage = string.format(message, ...)

    -- Build the log entry
    local parts = {}

    -- Add timestamp
    if self.enableTimestamp then
        table.insert(parts, os.date("[%H:%M:%S]"))
    end

    -- Add level prefix
    table.insert(parts, config.prefix)

    -- Add message
    table.insert(parts, formattedMessage)

    return table.concat(parts, " ")
end

function Logger:log(level, message, ...)
    -- Check if this level should be logged
    if level < self.level then
        return
    end

    local formattedMessage = self:formatMessage(level, message, ...)

    -- Print to console
    print(formattedMessage)

    -- Write to file if enabled
    if self.logToFile and self.logFile then
        self.logFile:write(formattedMessage .. "\n")
        self.logFile:flush()
    end
end

-- Convenience methods
function Logger:debug(message, ...)
    self:log(LogLevel.DEBUG, message, ...)
end

function Logger:info(message, ...)
    self:log(LogLevel.INFO, message, ...)
end

function Logger:warn(message, ...)
    self:log(LogLevel.WARN, message, ...)
end

function Logger:error(message, ...)
    self:log(LogLevel.ERROR, message, ...)
end

function Logger:fatal(message, ...)
    self:log(LogLevel.FATAL, message, ...)
end

-- Special formatting methods
function Logger:success(message, ...)
    print("[SUCCESS] " .. string.format(message, ...))

    if self.logToFile and self.logFile then
        local plainMessage = "[SUCCESS] " .. string.format(message, ...)
        if self.enableTimestamp then
            plainMessage = os.date("[%H:%M:%S]") .. " " .. plainMessage
        end
        self.logFile:write(plainMessage .. "\n")
        self.logFile:flush()
    end
end

-- Pretty print tables (useful for debugging)
function Logger:table(tbl, name)
    if type(tbl) ~= "table" then
        self:debug("Not a table: %s = %s", name or "value", tostring(tbl))
        return
    end

    local function tableToString(t, indent)
        indent = indent or 0
        local spacing = string.rep("  ", indent)
        local result = "{\n"

        for k, v in pairs(t) do
            result = result .. spacing .. "  "

            -- Format key
            if type(k) == "string" then
                result = result .. k .. " = "
            else
                result = result .. "[" .. tostring(k) .. "] = "
            end

            -- Format value
            if type(v) == "table" then
                result = result .. tableToString(v, indent + 1)
            elseif type(v) == "string" then
                result = result .. '"' .. v .. '"'
            else
                result = result .. tostring(v)
            end

            result = result .. ",\n"
        end

        result = result .. spacing .. "}"
        return result
    end

    local tableName = name and (name .. " = ") or ""
    self:debug("%s%s", tableName, tableToString(tbl))
end

-- Performance logging
function Logger:benchmark(name, func)
    local startTime = love.timer.getTime()
    local result = func()
    local endTime = love.timer.getTime()
    local duration = (endTime - startTime) * 1000 -- Convert to milliseconds

    self:info("Benchmark [%s]: %.2fms", name, duration)
    return result
end


-- Usage examples:
--[[
-- Basic usage
logger:info("Game started successfully!")
logger:warn("Low health: %d", player.health)
logger:error("Failed to load texture: %s", filename)

-- Using global functions
info("Player position: %.2f, %.2f", player.x, player.y)
warn("Enemy count is high: %d", #enemies)
error("Invalid game state: %s", currentState)

-- Configuration
logger:setLevel(LogLevel.DEBUG)  -- Show all messages
logger:enableFileLogging("my_game.log")  -- Log to file

-- Special formatting
logger:success("Level completed!")
logger:highlight("BOSS FIGHT!")

-- Debug tables
logger:table(player, "player")
logger:table({x = 10, y = 20, items = {"sword", "potion"}}, "inventory")

-- Performance benchmarking
local result = logger:benchmark("Level loading", function()
    -- Your expensive operation here
    love.timer.sleep(0.1)
    return "level_data"
end)
--]]