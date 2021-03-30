--[[
    PADDLE CLASS
    CS50G Project 3
    Breakout
    Author: Maxime Blanc
    https://github.com/salty-max
--]]

Paddle = Class{}

--[[
  The paddle will spawn at the same spot every time, horizontally
  centered, toward the bottom.
--]]
function Paddle:init()
    -- x is placed in the middle of the screen minus the medium paddle width divided by 2
    self.x = VIRTUAL_WIDTH / 2 - 32
    -- y is placed a little above the bottom edge of the screen
    self.y = VIRTUAL_HEIGHT - 32
    -- start with no velovity
    self.dx = 0
    -- starting dimensions
    self.width = 64
    self.height = 16
    -- the skin in only cosmetic, used to offset into the
    -- the gPaddleSkins table later
    self.skin = 1
    -- the variant is which of the four paddle sizes is the current one
    -- 2 (medium) is the starting size because devs are kind people
    self.size = 2
end

function Paddle:update(dt)
    -- keyboard input
    if love.keyboard.isDown('left') then
        self.dx = -PADDLE_SPEED
    elseif love.keyboard.isDown('right') then
        self.dx = PADDLE_SPEED
    else
        self.dx = 0
    end

    -- clamp X so the paddle doesn't go out of bounds
    if self.dx < 0 then
        self.x = math.max(0, self.x + self.dx * dt)
    else
        self.x = math.min(VIRTUAL_WIDTH - self.width, self.x + self.dx * dt)
    end
end

--[[
  Render the paddle by drawing the main texture, passing in the quad
  that corresponds to the proper skin and size.
--]]
function Paddle:render()
    love.graphics.draw(
        gTextures['main'],
        -- shift the index depending on the skin
        gFrames['paddles'][self.size + 4 * (self.skin - 1)],
        self.x, self.y
    )
end