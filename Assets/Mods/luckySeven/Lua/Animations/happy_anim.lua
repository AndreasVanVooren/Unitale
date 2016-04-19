-------------------
--Module definition
-------------------

local happyAnim = {};



--------------------------------
--Script Variable Initialization
--------------------------------
local timeStart = Time.time;
local timeActive = 0;

local shakeTime = 0;
local maxShakeTime = 0;
local maxShakeOffset = 4;

local springTimer = 0;
local sprung = 0;
local swaying = true;

--note anchors and pivots are all values I got by fucking around in the Unity editor
local legs  = CreateSprite("Happy/tempSprites/legs");
--torso.SetAnchor(0.5,0);
legs.SetPivot(0.5,0);
legs.MoveTo(320,240);

local torso = CreateSprite("Happy/tempSprites/torso");
torso.SetAnchor(0.455,1);
torso.SetPivot(0.37,0);
torso.SetParent(legs);
torso.MoveTo(0,0);

local torsEye = CreateSprite("Happy/tempSprites/eyes/torsEyeClosed");
--torso.SetAnchor(0.455,1);
--torso.SetPivot(0.37,0);
torsEye.SetParent(torso);
torsEye.MoveTo(-14.4,-6.8);

local neck = nil;
local armNeckTop = nil;
local armNeckHiR = nil;
local armNeckL = nil;
	local armNeckLRot = 325;
local armNeckLoR = nil;
local armUp1 = nil;
local armUp2 = nil;
	local armUp2Rot = 23.9;
local armLo1 = nil;
local armLo2 = nil;
	local armLo2Rot = 312.5;
local armLoL = nil;
local hand1 = nil;
local hand2 = nil;
	local hand2Rot = 23.6;

local generalVal = 1;

	
-------------------
--Private Functions
-------------------

--General Helpers
local function Recenter(obj, speed, tgtRot)
	tgtRot = tgtRot or 0;
	while (tgtRot < 0) do
		tgtRot = tgtRot + 360;
	end
	while (tgtRot >= 360) do
		tgtRot = tgtRot - 360;
	end
	speed = speed or 5;
	
	local curRot = obj.localRotation;
	
	local diff = Time.dt*speed;
	
	if(curRot - tgtRot > 180)then
		curRot = curRot - 360;
	elseif (tgtRot - curRot > 180)then
		curRot = curRot + 360;
	end
	
	--DEBUG(curRot);
	if (curRot > tgtRot ) then
	
		curRot = curRot - diff;
		if(curRot < tgtRot) then
			curRot = tgtRot;
		end
	elseif ( curRot <tgtRot ) then
	
		curRot = curRot + diff;
		if(curRot > tgtRot ) then
			curRot = tgtRot;
		end
	else 
		diff = 0;
	end
	obj.localRotation = curRot;
	return diff;
end

--Big Happy Functions
local function CreateHead(X, Y, pivotX, pivotY, withJaw, hasEye)
	--Default params
	withJaw = withJaw or true;
	hasEye = hasEye or 1;
	
	--Create skull, in my lazy haze called head.
	local head  = CreateSprite("Happy/tempSprites/headUpper");
	--head1.SetAnchor(0.4,0.79);
	head.SetPivot(pivotX,pivotY);
	head.SetParent(legs);
	head.SendToBottom();
	head.MoveTo(X,Y);
	
	local jaw = nil;
	--if a jaw is defined, add it.
	if(withJaw == true)then
		jaw = CreateSprite("Happy/tempSprites/headJaw");
		jaw.SetParent(head);
		jaw.SetAnchor(0.9333334,0.4166666);
		jaw.SetPivot(0.9105945,1);
		jaw.MoveTo(0,0);
	end
	
	local eye = nil;
	if(hasEye > 0)then
		if(hasEye > 1)then
			eye = CreateSprite("Happy/tempSprites/eyes/eyeClosed");
		else
			eye = CreateSprite("Happy/tempSprites/eyes/eyeSmallClosed");
		end
		eye.SetParent(head);
		eye.SetAnchor(0.5,0.5);
		eye.SetPivot(0.5,0.5);
		eye.MoveTo(0,0);
	end
	
	return { head, eye, jaw };
end
	
local head1 = CreateHead(-7.7, 75.57988, 0.5, -0.27, true,0);
head1[1].SetParent(torso);
head1[1].y = 12.3;
local head2 = nil --CreateHead(-64.6, 39.6, 0.5, 1, true);
local head3 = nil --CreateHead(80.6, 77.9, 0.5, -0.27, true);
local head4 = nil --CreateHead(80.6, 77.9, 0.5, -0.27, true);
local head5 = nil --CreateHead(80.6, 77.9, 0.5, -0.27, true);
local head6 = nil --CreateHead(80.6, 77.9, 0.5, -0.27, true);
local head7 = nil --CreateHead(80.6, 77.9, 0.5, -0.27, true);

local looseHeadParts = {} --format : { {headpart, velocityX, velocityY, yOffset} }

legs.Scale(1.6,1.6, true);

function happyAnim.Shake(dt)
	dt = dt or 0.5;
	maxShakeTime = dt;
	shakeTime = dt;
end


--LetShitGoDown();
local function PositionHead(head, target, dispX, dispY, rotOffset)
	if (head == nil)then
		DEBUG("No valid head has been passed through")
	end
	
	head[1].rotation = target.rotation + rotOffset;
	
	local Cos = math.cos(math.rad(target.rotation));
	local Sin = math.sin(math.rad(target.rotation));
	
	local x = dispX*Cos - dispY*Sin;
	local y = dispY*Cos + dispX*Sin;
	
	head[1].MoveToAbs( target.xAbs + x, target.yAbs + y  );
end


local function UpdateSpring()
	springTimer = springTimer - Time.dt;
	
	if(springTimer <=0)then
		if(sprung ~= 0)then
			springTimer = 0.5;
			timeStart = Time.time;
		end
		if(sprung == 1)then
			sprung = 2;
			--neck
			neck = CreateSprite("Happy/tempSprites/neckBone");
			neck.SetParent(torso);
			neck.SetAnchor(0.425,0.579);
			neck.SetPivot(0.3,0);
			neck.MoveTo(0,0);
			
			armNeckTop = CreateSprite("Happy/tempSprites/armNeckTopTop")
			armNeckTop.SetParent(neck);
			armNeckTop.SetAnchor(0.17,0.8914);
			armNeckTop.SetPivot(0.4729,0.0253);
			armNeckTop.MoveTo(0,0);
			
			head4 = CreateHead(0,0, 0.5, -0.27, true,2); --neckTop
			
			legs.Scale(1.6,1.6, true);
			
			PositionHead(head4, armNeckTop, 0, 20, 0);
			happyAnim.Shake(0.25);	--for some reason these kinds of func defines need a ptr to the module. Just stick with it.
			
			if(head1 ~= nil)then
				head1[1].Remove();
				head1[3].Remove();
				head1 = nil;
			end
		elseif(sprung ==2 )then
			sprung = 3;
			--left arm
			armLoL = CreateSprite("Happy/tempSprites/armLowerL");
			armLoL.SetParent(torso);
			armLoL.SetAnchor(0.22,0.965)
			armLoL.SetPivot(1,0.733);
			armLoL.MoveTo(0.4,0);
			
			head2 = CreateHead(-64.6, 39.6, 0.5, 1, true); -- armLoL
			
			legs.Scale(1.6,1.6, true);
			
			PositionHead(head2, armLoL,-45,-45, 0);
			happyAnim.Shake(0.25);
		elseif(sprung ==3 )then
			sprung = 4;
			
			armUp1 = CreateSprite("Happy/tempSprites/armUpper");
			armUp1.SetParent(torso);
			armUp1.SetAnchor(0.6792037, 0.3424562);
			armUp1.SetPivot(0.5, 1);
			armUp1.MoveTo(0,0);
			
			armLo1 = CreateSprite("Happy/tempSprites/armLower");
			armLo1.SetParent(armUp1);
			armLo1.SetAnchor(0.3888889, 0.06450538);
			armLo1.SetPivot(0.06965858, 0.8420351);
			armLo1.MoveTo(0,0);
			
			armUp2 = CreateSprite("Happy/tempSprites/armUpper2");
			armUp2.SetParent(torso);
			armUp2.SetAnchor(0.78, 0.52);
			armUp2.SetPivot(0.5, 0.935167);
			armUp2.MoveTo(-2.5,2);
			armUp2.localRotation = armUp2Rot;
			
			armLo2 = CreateSprite("Happy/tempSprites/armLower2");
			armLo2.SetParent(armUp2);
			armLo2.SetAnchor(0.5, 0.14);
			armLo2.SetPivot(0.5, 0.02837969);
			armLo2.MoveTo(0,0);
			armLo2.localRotation = armLo2Rot;
			
			hand1 = CreateSprite("Happy/tempSprites/hand1");
			hand1.SetParent(armLo1);
			hand1.SetAnchor(0.984, 0.495);
			hand1.SetPivot(0.1571406, 0.17743);
			hand1.MoveTo(0,0);
			
			hand2 = CreateSprite("Happy/tempSprites/hand2");
			hand2.SetParent(armLo2);
			hand2.SetAnchor(0.8, 0.948);
			hand2.SetPivot(0.5, 0.06390622);
			hand2.MoveTo(0,0);
			hand2.localRotation = hand2Rot;
			
			head3 = CreateHead(0,0, 0.5, -0.27, true); --arm2
			
			legs.Scale(1.6,1.6, true);
			
			PositionHead(head3, hand2, 0, 3, 0);
			happyAnim.Shake(0.25);
		elseif(sprung ==4 )then
			sprung = 5;
			armNeckL = CreateSprite("Happy/tempSprites/armNeckL")
			armNeckL.SetParent(neck);
			armNeckL.SetAnchor(0.17, 0.57);
			armNeckL.SetPivot(0.994, 0.374);
			armNeckL.MoveTo(0,0);
			armNeckL.localRotation = armNeckLRot;
			
			head6 = CreateHead(0,0, 0.5, 0, false); --neckArmL
			
			legs.Scale(1.6,1.6, true);
			
			PositionHead(head6,armNeckL,-60,5,180);
			happyAnim.Shake(0.25);
		elseif(sprung ==5 )then
			sprung = 6;
			
			armNeckHiR = CreateSprite("Happy/tempSprites/armNeckUpperR")
			armNeckHiR.SetParent(neck);
			armNeckHiR.SetAnchor(0.8943, 0.9286);
			armNeckHiR.SetPivot(0.171, 0.0798);
			armNeckHiR.MoveTo(0,0);
			
			head5 = CreateHead(0,0, 0.5, -0.27, true); --neckarmRTop
			
			
			armNeckLoR = CreateSprite("Happy/tempSprites/armNeckLowerR")
			armNeckLoR.SetParent(neck);
			armNeckLoR.SetAnchor(0.93939, 0.8914);
			armNeckLoR.SetPivot(0.10067, 0.9942);
			armNeckLoR.MoveTo(0,0);
			
			head7 = CreateHead(0,0, 0.5, 0, false); --neckArmRBot
			
			
			legs.Scale(1.6,1.6, true);
			
			PositionHead(head5,armNeckHiR,25,30,-60);
			PositionHead(head7,armNeckLoR,25,-15,-20);
			happyAnim.Shake(0.25);
		end
	end
end

local function LetShitGoDown()
	--reset timer
	timeStart = Time.time;
	
	Audio.LoadFile("Happy_Loop");
	legs.Scale(1.6,1.6, true);
	sprung = 1;
	swaying = true;
	SetGlobal("isSprung", true);
end

--tentacle thing in bounds : armLol (2)
--tentacle thing out of bounds : hand2 (3)
--burst arms : arm neck top (4)
--head left tentacle = right upper (5)
--head right tentacle = right upper (6)
--lasers any  = right lower (7)

local function UpdateHeads()
	if(head2 ~= nil)then
		PositionHead(head2, armLoL,-45,-45, 0);
	end
	if(head3 ~= nil)then
		PositionHead(head3, hand2, 0, 3, 0);
	end
	if(head4 ~= nil)then
		PositionHead(head4, armNeckTop, 0, 20, 0);
	end
	if(head5 ~= nil)then
		PositionHead(head5,armNeckHiR,25,30,-60);
	end
	if(head6 ~= nil)then
		PositionHead(head6,armNeckL,-60,5,180);
	end
	if(head7 ~= nil)then
		PositionHead(head7,armNeckLoR,25,-15,-20);
	end
end

local function AnimateBigPap()
	if(swaying) then
		torso.localRotation = math.sin(timeActive * math.pi *(76/60) /8 ) * 3;
		--head1[1].localRotation = (math.sin(timeActive * math.pi *(76/60) /4 )+1) * 5;
		armLoL.localRotation =  math.sin(timeActive * math.pi *(76/60)/3 ) * 6;
		
		armUp1.localRotation =  math.sin(timeActive * math.pi *(76/60)/5 ) * 8;
		armLo1.localRotation =  math.sin(timeActive * math.pi *(76/60)/6 ) * 3;
		
		armUp2.localRotation =  armUp2Rot + (math.sin(timeActive * math.pi *(76/60)/3 )) * 8;
		armLo2.localRotation =  armLo2Rot + math.sin(timeActive * math.pi *(76/60)/7 ) * 3;
		
		neck.localRotation =  math.sin(timeActive * math.pi *(76/60)/4 ) * 3;
		
		armNeckL.localRotation = armNeckLRot + math.sin(timeActive * math.pi *(76/60)/8 ) * 10;
		
		armNeckHiR.localRotation =  math.sin(timeActive * math.pi *(76/60)/4 ) * 6;
		armNeckLoR.localRotation =  math.sin(timeActive * math.pi *(76/60)/9 ) * 2;
		
		
	else
		Recenter(torso);
		Recenter(armLoL);
		Recenter(armUp1,10);
		Recenter(armLo1,10);
		Recenter(armUp2,5,armUp2Rot);
		Recenter(armLo2,5,armLo2Rot);
		Recenter(neck);
		Recenter(armNeckL,5,armNeckLRot);
		Recenter(armNeckHiR);
		Recenter(armNeckLoR);
	end
	UpdateHeads();
		--DEBUG(hand1.absx);
		--DEBUG(hand1.absy);
	if(Input.Menu == 1)then
		--swaying = not swaying;
		--timeStart = Time.time;
		--LetShitGoDown();
	end
end

local function GentleSway()
	if(swaying) then
		torso.localRotation = math.sin(timeActive * math.pi *(76/60) /4 ) * 10;
		if(head1 ~= nil)then
			head1[1].localRotation = (math.sin(timeActive * math.pi *(76/60) /4 )+1) * 5;
		end
	else
		Recenter(torso);
		if(head1 ~= nil)then
			Recenter(head1[1]);
		end
	end
	
	if(Input.Menu == 1)then
		--swaying = not swaying;
		--timeStart = Time.time;
		--LetShitGoDown();
	end
end

function happyAnim.ToggleSway(newState)
	if(newState == nil)then
		swaying = not swaying;
	else
		swaying = newState;
	end
	
end

function KillHeadLoc(head, yOffset, yOffsetJaw)
	yOffset = yOffset or 0;
	yOffsetJaw = yOffsetJaw or 0;
	
	head[1].SetParent(legs);
	
	table.insert(looseHeadParts, {head[1],-15, 0, yOffset});
	if(head[3] == nil)then
		return;
	end
	head[3].SetParent(legs);
	
	table.insert(looseHeadParts, {head[3], 15, 0, yOffsetJaw});
end

function happyAnim.KillHead(index)
	if(index == 1 and head1 ~= nil)then
		KillHeadLoc(head1,-5,30);
		head1 = nil;
	elseif(index == 2 and head2 ~= nil)then
		KillHeadLoc(head2);
		head2 = nil;
	elseif(index == 3 and head3 ~= nil)then
		KillHeadLoc(head3);
		head3 = nil;
	elseif(index == 4 and head4 ~= nil)then
		KillHeadLoc(head4);
		head4 = nil;
	elseif(index == 5 and head5 ~= nil)then
		KillHeadLoc(head5);
		head5 = nil;
	elseif(index == 6 and head6 ~= nil)then
		KillHeadLoc(head6);
		head6 = nil;
	elseif(index == 7 and head7 ~= nil)then
		KillHeadLoc(head7);
		head7 = nil;
	
	end
end

function happyAnim.ToggleHand()
	if(hand1 == nil)then
		hand1 = CreateSprite("Happy/tempSprites/hand1");
		hand1.SetParent(armLo1);
		hand1.SetAnchor(0.984, 0.495);
		hand1.SetPivot(0.1571406, 0.17743);
		hand1.MoveTo(0,0);
	else
		hand1.Remove();
		hand1 = nil;
	end
end

local function UpdateDeadItems()
	for	i=1, (#looseHeadParts)do
		--get displacement
		local x = looseHeadParts[i][1].xAbs;
		local y = looseHeadParts[i][1].yAbs;
		x = x + looseHeadParts[i][2] * Time.dt;
		y = y + looseHeadParts[i][3] * Time.dt;
		
		--apply gravity for next update
		looseHeadParts[i][3] = looseHeadParts[i][3] + (Time.dt * -100);
		
		--check if we need to invert gravity for bouncing
		if(y < 240 + looseHeadParts[i][4])then
			looseHeadParts[i][2] = looseHeadParts[i][2] / 3;
			looseHeadParts[i][3] = -looseHeadParts[i][3] / 3;
			y = 240 + looseHeadParts[i][4];
		end
		
		--final move
		looseHeadParts[i][1].MoveToAbs(x,y);
		
		local curVal = looseHeadParts[i][1].color[1];
		if(curVal > generalVal /2)then
			local v = curVal - Time.dt * generalVal
			looseHeadParts[i][1].color = {v,v,v};
		end
		
		looseHeadParts[i][1].SendToBottom();
		
	end
end

local eyeState = {0, 0,0,0,0,0,0};
local eyeAnimationTimers = {-1,-1,-1,-1,-1,-1,-1};

local function UpdateEye(eyeRef, index, isSmall)
	isSmall = isSmall or true;
	
	
	if(eyeAnimationTimers[index] > 0)then
		eyeAnimationTimers[index] = eyeAnimationTimers[index] - Time.dt;
	elseif(eyeState[index] == 1)then
		eyeState[index] = 2;
		eyeRef.StopAnimation();
	end
	--set;
	
	--basically the state when the eye is open, not animating.
	if(eyeState == 2)then
	
		--deduce direction
		--get x and y
		local x = Player.absx - eyeRef.absx;
		local y = Player.absy - eyeRef.absy;
		
		--oh no another square root noooooooo
		local length =  math.sqrt(x*x-y*y);
		
		--x = x/length; --cos get
		local s = y/length; --sin get
		
		--oh no all the taxing operations y u do dis
		local angle = math.asin(s); --note : in rad
		
		angle = angle + math.pi/2; --rotate 90 degrees to check it properly
		
		angle = math.deg(angle) + eyeRef.rotation;
		
		--ensure it's in the right range
		while(angle > 180)do
			angle = angle - 360;
		end
		while(angle < -180)do
			angle = angle + 360;
		end
		
		--Do some string shenanigans
		local dir = "";
		if(angle > 157.5)then
			dir = "Open"
		elseif(angle > 112.5)then
			dir = "Open"
		elseif(angle > 67.5)then
			dir = "R"
		elseif(angle > 22.5)then
			dir = "DR"
		elseif(angle > -22.5)then
			dir = "D"
		elseif(angle > -67.5)then
			dir = "DL"
		elseif(angle > -112.5)then
			dir = "L"
		elseif(angle > -157.5)then
			dir = "Open"
		else
			dir = "Open"
		end
		
		if(isSmall)then
			dir = "Small" .. dir
		end
		
		eyeRef.Set("Happy/tempSprites/eyes/eye" .. dir);
	else
		
		if(isSmall)then
			eyeRef.Set("Happy/tempSprites/eyes/eyeSmallClosed");
			
		else
			eyeRef.Set("Happy/tempSprites/eyes/eyeClosed");
		end
	end
end

local function UpdateEyes()
	if(eyeAnimationTimers[1] > 0)then
		eyeAnimationTimers[1] = eyeAnimationTimers[1] - Time.dt;
	elseif(eyeState[1] == 1)then
		eyeState[1] = 2;
		torsEye.StopAnimation();
		torsEye.Set("Happy/tempSprites/eyes/torsEyeOpen");
	end
	
	if(sprung > 5)then
		if(head2 ~= nil)then
			UpdateEye(head2[2],2);
		end
		if(head3 ~= nil)then
			UpdateEye(head3[2],3);
		end
		if(head4 ~= nil)then
			UpdateEye(head4[2],4);
		end
		if(head5 ~= nil)then
			UpdateEye(head5[2],5);
		end
		if(head6 ~= nil)then
			UpdateEye(head6[2],6);
		end
		if(head7 ~= nil)then
			UpdateEye(head7[2],7);
		end
	end
end
--NOTE TO SELF: index starts at 2
local function ShowEyeLoc(eyeRef, index, isSmall)
	isSmall = isSmall or true;
	
	if(isSmall)then
		--eyeRef.Set("Happy/tempSprites/eyes/eyeOpen");
		eyeRef.SetAnimation({
				"Happy/tempSprites/eyes/eyeOpening1",
				"Happy/tempSprites/eyes/eyeOpening2",
				"Happy/tempSprites/eyes/eyeOpen",
			});--plays 1 frame for 1/30 
		eyeAnimationTimers[index] = 3/30;
	else
		--eyeRef.Set("Happy/tempSprites/eyes/eyeOpen");
		eyeRef.SetAnimation({
				"Happy/tempSprites/eyes/eyeSmallOpening",
				"Happy/tempSprites/eyes/eyeSmallOpen",
			});--plays 1 frame for 1/30 
		eyeAnimationTimers[index] = 2/30;
	end

	eyeState[index] = 1;
end

--Note : bit contrived, put in head array?
function happyAnim.ShowEye(index)
	if(index == 1)then
		torsEye.SetAnimation({"Happy/tempSprites/eyes/torsEyeOpening1",
				"Happy/tempSprites/eyes/torsEyeOpening2",
				"Happy/tempSprites/eyes/torsEyeOpen",});
		--torsEye.Set("Happy/tempSprites/eyes/torsEyeOpen");
		eyeAnimationTimers[index] = 3/30;
		eyeState[index] = 1;
	elseif(index == 2)then
		ShowEyeLoc(head2[2],2);
	elseif(index == 3)then
		ShowEyeLoc(head3[2],3);
	elseif(index == 4)then
		ShowEyeLoc(head4[2],4);
	elseif(index == 5)then
		ShowEyeLoc(head5[2],5);
	elseif(index == 6) then
		ShowEyeLoc(head6[2],6);
	elseif(index == 7) then
		ShowEyeLoc(head7[2],7);
	end
end

function happyAnim.Update()
	timeActive = Time.time - timeStart;

	if (sprung >5) then
		AnimateBigPap();
	elseif(sprung == 0) then
		GentleSway();
	else
		UpdateSpring();
	end
	
	if(shakeTime > 0)then
		local xOffset = math.random(-maxShakeOffset, maxShakeOffset ) * (shakeTime/maxShakeTime);
		local yOffset = math.random(-maxShakeOffset, maxShakeOffset ) * (shakeTime/maxShakeTime);
		legs.MoveTo(320 + xOffset, 240 + yOffset);
		shakeTime = shakeTime - Time.dt;
		if(shakeTime <=0)then
			legs.MoveTo(320 , 240 );
		end
	end

	UpdateEyes();
	
	UpdateDeadItems();
end

function happyAnim.SpringUp()

	--DEBUG("Yo intro");
	LetShitGoDown();
end


---------------------
--Module return value
---------------------
return happyAnim;