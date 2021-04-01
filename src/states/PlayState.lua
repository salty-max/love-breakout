--[[
    PLAY STATE CLASS
    CS50G Project 3
    Breakout
    Author: Maxime Blanc
    https://github.com/salty-max
--]]

-- extends BaseState
PlayState = Class{__includes = BaseState}

function PlayState:enter(params)
    -- get game state from serve state
    self.paddle = params.paddle
    self.ball = params.ball
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.level = params.level

    -- give ball random starting velocity
    self.ball.dx = math.random(-200, 200)
    self.ball.dy = math.random(-50, -60)
end

function PlayState:update(dt)
    if self.paused then
        if love.keyboard.wasPressed('space') then
            self.paused = false
            gSounds['pause']:play()
            gSounds['music']:play()
        else
            return
        end
    elseif love.keyboard.wasPressed('space') then
        self.paused = true
        gSounds['pause']:play()
        gSounds['music']:pause()
        return
    end

    -- update positions based on dt
    self.paddle:update(dt)
    self.ball:update(dt)

    -- detect collision between ball and paddle
    if self.ball:collides(self.paddle) then
        -- raise ball above paddle to avoid infinite collision
        self.ball.y = self.paddle.y - 8
        -- reverse ball Y velocity
        self.ball.dy = -self.ball.dy

        --
        -- tweak angle of bounce based on where it hits the paddle
        --

        -- if it hits the paddle on its left side while moving left...
        if self.ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
            self.ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - self.ball.x))
        -- else if it hits the paddle on its right side while moving right...
        elseif self.ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
            self.ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - self.ball.x))
        end

        gSounds['paddle-hit']:play()
    end

    -- detect collision across all bricks with the ball
    for k, brick in pairs(self.bricks) do
        -- update particle system for this brick
        brick:update(dt)
        -- only check for bricks in play
        if brick.inPlay and self.ball:collides(brick) then
            -- add to score
            self.score = self.score + (brick.tier * BASE_SCORE_PER_TIER + brick.color * BASE_SCORE_PER_COLOR)

            brick:hit()
            --
            -- brick collision code
            --
            -- check to see of the opposite side of the ball velocity is outside the brick
            -- if it is, trigger a collision on that side. else check to see if the top or
            -- bottom edge is outside the brick, colliding on top or bottom accordingly
            --

            -- left edge: only check if moving right
            if self.ball.x + 2 < brick.x and self.ball.dx > 0 then
                -- flip x velocity and reset position outside the brick
                self.ball.dx = -self.ball.dx
                self.ball.x = brick.x - self.ball.width
            -- right edge; only check if moving left
            elseif self.ball.x + 6 > brick.x + brick.width and self.ball.dx < 0 then
                -- flip x velocity and reset position outside the brick
                self.ball.dx = -self.ball.dx
                self.ball.x = brick.x + brick.width
            -- top edge if no X collisions; always check
            elseif self.ball.y < brick.y then
                -- flip y velocity and reset position outside the brick
                self.ball.dy = -self.ball.dy
                self.ball.y = brick.y - self.ball.height
            -- bottom edge; if none of the above; always check
            else
                self.ball.dy = -self.ball.dy
                self.ball.y = brick.y + brick.height
            end

            -- slightly scale the y velocity to speed up the game
            self.ball.dy = self.ball.dy * 1.02

            -- only allow collision with one brick, for corners
            break
        end
    end

    -- if ball goes below bottom edge, revet to serve state and decrease health
    if self.ball.y >= VIRTUAL_HEIGHT + self.ball.height then
        self.health = self.health - 1
        gSounds['hurt']:play()

        if self.health == 0 then
            gStateMachine:change('game-over', {
                score = self.score
            })
        else
            gStateMachine:change('serve', {
                paddle = self.paddle,
                bricks = self.bricks,
                health = self.health,
                score = self.score,
                level = self.level
            })
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
        brick:renderParticles()
    end

    self.paddle:render()
    self.ball:render()

    renderHealth(self.health)
    renderScore(self.score)

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf('PAUSE', 0, VIRTUAL_HEIGHT / 3, VIRTUAL_WIDTH, 'center')
    end
end