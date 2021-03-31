--[[
    PLAY STATE CLASS
    CS50G Project 3
    Breakout
    Author: Maxime Blanc
    https://github.com/salty-max
--]]

-- extends BaseState
PlayState = Class{__includes = BaseState}

function PlayState:init()
    self.paddle = Paddle()

    -- initialize ball with skin #1
    self.ball = Ball(1)

    -- position the ball in the center
    self.ball.x = VIRTUAL_WIDTH / 2 - self.ball.width
    self.ball.y = VIRTUAL_HEIGHT - 42

    -- give ball random starting velocity
    self.ball.dx = math.random(-200, 200)
    self.ball.dy = math.random(-50, -60)

    -- use the static createMap function to generate a brick layout
    self.bricks = LevelMaker.createMap()
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        return
    end

    -- update positions based on dt
    self.paddle:update(dt)
    self.ball:update(dt)

    -- detect collision between ball and paddle
    if self.ball:collides(self.paddle) then
        -- reverse ball Y velocity
        self.ball.dy = -self.ball.dy
        gSounds['paddle-hit']:play()
    end

    -- detect collision across all bricks with the ball
    for k, brick in pairs(self.bricks) do
        -- only check for bricks in play
        if brick.inPlay and self.ball:collides(brick) then
            brick:hit()
        end
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    -- render bricks
    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    self.paddle:render()
    self.ball:render()

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf('PAUSE', 0, VIRTUAL_HEIGHT / 3, VIRTUAL_WIDTH, 'center')
    end
end