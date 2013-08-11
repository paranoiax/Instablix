display.setStatusBar(display.HiddenStatusBar)
display.setDefault( "magTextureFilter", "nearest" )
display.setDefault( "minTextureFilter", "nearest" )

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

music = audio.loadStream("music.mp3")
musicChannel = audio.play( music, { channel=1, loops=-1, fadein=3000 }  )

explosion = {}
explosion[1] = audio.loadSound("explosion1.wav")
explosion[2] = audio.loadSound("explosion2.wav")
explosion[3] = audio.loadSound("explosion3.wav")
explosion[4] = audio.loadSound("explosion4.wav")
 
local function playExplosion()
      local thisExplosion = math.random(#explosion) 
      audio.play(explosion[thisExplosion])
end

local background = display.newImage( "bg.jpg", true )
background.x = display.contentWidth / 2
background.y = display.contentHeight / 2

local balloon = display.newCircle( 550,100,25 )
balloon:setFillColor(255,0,0)
balloon.force = 0.0005
physics.addBody(balloon, { bounce = 0, radius = 12, friction = 1.0, filter = {maskBits = 2, categoryBits = 1} } )
balloon.isFixedRotation = true
balloon.angularVelocity = 0
balloon.ID = "balloon"
balloon.isBullet = true
balloon.paused = false
balloon.isVisible = false
balloon.canJump = false

currentParticle = 1
limit = 0
Particle = {}
explode = false

local ground = display.newRect(0,450,1000,50)
ground:setFillColor(180,30,30)
physics.addBody(ground, "static", { bounce = 0, friction = 1.0, filter = {maskBits = 5, categoryBits = 2} } )

obstacle = display.newRect(0,0,0,0)
obstacle:setFillColor(80,80,80)
obstacle.x = 550
obstacle.y = 200
obstacle.width = 300
obstacle.height = 30
physics.addBody(obstacle, "static", { bounce = 0, friction = 1.0, filter = {maskBits =5, categoryBits = 2} } )
obstacle.ID = "obstacle"

local camera = display.newGroup()
camera.shake = 0
local shake = false

camera:insert(obstacle)
camera:insert(balloon)
camera:insert(ground)
for i,v in ipairs(Particle) do
	camera:insert(Particle[i])
end

function addParticle()	
	
	for i = 1, limit do
		Particle[i] = {}
		Particle[i].size = math.random(3,6)
		Particle[i] = display.newRect(collX + math.random(-collW / 2, collW / 2), collY + math.random(-collH / 2,collH / 2),Particle[i].size,Particle[i].size)
		physics.addBody(Particle[i], { bounce = 0.05, friction = 0.9, filter = {maskBits = 6, categoryBits = 4} } )
		Particle[i]:setFillColor(80,80,80)
		camera:insert(Particle[i])
		--Particle[currentParticle].fixture:setUserData("particle")
		--Particle[currentParticle].fixture:setCategory(3)
		--Particle[currentParticle].fixture:setMask(4,5)
		currentParticle = currentParticle + 1
	end
	currentParticle = 1
end

local runtime = 0

local function getDeltaTime()
	local temp = system.getTimer()  --Get current game time in ms
	local dt = (temp-runtime) / (1000/60)  --60fps or 30fps as base
	runtime = temp  --Store game time
	return dt
end
	
local sheet1 = graphics.newImageSheet( "ball_anim.png", { width=24, height=24, numFrames=16 } )
local instance1 = display.newSprite( sheet1, { name="ball_idle", start=1, count=16, time=2000 } )
instance1.x = 0
instance1.y = 0
instance1:play()

function slowMotion()
	physics.pause()
	timer.performWithDelay( 700, function()
		physics.start()
	end, 1 )
end

local function update()

	local dt = getDeltaTime()

	if explode then
		addParticle()
		explode = false
		for i,v in ipairs(Particle) do
			v:applyLinearImpulse(math.random(-2,2)/1000,math.random(-2,2)/1000)
		end
	end	
	
	if shake then
		camera.shake = math.random(-15,15)
	else
		camera.shake = 0
	end
	
	camera.x = ((balloon.x - display.contentWidth / 2) * -1) + camera.shake
	camera.y = ((balloon.y - display.contentHeight / 2) * -1) + camera.shake
	
	instance1.x = balloon.x + camera.x
	instance1.y = balloon.y + camera.y
	
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
				balloon.canJump = true
				collX, collY, collW, collH = obstacle.x, obstacle.y, obstacle.width, obstacle.height
				limit = (collW + collH) / 4
				if limit > 120 then limit = 120 end
			end
		end
	end
	if (event.phase == "ended") then
		if (event.object1.ID == "obstacle") or (event.object2.ID == "obstacle") then
			if (event.object1.ID == "balloon") or (event.object2.ID == "balloon") then				
				obstacle:removeSelf()
				obstacle = nil
				shake = true
				playExplosion()
				explode = true
				balloon.paused = false
				balloon.canJump = false
				local function stopShake(event)
					shake = false
				end
				timer.performWithDelay( 700, stopShake )
				slowMotion()
			end
		end
	end
end

function onTouch(event)
	if event.phase == "ended" and balloon.canJump then
		balloon.paused = false
		balloon:applyLinearImpulse(((event.x-balloon.x - camera.x)*balloon.force)*settings.reverseInt,((event.y-balloon.y - camera.y)*balloon.force)*settings.reverseInt)
		display.remove(line)
	end
	if event.phase == "moved" or event.phase == "began" then
		if (line) then
			display.remove(line)
		end
		if balloon.canJump then
			line = display.newLine(balloon.x + camera.x, balloon.y + camera.y, event.x, event.y)
			line:setColor(255,255,255,distanceFrom(event.x,event.y,balloon.x + camera.x,balloon.y + camera.y))
		end			
	end
end

function distanceFrom(x1,y1,x2,y2)
	local distance = math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2) * 0.65
	if distance > 255 then distance = 255 end
	return math.floor(distance + .5)
end

Runtime:addEventListener("collision", onCollision)
Runtime:addEventListener("enterFrame", update)
Runtime:addEventListener("touch", onTouch)