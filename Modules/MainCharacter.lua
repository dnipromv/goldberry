--[[

	MainCharacter module. Contains character sprite and methods to control its movements

	Methods:

	MainCharacter:walk(vectorX, vectorY) - move character in direction provided by vectors
	this function is continuous - must be called every frame in order to last longer
	vectorX and vectorY values are floats between -1 and 1. Sign meaning:
	vectorX = -1 - left; 1 - right; 0 - doesn't change position on x coordinate 
	vectorY = -1 - up; 1 - down; 0 - doesn't change position on Y coordinate 

	MainCharacter:jump()
	
	Usage:

	To move character: (in runtime or any other continuous function):
	mainCharacter:setVectors(0.234,-0.873);

]]--
local mainCharacter = display.newImage("Textures/boy.png");
-- radius of character "orbit", on which he moves
local surfaceRadius = planetRadius+45;
mainCharacter.onPlanetPosition = 270
mainCharacter.x = planetCenterX + surfaceRadius * math.cos(math.rad(mainCharacter.onPlanetPosition));
mainCharacter.y = planetCenterY + surfaceRadius * math.sin(math.rad(mainCharacter.onPlanetPosition));

-- private parameters
local maxSpeedX = 12.0;
local maxSpeedY = 1.5;

local velocityX = 0.0;

local directionX = 0;
local directionY = 0;

local friction = 0.5;
local acceleration = 0.5;

-- when true, forces character to jump
local isJumping = false;
local jumpHeight = 300;
local jumpArc = 0; -- angle for jump arc sinusoid
local jumpSpeed = 3.7;

-- methods declarations
function mainCharacter:setVectors(vecX, vecY)
	if vecX then
		if(vecX==0) then
			directionX = 0;
		else
			directionX = vecX>0 and math.ceil( vecX ) or math.floor(vecX);
		end
	end
	
	if vecY then
		if(vecY==0) then
			directionY = 0;
		else
			directionY = vecY>0 and math.ceil( vecY ) or math.floor(vecY);
		end
	end

end

function mainCharacter:jump()
	-- ignore jump event if previous jump hasn't finished
	if(isJumping) then return end

	-- set jumping state to true and allow runtime handle the rest
	isJumping = true;
	jumpArc = 0;
end

-- controlling character movements

local runtime = 0
local function getDeltaTime()
    local temp = system.getTimer()  -- Get current game time in ms
    local dt = (temp-runtime) / (1000/60)  -- 60 fps or 30 fps as base
    runtime = temp  -- Store game time
    return dt
end

local function movementController(event)
	local deltaTime = getDeltaTime();

	if(isJumping) then
		-- when jumping - move character by sinusoidal trajektory for one period
		-- reset jump state when period was reached
		if(jumpArc>180) then 
			isJumping=false; 
			jumpArc=0;
		end

		-- slightly change character movement radius 
		local leapHeight = surfaceRadius + jumpHeight*math.sin(math.rad(jumpArc));
		mainCharacter.x = planetCenterX + leapHeight * math.cos(math.rad(mainCharacter.onPlanetPosition));
		mainCharacter.y = planetCenterY + leapHeight * math.sin(math.rad(mainCharacter.onPlanetPosition));

		-- increase sinusoidal entry
		jumpArc = jumpArc + jumpSpeed;
	else
		if(directionX==0) then
			if(velocityX==0) then return end; -- return if character doesn't move

			-- slowly stop character
			local velocityDirectionX = velocityX>0 and 1 or -1;
			velocityX = velocityX - friction*velocityDirectionX*deltaTime;
			if(math.abs(velocityX)<1) then velocityX = 0 end
		else
			-- slowly accelerate character
			velocityX = velocityX + acceleration*directionX;
			if(math.abs(velocityX)>maxSpeedX) then velocityX = maxSpeedX*directionX; end
		end
		local stepDistance = velocityX*deltaTime;

		local currentAngle = mainCharacter.onPlanetPosition;
		local currentArc = math.pi*planetRadius*currentAngle/180;
		local targetArc = currentArc+stepDistance;
		mainCharacter.onPlanetPosition = (targetArc*180)/(math.pi*planetRadius);

		mainCharacter.x = planetCenterX + surfaceRadius * math.cos(math.rad(mainCharacter.onPlanetPosition));
		mainCharacter.y = planetCenterY + surfaceRadius * math.sin(math.rad(mainCharacter.onPlanetPosition));
	end
end
Runtime:addEventListener( "enterFrame", movementController )

return mainCharacter;