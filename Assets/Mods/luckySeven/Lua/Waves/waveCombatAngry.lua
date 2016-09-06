--note : this wave only gets called if in Genocide mode.

waveState = 0;	--0 = just started, 1 = going back
waveData = 0;
waveTimer = 0;

simulWaveCount = 0;
activeWaveIndices = {};
activeWaves = {};
waveSteps = 0;

toggleWhenDone = false;

function Test1 (i)
		table.insert(activeWaveIndices,i);
end

function Test2 (i,j)

		table.insert(activeWaveIndices,i);
		table.insert(activeWaveIndices,j);
end

local fiveFound = false;
local sixFound = false;
local sevenFound = false;

function PreInitialize()
	--todo : get able heads
	--waveType = math.random(1,7);
	--local heads = Encounter.Call("GetLivingHeads");
	--if(heads == nil)then
	--	DEBUG("ERRSADFSADFSAFDSAFASDFASDFASDFSADFSADF");
	--	Finalize();
	--end

	--local randCount = (#heads)/2;
	--if(randCount < 1)then
	--	randCount = 1;
	--end
	--if(randCount > 2)then
	--	randCount = 2;
	--end


	--simulWaveCount = randCount;
	--local i = 1;
	--while (i <= simulWaveCount and #heads > 0) do
	--	--get a random head from the array
	--	local rand = math.random(1,#heads);
	--	local valid = true;
	--	--insert it in the activeWaveIndices

	--	--if 2 or 3 or 4 is selected, remove the other ones.
	--	if(heads[rand] == 2)then
	--		for j=(#heads),1,-1 do
	--			if(heads[j] == 3 or heads[j] == 4)then
	--				table.remove(heads,j);
	--			end
	--		end
	--	elseif(heads[rand]== 3)then
	--		for j=(#heads),1,-1 do
	--			if(heads[j] == 3 or heads[j] == 2)then
	--				table.remove(heads,j);
	--			end
	--		end
	--	elseif(heads[rand]== 4)then
	--		for j=(#heads),1,-1 do
	--			if(heads[j] == 2 or heads[j] == 3)then
	--				table.remove(heads,j);
	--			end
	--		end
	--	--if 2 of 5,6 or 7 are present, don't add the other to the array.
	--	elseif(heads[rand] == 5)then
	--		if(sixFound and sevenFound)then
	--			valid = false;
	--		end
	--		fiveFound = true;
	--	elseif(heads[rand] == 6)then
	--		if(fiveFound and sevenFound)then
	--			valid = false;
	--		end
	--		sixFound = true;
	--	elseif(heads[rand] == 7)then
	--		if(fiveFound and sixFound)then
	--			valid = false;
	--		end
	--		sevenFound = true;
	--	end

	--	if(valid)then
	--		table.insert(activeWaveIndices, heads[rand]);
	--		i = i+1;
	--	end
	--	--remove head from array against
	--	table.remove(heads,rand);

	--end

	--test data
	Test2(7,5);
	fiveFound = true;
	simulWaveCount = 2;

	table.sort(activeWaveIndices);
	waveState = 0;
	waveData = 0;
	Encounter.Call("ToggleSway",false);
end

function Finalize()
	if(toggleWhenDone)then
		Encounter.Call("ToggleHand");
	end
	Encounter.Call("HideEyes");
	EndWave();
end

function CreateHandProjectile(initX,initY)
	local hand = CreateProjectileAbs("Happy/tempSprites/hand1",initX,initY);
	hand.SetCollider("Circle");
	hand.SetCircleColliderSize(9.65);
	hand.SetColliderOffset(-0.76,-2.33);
	hand.sprite.SetPivot(0.1571406, 0.17743);
	hand.sprite.Scale(1.6,1.6);

	return hand;
end

local lHeadI = 1;
local lSideI = 2;
local lTimeI = 3;
local lCountI = 4;
local lInitXI = 5;
local lInitYI = 6;
local lSpecChanceI = 7;
local lNormChanceI = 8;
local lBeamXI = 9;
local lBeamYI = 10;
local lBeamArrStartI = 11;

function InitLasers(side)
	Encounter.Call("ShowEye7");
	if(waveSteps < 1)then
		waveSteps = 1;
	end

	local side = side or math.random(0,1);
	local head = nil;
	local initSprite = "";
	local initX = 0;
	local initY = 0;
	local beamInitX = 0;
	local beamInitY = 0;
	if((side % 2) == 1)then
		initX = Arena.width/3;
		initY = Arena.height/8;
		initSprite = "Happy/tempSprites/attacks/headAimL";
		beamInitX = initX - (25 / 3 * 2) ;
		beamInitY = Arena.height/8*3 - 10;
	else
		initX = -Arena.width/3;
		initY = Arena.height/8;
		initSprite = "Happy/tempSprites/attacks/headAimR";
		beamInitX = initX + (25 / 3 * 2) ;
		beamInitY = Arena.height/8*3 - 10;
	end


	head = CreateProjectile(initSprite,initX,initY);
	head.SendToBottom();
	head.sprite.Scale(3,3);
	return {head,side,0,0,initX,initY,1,1, beamInitX,beamInitY};
end

function UpdateLasers(bulletArr, beamCount, useOrange, travelTime, descentDelay)
	local counter = bulletArr[lCountI];
	local timer = bulletArr[lTimeI] + Time.dt;
	bulletArr[lTimeI] = timer;
	if(counter < beamCount)then
		if(timer > 0.01)then
			--DEBUG("beep")
			local beam = CreateProjectile("Happy/tempSprites/attacks/beam",bulletArr[lBeamXI],bulletArr[lBeamYI])

			local side = bulletArr[lSideI];
			if((side%2) == 1)then
				beam.sprite.SetPivot(1,0.5);
				bulletArr[lBeamXI] = bulletArr[lBeamXI] - 20;
			else
				beam.sprite.SetPivot(0,0.5);
				bulletArr[lBeamXI] = bulletArr[lBeamXI] + 20;
			end
			beam.SetVar("dmg",5);
			local isSpecial = math.random();
			local chance = bulletArr[lSpecChanceI] / (bulletArr[lSpecChanceI] + bulletArr[lSpecChanceI])
			if(isSpecial < chance)then
				bulletArr[lSpecChanceI] = bulletArr[lSpecChanceI] - 1;
				bulletArr[lSpecChanceI] = bulletArr[lSpecChanceI] + 1;
				if(useOrange)then
					beam.SetVar("orange",true);
					beam.sprite.color = {255/255, 154/255, 34/255};
				else
					beam.SetVar("blue",true);
					beam.sprite.color = {0/255, 162/255, 232/255};
				end
			else
				bulletArr[lSpecChanceI] = bulletArr[lSpecChanceI] + 1;
			end

			bulletArr[lBeamArrStartI+counter] = beam;

			bulletArr[lTimeI] = 0;
			bulletArr[lCountI] = counter + 1;

		end
	else
		if(timer > descentDelay)then
			--make head descend
			local travelTimer = timer - descentDelay;
			local initX = bulletArr[lInitXI];
			local initY = bulletArr[lInitYI];
			bulletArr[lHeadI].MoveTo(initX, initY - (initY * 2) * travelTimer/travelTime);

			--make all lasers descend
			for i=lBeamArrStartI, (lBeamArrStartI+beamCount-1)do
				local beamX = bulletArr[i].x;
				local beamY = bulletArr[lBeamYI] - (Arena.height/8*5 - 20) * travelTimer/travelTime;
				bulletArr[i].MoveTo(beamX, beamY);
			end

			if(travelTimer > travelTime)then
				return true;	--I'm done
			end
		end
	end
end

local eHandI = 1;
local eExtraI = 2;
local eBoneCI = 3;
local eGoesBackI = 4;
local eLimitI = 5;
local eInitXI = 6;
local eInitYI = 7;
local eRotVI = 8;
local eTimeI = 9;
local eBoneStartI = 10;

function InitWaveExtrude(index,startTime, startRand, startRot)
	--disable hand
	Encounter.Call("ToggleHand");
	toggleWhenDone = true;
	if(index >= 2 and index <= 7)then
		Encounter.Call("ShowEye" .. index);
	end
	if(waveSteps < 2)then
		waveSteps = 2;
	end

	--this has to be hardcoded, reason being fuck you.
	local initX = 395.867095947266;
	local initY = 279.202453613281;
	local hand = CreateHandProjectile(initX,initY);
	hand.SetVar("dmg",6);
	hand.canCollideWithProjectiles = true;
	--wave 2 pattern : hand ref, time to chuck,x pos, y pos, rotation speed

	return {hand, nil, 0,false,startTime + (math.random() * startRand) ,initX, initY, startRot,0}
end

function UpdateWaveBoneExtrude(
				bulletTable,
				baseTimer,
				counterTimeDecrease,
				randomInfluence,
				rotSpeedIncrease,
				repeatCount,
				targetX,
				targetY,
				possibilities,
				lengths,
				needsToWait)

	--default variables
	possibilities = possibilities or {
			"Happy/tempSprites/attacks/atkBone1",
			"Happy/tempSprites/attacks/atkBone2",
			"Happy/tempSprites/attacks/atkBone3",
			"Happy/tempSprites/attacks/atkBone4",
		};
	lengths = lengths or {72,104,60,112};
	if(needsToWait == nil)then needsToWait = false; end

	local transition = 0;

	local counter = bulletTable[eBoneCI];
	local isGoingBack = bulletTable[eGoesBackI];
	local hand = bulletTable[eHandI];
	local timerlimit = bulletTable[eLimitI];
	local x = bulletTable[eInitXI];
	local y = bulletTable[eInitYI];
	local rotSpeed = bulletTable[eRotVI];
	local timer = bulletTable[eTimeI] + Time.dt;
	bulletTable[eTimeI] = timer;

	hand.MoveToAbs( x + math.random(-2,2), y + math.random(-2,2));
	local curRot = hand.sprite.rotation;

	local vecX = (targetX - x);
	local vecY = (targetY - y);
	local length = math.sqrt((vecX * vecX) + (vecY * vecY));
	local vCos = vecX/length;
	local vSin = vecY/length;
	local angle = math.deg( math.atan2(vSin,vCos) );

	--DEBUG ("RotSpeed : ".. rotSpeed);

	while (angle < -180) do
		angle = angle + 360;
	end
	while (angle >= 180) do
		angle = angle - 360;
	end
	--DEBUG ("Angle 2nd pass : ".. angle);

	while(curRot - angle > 180)do
		curRot = curRot - 360;
	end
	while (angle - curRot > 180)do
		curRot = curRot + 360;
	end

	local diff = Time.dt*rotSpeed;

	if (curRot > angle ) then

		curRot = curRot - diff;
		if(curRot < angle) then
			curRot = angle;
		end
	elseif ( curRot <angle ) then

		curRot = curRot + diff;
		if(curRot > angle ) then
			curRot = angle;
		end
	else
		diff = 0;
	end

	--DEBUG ("Cur rot : ".. curRot);

	hand.sprite.rotation = curRot;

	if(isGoingBack ~= true)then
		if(timer > timerlimit)then
			--CHAKKA
			--if x out of bounds NOW, wrap around

			if(counter >= repeatCount) then
				if(needsToWait)then
					return true;
				end
				bulletTable[eGoesBackI] = true;
				bulletTable[eLimitI] = 1.0;
				bulletTable[eRotVI] = 0;
				return;
			end

			if(x > 650 or x < -10)then
				x = 640-x;
				transition = 1;
			end

			local i = math.random(1,#possibilities);

			local bone = CreateProjectileAbs(possibilities[i], x,y);
			bone.SetVar("dmg",4);
			bone.sprite.SetPivot(0,0.5);
			bone.sprite.rotation = curRot;
			x = x + math.cos( math.rad(curRot) )*lengths[i];
			y = y + math.sin( math.rad(curRot) )*lengths[i];
			hand.MoveToAbs(x,y);

			bulletTable[eBoneCI] = counter + 1;
			local newTime = baseTimer - (counterTimeDecrease*waveCounter);
			if(newTime < 0.0)then
				newTime = 0;
			end
			bulletTable[eLimitI] = newTime + (math.random() * randomInfluence);
			bulletTable[eInitXI] = x;
			bulletTable[eInitYI] = y;
			bulletTable[eRotVI] = rotSpeed + rotSpeedIncrease;
			bulletTable[eTimeI] = 0;
			bulletTable[eBoneStartI + counter-1] = bone;
		end
	else
		if(timer > timerlimit)then
			if(counter <= 1)then
				--do end wave stuff
				return true;
			end

			local bone = bulletTable[eBoneStartI + counter - 1];
			hand.MoveToAbs(bone.absx, bone.absy);

			bulletTable[eLimitI] = 0.5;
			bulletTable[eInitXI] = bone.absx;
			bulletTable[eInitYI] = bone.absy;
			hand.sprite.rotation = bone.sprite.rotation;
			bulletTable[eRotVI] = 0;

			bone.Remove();

			bulletTable[eBoneCI] = counter - 1;
			bulletTable[eTimeI] = 0;
		end
	end
	return transition;
end

local bStateI = 1;

local b1HandI = 2;
local b1TimerI = 3;
local b1InitXI = 4;
local b1InitYI = 5;
local b1RotVI = 6;

local b2BurstCI = 2;
local b2TimerI = 3;
local b2PartSysI = 4;

function InitWaveBurst()
	Encounter.Call("ToggleHand");
	Encounter.Call("ShowEye4");

	if(waveSteps < 1)then
		waveSteps = 1;
	end

	--this has to be hardcoded, reason being fuck you.
	local initX = 395.867095947266;
	local initY = 279.202453613281;
	local hand = CreateHandProjectile(initX,initY);
	return {0,hand,0,initX,initY, 80};
end

function WaveBurstWarmup(bulletArr,targetX,targetY)
	local hand = bulletArr[b1HandI];
	local x = bulletArr[b1InitXI];
	local y = bulletArr[b1InitYI];
	local rotSpeed = bulletArr[b1RotVI];
	local curRot = hand.sprite.rotation;
	local timer = bulletArr[b1TimerI] + Time.dt;
	bulletArr[b1TimerI] = timer;

	hand.MoveToAbs( x + math.random(-2,2), y + math.random(-2,2));

	local vecX = (targetX - x);
	local vecY = (targetY - y);
	local length = math.sqrt((vecX * vecX) + (vecY * vecY));
	local vCos = vecX/length;
	local vSin = vecY/length;
	local angle = math.deg( math.atan2(vSin,vCos) );

	--DEBUG ("RotSpeed : ".. rotSpeed);

	while (angle < -180) do
		angle = angle + 360;
	end
	while (angle >= 180) do
		angle = angle - 360;
	end
	--DEBUG ("Angle 2nd pass : ".. angle);

	while(curRot - angle > 180)do
		curRot = curRot - 360;
	end
	while (angle - curRot > 180)do
		curRot = curRot + 360;
	end

	local diff = Time.dt*rotSpeed;

	if (curRot > angle ) then

		curRot = curRot - diff;
		if(curRot < angle) then
			curRot = angle;
		end
	elseif ( curRot <angle ) then

		curRot = curRot + diff;
		if(curRot > angle ) then
			curRot = angle;
		end
	else
		diff = 0;
	end

	--DEBUG ("Cur rot : ".. curRot);

	hand.sprite.rotation = curRot;

	if(timer > 0.75)then
		hand.Remove();
		local arm = CreateProjectileAbs("Happy/tempSprites/attacks/burstHandDug",x,y);
		arm.sprite.SetPivot(0,1);
		arm.sprite.Scale(1.6,1.4);
		bulletArr[bStateI] = 1;
	end
end

function CreateArm(x, dist,targetYMin,targetYMax)
	local y = -dist + math.random(targetYMin,targetYMax);

	local hand = CreateProjectile("Happy/tempSprites/attacks/burstHand",x,y);
	hand.sprite.SetPivot(0.5,0);
	hand.sprite.Scale(1.6,1.6);
	hand.SetVar("dmg",6);

	local rand = math.random(0,1);
	local arm = CreateProjectile("Happy/tempSprites/attacks/burstBone1",x,y);
	if(rand == 0)then
		arm.sprite.SetPivot(0.5,1);
	else
		arm.sprite.rotation = 180;
		arm.sprite.SetPivot(0.5,0);
	end

	arm.sprite.Scale(1.6,1.6);
	arm.SetVar("dmg",4);

	return {hand,arm};
end

function UpdateWaveBoneBurst(bulletArr,travelDistance,travelTime,targetYMin,targetYMax)
	local data = bulletArr[bStateI];
	if(data == 0)then		--first phase (hand in ground)
		WaveBurstWarmup(bulletArr,437,209);
	elseif(data == 1)then
		for k in pairs (bulletArr) do
			if(k ~= bStateI)then
				bulletArr[k] = nil
			end
		end
		--create arms below the screen, create particles below spawn points
		local burstAmount = math.random(3,7);
		local partSystem = require "Libraries/ParticleManager";
		table.insert(bulletArr,burstAmount);
		table.insert(bulletArr,0);
		table.insert(bulletArr,partSystem);
		for i=1,burstAmount do
			local spawnPosX = math.random(-Arena.width*3/8,Arena.width*3/8);
			table.insert(bulletArr,spawnPosX);
			table.insert(bulletArr,CreateArm(spawnPosX,travelDistance,targetYMin,targetYMax));
			--create a particle system
			partSystem.CreateParticles({"Happy/tempSprites/particles/ground"},
										spawnPosX,
										-Arena.height/2,
										0.05,
										0.2,
										-100,100, 100,300,
										-1600,
										-40,40,
										20);
		end
		bulletArr[bStateI] = 2;
	elseif(data == 2)then
		local timer = bulletArr[b2TimerI] + Time.dt;
		bulletArr[b2TimerI] = timer;
		local partSystem = bulletArr[b2PartSysI];
		if(timer < travelTime )then
			local burstAmount = bulletArr[b2BurstCI];
			for i=0,burstAmount-1 do
				local index = 4 + i*2;
				local arm = bulletArr[index+1];
				arm[1].MoveTo( bulletArr[index], arm[1].y + travelDistance * Time.dt/travelTime );
				arm[2].MoveTo( bulletArr[index], arm[2].y + travelDistance * Time.dt/travelTime );
			end

		elseif(timer > travelTime + 1.0)then
			return true;
		end
		partSystem.UpdateParticles();
	end
end

function InitHeadExtrude(side,startTime, startRand, startRot)
	local initSprite = "";
	local initX = 0;
	local initY = 0;
	local initHandRot = 0;
	if( (type(side) == "string" and side == "right") or
		(type(side) == "number" and (side%2) == 1) )then
		initX = Arena.width/2 - 50;
		initY = 0;
		initSprite = "Happy/tempSprites/attacks/headAimL";
		Encounter.Call("ShowEye6");
		initHandRot = 180;
	elseif( (type(side) == "string" and side == "left") or
			(type(side) == "number" and (side%2) == 0 ))then
		initX = -Arena.width/2+50;
		initY = 0;
		initSprite = "Happy/tempSprites/attacks/headAimR";
		Encounter.Call("ShowEye5");
	end
	local head = CreateProjectile(initSprite,initX,initY);	--autodestroys upon wave end
	head.sprite.Scale(3,3);
	head.SendToBottom();
	local handInitX = head.absx;
	local handInitY = head.absy + Arena.height/8*1 - 10;

	--initWaveExtrude also deals with toggle hand and bool setup
	local wave = InitWaveExtrude(-1,startTime,startRand,startRot);
	local hand = wave[eHandI];
	hand.MoveToAbs(handInitX,handInitY);
	hand.sprite.rotation = initHandRot;
	wave[eExtraI] = head;
	wave[eInitXI] = handInitX;
	wave[eInitYI] = handInitY;
	return wave;
end

function CreateWave(waveType)
	DEBUG("IJJIJ" .. waveType);
	if(waveType == 2)then		--tentacle thing in/out bounds
		return InitWaveExtrude(2, 1.5, 0.5, 30);
	elseif(waveType==3)then
		return InitWaveExtrude(3, 1.1, 0.3, 80);
	elseif(waveType == 4)then	--burst arms
		return InitWaveBurst();
	elseif(waveType == 5)then	--burst arms + laser
		return InitHeadExtrude("left",1.5, 0.5, 60);
	elseif(waveType == 6)then
		return InitHeadExtrude("right",1.5, 0.5, 60);
	elseif(waveType == 7)then	--laser
		if(fiveFound)then
			return InitLasers(1);
		elseif(sixFound)then
			return InitLasers(0);
		else
			return InitLasers();
		end
	else
		DEBUG("Invalid wave index found");
	end
end

PreInitialize();

function UpdateWaves(waveBullets, waveType)
	if(waveType == 2)then		--tentacle thing in/out bounds
		return UpdateWaveBoneExtrude(waveBullets, 1.5, 0.3, 0.5, 10, 5, Player.absx, Player.absy,nil,nil,(waveData == 0));
	elseif(waveType==3)then
		local x = Player.absx;
		if(waveBullets[eExtraI] ~=1 and waveBullets[eBoneCI] >= 2 )then
			x = x + 640;
		end
		local val = UpdateWaveBoneExtrude(
						waveBullets, 			--ref bullets
						1.1,					--base timer
						0.08,					--counter time decrease
						0.3, 					--random factor
						1,
						12,
						x,
						Player.absy,
						{
							"Happy/tempSprites/attacks/atkBone2",
							"Happy/tempSprites/attacks/atkBone4"
						},
						{104,112},				--possibility lengths,
						(waveData == 0)
					);
		if(val == 1 and waveBullets[eExtraI] ~= 1)then
			waveBullets[eExtraI] = 1;
		end
		if(val ~= true)then
			return false;
		else
			return true;
		end

	elseif(waveType == 4)then	--burst arms
		return UpdateWaveBoneBurst(waveBullets,1500, 1.5,Arena.height/8,Arena.height*3/8);
	elseif(waveType == 5)then	--burst arms + laser
		return UpdateWaveBoneExtrude(
			waveBullets, 			--ref bullets
			1.1,					--base timer
			0.08,					--counter time decrease
			0.3, 					--random factor
			1,
			5,
			Player.absx,
			Player.absy,
			{
				"Happy/tempSprites/attacks/atkBoneSmall1",
				"Happy/tempSprites/attacks/atkBoneSmall2"
			},
			{36,34},				--possibility lengths
			(waveData == 0)
		);
	elseif(waveType == 6)then
		return UpdateWaveBoneExtrude(
			waveBullets, 			--ref bullets
			1.1,					--base timer
			0.08,					--counter time decrease
			0.3, 					--random factor
			1,
			5,
			Player.absx,
			Player.absy,
			{
				"Happy/tempSprites/attacks/atkBoneSmall1",
				"Happy/tempSprites/attacks/atkBoneSmall2"
			},
			{36,34},				--possibility lengths
			(waveData == 0)
		);
	elseif(waveType == 7)then	--laser
		--only use blue lasers when no other wave is playing
		return UpdateLasers(waveBullets,10,(simulWaveCount <= 1),2,0.75);
	else
		DEBUG("Invalid wave index found");
	end
end

function Update()
	waveTimer = waveTimer + Time.dt;
	if(waveState == 0)then
		if(waveTimer > 1) then
			waveTimer = 0;
			waveState = 1;
			for i=1,simulWaveCount do
				local wave = CreateWave( activeWaveIndices[i] );
				if(wave == nil)then
					DEBUG("AAAAAAAAAAAH")
					Finalize();
				else
					activeWaves[i] = wave;
				end
			end
		end
	elseif(waveState == 1)then
		local allTrue = true;
		for i=1,simulWaveCount do
			local wave = activeWaves[i];
			local index = activeWaveIndices[i];
			allTrue = allTrue and (UpdateWaves(wave,index) == true);
			if(allTrue)then
				if(waveData < waveSteps-1)then
					waveData = waveData + 1;
				else
					Finalize();
				end
			end
		end
	end
end

--function OldUpdate()
--	waveTimer = waveTimer + Time.dt;
--	if(waveState == 0)then
--		if(waveTimer > 1)then
--			CreateWave();
--			waveTimer = 0;
--			waveState = 1;
--		end
--	elseif(waveState == 1)then
--		if(waveType == 1)then
--			UpdateLasers(waveBullets1,10,false,2,0.75);
--		elseif(waveType == 2)then		--tentacle thing in bounds
--			UpdateWaveBoneExtrude(waveBullets1, 1.5, 0.3, 0.5, 10, 5, Player.absx, Player.absy,nil,nil);
--		elseif(waveType == 3)then	--tentacle thing out of bounds
--
--			local x = Player.absx;
--
--			if(waveData == 0 and waveCounter >= 2 )then
--				x = x + 640;
--			end
--
--			if(UpdateWaveBoneExtrude(
--				waveBullets1, 			--ref bullets
--				1.1,					--base timer
--				0.08,					--counter time decrease
--				0.3, 					--random factor
--				1,
--				12,
--				x,
--				Player.absy,
--				{
--					"Happy/tempSprites/attacks/atkBone2",
--					"Happy/tempSprites/attacks/atkBone4"
--				},
--				{104,112}				--possibility lengths
--			) == true and waveData == 0 )then
--				waveData = 1;
--			end
--		elseif(waveType == 4)then	--burst arms
--			UpdateWaveBoneBurst(waveBullets1,1500, 1.5,Arena.height/8,Arena.height*3/8);
--		elseif(waveType == 5)then	--head both tentacle
--			UpdateWaveBoneExtrude(
--				waveBullets1, 			--ref bullets
--				1.1,					--base timer
--				0.08,					--counter time decrease
--				0.3, 					--random factor
--				1,
--				5,
--				Player.absx,
--				Player.absy,
--				{
--					"Happy/tempSprites/attacks/atkBoneSmall1",
--					"Happy/tempSprites/attacks/atkBoneSmall2"
--				},
--				{36,34},				--possibility lengths
--				false
--			);
--		elseif(waveType == 6)then	--head right tentacle
--			if(waveData < 4) then
--				if(UpdateWaveBoneExtrude(
--					waveBullets1, 			--ref bullets
--					1.1,					--base timer
--					0.08,					--counter time decrease
--					0,						--random factor
--					1,
--					5,
--					Player.absx,
--					Player.absy,
--					{
--						"Happy/tempSprites/attacks/atkBoneSmall1",
--						"Happy/tempSprites/attacks/atkBoneSmall2"
--					},
--					{36,34},				--possibility lengths
--					false,
--					(waveData == 0),
--					true
--				)
--				and
--				UpdateWaveBoneExtrude(
--					waveBullets2, 			--ref bullets
--					1.1,					--base timer
--					0.08,					--counter time decrease
--					0,	 					--random factor
--					1,
--					5,
--					Player.absx,
--					Player.absy,
--					{
--						"Happy/tempSprites/attacks/atkBoneSmall1",
--						"Happy/tempSprites/attacks/atkBoneSmall2"
--					},
--					{36,34},				--possibility lengths
--					false,
--					(waveData == 0),
--					true
--				))then
--					if(waveData == 0)then
--						waveData = 1;
--					else
--						Encounter.Call("ToggleHand");
--						Encounter.Call("HideEyes");
--						EndWave();
--					end
--				end
--			elseif (waveTimer >= 1.0)then
--				--Encounter.Call("ToggleHand");
--				Encounter.Call("HideEyes");
--				EndWave();
--			end
--		elseif(waveType == 7)then	--lasers + burst?
--			UpdateWaveBoneBurst(waveBullets1,1500,1.5, -Arena.height*2/8,-Arena.height*3/8);
--			UpdateLasers(waveBullets2,10,true,2.5,0.25);
--
--	end
--
--end


function OnHit(bullet)
	local dmg = bullet.GetVar("dmg");
	if(dmg ~= nil and dmg > 0)then
		if(bullet.GetVar("blue")==true)then
			if(Player.isMoving)then
				Player.Hurt(dmg);
			end
		elseif(bullet.GetVar("orange")==true)then
			if(not Player.isMoving)then
				Player.Hurt(dmg);
			end
		else
			Player.Hurt(dmg);
		end
	end
end

function OnHitProjectile(bullet,other)
	if(bullet.isactive and other.isactive)then
		--bullet.Remove();
		--other.Remove();
		--do the eye glowey thing
		waveData = 999;
		waveTimer = 0;
	end
end
