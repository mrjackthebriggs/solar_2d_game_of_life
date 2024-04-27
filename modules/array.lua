local math =require("math")

-- Manages all the functions for generating grids

function generateArray(x,y)
    local retarr = {}

    x = math.round(x)
    y = math.round(y)

    for i = 1, x do
        retarr[i] = {}

        for j = 1, y do
            retarr[i][j] = false
        end
    end

    return retarr
end

function generateRandArray(x,y,density)
    local retarr = generateArray(x,y)

    for i = 1, x do
        for j = 1, y  do
            local ranSw = math.random(31 - density) -- The best nuumber for generating random grids

            if ranSw == 1 then
                retarr[i][j] = true
            end
        end
    end

    return retarr
end

function copyGrid(grid)
    local copy = {}

    for i = 1, #grid  do
        copy[i] = {}
        for j = 1, #grid[1]  do
            if grid[i][j] then
                copy[i][j] = true
            else
                copy[i][j] = false
            end
        end
    end

    return copy
end

