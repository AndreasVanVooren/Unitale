--FUCK ALL THAT PIVOT SHIT, let's just hardcode it.

--define some constants now.
baseDimensions = 308;
eyeHeight = 98;
eyeDiff = 29;
scale = 1.5;
rimScale = scale * 1.1;

--Screen height is 480, character should be spawned at 360
itCenter = CreateSprite("It/center");
xPivot = 320-6;
yPivot = 360;
xShakeOffset = 0;
yShakeOffset = 0;
isShaking = false;
itCenter.x = xPivot;
itCenter.y = yPivot;		--ToDo : check for screen property.

--itRim.SetAnchor(0.5,0.5);

itRim = CreateSprite("It/rim");
itRim.SetParent(itCenter);
itRim.y = 0;
itRim.x = 0;
--Scale at end to scale EVERYTHING (Note : scaling everything does not work.)
--itRim.Scale(0.8,0.8);		--also scale bc it's too big

itEye = CreateSprite("It/eye");
itEye.SetParent(itCenter);	--makes more sense to set center as main parent, but oh well
itEye.x = 0;
itEye.y = eyeDiff * scale;	--add scale to take into account that it scales globally

itRim.Scale(rimScale,rimScale);
itCenter.Scale(scale,scale);
itEye.Scale(scale,scale);

--GOOD. FINE. 
disableSpecials = false;

local itSkull = nil;

local skullX = 5 * scale;
local skullY = 12 * scale;
local skullXOffset = 0;
local skullYOffset = 0;

local showSkull = true;
local skullTimer = 0;

local function HandleSkull()
	skullTimer = skullTimer - Time.dt;
	
	if(skullTimer <= 0)then
		if(showSkull == false) then
			showSkull = true;
			itSkull = CreateSprite("It/skull2");
			itSkull.SetAnimation({
				"It/skull2",
				"It/skull2",
				"It/skull",
				"It/skull2",
				"It/skull",
				"It/skull2"
			})
			itSkull.SetParent(itCenter);
			itSkull.x = skullX;
			itSkull.y = skullY;
			itSkull.Scale(scale,scale);
			skullTimer = math.random()/2 + 0.25 ;
			
				Audio.PlaySound("scream");
		else
			showSkull = false;
			if(itSkull ~= nil) then
				itSkull.Remove();
				itSkull = nil;
			end
			skullTimer = math.random()*16 +2;
		end
	end
	
	if(showSkull) then
		skullXOffset = math.random(-3,3);
		skullYOffset = math.random(-3,3);
		itSkull.x = skullX + skullXOffset;
		itSkull.y = skullY + skullYOffset;
	end
end

local itGlitch = nil;

local glitchX = 0;
local glitchY = 7 * scale;
--local glitchXOffset = 0;

local glitchTimer = 16;
local glitchPhase = 0;

local function HandleGlitch()
	glitchTimer = glitchTimer - Time.dt;
	
	if(glitchTimer < 0) then
		if(itGlitch == nil) then
			itGlitch = CreateSprite("It/glitch");
			itGlitch.SetAnimation({
				"It/glitch",
				"It/glitch2",
				"It/glitch3"
			},1/60);
			itGlitch.SetParent(itCenter);
			itGlitch.x = glitchX;
			itGlitch.y = glitchY;
			itGlitch.Scale(scale,scale);
			
			if(glitchPhase < 2)then
				glitchTimer = 0.2;
				Audio.PlaySound("noiseShort");
			else
				glitchTimer = 0.66;
				Audio.PlaySound("noiseLong");
			end
			
		else
			--if(itGlitch ~= nil) then
			itGlitch.Remove();
			itGlitch = nil;
			--end
			
			if(glitchPhase == 0) then
				glitchTimer = 0.2;
				glitchPhase = 1;
			else
				if(glitchPhase == 1) then
				
					glitchPhase = 2;
				else
					glitchPhase = 0;
				end
				glitchTimer = 10;
			end
		end
	end
	
end

fadingToGrey = false;

local function HandleGrey()
	local grad = itRim.color[1];
	if(fadingToGrey == true) then
		grad = grad - Time.dt ;
		
		if(grad < 0.5) then
			grad = 0.5;
		end
	else
		grad = grad+ Time.dt ;
		
		if(grad > 1) then
			grad = 1;
		end
	end
	
	local c = {grad,grad,grad};
	
	itRim.color = c;
	itCenter.color = c;
	itEye.color = c;
	
	if(showSkull) then
		itSkull.color = c;
	end
	
	if(itGlitch ~= nil) then
		itGlitch.color = c;
	end
end

eyeState = 0;
eyeTimer = 0;

function HandleEyeTimer()

	if(eyeTimer > 0) then
		eyeTimer = eyeTimer - Time.dt;
		if(eyeTimer <= 0) then
			if(eyeState == 0) then	--eye went from closed to open.
				eyeState = 1;
				eyeTimer = 1;
				--itEye.StopAnimation();	--NEVER EVER EVER CALL THIS FUNCTION WHEN HANDLING MULTIPLE ANIMS
				itEye.SetAnimation({"It/eyeAnim/7"})
				--DEBUG("1");
			elseif (eyeState == 1)then	--eye succeeded in being open for a good amount of time.
				eyeState = 2;
				eyeTimer = 1/30 - 0.001;
				itEye.SetAnimation({"It/eyeAnim/8"}); --it's 1 frame, so I don't need to put much effort into this.
				--DEBUG("2");
			elseif (eyeState == 2)then	--eye went from open to oh god it's staring right at me.
				itEye.SetAnimation({"It/eyeAnim/9"}); --final frame;
				eyeState = 3;
				--DEBUG("3");
			elseif (eyeState == 3)then	--eye went from stare to closed.
				--itEye.StopAnimation();	--REPEAT, NEVER!!!!
				itEye.SetAnimation({"It/eye"});
				eyeState = 0;
			else DEBUG("!!!UNHANDLED ANIMATION STATE!!!");
			end
		end
	end
end

function AnimateSans()
	if(not disableSpecials) then
		HandleSkull();
		HandleGlitch();
	end
	HandleGrey();
	
	if(isShaking)then
		xShakeOffset = math.random(-10,10);
		yShakeOffset = math.random(-10,10);
		Audio.Pitch( 1.5 + 0.5*math.sin(Time.time*16) )
	end

	local rot = 20*math.sin(Time.time*0.5);
	itRim.rotation = rot;
	itCenter.MoveTo(xPivot + xShakeOffset, yPivot + yShakeOffset + 2 *math.sin(Time.time) );
	--itCenter.rotation = 0;
	
	HandleEyeTimer();
end

function StartVibrating()
	isShaking = true;
end

function StopVibrating()
	isShaking = false;
	xShakeOffset = 0;
	yShakeOffset = 0;
	Audio.Pitch(1);
	Audio.Pause();
end

function OpenEye()
	if(eyeState == 3) then
		DEBUG("Already open");
		return;
	elseif (eyeState ~= 0) then
		DEBUG("Already opening");
		return;
	end
	eyeTimer = 6/60 - 0.001;
	itEye.SetAnimation({
		"It/eyeAnim/1",
		"It/eyeAnim/2",
		"It/eyeAnim/3",
		"It/eyeAnim/4",
		"It/eyeAnim/5",
		"It/eyeAnim/6"
	}, 1/60); --divide by 60 for them smooth 60 fps
	Audio.Pitch(1.25);
	SetGlobal("angry", true);
end

function CloseEye()
	if(eyeState ~= 3) then
		--DEBUG("y u do dis");
		if(eyeTimer <= 0) then	--pure open or pure shut, this case pure shut.
			--DEBUG("SFASDFASD");
			return;
		end
	end
	--itEye.StartAnimation();
	itEye.SetAnimation({
		"It/eyeAnim/8",
		"It/eyeAnim/7",
		"It/eyeAnim/6",
		"It/eyeAnim/5",
		"It/eyeAnim/4",
		"It/eyeAnim/3",
		"It/eyeAnim/2",
		"It/eyeAnim/1"
	}, 1/15);
	eyeTimer = 8/15 - 0.001;
	Audio.Pitch(1);
	--DEBUG("START ANIM")
	SetGlobal("angry", false);
		
end

function FadeToGrey()
	fadingToGrey = true;
end

function FadeToWhite()
	fadingToGrey = false;
end