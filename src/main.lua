local physics = require("physics")
physics.start()
physics.setGravity(0,9.8)
physics.setDrawMode("normal")

settings = {}
settings.reverse = false
settings.reverseInt = 0

if settings.reverse == true then
	settings.reverseInt = -1
else
	settings.reverseInt = 1
end

local gradient = graphics.newGradient(
  { 2,176,230 },
  { 153,223,245 },
  "down" )

local background = display.newRect( 0, 0, display.contentWidth, display.contentHeight )
background:setFillColor( gradient )

local balloon = display.newCircle( 0,0,25 )
balloon:setFillColor(255,0,0)
balloon.force = 0.002
balloon.x = display.contentWidth/2
balloon.y = display.contentHeight/2 - balloon.contentHeight
physics.addBody(balloon, { bounce = 0, radius = 25, friction = 1.0 } )
balloon.isFixedRotation = true
balloon.angularVelocity = 0
balloon.ID = "balloon"
balloon.isBullet = true
balloon.paused = false

local ground = display.newRect(0,display.contentHeight-50,display.contentWidth,50)
ground.y = display.contentHeight - ground.contentHeight/2
ground:setFillColor(80,75,70)
physics.addBody(ground, "static", { bounce = 0, friction = 1.0 } )

local leftWall = display.newRect(0,0,0,display.contentHeight)
physics.addBody(leftWall, "static", { bounce = 0, friction = 1.0 } )

local rightWall = display.newRect(display.contentWidth,0,0,display.contentHeight)
physics.addBody(rightWall, "static", { bounce = 0, friction = 1.0 } )

local topWall = display.newRect(0,0,display.contentWidth,0)
physics.addBody(topWall, "static", { bounce = 0, friction = 1.0 } )

local obstacle = display.newRect(50,50,150,30)
obstacle:setFillColor(145,135,125)
physics.addBody(obstacle, "static", { bounce = 0, friction = 1.0 } )
obstacle.ID = "obstacle"

camera = display.newGroup()

camera:insert(obstacle)
camera:insert(balloon)
camera:insert(ground)
camera:insert(leftWall)
camera:insert(topWall)
camera:insert(rightWall)

local runtime = 0

	local function getDeltaTime()
		local temp = system.getTimer()  --Get current game time in ms
		local dt = (temp-runtime) / (1000/30)  --60fps or 30fps as base
		runtime = temp  --Store game time
		return dt
	end

local function update()
	
	local dt = getDeltaTime()
	
	camera.x = ((balloon.x - display.contentWidth / 2) * -1)
	camera.y = ((balloon.y - display.contentHeight / 2) * -1)
	if balloon.paused then
		balloon.isAwake = false
		balloon:setLinearVelocity(0,0)
	else
		balloon.isAwake = true
	end
end

local function onCollision(event)
	if (event.phase == "began") then
		if (event.object1.ID == "obstacle") or (event.object2.ID == "obstacle") then
			if (event.object1.ID == "balloon") or (event.object2.ID == "balloon") then
				balloon.paused = true
			end
		end
	end
	if (event.phase == "ended") then
		if (event.object1.ID == "obstacle") or (event.object2.ID == "obstacle") then
			if (event.object1.ID == "balloon") or (event.object2.ID == "balloon") then
				obstacle:removeSelf()
				obstacle = nil
			end
		end
	end
end

display.setStatusBar(display.HiddenStatusBar)

function onTouch(event)
	if event.phase == "ended" then
		balloon.paused = false
		balloon:applyLinearImpulse(((event.x-balloon.x - camera.x)*balloon.force)*settings.reverseInt,((event.y-balloon.y - camera.y)*balloon.force)*settings.reverseInt)
		display.remove(line)
	end
	if event.phase == "moved" or event.phase == "began" then
		if (line) then
			display.remove(line)
		end
		if balloon.paused then line = display.newLine(balloon.x + camera.x, balloon.y + camera.y, event.x, event.y) end
	end
end

Runtime:addEventListener("collision", onCollision)
Runtime:addEventListener("enterFrame", update)
Runtime:addEventListener("touch", onTouch)