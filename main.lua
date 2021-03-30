--[[
    MAIN PROGRAM
    CS50G Project 3
    Breakout
    Author: Maxime Blanc
    https://github.com/salty-max
--]]

require 'src/Dependencies'

function love.load()
    -- disable filtering
    love.graphics.setDefaultFilter('nearest', 'nearest')

    -- seed the RNG
    math.randomseed(os.time())

    -- set window title
    love.window.setTitle('Breakout')

    -- initialize fonts
    gFonts = {
        ['small'] = love.graphics.newFont('fonts/font.ttf', 8),
        ['medium'] = love.graphics.newFont('fonts/font.ttf', 16),
        ['large'] = love.graphics.newFont('fonts/font.ttf', 32)
    }
    love.graphics.setFont(gFonts['small'])

    -- load up graphical assets used throughout the game
    gTextures = {
        ['background'] = love.graphics.newImage('graphics/background.png'),
        ['main'] = love.graphics.newImage('graphics/breakout.png'),
        ['arrows'] = love.graphics.newImage('graphics/arrows.png'),
        ['hearts'] = love.graphics.newImage('graphics/hearts.png'),
        ['particle'] = love.graphics.newImage('graphics/particle.png'),
    }

    -- initialize virtual resolution
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = true,
        fullscreen = false,
        resizable = true
    })

    -- set up sound effects
    gSounds = {
        ['paddle-hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall-hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
        ['confirm'] = love.audio.newSource('sounds/confirm.wav', 'static'),
        ['select'] = love.audio.newSource('sounds/select.wav', 'static'),
        ['no-select'] = love.audio.newSource('sounds/no-select.wav', 'static'),
        ['brick-hit-1'] = love.audio.newSource('sounds/brick-hit-1.wav', 'static'),
        ['brick-hit-2'] = love.audio.newSource('sounds/brick-hit-2.wav', 'static'),
        ['hurt'] = love.audio.newSource('sounds/hurt.wav', 'static'),
        ['victory'] = love.audio.newSource('sounds/victory.wav', 'static'),
        ['recover'] = love.audio.newSource('sounds/recover.wav', 'static'),
        ['high-score'] = love.audio.newSource('sounds/high_score.wav', 'static'),
        ['pause'] = love.audio.newSource('sounds/pause.wav', 'static'),
        --
        ['music'] = love.audio.newSource('sounds/music.wav', 'static')
    }

    -- initialize the state machine
    gStateMachine = StateMachine {
        ['start'] = function() return StartState() end
    }
    gStateMachine:change('start')

    -- inputs table to be able to check for inputs globally
    love.keyboard.keysPressed = {}
end

function love.resize(x, y)
    push:resize(x, y)
end

function love.update(dt)
    -- pass dt to the state object
    gStateMachine:update(dt)

    --reset inputs table each frame
    love.keyboard.keysPressed = {}
end

function love.keypressed(key)
    love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.draw()
    -- begin drawing with push
    push:start()

    -- background is drawn regardless of state, scaled to fit
    -- the virtual resolution
    local backgroundWidth = gTextures['background']:getWidth()
    local backgroundHeight = gTextures['background']:getHeight()

    love.graphics.draw(
        gTextures['background'],
        -- draw at origin
        0, 0,
        -- no rotation
        0,
        -- scale factors on X and Y so it fills the screen
        VIRTUAL_WIDTH / (backgroundWidth - 1), VIRTUAL_HEIGHT / (backgroundHeight - 1)
    )

    -- use state machine to defer rendering to the current state
    gStateMachine:render()

    -- display FPS for debugging across all states
    displayFPS()

    push:finish()
end

--[[
    Renders the current FPS
--]]
function displayFPS()
    love.graphics.setFont(gFonts['small'])
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 5, 5)
end