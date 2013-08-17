-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------
local myData = require( "mydata" )
-- hide the status bar
display.setStatusBar( display.HiddenStatusBar )

-- include the Corona "storyboard" module
local storyboard = require "storyboard"
storyboard.isDebug = true
storyboard.state = {}
myData.currentLevel = 1
-- load menu screen
storyboard.gotoScene( "menu" )
