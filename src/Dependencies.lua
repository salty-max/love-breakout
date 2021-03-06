--[[
    Library to set virtual resolution
    -- https://github.com/Ulydev/push
--]]
push = require 'lib/push'

--[[
    Library to implement a class system in lua
    -- https://github.com/vrld/hump/blob/master/class.lua
--]]
Class = require 'lib/class'

-- centralized global constants
require 'src/constants'

-- utility functions
require 'src/Util'

-- basic state machine
require 'src/StateMachine'

-- level maker
require 'src/LevelMaker'

-- entities
require 'src/Paddle'
require 'src/Ball'
require 'src/Brick'
require 'src/PowerUp'

-- states
require 'src/states/BaseState'
require 'src/states/StartState'
require 'src/states/HighScoreState'
require 'src/states/PaddleSelectState'
require 'src/states/ServeState'
require 'src/states/PlayState'
require 'src/states/VictoryState'
require 'src/states/GameOverState'
require 'src/states/EnterHighScoreState'