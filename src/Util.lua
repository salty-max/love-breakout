--[[
    UTILITY FUNCTIONS
    CS50G Project 3
    Breakout
    Author: Maxime Blanc
    https://github.com/salty-max
--]]

--[[
    Given an "atlas" (a spritesheet), as well as a
    width and a height for the tiles therein, split the texture into
    all of the quas by dividing it evenly.
--]]
function GenerateQuads(atlas, tileWidth, tileHeight)
    local sheetWidth = atlas:getWidth() / tileWidth
    local sheetHeight = atlas:getHeight() / tileHeight

    local sheetCounter = 1
    local spritesheet = {}

    for y = 0, sheetHeight - 1 do
        for x = 0, sheetWidth - 1 do
            -- generate a new quad or store it in the spritesheet
            spritesheet[sheetCounter] = love.graphics.newQuad(
                x * tileWidth,
                y * tileHeight,
                tileWidth, tileHeight,
                atlas:getDimensions()
            )

            -- increment next index
            sheetCounter = sheetCounter + 1
        end
    end

    return spritesheet
end

--[[
    Utility function for slicing tables, a la Python.
--]]
function table.slice(tbl, first, last, step)
    local sliced = {}

    for i = first or 1, last or #tbl, step or 1 do
        sliced[#sliced+1] = tbl[i]
    end

    return sliced
end

--[[
    This function is specifically made to piece out the paddles from the
    sprite sheet. It has to be done a bit more manually, since they are
    all different sizes.
--]]
function GenerateQuadsPaddles(atlas)
    local x = 0
    local y = 64

    local counter = 1
    local quads = {}
    for i = 0, 3 do
        -- smallest
        quads[counter] = love.graphics.newQuad(x, y, 32, 16, atlas:getDimensions())
        counter = counter + 1
        -- medium
        quads[counter] = love.graphics.newQuad(x + 32, y, 64, 16, atlas:getDimensions())
        counter = counter + 1
        -- large
        quads[counter] = love.graphics.newQuad(x + 96, y, 96, 16, atlas:getDimensions())
        counter = counter + 1
        -- huge
        quads[counter] = love.graphics.newQuad(x, y + 16, 128, 16, atlas:getDimensions())
        counter = counter + 1

        -- prepare X and Y for the next set of paddles
        x = 0
        y = y + 32
    end

    return quads
end

--[[
    This function is specifically made to piece out the balls from the
    sprite sheet. It has to be done a bit more manually, since they are
    in an akward part of the sheet and small.
--]]
function GenerateQuadsBalls(atlas)
    local x = 96
    local y = 48

    local counter = 1
    local quads = {}

    for i = 0, 3 do
        quads[counter] = love.graphics.newQuad(x, y, 8, 8, atlas:getDimensions())
        x = x + 8
        counter = counter + 1
    end

    x = 96
    y = 56

    for i = 0, 2 do
        quads[counter] = love.graphics.newQuad(x, y, 8, 8, atlas:getDimensions())
        x = x + 8
        counter = counter + 1
    end

    return quads
end