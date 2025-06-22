-- Settings
DEBUG = false
FIXED_DT = 1 / 60

-- Window
CELL_SIZE = 16
WINDOW_WIDTH   = 1280
WINDOW_HEIGHT  = 720
VIRTUAL_WIDTH  = 1280
VIRTUAL_HEIGHT = 720

-- Sprites
LVL_LAYER_WORLD = "World"
LVL_LAYER_BG = "Background"
LVL_LAYER_COLLISIONS = "Ground"
LVL_LAYER_KILLZONE = "Killzone"

-- Physics
GRAVITY = 9.8
-- Camera
CAM_ZOOM = 4

-- Poll type constants
POLL_TYPE = {
    JUST_PRESSED = "justPressed",
    JUST_RELEASED = "justReleased",
    IS_HELD = "isHeld",
}

GAME_STATES = {
    START = "start",
    PAUSE = "pause",
    PLAY  = "play",
}

-- TODO: MOVE TO INPUT KEYS CLASS
KEYBOARD = "keyboard"
GAMEPAD  = "gamepad"
GAMEPAD_AXIS  = "gamepad_axis"
AXIS = {
    LEFT_X = "leftx",
    LEFT_Y = "lefty",
    RIGHT_X = "rightx",
    RIGHT_Y = "righty",
    TRIGGER_LEFT = "triggerleft",
    TRIGGER_RIGHT = "triggerright"
}

INPUT_TYPE = "inputType"
JOYSTICK_ID = "joystickID"

Key = {}
Key.left   = "left"
Key.right  = "right"
Key.up     = "up"
Key.enter  = "return"
Key.down   = "down"
Key.space  = "space"
Key.escape = "escape"
Key.w = "w"
Key.a = "a"
Key.s = "s"
Key.d = "d"
Key.q = "q"
Key.e = "e"

Button = {}
Button.dpup = "dpup"
Button.dpdown = "dpdown"
Button.dpleft = "dpleft"
Button.dpright = "dpright"
Button.a_btn = "a"
Button.b_btn = "b"
Button.x_btn = "x"
Button.y_btn = "y"
Button.leftstick = "leftstick"
Button.rightstick = "rightstick"
Button.lefttrigger = "lefttrigger"  -- also available as axes
Button.righttrigger = "righttrigger"-- also available as axes
Button.leftshoulder = "leftshoulder"
Button.rightshoulder = "rightshoulder"
Button.start = "start"
Button.back = "back"
Button.guide = "guide"
