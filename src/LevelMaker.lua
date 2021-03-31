--[[
    LEVEL MAKER CLASS
    CS50G Project 3
    Breakout
    Author: Maxime Blanc
    https://github.com/salty-max
--]]

LevelMaker = Class{}

--[[
  Creates a table of bricks to be returned to the main game, with different
  possible ways of randomizing rows and columns of bricks. Calculates the
  bricks colors and tiers to choose based on the level passed in.
--]]
function LevelMaker.createMap(level)
  local bricks = {}

  -- randomly choose the number of rows
  local numRows = math.random(1, 5)
  -- randomly choose the number of columns
  local numCols = math.random(7, 13)

  -- lay out bricks such that thet touch each other and fill the screen
  for y = 1, numRows do
    for x = 1, numCols do
      b = Brick(
        -- x-coordinate
        (x - 1)                     -- decrement x by 1 because tables are 1-indexed, coords are 0
        * 32                        -- multiply by 32, the brick width
        + 8                         -- screen padding, can fit at max 13 columns + 16px of padding
        + (13 - numCols) * 16,      -- left-side padding for when there are fewer than 13 columns

        -- y-coordinate
        y * 16                      -- just use y * 16, since screen has to have padding top
      )

      table.insert(bricks, b)
    end
  end

  return bricks
end