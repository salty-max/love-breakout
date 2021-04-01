--[[
    CONSTANTS
    CS50G Project 3
    Breakout
    Author: Maxime Blanc
    https://github.com/salty-max
--]]

-- size of actual window
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

-- emulated size
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

-- paddle movement speed
PADDLE_SPEED = 200

-- powerup movement speed
POWERUP_SPEED = 50
POWERUP_SPAWN_INTERVAL = math.random(20, 40)

MAX_HEALTH = 3
BASE_RECOVER_POINTS = 5000
BASE_SCORE_PER_TIER = 200
BASE_SCORE_PER_COLOR = 25