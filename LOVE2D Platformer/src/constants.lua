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

-- Physics
GRAVITY = 9.8
-- Camera
CAM_ZOOM = 4

-- Poll type constants
POLL_TYPE = {
    JUST_PRESSED = "justPressed",
    JUST_RELEASED = "justReleased",
    IS_HELD = "isHeld"
}

-- TODO: MOVE TO INPUT KEYS CLASS
KEYBOARD = "keyboard"
GAMEPAD  = "gamepad"
INPUT_TYPE = "inputType"
JOYSTICK_ID = "joystickID"

Key = {}
Key.left = "left"
Key.right = "right"
Key.up = "up"
Key.space = "space"
Key.w = "w"
Key.a = "a"
Key.s = "s"
Key.d = "d"
Key.q = "q"
Key.e = "e"
Key.escape = "escape"

Button = {}
Button.dpup = "dpup"
Button.dpdown = "dpdown"
Button.dpleft = "dpleft"
Button.dpright = "dpright"
Button.a_btn = "a"
Button.b_btn = "b"
Button.x_btn = "x"
Button.y_btn = "y"

INPUTS = {}
INPUTS.left      =  {INPUT_TYPE = KEYBOARD}
INPUTS.right     =  {INPUT_TYPE = KEYBOARD}
INPUTS.up        =  {INPUT_TYPE = KEYBOARD}
INPUTS.space     =  {INPUT_TYPE = KEYBOARD}
INPUTS.escape    =  {INPUT_TYPE = KEYBOARD}
INPUTS.w         =  {INPUT_TYPE = KEYBOARD}
INPUTS.a         =  {INPUT_TYPE = KEYBOARD}
INPUTS.s         =  {INPUT_TYPE = KEYBOARD}
INPUTS.d         =  {INPUT_TYPE = KEYBOARD}
INPUTS.q         =  {INPUT_TYPE = KEYBOARD}
INPUTS.e         =  {INPUT_TYPE = KEYBOARD}
INPUTS.dpup    =  {INPUT_TYPE = GAMEPAD, JOYSTICK_ID = 1}
INPUTS.dpdown  =  {INPUT_TYPE = GAMEPAD, JOYSTICK_ID = 1}
INPUTS.dpleft  =  {INPUT_TYPE = GAMEPAD, JOYSTICK_ID = 1}
INPUTS.dpright =  {INPUT_TYPE = GAMEPAD, JOYSTICK_ID = 1}
