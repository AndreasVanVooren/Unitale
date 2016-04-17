-------------------
--Module definition
-------------------

local happyAnim = {};



--------------------------------
--Script Variable Initialization
--------------------------------

local timeStart = Time.time;
local timeActive = 0;

local sprung = false;
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
	
--local head1 = CreateHead(-7.7, 75.57988, 0.5, -0.27, true,0);
--head1[1].SetParent(torso);
--head1[1].y = 12.3;
local head2 = nil --CreateHead(-64.6, 39.6, 0.5, 1, true);
local head3 = nil --CreateHead(80.6, 77.9, 0.5, -0.27, true);
local head4 = nil --CreateHead(80.6, 77.9, 0.5, -0.27, true);
local head5 = nil --CreateHead(80.6, 77.9, 0.5, -0.27, true);
local head6 = nil --CreateHead(80.6, 77.9, 0.5, -0.27, true);
local head7 = nil --CreateHead(80.6, 77.9, 0.5, -0.27, true);

local looseHeadParts = {} --format : { {headpart, velocityX, velocityY} }

legs.Scale(1.6,1.6, true);



local function LetShitGoDown()
	--reset timer
	timeStart = Time.time;
	
	--create bones
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
	
	armNeckHiR = CreateSprite("Happy/tempSprites/armNeckUpperR")
	armNeckHiR.SetParent(neck);
	armNeckHiR.SetAnchor(0.8943, 0.9286);
	armNeckHiR.SetPivot(0.171, 0.0798);
	armNeckHiR.MoveTo(0,0);
	
	armNeckL = CreateSprite("Happy/tempSprites/armNeckL")
	armNeckL.SetParent(neck);
	armNeckL.SetAnchor(0.17, 0.57);
	armNeckL.SetPivot(0.994, 0.374);
	armNeckL.MoveTo(0,0);
	armNeckL.localRotation = armNeckLRot;
	
	armNeckLoR = CreateSprite("Happy/tempSprites/armNeckLowerR")
	armNeckLoR.SetParent(neck);
	armNeckLoR.SetAnchor(0.93939, 0.8914);
	armNeckLoR.SetPivot(0.10067, 0.9942);
	armNeckLoR.MoveTo(0,0);
	
	armUp1 = CreateSprite("Happy/tempSprites/armUpper");
	armUp1.SetParent(torso);
	armUp1.SetAnchor(0.6792037, 0.3424562);
	armUp1.SetPivot(0.5, 1);
	armUp1.MoveTo(0,0);
	
	armUp2 = CreateSprite("Happy/tempSprites/armUpper2");
	armUp2.SetParent(torso);
	armUp2.SetAnchor(0.78, 0.52);
	armUp2.SetPivot(0.5, 0.935167);
	armUp2.MoveTo(-2.5,2);
	armUp2.localRotation = armUp2Rot;
	
	armLo1 = CreateSprite("Happy/tempSprites/armLower");
	armLo1.SetParent(armUp1);
	armLo1.SetAnchor(0.3888889, 0.06450538);
	armLo1.SetPivot(0.06965858, 0.8420351);
	armLo1.MoveTo(0,0);
	
	armLo2 = CreateSprite("Happy/tempSprites/armLower2");
	armLo2.SetParent(armUp2);
	armLo2.SetAnchor(0.5, 0.14);
	armLo2.SetPivot(0.5, 0.02837969);
	armLo2.MoveTo(0,0);
	armLo2.localRotation = armLo2Rot;
	
	armLoL = CreateSprite("Happy/tempSprites/armLowerL");
	armLoL.SetParent(torso);
	armLoL.SetAnchor(0.22,0.965)
	armLoL.SetPivot(1,0.733);
	armLoL.MoveTo(0.4,0);
	
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
	
	--create heads
	head2 = CreateHead(-64.6, 39.6, 0.5, 1, true); -- armLoL
	head3 = CreateHead(0,0, 0.5, -0.27, true); --arm2
	head4 = CreateHead(0,0, 0.5, -0.27, true,2); --neckTop
	head5 = CreateHead(0,0, 0.5, -0.27, true); --neckarmRTop
	head6 = CreateHead(0,0, 0.5, 0, false); --neckArmL
	head7 = CreateHead(0,0, 0.5, 0, false); --neckArmRBot
	
	--create bone frag projectiles springing from thing
	
	Audio.LoadFile("Happy_Loop");
	legs.Scale(1.6,1.6, true);
	sprung = true;
	SetGlobal("isSprung", false);
end

LetShitGoDown();
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

--tentacle thing in bounds : armLol (2)
--tentacle thing out of bounds : hand2 (3)
--burst arms : arm neck top (4)
--head left tentacle = right upper (5)
--head right tentacle = right upper (6)
--lasers any  = right lower (7)

local function UpdateHeads()
	PositionHead(head2, armLoL,-35,-40, 0);
	PositionHead(head3, hand2, 0, 3, 0);
	PositionHead(head4, armNeckTop, 0, 20, 0);
	PositionHead(head5,armNeckHiR,25,30,-60);
	PositionHead(head6,armNeckL,-60,5,180);
	PositionHead(head7,armNeckLoR,25,-15,-20);
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
		Recenter(armUp1);
		Recenter(armLo1);
		Recenter(armUp2,5,armUp2Rot);
		Recenter(armLo2,5,armLo2Rot);
		Recenter(neck);
		Recenter(armNeckL,5,armNeckLRot);
		Recenter(armNeckHiR);
		Recenter(armNeckLoR);
	end
	UpdateHeads();
	
	if(Input.Menu == 1)then
		swaying = not swaying;
		timeStart = Time.time;
		--LetShitGoDown();
	end
end

local function GentleSway()
	if(swaying) then
		torso.localRotation = math.sin(timeActive * math.pi *(76/60) /4 ) * 10;
		head1[1].localRotation = (math.sin(timeActive * math.pi *(76/60) /4 )+1) * 5;
	else
		Recenter(torso);
		Recenter(head1[1]);
	end
	
	if(Input.Menu == 1)then
		--swaying = not swaying;
		--timeStart = Time.time;
		LetShitGoDown();
	end
end

function happyAnim.ToggleSway(newState)
	if(newState == nil)then
		swaying = not swaying;
	else
		swaying = newState;
	end
	
end

function happyAnim.ToggleHand()
	if(hand == nil)then
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

local eyeState = {false, false,false,false,false,false,false};
local eyeAnimationTimers = {-1,-1,-1,-1,-1,-1,-1};

local function UpdateEye(eyeRef, index, isSmall)
	isSmall = isSmall or true;
	
	--deduce direction
	if(eyeAnimationTimers[index] > 0)then
		eyeAnimationTimers[index] = eyeAnimationTimers[index] - Time.dt;
	elseif(eyeState[index] == true)then
		eyeState[index] = false;
		eyeRef.StopAnimation();
	end
	--set;
	if(isSmall)then
		eyeRef.Set("Happy/tempSprites/eyes/eyeSmallOpen");
		
	else
		eyeRef.Set("Happy/tempSprites/eyes/eyeOpen");
	end
end

local function UpdateEyes()
	if(eyeAnimationTimers[1] > 0)then
		eyeAnimationTimers[1] = eyeAnimationTimers[1] - Time.dt;
	elseif(eyeState[1] == true)then
		eyeState[1] = false;
		torsEye.StopAnimation();
	end

	UpdateEye(head2[2],2);
	UpdateEye(head3[2],3);
	UpdateEye(head4[2],4);
	UpdateEye(head5[2],5);
	UpdateEye(head6[2],6);
	UpdateEye(head7[2],7);
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

	eyeState[index] = true;
end

--Note : bit contrived, put in head array?
function happyAnim.ShowEye(index)
	if(index == 1)then
		torsEye.SetAnimation({"Happy/tempSprites/eyes/torsEyeOpening1",
				"Happy/tempSprites/eyes/torsEyeOpening2",
				"Happy/tempSprites/eyes/torsEyeOpen",});
		torsEye.Set("Happy/tempSprites/eyes/torsEyeOpen");
		eyeAnimationTimers[index] = 3/30;
		eyeState[index] = true;
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

	if (sprung) then
		AnimateBigPap();
	else
		GentleSway();
	end

	UpdateEyes();
end

---------------------
--Module return value
---------------------
return happyAnim;