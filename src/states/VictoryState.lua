--[[
    VICTORY STATE CLASS
    CS50G Project 3
    Breakout
    Author: Maxime Blanc
    https://github.com/salty-max
--]]

-- extends BaseState
VictoryState = Class{__includes = BaseState}

function VictoryState:enter(params)
    self.level = params.level
    self.score = params.score
    self.paddle = params.paddle
    self.ball = params.ball
    self.health = params.health
    self.highScores = params.highScores
    self.recoverPoints = params.recoverPoints
end

function VictoryState:update(dt)
    self.paddle:update(dt)

    -- have the ball track the player
    self.ball.x = self.paddle.x + (self.paddle.width / 2) - self.ball.width / 2
    self.ball.y = self.paddle.y - self.ball.height

    -- go to play state if enter is pressed
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('serve', {
            level = self.level + 1,
            score = self.score,
            health = self.health,
            paddle = self.paddle,
            bricks = LevelMaker.createMap(self.level + 1),
            highScores = self.highScores,
            recoverPoints = self.recoverPoints
        })
    end
end

function VictoryState:render()
    self.paddle:render()
    self.ball:render()

    renderHealth(self.health)
    renderScore(self.score)

    -- level complete text
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf(
        'Level ' .. tostring(self.level) .. ' completed!',
        0, VIRTUAL_HEIGHT / 4,
        VIRTUAL_WIDTH, 'center'
    )

    -- instructions text
    love.graphics.setFont(gFonts['medium'])
    love.graphics.printf('Press Enter to serve!', 0, VIRTUAL_HEIGHT / 2, VIRTUAL_WIDTH, 'center')
end