--[[
    LEVEL MAKER CLASS
    CS50G Project 3
    Breakout
    Author: Maxime Blanc
    https://github.com/salty-max
--]]

-- global patterns (used to make certain shapes with the bricks)
NONE = 1
SINGLE_PYRAMID = 2
MULTI_PYRAMID = 3

-- per-row patterns
SOLID = 1       -- all colors are the same
ALTERNATE = 2   -- alternate colors
SKIP = 3        -- skip every other block
NONE = 4        -- no bricks on this row

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
    -- randomly choose the number of columns, ensuring odd
    local numCols = math.random(7, 13)
    numCols = numCols % 2 == 0 and (numCols + 1) or numCols

    -- highest possible spawned brick tier in this level
    -- don't go above 3
    local highestTier = math.min(3, math.floor(level / 5))

    -- highest color of the highest tier
    local highestColor = math.min(5, level % 5 + 3)

    -- lay out bricks such that thet touch each other and fill the screen
    for y = 1, numRows do
        --whether skipping is enable for this row
        local skipPattern = math.random(1, 2) == 1 and true or false
        --whether alternating colors is enable for this row
        local alternatePattern = math.random(1, 2) == 1 and true or false

        --choose two colors to alternate between
        local alternateColor1 = math.random(1, highestColor)
        local alternateColor2 = math.random(1, highestColor)
        local alternateTier1 = math.random(0, highestTier)
        local alternateTier2 = math.random(0, highestTier)

        -- used only for skipping a brick
        local skipFlag = math.random(2) == 1 and true or false
        -- used only for alternating a brick
        local alternateFlag = math.random(2) == 1 and true or false
        -- use only for locked bricks
        local lockedFlag = math.random(2) == 1 and true or false

        -- solid color used of not alternatig
        local solidColor = math.random(1, highestColor)
        local solidTier = math.random(1, highestTier)

        for x = 1, numCols do
            -- if skipping is enabled and it's on a skip iteration
            if skipPattern and skipFlag then
                -- turn skipping off for the next iteration
                skipFlag = not skipFlag

                -- Lua doesn't have a continue statement, so a workaround is used
                goto continue
            else
                -- flip the flag to true on an iteration it is not used
                skipFlag = not skipFlag
            end

            b = Brick(
                -- x-coordinate
                (x - 1)                     -- decrement x by 1 because tables are 1-indexed, coords are 0
                * 32                        -- multiply by 32, the brick width
                + 8                         -- screen padding, can fit at max 13 columns + 16px of padding
                + (13 - numCols) * 16,      -- left-side padding for when there are fewer than 13 columns

                -- y-coordinate
                y * 16                      -- just use y * 16, since screen has to have padding top
            )

            -- if alternating is enabled, figure out which color/tier is up
            if alternatePattern and alternateFlag then
                b.color = alternateColor1
                b.tier = alternateTier1
                alternateFlag = not alternateFlag
            else
                b.color = alternateColor2
                b.tier = alternateTier2
                alternateFlag = not alternateFlag
            end

            -- if not alternating, use solid color
            if not alternatePattern then
                b.color = solidColor
                b.tier = solidTier
            end

            -- the brick is a locked brick at random
            if math.random(1, 20) == 1 then
                b.color = 6
                b.tier = 1
            end

            table.insert(bricks, b)

            -- Lua's version of the 'continue' statement
            ::continue::
        end
    end

    -- in the event we didn't generate any bricks, try again
    if #bricks == 0 then
        return LevelMaker.createMap(level)
    else
        return bricks
    end
end