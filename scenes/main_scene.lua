local composer = require( "composer" )
local timer = require("timer")
local widget = require( "widget" )
local scene = composer.newScene()
local os = require("os")
require("modules.array")
require("modules.iteration")


-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
-- Grid Placement and Size
local sqX = 50
local sqY = 50
local sqOffsetX = display.contentCenterX/32
local sqOffsetY = display.contentCenterY/16
local sqSizeY = (display.contentCenterY)/sqY
local sqSizeX = ((display.actualContentWidth-(sqOffsetX*3.5))/sqX)
local dispArr = {}
local animSpeed = 70
local arr = generateArray(sqX,sqY)
local initialArr = copyGrid(arr)
local lastSquareTouched = {}

-- Buttons
local playPause = false
local buttonsFillColor = { default={0,0.7,0.5,0.8}, over={1,0.1,0.7,0.4} }
local buttonsStrokeColor = { default={0,1,0,1}, over={1,0.1,0.7,0.4}}
local buttonTextColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } }

--Text
local animSpeedText = display.newText( "Animation Speed", display.actualContentWidth/1.95, display.contentCenterY*1.45, native.systemFont, 20 )
animSpeedText:setFillColor( 0, 1, 0 )

local savedText = display.newText( "Test", display.contentCenterX, display.contentCenterY*1.95, native.systemFont, 16 )
savedText:setFillColor( 0, 1, 0 )
savedText.isVisible = false

-- Listener for if a square is touched, is always called when the grid is touched or dragged accross
local function tappedSquare( event )
    for i = 1, sqX  do
        for j = 1, sqY  do
            if dispArr[i][j] == event.target then
                -- Issues with touch events, tapping and letting go makes, 
                -- then removes a square. having an object that logs the last 
                -- square touched solves this
                if lastSquareTouched == event.target then   
                    return true
                else    
                    if arr[i][j] then
                        event.target:setFillColor(0, 0.2, 0)
                    else
                        event.target:setFillColor(0, 1, 0)
                    end

                    lastSquareTouched = event.target
                end
                arr[i][j] = not arr[i][j]
                return true
            end
        end
    end
end

-- Initial versions of the app used more buttons, left over,
-- But still used for the current option buttons
function makeOptionButton(buttonName, MethodName, xPos, yPos)
    local optButton = widget.newButton(
        {
            label = buttonName,
            onRelease = MethodName,
            fontSize = 32,
            shape = "roundedRect",
            x = xPos,
            y = yPos,
            width = (display.actualContentWidth - sqOffsetX*2)/4,
            height = 40,
            cornerRadius = 2,
            fillColor = buttonsFillColor, 
            strokeColor = buttonsStrokeColor,
            labelColor = buttonTextColor,
            strokeWidth = 4
        }
    )
    return optButton
end

function drawGrid()
    for i = 1, sqX  do
        for j = 1, sqY  do         
            if arr[i][j] then
                dispArr[i][j]:setFillColor(0, 1, 0)
            else
                dispArr[i][j]:setFillColor(0, 0.2, 0)
            end 
        end
    end
end

function reloadInitialArray(event)
    arr = copyGrid(initialArr)
    
    if  playPause then
        switchPlayPause()
    end
    
    drawGrid()
end

function init()
    sqOffsetX = display.actualContentWidth/48
    sqOffsetY = display.contentCenterY/16
    sqSizeY = (display.contentCenterY)/sqY
    sqSizeX = ((display.actualContentWidth-(sqOffsetX*3))/sqX)

    for i = 1, sqX  do
        dispArr[i] = {}
        for j = 1, sqY  do
            dispArr[i][j] = display.newRect( (sqOffsetX-sqSizeX/2) + (i * sqSizeX), (sqOffsetY-sqSizeY/2) + (j * sqSizeY), sqSizeX, sqSizeY )
            dispArr[i][j]:setFillColor(0, 0.2, 0)
            dispArr[i][j].strokeWidth = 0
            dispArr[i][j]:addEventListener( "touch",tappedSquare)
        end
    end

end
function animSpeedSlider(event)
    animSpeed = 170 - (event.value*1.6)
end

function goBack(event)
    local options = {
        effect = "slideRight",
        time = 800,
    }
    timer.pause( performwDelay )
    composer.gotoScene( "scenes.start_options_scene", options )
end

function iter(event)
    if playPause then
        arr = iterate(arr, sqX, sqY)

        drawGrid()
    end

    performwDelay = timer.performWithDelay(animSpeed,iter)
end

function switchPlayPause(event)
    if playPause then
        playButton:setLabel("     ▶     ")
        timer.pause(performwDelay)
    else 
        playButton:setLabel("     II     ")
        timer.resume(performwDelay)
    end

    playPause = not playPause
end

function saveArray(event)  
    local date = os.date( "*t" )

    -- Path for the file to write
    local path = system.pathForFile( "gridState.txt", system.DocumentsDirectory )
    
    print(path)

    -- Open the file handle
    local file, errorString = io.open( path, "w" )
    
    if not file then
        -- Error occurred; output the cause
        print( "File error: " .. errorString )
    else
        -- Write data to file
        -- this is here so the grid size is updated when a saved grid is loaded in
        file:write( tostring(sqX).."\n" )
        file:write( tostring(sqY).."\n" )

        for i = 1, sqX  do
            for j = 1, sqY  do         
                if arr[i][j] then
                    file:write( "1" )
                else
                    file:write( "0" )
                end 
            end
            file:write( "\n" )
        end
        -- Close the file handle
        io.close( file )
    end

    savedText.text = "Grid State Saved"
    savedText.isVisible = true  

    timer.performWithDelay(5000, hideSaveText)
    
    file = nil
end

-- for hiding the save text after 5 seconds
function hideSaveText(event)
    savedText.isVisible = false 
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

    -- Code here runs when the scene is first created but has not yet appeared on screen
    -- set up grid dimnentions and size
    -- Assign "self.view" to local variable "sceneGroup" for easy reference

    playButton = widget.newButton(
        {
            label = "     ▶     ",
            onRelease = switchPlayPause,
            fontSize = 32,
            -- Properties for a rounded rectangle button
            shape = "roundedRect",
            x = display.contentCenterX,
            y = display.contentCenterY*1.25,
            width = display.actualContentWidth - sqOffsetX*2,
            height = 40,
            cornerRadius = 2,
            fillColor = buttonsFillColor, 
            strokeColor = buttonsStrokeColor,
            labelColor = buttonTextColor,
            strokeWidth = 4
        }
    )

    returnButton = makeOptionButton("↩",goBack,display.actualContentWidth/7,display.contentCenterY*1.8)         
    restartButton = makeOptionButton("↻",reloadInitialArray,display.actualContentWidth/1.17,display.contentCenterY*1.8)   
    saveButton = makeOptionButton("Save",saveArray,display.contentCenterX,display.contentCenterY*1.8)  

    -- Sliders were used to avoid:
    -- A: programming range limitations
    -- B: Having a keyboard fly up over the screen, makes the experience more cohesive
    local speedSlider = widget.newSlider(
    {
        x = display.contentCenterX,
        y = display.contentCenterY*1.6,
        width = 200,
        value = 50, 
        listener = animSpeedSlider
    }
)

    init()
    iter()

    local sceneGroup = self.view

    -- Insert rectangle into "sceneGroup"
    sceneGroup:insert( playButton )
    sceneGroup:insert(speedSlider)
    sceneGroup:insert(returnButton)
    sceneGroup:insert(restartButton)
    sceneGroup:insert(animSpeedText)
    sceneGroup:insert(saveButton)
    sceneGroup:insert(savedText)

    -- adds the grid to the scene group
    for i = 1, sqX  do
        for j = 1, sqY  do
            sceneGroup:insert(dispArr[i][j])
        end
    end
end


-- show()
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- for when the grid scene has laready been and new grid is placed in from the options
        local params = event.params
        sqX = params.xGrid
        sqY = params.yGrid

        arr = params.arr
        initialArr = copyGrid(params.arr)

        playButton:setLabel("     ▶     ")
        playPause = false
        
        
    elseif ( phase == "did" ) then
        -- so the grid updates after coming back with a new grid 
        init()
        drawGrid()

        -- grid needs to be added to this scene group as well, otherwise the screen transitions are wacky
        for i = 1, sqX  do
            for j = 1, sqY  do
                sceneGroup:insert(dispArr[i][j])
            end
        end
    end
end


-- hide()
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)

    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
        -- Mainly to clear memory and allow new grid sizes 
        -- to be displayed without visual oddities
        for i = 1, sqX  do
            for j = 1, sqY  do
                dispArr[i][j]:removeSelf()
            end
        end
    end
end


-- destroy()
function scene:destroy( event )

    local sceneGroup = self.view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene

