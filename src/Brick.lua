--[[
    BRICK CLASS
    CS50G Project 3
    Breakout
    Author: Maxime Blanc
    https://github.com/salty-max
--]]

Brick = Class{}

-- some of the colors in the palette (to be used with particle system)
paletteColors = {
    -- blue
    [1] = {
        ['r'] = 99,
        ['g'] = 155,
        ['b'] = 255
    },
    -- green
    [2] = {
        ['r'] = 106,
        ['g'] = 190,
        ['b'] = 47
    },
    -- red
    [3] = {
        ['r'] = 217,
        ['g'] = 87,
        ['b'] = 99
    },
    -- purple
    [4] = {
        ['r'] = 215,
        ['g'] = 123,
        ['b'] = 186
    },
    -- gold
    [5] = {
        ['r'] = 251,
        ['g'] = 242,
        ['b'] = 54
    }
}

function Brick:init(x, y)
    self.tier = 0
    self.color = 1

    self.x = x
    self.y = y
    self.width = 32
    self.height = 16

    -- used to determine whether this brick should be rendered
    self.inPlay = true

    -- particle system belonging to the brick, emitted on hit
    self.psystem = love.graphics.newParticleSystem(gTextures['particle'], 64)

    -- various behavior-determining methods for the particle system
    -- https://love2d.org/wiki/ParticleSystem

    -- lasts between 0.5-1 second
    self.psystem:setParticleLifetime(0.5, 1)

    -- give it an acceleration of anywhere X1,Y1 and X2,Y2 (0,0) and
    -- gives generally downward
    self.psystem:setLinearAcceleration(-15, 0, 15, 80)

    -- spread of particles; normal looks more natural then uniform
    -- amount of standard deviation away in X and Y axis
    self.psystem:setEmissionArea('normal', 10, 10)
end


--[[
  Triggers a hit on the brick, taking it out of play if at 0 health or
  changing its color otherwise.
--]]
function Brick:hit()
    -- set the particle system to interpolate between two colors; in this case,
    -- given brick color but with varying alpha; brighter for higher tiers, fading to 0
    -- over the particle's lifetime (the second color)
    self.psystem:setColors(
        paletteColors[self.color].r / 255,
        paletteColors[self.color].g / 255,
        paletteColors[self.color].b / 255,
        55 * (self.tier + 1),
        paletteColors[self.color].r / 255,
        paletteColors[self.color].g / 255,
        paletteColors[self.color].b / 255,
        0
    )
    self.psystem:emit(64)

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

function Brick:update(dt)
    self.psystem:update(dt)
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

function Brick:renderParticles()
    love.graphics.draw(self.psystem, self.x + self.width / 2, self.y + self.height / 2)
end