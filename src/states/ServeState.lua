--[[
    SERVE STATE CLASS
    CS50G Project 2
    Breakout
    Author: Maxime Blanc
    https://github.com/salty-max
--]]

-- extends BaseState
ServeState = Class{__includes = BaseState}

function ServeState:enter(params)
    -- grab game state from params
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.level = params.level
    self.highScores = params.highScores
    self.recoverPoints = params.recoverPoints
    self.playerHasKey = params.playerHasKey

    self.balls = {}

    -- init new ball (random color for fun)
    local ball = Ball()
    ball.skin = math.random(7)
    table.insert(self.balls, ball)
end

function ServeState:update(dt)
    -- have the ball track the paddle
    self.paddle:update(dt)
    for k, ball in pairs(self.balls) do
        ball.x = self.paddle.x + (self.paddle.width / 2) - (ball.width / 2)
        ball.y = self.paddle.y - ball.height
    end

    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        -- pass game state to play state
        gStateMachine:change('play', {
            paddle = self.paddle,
            bricks = self.bricks,
            balls = self.balls,
            health = self.health,
            score = self.score,
            level = self.level,
            highScores = self.highScores,
            recoverPoints = self.recoverPoints,
            playerHasKey = self.playerHasKey
        })
    end

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function ServeState:render()

    self.paddle:render()

    for k, ball in pairs(self.balls) do
        ball:render()
    end

    for k, brick in pairs(self.bricks) do
        brick:render()
    end

    renderScore(self.score)
    renderHealth(self.health)

    love.graphics.setFont(gFonts['large'])
    love.graphics.printf('Level ' .. tostring(self.level), 0, VIRTUAL_HEIGHT / 3,
        VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Press Enter to serve!', 0, VIRTUAL_HEIGHT / 2,
        VIRTUAL_WIDTH, 'center')
end

