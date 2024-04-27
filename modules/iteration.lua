require("modules.array")

-- checks for neighbours
function check_neigh(grid,x,y)
    -- uses an array to iterate over its neighbours
    local neigh_nums = {{-1,-1},{0,-1},{1,-1},{-1,0},{1,0},{-1,1},{0,1},{1,1}}
    local live_neigh = 0
    local newx = 0
    local newy = 0

    -- for checking overflows with the grid
    for i = 1 , #neigh_nums do
        if x + neigh_nums[i][2] > #grid[1] then
            newx = (x + neigh_nums[i][2]) % #grid[1]
        elseif x + neigh_nums[i][2] < 1 then
            newx = #grid[1] + 1 + neigh_nums[i][2]
        else
            newx = x + neigh_nums[i][2]
        end

        if y + neigh_nums[i][1] > #grid then
            newy = (y + neigh_nums[i][1]) % #grid
        elseif y + neigh_nums[i][1] < 1 then
            newy = #grid + 1 + neigh_nums[i][1]
        else 
            newy = y +  neigh_nums[i][1]
        end

        if grid[newy][newx] then
            live_neigh = live_neigh + 1
        end
    end

    return live_neigh
end

-- iterates the fed in grid and returns the update
-- needs x and y because # didnt work initially
function iterate(grid, ax, ay)
    local new_grid = generateArray(ax, ay)
    
    for y = 1 , #grid do
        for x = 1, #grid[1] do
            local neigh_num = check_neigh(grid, x, y)


            -- rules
            if grid[y][x]==true and neigh_num == 2 then
                new_grid[y][x] = true
            elseif grid[y][x]==true and neigh_num == 3 then
                new_grid[y][x] = true
            elseif grid[y][x] == false and neigh_num == 3 then
                new_grid[y][x] = true
            else 
                new_grid[y][x] = false
            end
        end
    end
    return new_grid 
end