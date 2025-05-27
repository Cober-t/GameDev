-- Settings
DEBUG = false

-- Window
CELL_SIZE = 16
WINDOW_WIDTH   = 1200
WINDOW_HEIGHT  = 720
VIRTUAL_WIDTH  = 1200
VIRTUAL_HEIGHT = 720

-- Sprites
LVL_LAYER_WORLD = "World"
LVL_LAYER_BG = "Background"
LVL_LAYER_COLLISIONS = "Ground"

-- Physics
GRAVITY = 660
-- Camera
CAM_ZOOM = 4

-- input keys
KEYBOARD = "keyboard"
GAMEPAD  = "gamepad"
Key = {}
Key.up       = { bindings= { KEYBOARD="w",      GAMEPAD="dpup"   } }
Key.down     = { bindings= { KEYBOARD="s",      GAMEPAD="dpdown" } }
Key.left     = { bindings= { KEYBOARD="a",      GAMEPAD="dpleft" } }
Key.right    = { bindings= { KEYBOARD="d",      GAMEPAD="dpright"} }
Key.jump     = { bindings= { KEYBOARD="j",      GAMEPAD="x"      } }
Key.uiAccept = { bindings= { KEYBOARD="j",      GAMEPAD="a"      } }
Key.uiCancel = { bindings= { KEYBOARD="escape", GAMEPAD="start"  } }
