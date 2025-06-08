-- Settings
DEBUG = true

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

-- Input keys
KEYBOARD = "keyboard"
GAMEPAD  = "gamepad"

Key = {}
Key.up       = { KEYBOARD="w",      GAMEPAD="dpup"   }
Key.down     = { KEYBOARD="s",      GAMEPAD="dpdown" }
Key.left     = { KEYBOARD="a",      GAMEPAD="dpleft" }
Key.right    = { KEYBOARD="d",      GAMEPAD="dpright"}
Key.jump     = { KEYBOARD="j",      GAMEPAD="x"      }
Key.uiAccept = { KEYBOARD="j",      GAMEPAD="a"      }
Key.uiCancel = { KEYBOARD="escape", GAMEPAD="start"  }
