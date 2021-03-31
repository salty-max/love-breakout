--[[
    BRICK CLASS
    CS50G Project 3
    Breakout
    Author: Maxime Blanc
    https://github.com/salty-max
--]]

Brick = Class{}

function Brick:init(x, y)
    self.tier = 0
    self.color = 1

    self.x = x
    self.y = y
    self.width = 32
    self.height = 16

    -- used to determine whether this brick should be rendered
    self.inPlay = true
end


--[[
  Triggers a hit on the brick, taking it out of play if at 0 health or
  changing its color otherwise.
--]]
function Brick:hit()
    -- sound on hit
    gSounds['brick-hit-2']:stop()
    gSounds['brick-hit-2']:play()
    
    -- if brick is at a higher tier than the base, go down a tier
    -- if it is already at the lowest color, go down a color
    if self.tier > 0 then
        if self.color == 1 then
            self.tier = self.tier - 1
            self.color = 5
        else
            self.color = self.color - 1
        end
    else
        -- if brick is at the first tier and the base color, remove it
        if self.color == 1 then
            self.inPlay = false
        else
            self.color = self.color - 1
        end
    end

    -- play a second layer sound if brick is destroyed
    if not self.inPlay then
        gSounds['brick-hit-1']:stop()
        gSounds['brick-hit-1']:play()
    end
end

function Brick:render()
    if self.inPlay then
        love.graphics.draw(
            gTextures['main'],
            -- multiply color by 4 (-1) to get color offset, then add tier
            -- to draw the correct tier and color brick
            gFrames['bricks'][1 + ((self.color - 1) * 4) + self.tier],
            self.x, self.y
        )
    end
end