--[[
    MAIN PROGRAM
    CS50G Project 2
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
        ['bricks'] = love.graphics.newImage('graphics/bricks.png'),
        ['arrows'] = love.graphics.newImage('graphics/arrows.png'),
        ['hearts'] = love.graphics.newImage('graphics/hearts.png'),
        ['particle'] = love.graphics.newImage('graphics/particle.png'),
        ['key'] = love.graphics.newImage('graphics/key.png')
    }

    -- Quads generated for all textures
    gFrames = {
        ['paddles'] = GenerateQuadsPaddles(gTextures['main']),
        ['balls'] = GenerateQuadsBalls(gTextures['main']),
        ['bricks'] = GenerateQuadsBricks(gTextures['bricks']),
        ['powerups'] = GenerateQuadsPowerUps(gTextures['main']),
        ['hearts'] = GenerateQuads(gTextures['hearts'], 10, 9),
        ['arrows'] = GenerateQuads(gTextures['arrows'], 24, 24)
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
        ['locked'] = love.audio.newSource('sounds/locked.wav', 'static'),
        ['powerup'] = love.audio.newSource('sounds/powerup.wav', 'static'),
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
        ['start'] = function() return StartState() end,
        ['high-scores'] = function() return HighScoreState() end,
        ['paddle-select'] = function() return PaddleSelectState() end,
        ['serve'] = function() return ServeState() end,
        ['play'] = function() return PlayState() end,
        ['victory'] = function() return VictoryState() end,
        ['game-over'] = function() return GameOverState() end,
        ['enter-high-score'] = function() return EnterHighScoreState() end
    }
    gStateMachine:change('start', {
        highScores = loadHighScores()
    })

    gSounds['music']:setLooping(true)
    gSounds['music']:play()

    love.audio.setVolume(0.1)

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
    Loads high scores from a .lst file, saved in L??VE2D default save directory
    called 'breakout'
--]]
function loadHighScores()
    love.filesystem.setIdentity('breakout')

    -- if the file doesn't exist, initialize it with some dummy data
    if not love.filesystem.getInfo('breakout.lst') then
        local scores = ''
        for i = 10, 1, -1 do
            scores = scores .. 'DUM \n'
            scores = scores .. tostring(i * 1000) .. '\n'
        end

        love.filesystem.write('breakout.lst', scores)
    end
    -- flag for whether reading a name or not
    local name = true
    local currentName = nil
    local counter = 1

    -- initialize scores table with at least 10 blank entries
    local scores = {}

    for i = 1, 10 do
        -- blank table; each will hold a name and a score
        scores[i] = {
            name = nil,
            score = nil
        }
    end

    -- iterate over each line in the file, filling in names and scores
    for line in love.filesystem.lines('breakout.lst') do
        if name then
            scores[counter].name = string.sub(line, 1, 3)
        else
            scores[counter].score = tonumber(line)
            counter = counter + 1
        end

        -- flip the name flag
        name = not name
    end

    return scores
end

--[[
    Renders hearts based on how much health the player has. First renders
    full hearts and then empty hearts for however much health he's missing
--]]
function renderHealth(health)
    -- start of health rendering
    local healthX = VIRTUAL_WIDTH - 100

    -- render health left
    for i = 1, health do
        love.graphics.draw(gTextures['hearts'], gFrames['hearts'][1], healthX, 5)
        healthX = healthX + 11 -- 11 is heart width + 1 for margin
    end

    --render missing health
    for i = 1, 3 - health do
        love.graphics.draw(gTextures['hearts'], gFrames['hearts'][2], healthX, 5)
        healthX = healthX + 11 -- 11 is heart width + 1 for margin
    end
end

--[[
    Renders the player's score at the top right, with left-side passing
    for the score number.
--]]
function renderScore(score)
    love.graphics.setFont((gFonts['small']))
    love.graphics.print('Score: ', VIRTUAL_WIDTH - 60, 5)
    love.graphics.printf(tostring(score), VIRTUAL_WIDTH - 50, 5, 40, 'right')
end

--[[
    Renders the level the player currently is at the top right.
--]]
function renderLevel(level)
    love.graphics.setFont((gFonts['small']))
    love.graphics.print('Level ', 5, 5)
    love.graphics.print(tostring(level), 30, 5)
end

--[[
    Renders a key if the player has one.
--]]
function renderKey(level)
    love.graphics.draw(gTextures['key'], 40, 5)
end

--[[
    Renders the current FPS.
--]]
function displayFPS()
    love.graphics.setFont(gFonts['small'])
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 5, 20)
end