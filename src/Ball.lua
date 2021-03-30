--[[
    BALL CLASS
    CS50G Project 3
    Breakout
    Author: Maxime Blanc
    https://github.com/salty-max
--]]

Ball = Class{}

function Ball:init(skin)
  -- positional and dimensional variables
  self.width = 8
  self.height = 8

  -- velocity
  self.dx = 0
  self.dy = 0

  -- color index of the ball, to be used to get
  -- the correct sprite in the quads
  self.skin = skin
end

--[[
  AABB collision detection with another bounding box
  passed as a parameter.
]]
function Ball:collides(target)
  if self.x > target.x + target.width or target.x > self.x + self.width then
    return false
  end

  if self.y > target.y + target.height or target.y > self.y + self.height then
    return false
  end

  return true
end

--[[
  Places the ball in the middle of the screen, with no movement.
--]]
function Ball:reset()
  self.x = VIRTUAL_WIDTH / 2 - self.width / 2
  self.y = VIRTUAL_HEIGHT / 2 - self.height / 2
  self.dx = 0
  self.dy = 0
end

function Ball:update(dt)
  self.x = self.x + self.dx * dt
  self.y = self.y + self.dy * dt

  -- allow ball to bounce off edges, except for the bottom one 
  if self.x <= 0 then
    self.x = 0
    self.dx = -self.dx
    gSounds['wall-hit']:play()
  end
  
  if self.x >= VIRTUAL_WIDTH - self.width then
    self.x = VIRTUAL_WIDTH - self.width
    self.dx = -self.dx
    gSounds['wall-hit']:play()
  end

  if self.y <= 0 then
    self.y = 0
    self.dy = -self.dy
    gSounds['wall-hit']:play()
  end
end

function Ball:render()
  love.graphics.draw(gTextures['main'], gFrames['balls'][self.skin], self.x, self.y)
end