module(...,package.seeall)
require("modules.array")
require("modules.iteration")

-- Array Tests
function testArrayGen1()
    arr = generateArray(100,100)
    assert_equal(#arr,100)
    assert_equal(#arr[1],100)
end

function testArrayGen2()
    arr = generateArray(1,1)
    assert_equal(#arr,1)
    assert_equal(#arr[1],1)
end

function testArrayGen3()
    arr = generateArray(1.1,1.1)
    assert_equal(#arr,1)
    assert_equal(#arr[1],1)
end

function testArrayGen4()
    arr = generateArray(1000.1, 0.9)
    assert_equal(#arr,1000)
    assert_equal(#arr[1],1)
end

function testArrayCopy1()
    arr = generateRandArray(5,5,15)
    newArr = copyGrid(arr)
    assert_not_equal(arr,newArr)
end


-- Iterate Tests
-- uses test grids from the weekly deliverables to ensure iteration doesn't chage during development
function testIteration1()
    arr = {
        {false,false,false,false,false},
        {false,true,false,false,false},
        {false,false,true,false,false},
        {false,false,false,true,false},
        {false,false,false,false,false}
    }

    assert_true(arr[2][2])
    assert_true(arr[3][3])
    assert_true(arr[4][4])

    iterArr = iterate(arr,5,5)

    assert_false(iterArr[2][2])
    assert_true(iterArr[3][3])
    assert_false(iterArr[4][4])
end

function testIteration2()
    arr = {
        {false,false,false,false,false},
        {false,false,false,false,false},
        {false,false,true,false,false},
        {false,false,false,false,false},
        {false,false,false,false,false}
    }

    assert_false(arr[2][2])
    assert_true(arr[3][3])
    assert_false(arr[4][4])

    iterArr = iterate(arr,5,5)

    assert_false(iterArr[2][2])
    assert_false(iterArr[3][3])
    assert_false(iterArr[4][4])
end

