--[[
    Tic Tac Toe

    Author: Colton Ogden
    cogden@cs50.harvard.edu
]]

-- libraries
local push = require 'lib/push'

-- constants
VIRTUAL_WIDTH = 256
VIRTUAL_HEIGHT = 144

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

GRID_HEIGHT, GRID_WIDTH = 3, 3
GRID_TILE_SIZE = 40

SPRITE_PADDING = 4

-- assets
local xSprite = love.graphics.newImage('graphics/x.png')
local oSprite = love.graphics.newImage('graphics/o.png')

local retroFont = love.graphics.newFont('fonts/pressstart.ttf', 8)

-- data structures
local grid = {
    {"", "", ""},
    {"", "", ""},
    {"", "", ""}
}

local currentPlayer = 1
local selectedX, selectedY = 1, 1
local winningPlayer = 0
local gameOver = false

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.graphics.setFont(retroFont)

    love.window.setTitle('TicTacToe50')

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        vsync = true,
        resizable = true
    })
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    if not gameOver then
        if key == 'left' then
            if selectedX > 1 then
                selectedX = selectedX - 1
            end
        elseif key == 'right' then
            if selectedX < 3 then
                selectedX = selectedX + 1
            end
        elseif key == 'up' then
            if selectedY > 1 then
                selectedY = selectedY - 1
            end
        elseif key == 'down' then
            if selectedY < 3 then
                selectedY = selectedY + 1
            end
        elseif key == 'space' then
            if grid[selectedY][selectedX] == "" then
                if currentPlayer == 1 then
                    grid[selectedY][selectedX] = 'X'
                    currentPlayer = 2
                    checkVictory()
                else
                    grid[selectedY][selectedX] = 'O'
                    currentPlayer = 1
                    checkVictory()
                end
            end
        end
    end
end

function love.draw()
    push:start()
    drawGrid()
    if gameOver then
        love.graphics.print('Player ' .. winningPlayer .. ' wins!', 1, 1)
    else
        love.graphics.print('Player ' .. currentPlayer .. "'s turn", 1, 1)
    end
    push:finish()
end

function drawGrid()
    
    -- calculate margins
    local xMargin = VIRTUAL_WIDTH - (GRID_TILE_SIZE * GRID_WIDTH)
    local yMargin = VIRTUAL_HEIGHT - (GRID_TILE_SIZE * GRID_HEIGHT)

    love.graphics.setLineWidth(2)

    -- draw lines of the grid
    -- vertical lines
    love.graphics.line(xMargin / 2 + GRID_TILE_SIZE, yMargin / 2,
        xMargin / 2 + GRID_TILE_SIZE, VIRTUAL_HEIGHT - yMargin / 2)
    love.graphics.line(VIRTUAL_WIDTH - xMargin / 2 - GRID_TILE_SIZE, yMargin / 2,
        VIRTUAL_WIDTH - xMargin / 2 - GRID_TILE_SIZE, VIRTUAL_HEIGHT - yMargin / 2)

    -- horizontal lines
    love.graphics.line(xMargin / 2, yMargin / 2 + GRID_TILE_SIZE,
        VIRTUAL_WIDTH - xMargin / 2, yMargin / 2 + GRID_TILE_SIZE)
    love.graphics.line(xMargin / 2, VIRTUAL_HEIGHT - yMargin / 2 - GRID_TILE_SIZE,
        VIRTUAL_WIDTH - xMargin / 2, VIRTUAL_HEIGHT - yMargin / 2 - GRID_TILE_SIZE)

    -- draw the sprites within the lines
    for y = 1, GRID_HEIGHT do
        for x = 1, GRID_WIDTH do
            local xOffset = xMargin / 2 + GRID_TILE_SIZE * (x - 1)
            local yOffset = yMargin / 2 + GRID_TILE_SIZE * (y - 1)

            if grid[y][x] == "" then
                -- draw nothing
            elseif grid[y][x] == "X" then
                -- draw X sprite at x * y location
                love.graphics.draw(xSprite, xOffset + SPRITE_PADDING, yOffset + SPRITE_PADDING)
            else
                -- draw O sprite at x * y location
                love.graphics.draw(oSprite, xOffset + SPRITE_PADDING, yOffset + SPRITE_PADDING)
            end

            if x == selectedX and y == selectedY then
                love.graphics.setColor(1, 1, 1, 0.5)
                love.graphics.rectangle('fill', xOffset, yOffset, GRID_TILE_SIZE, GRID_TILE_SIZE)
                love.graphics.setColor(1, 1, 1, 1)
            end
        end
    end
end

function checkVictory()
    checkHorizontals()
    checkVerticals()
    checkDiagonals()
end

function checkHorizontals()
    -- check Y horizontal rows
    for y = 1, GRID_HEIGHT do
        local win = true
        local firstCharacter = grid[y][1]

        if firstCharacter == "" then
            goto continue
        end

        for x = 2, GRID_WIDTH do
            if grid[y][x] ~= firstCharacter then
                goto continue
            end
        end

        gameOver = true
        winningPlayer = firstCharacter == "X" and 1 or 2
        ::continue::
    end
end

function checkVerticals()
    -- check X vertical columns
    for x = 1, GRID_WIDTH do
        local win = true
        local firstCharacter = grid[1][x]

        if firstCharacter == "" then
            goto continue
        end

        for y = 2, GRID_HEIGHT do
            if grid[y][x] ~= firstCharacter then
                goto continue
            end
        end

        gameOver = true
        winningPlayer = firstCharacter == "X" and 1 or 2
        ::continue::
    end
end

function checkDiagonals()
    -- check two diagonal rows
    local firstCharacter = grid[1][1]

    -- from top left to bottom right
    local match = true
    if firstCharacter == "" then
        -- do nothing
    else
        for diagonal = 1, GRID_HEIGHT do
            if grid[diagonal][diagonal] ~= firstCharacter then
                match = false
                break
            end
        end

        if match then
            gameOver = true
            winningPlayer = firstCharacter == "X" and 1 or 2
        end
    end

    -- from bottom left to top right
    local match = true
    firstCharacter = grid[GRID_HEIGHT][1]

    if firstCharacter == "" then
        -- do nothing
    else
        local x, y = 2, 2 
        
        for i = 1, GRID_HEIGHT - 1 do
            if grid[y][x] ~= firstCharacter then
                match = false
                break
            end

            y = y - 1
            x = x + 1
        end

        if match then
            gameOver = true
            winningPlayer = firstCharacter == "X" and 1 or 2
        end
    end
end