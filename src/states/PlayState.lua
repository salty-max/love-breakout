--[[
    PLAY STATE CLASS
    CS50G Project 2
    Breakout
    Author: Maxime Blanc
    https://github.com/salty-max
--]]

-- extends BaseState
PlayState = Class{__includes = BaseState}

function PlayState:enter(params)
    -- get game state from serve state
    self.paddle = params.paddle
    self.balls = params.balls
    self.bricks = params.bricks
    self.health = params.health
    self.score = params.score
    self.level = params.level
    self.highScores = params.highScores
    self.recoverPoints = params.recoverPoints
    self.playerHasKey = params.playerHasKey

    self.powerUpSpawnTimer = 0
    self.powerups = {}

    for k, ball in pairs(self.balls) do
        -- give ball random starting velocity
        ball.dx = math.random(-200, 200)
        ball.dy = math.random(-50, -60)
    end
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

    -- spawn a random powerup every given time
    self.powerUpSpawnTimer = self.powerUpSpawnTimer + dt
    if self.powerUpSpawnTimer > POWERUP_SPAWN_INTERVAL then
        local powerup = PowerUp(math.random(0, VIRTUAL_WIDTH - 16), -16)
        powerup.type = math.random(9, 10)
        table.insert(self.powerups, powerup)
        self.powerUpSpawnTimer = 0
    end

    -- update positions based on dt
    self.paddle:update(dt)

    for k, pup in pairs(self.powerups) do
        pup:update(dt)

        if pup:collides(self.paddle) then
            -- multiball
            if pup.type == 9 then
                -- spawn two balls on paddle
                for i = 0, 1 do
                    local ball = Ball()
                    ball.skin = math.random(7)
                    ball.x = self.paddle.x + self.paddle.width / 2 - ball.width / 2
                    ball.y = self.paddle.y - ball.height
                    ball.dx = math.random(-200, 200)
                    ball.dy = math.random(-50, -60)
                    table.insert(self.balls, ball)
                end
            -- key
            elseif pup.type == 10 then
                self.playerHasKey = true
            end

            gSounds['powerup']:stop()
            gSounds['powerup']:play()

            -- remove powerup from game to avoid multiple activations
            table.remove(self.powerups, k)
        end
    end
    
    for k, ball in pairs(self.balls) do
        ball:update(dt)

        -- detect collision between ball and paddle
        if ball:collides(self.paddle) then
            -- raise ball above paddle to avoid infinite collision
            ball.y = self.paddle.y - 8
            -- reverse ball Y velocity
            ball.dy = -ball.dy

            --
            -- tweak angle of bounce based on where it hits the paddle
            --

            -- if it hits the paddle on its left side while moving left...
            if ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
                ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - ball.x))
            -- else if it hits the paddle on its right side while moving right...
            elseif ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
                ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - ball.x))
            end

            gSounds['paddle-hit']:play()
        end

        -- detect collision across all bricks with the ball
        for l, brick in pairs(self.bricks) do
            -- update particle system for this brick
            brick:update(dt)
            -- only check for bricks in play
            if brick.inPlay and ball:collides(brick) then
                -- if brick is locked
                if brick.color == 6 and brick.tier == 1 then
                    if self.playerHasKey then
                         -- add to score + bonus locked brick
                        self.score = self.score + (brick.color * BASE_SCORE_PER_TIER)
                        
                        -- unlock it
                        brick:hit()
                        self.playerHasKey = false
                    else
                        gSounds['locked']:play()
                    end
                else
                    -- add to score
                    self.score = self.score + (brick.tier * BASE_SCORE_PER_TIER + brick.color * BASE_SCORE_PER_COLOR)

                    brick:hit()
                end

                -- recover health and expand paddle if enough points
                if self.score > self.recoverPoints then
                    self.health = math.min(MAX_HEALTH, self.health + 1)
                    if self.paddle.size < 4 then
                        self.paddle.size = self.paddle.size + 1
                    end
                    -- multiply threshold by 2
                    self.recoverPoints = math.min(100000, self.recoverPoints * 2)

                    gSounds['recover']:play()
                end

                -- go to victory screen if there are no more bricks left
                if self:checkVictory() then
                    gSounds['victory']:play()

                    gStateMachine:change('victory', {
                        level = self.level,
                        paddle = self.paddle,
                        health = self.health,
                        score = self.score,
                        balls = self.balls,
                        highScores = self.highScores,
                        recoverPoints = self.recoverPoints,
                        playerHasKey = self.playerHasKey
                    })
                end

                --
                -- brick collision code
                --
                -- check to see of the opposite side of the ball velocity is outside the brick
                -- if it is, trigger a collision on that side. else check to see if the top or
                -- bottom edge is outside the brick, colliding on top or bottom accordingly
                --

                -- left edge: only check if moving right
                if ball.x + 2 < brick.x and ball.dx > 0 then
                    -- flip x velocity and reset position outside the brick
                    ball.dx = -ball.dx
                    ball.x = brick.x - ball.width
                -- right edge; only check if moving left
                elseif ball.x + 6 > brick.x + brick.width and ball.dx < 0 then
                    -- flip x velocity and reset position outside the brick
                    ball.dx = -ball.dx
                    ball.x = brick.x + brick.width
                -- top edge if no X collisions; always check
                elseif ball.y < brick.y then
                    -- flip y velocity and reset position outside the brick
                    ball.dy = -ball.dy
                    ball.y = brick.y - ball.height
                -- bottom edge; if none of the above; always check
                else
                    ball.dy = -ball.dy
                    ball.y = brick.y + brick.height
                end

                -- slightly scale the y velocity to speed up the game
                ball.dy = ball.dy * 1.02

                -- only allow collision with one brick, for corners
                break
            end
        end

        -- if ball goes below bottom edge, if only one ball revert to serve state and decrease health
        if ball.y >= VIRTUAL_HEIGHT + ball.height then
            if #self.balls > 1 then
                table.remove(self.balls, k)
            else
                -- shrink paddle
                if self.paddle.size > 1 then
                    self.paddle.size = self.paddle.size - 1
                end
                self.health = self.health - 1
                gSounds['hurt']:play()

                if self.health == 0 then
                    gStateMachine:change('game-over', {
                        score = self.score,
                        highScores = self.highScores
                    })
                else
                    gStateMachine:change('serve', {
                        paddle = self.paddle,
                        bricks = self.bricks,
                        health = self.health,
                        score = self.score,
                        level = self.level,
                        highScores = self.highScores,
                        recoverPoints = self.recoverPoints,
                        playerhasKey = self.playerHasKey
                    })
                end
            end
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
    for k, ball in pairs(self.balls) do
        ball:render()
    end

    for k, pup in pairs(self.powerups) do
        pup:render()
    end

    renderHealth(self.health)
    renderScore(self.score)
    renderLevel(self.level)
    if self.playerHasKey then
        renderKey()
    end

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf('PAUSE', 0, VIRTUAL_HEIGHT / 3, VIRTUAL_WIDTH, 'center')
    end
end

function PlayState:checkVictory()
    for k, brick in pairs(self.bricks) do
        if brick.inPlay then
            return false
        end
    end

    return true
end