local composer = require( "composer" )
local widget = require("widget")
local math = require("math")
local string = require("string")
local scene = composer.newScene()
require("modules.array")
require("modules.iteration")



--Button Colours
local buttonsFillColor = { default={0,0.7,0.5,0.8}, over={1,0.1,0.7,0.4} }
local buttonsStrokeColor = { default={0,1,0,1}, over={1,0.1,0.7,0.4}}
local buttonTextColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } }

-- Default Grid Options
xGridSize = 64
yGridSize = 64
randDensity = 14

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
-- set functions set size and randomisation density (if used) for a new grid
function setXGridSize(event)
    local val = math.round(4 + (1.2 * event.value))
    xGridSize = val
    optionsNumberText.text = "Grid Size:"..tostring(xGridSize).."X"..tostring(yGridSize)
end

function setYGridSize(event)
    local val = math.round(4 + (1.2 * event.value))
    yGridSize = val
    optionsNumberText.text = "Grid Size:"..tostring(xGridSize).."X"..tostring(yGridSize)
end

function randDensSet(event)
    local val = math.round(event.value/3.5)
    randDensity = val
    randDensityText.text = "Rand Density:"..tostring(randDensity)
end

-- goes to main_scene with the grid, random, blank or loaded

function goToGridwRand(event)
    local options = {
        effect = "slideLeft",
        time = 600,
        params = { 
            xGrid=xGridSize, 
            yGrid=yGridSize,
            arr = generateRandArray(xGridSize,yGridSize,randDensity)
        }
    }
    composer.gotoScene( "scenes.main_scene", options )
end

function goToGridwBlank(event)
    local options = {
        effect = "slideLeft",
        time = 600,
        params = { 
            xGrid=xGridSize, 
            yGrid=yGridSize,
            arr = generateArray(xGridSize,yGridSize)
        }
    }
    composer.gotoScene( "scenes.main_scene", options )
end

function loadGrid(event)
    local fileXGridSize = 0
    local fileYGridSize = 0
    local loadedArray = {}

    -- stolen from : https://docs.coronalabs.com/guide/data/readWriteFiles/index.html
    local path = system.pathForFile( "gridState.txt", system.DocumentsDirectory )
 
    local file, errorString = io.open( path, "r" )
    
    if not file then
        print( "File error: " .. errorString )
    else
        local lineNo = 0
        for line in file:lines() do
            lineNo = lineNo + 1

            -- Makes sure x and y are set before loading in the data
            if fileXGridSize == 0 then
                fileXGridSize = tonumber(line)
                lineNo = 0
            elseif fileYGridSize == 0 then
                fileYGridSize = tonumber(line)
                lineNo = 0
            else
                loadedArray[lineNo] = {}
                for a=1, #line do
                    if tonumber(line:sub(a,a)) == 1 then
                        loadedArray[lineNo][a] = true
                    else
                        loadedArray[lineNo][a] = false
                    end
                end
            end
        end
        io.close( file )
    end
    
    file = nil
    

    local options = {
        effect = "slideLeft",
        time = 600,
        params = { 
            xGrid=fileXGridSize, 
            yGrid=fileYGridSize,
            arr = loadedArray
        }
    }
    composer.gotoScene( "scenes.main_scene", options )
end
-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

    -- Code here runs when the scene is first created but has not yet appeared on screen
    local iconText = display.newText( "Game of Life", display.contentCenterX, display.contentHeight/16 , "BlueScreen.ttf", 32 )
    iconText:setFillColor( 0, 1, 0 )

    local optionsText = display.newText( "Options:", display.contentCenterX, display.contentHeight/6.5 , "PixeloidSans.ttf", 24 )
    optionsText:setFillColor( 0, 1, 0 )

    optionsNumberText = display.newText("Grid Size:"..xGridSize.."X"..yGridSize, display.contentCenterX, display.contentHeight/4.8 , "PixeloidSans.ttf", 16 )
    optionsNumberText:setFillColor( 0, 1, 0 )

    randDensityText = display.newText("Rand Density:"..randDensity, display.contentCenterX/2, display.contentHeight/1.22 , "PixeloidSans.ttf", 16 )
    randDensityText:setFillColor( 0, 1, 0 )

    --Sliders used for range setting and ease of use
    local gridXSlider = widget.newSlider(
        {
            x = display.contentCenterX,
            y = display.contentHeight/3.5,
            width = display.actualContentWidth/1.2,
            value = 50,  
            listener = setXGridSize       
        }
    )

    local gridYSlider = widget.newSlider(
        {
            x = display.contentCenterX,
            y = display.contentHeight/2.7,
            width = display.actualContentWidth/1.2,
            value = 50,  
            listener = setYGridSize
        }
    )

    local randDensitySlider = widget.newSlider(
        {
            x = display.contentCenterX/2,
            y = display.contentHeight/1.6,
            orientation = "vertical",
            height = display.actualContentWidth/2.2,
            value = 50, 
            listener = randDensSet
        }
    )

    local horizontalDivSquare = display.newRect(display.contentCenterX,display.contentCenterY/1.15,display.actualContentWidth/1.2,3)
    horizontalDivSquare:setFillColor( 0,1,0,0.5 )

    local vertDivSquare = display.newRect(display.contentCenterX,display.contentCenterY*1.55,3,display.contentCenterY*1.3)
    vertDivSquare:setFillColor( 0,1,0,0.5 )

    local randStartButton = widget.newButton(
        {
            label = "Random Grid",
            labelAlign = center,
            onRelease = goToGridwRand,
            fontSize = 18,
            shape = "roundedRect",
            x = display.contentCenterX/2,
            y = display.contentCenterY*1.85,
            width = display.actualContentWidth/2.5,
            height = display.actualContentHeight/12,
            cornerRadius = 2,
            fillColor = buttonsFillColor, 
            strokeColor = buttonsStrokeColor,
            labelColor = buttonTextColor,
            strokeWidth = 4
        }
    )

    local blankStartButton = widget.newButton(
        {
            label = "Blank Grid",
            labelAlign = center,
            onRelease = goToGridwBlank,
            fontSize = 18,
            shape = "roundedRect",
            x = display.contentCenterX*1.5,
            y = display.contentCenterY*1.85,
            width = display.actualContentWidth/2.5,
            height = display.actualContentHeight/12,
            cornerRadius = 2,
            fillColor = buttonsFillColor, 
            strokeColor = buttonsStrokeColor,
            labelColor = buttonTextColor,
            strokeWidth = 4
        }
    )

    local loadButton = widget.newButton(
        {
            label = "Load Saved\nGrid State",
            labelAlign = center,
            onRelease = loadGrid,
            fontSize = 18,
            shape = "roundedRect",
            x = display.contentCenterX*1.5,
            y = display.contentCenterY*1.5,
            width = display.actualContentWidth/2.5,
            height = display.actualContentHeight/12,
            cornerRadius = 2,
            fillColor = buttonsFillColor, 
            strokeColor = buttonsStrokeColor,
            labelColor = buttonTextColor,
            strokeWidth = 4
        }
    )
    -- Assign "self.view" to local variable "sceneGroup" for easy reference
    local sceneGroup = self.view

    --local rect = display.newRect( 160, 240, 200, 200 )
    -- Insert rectangle into "sceneGroup"
    sceneGroup:insert( iconText )
    sceneGroup:insert(optionsText)
    sceneGroup:insert(optionsNumberText)
    sceneGroup:insert(gridXSlider)
    sceneGroup:insert(gridYSlider)
    sceneGroup:insert(randStartButton)
    sceneGroup:insert(horizontalDivSquare)
    sceneGroup:insert(vertDivSquare)
    sceneGroup:insert(randDensityText)
    sceneGroup:insert(randDensitySlider)
    sceneGroup:insert(blankStartButton)
    sceneGroup:insert(loadButton)
end


-- show()
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen

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

    end
end


-- destroy()
function scene:destroy( event )

    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view

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

