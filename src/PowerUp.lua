--[[
    POWERUP CLASS
    CS50G Project 2
    Breakout
    Author: Maxime Blanc
    https://github.com/salty-max
--]]

-- powerup types indexes
-- 9 = multiball
-- 10 = key

PowerUp = Class{}

function PowerUp:init(x, y)
  self.type = type
  self.x = x
  self.y = y
  self.width = 16
  self.height = 16

  self.dy = POWERUP_SPEED
end

--[[
  AABB collision detection with another bounding box
  passed as a parameter.
]]
function PowerUp:collides(target)
  if self.x > target.x + target.width or target.x > self.x + self.width then
    return false
  end

  if self.y > target.y + target.height or target.y > self.y + self.height then
    return false
  end

  return true
end

function PowerUp:update(dt)
  self.y = self.y + self.dy * dt
end

function PowerUp:render()
  love.graphics.draw(gTextures['main'], gFrames['powerups'][self.type], self.x, self.y)
end