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

    if love.keyboard.wasPressed('escape') then
        love.event.quit()
    end
end

function PlayState:render()
    self.paddle:render()

    -- pause text, if paused
    if self.paused then
        love.graphics.setFont(gFonts['large'])
        love.graphics.printf('PAUSE', 0, VIRTUAL_HEIGHT / 3, VIRTUAL_WIDTH, 'center')
    end
end