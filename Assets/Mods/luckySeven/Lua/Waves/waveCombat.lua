--OnWaveStart doesn't exist?
--DEBUG("Bepis");

waveTimer = 0;
waveState = 0;	--0 = just started, 1 = recentering
waveType = 0;
waveCounter = 0;
waveData = 0;

waveBullets1 = {};
waveBullets2 = {};
isWaveEnding = false;


function PreInitialize()
	--todo : get able heads
	waveType = math.random(7,7);
	waveState = 0;
	isWaveEnding = false;
	waveTimer = 0;
	waveCounter = 0;
	waveData = 0;
	Encounter.Call("ToggleSway",false);
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

function CreateWave()
	waveCounter = 0;
	if(waveType == 1)then	--laser
		Encounter.Call("ShowEye7");
		local side = math.random(0,1);
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

		--DEBUG("1st pass " .. waveData % 2)

		head = CreateProjectile(initSprite,initX,initY);
		waveBullets1 = {head,side,0,initX,initY,1,1, beamInitX,beamInitY};
		head.SendToBottom();
		head.sprite.Scale(3,3);
	elseif(waveType == 2 or waveType == 3)then		--tentacle thing in/out bounds

		--disable hand
		Encounter.Call("ToggleHand");
		Encounter.Call("ShowEye" .. waveType);

		--this has to be hardcoded, reason being fuck you.
		local initX = 395.867095947266;
		local initY = 279.202453613281;
		local hand = CreateHandProjectile(initX,initY);
		hand.SetVar("dmg",6);

		--wave 2 pattern : hand ref, time to chuck,x pos, y pos, rotation speed
		if(waveType == 2)then
			waveBullets1 = {hand, 1.5 + (math.random() * 0.5) ,initX, initY, 30,0}
		else
			waveBullets1 = {hand, 1.1 + (math.random() * 0.3) ,initX, initY, 80,0}
		end

	elseif(waveType == 4)then	--burst arms
		Encounter.Call("ToggleHand");
		Encounter.Call("ShowEye4");

		--this has to be hardcoded, reason being fuck you.
		local initX = 395.867095947266;
		local initY = 279.202453613281;
		local hand = CreateHandProjectile(initX,initY);
		waveBullets1 = {hand,initX,initY, 80};
	elseif(waveType == 5)then	--burst arms + laser
		local rand = math.random(0, 1);
		local initSprite = "";
		local initX = 0;
		local initY = 0;
		local initHandRot = 0;
		if(rand == 1)then
			initX = Arena.width/2 - 50;
			initY = 0;
			initSprite = "Happy/tempSprites/attacks/headAimL";
			Encounter.Call("ShowEye6");
			initHandRot = 180;
		else
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

		local hand = CreateHandProjectile(handInitX,handInitY);
		hand.SetVar("dmg",6);
		hand.sprite.rotation = initHandRot;
		waveBullets1 = {hand, 1.5 + (math.random() * 0.5) ,handInitX, handInitY, 60,0};

	elseif(waveType == 6)then	--head tentacle arena
		local head1 = CreateProjectile("Happy/tempSprites/attacks/headAimR",-Arena.width/2+50,0);	--autodestroys upon wave end
		head1.sprite.Scale(3,3);
		head1.SendToBottom();
		Encounter.Call("ShowEye5");

		local handInitX1 = head1.absx;
		local handInitY1 = head1.absy + Arena.height/8*1 - 10;

		local hand1 = CreateHandProjectile(handInitX1,handInitY1);
		hand1.canCollideWithProjectiles = true;
		hand1.SetVar("dmg",6);
		waveBullets1 = {hand1, 1.3 ,handInitX1, handInitY1, 60,0};

		local head2 = CreateProjectile("Happy/tempSprites/attacks/headAimL",Arena.width/2-50,0);	--autodestroys upon wave end
		head2.sprite.Scale(3,3);
		head2.SendToBottom();
		Encounter.Call("ShowEye5");

		local handInitX2 = head2.absx;
		local handInitY2 = head2.absy + Arena.height/8*1 - 10;

		local hand2 = CreateHandProjectile(handInitX2,handInitY2);
		hand2.canCollideWithProjectiles = true;
		hand2.SetVar("dmg",6);
		hand2.sprite.rotation = 180;
		waveBullets2 = {hand2, 1.3 ,handInitX2, handInitY2, 60,0};
	elseif(waveType == 7)then	--lasers any
		Encounter.Call("ToggleHand");
		Encounter.Call("ShowEye4");
		Encounter.Call("ShowEye7");

		--this has to be hardcoded, reason being fuck you.
		local initX = 395.867095947266;
		local initY = 279.202453613281;
		local hand = CreateHandProjectile(initX,initY);
		waveBullets1 = {hand,initX,initY, 80};

		local side = math.random(0,1);
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

		--DEBUG("1st pass " .. waveData % 2)

		head = CreateProjectile(initSprite,initX,initY);
		waveBullets2 = {head,side,0,initX,initY,1,1, beamInitX,beamInitY};
		head.SendToBottom();
		head.sprite.Scale(3,3);

	end

end

PreInitialize();

function UpdateLasers(bulletArr, beamCount, useOrange, travelTime, descentDelay)
	local timer = bulletArr[3] + Time.dt;
	bulletArr[3] = timer;
	if(waveCounter < beamCount)then
		if(timer > 0.01)then
			--DEBUG("beep")
			local beam = CreateProjectile("Happy/tempSprites/attacks/beam",bulletArr[8],bulletArr[9])
			--DEBUG("2nd pass " .. waveData % 2)
			local side = bulletArr[2];
			if((side) == 1)then
				beam.sprite.SetPivot(1,0.5);
				bulletArr[8] = bulletArr[8] - 20;
			else
				beam.sprite.SetPivot(0,0.5);
				bulletArr[8] = bulletArr[8] + 20;
			end
			beam.SetVar("dmg",5);
			local isSpecial = math.random();
			local chance = bulletArr[6] / (bulletArr[6] + bulletArr[7])
			if(isSpecial < chance)then
				bulletArr[6] = bulletArr[6] - 1;
				bulletArr[7] = bulletArr[7] + 1;
				if(useOrange)then
					beam.SetVar("orange",true);
					beam.sprite.color = {255/255, 154/255, 34/255};
				else
					beam.SetVar("blue",true);
					beam.sprite.color = {0/255, 162/255, 232/255};
				end
			else
				bulletArr[6] = bulletArr[6] + 1;
			end

			bulletArr[10+waveCounter] = beam;

			bulletArr[3] = 0;
			waveCounter = waveCounter + 1;

		end
	else
		if(timer > descentDelay)then
			--make head descend
			local travelTimer = timer - descentDelay;
			local initX = bulletArr[4];
			local initY = bulletArr[5];
			bulletArr[1].MoveTo(initX, initY - (initY * 2) * travelTimer/travelTime);

			--make all lasers descend
			for i=10, (10+beamCount-1)do
				local beamX = bulletArr[i].x;
				local beamY = bulletArr[9] - (Arena.height/8*5 - 20) * travelTimer/travelTime
				bulletArr[i].MoveTo(beamX, beamY);
			end

			if(travelTimer > travelTime)then
				Encounter.Call("HideEyes");
				EndWave();
			end
		end
	end
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
				toggleHandAfterEnd)

	possibilities = possibilities or {
			"Happy/tempSprites/attacks/atkBone1",
			"Happy/tempSprites/attacks/atkBone2",
			"Happy/tempSprites/attacks/atkBone3",
			"Happy/tempSprites/attacks/atkBone4",
		};
	lengths = lengths or {72,104,60,112};
	if(toggleHandAfterEnd == nil)then toggleHandAfterEnd = true; end
	local transition = false;
	local hand = bulletTable[1];
	local timerlimit = bulletTable[2];
	local x = bulletTable[3];
	local y = bulletTable[4];
	local rotSpeed = bulletTable[5];
	local timer = bulletTable[6] + Time.dt;
	bulletTable[6] = timer;

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

	if(isWaveEnding ~= true)then
		if(timer > timerlimit)then
			--CHAKKA
			--if x out of bounds NOW, wrap around

			if(waveCounter >= repeatCount) then
				isWaveEnding = true;
				bulletTable[2] = 1.0;
				bulletTable[5] = 0;
				return;
			end

			if(x > 650 or x < -10)then
				x = 640-x;
				transition = true;
			end

			local i = math.random(1,#possibilities);

			local bone = CreateProjectileAbs(possibilities[i], x,y);
			bone.SetVar("dmg",4);
			bone.sprite.SetPivot(0,0.5);
			bone.sprite.rotation = curRot;
			x = x + math.cos( math.rad(curRot) )*lengths[i];
			y = y + math.sin( math.rad(curRot) )*lengths[i];
			hand.MoveToAbs(x,y);

			waveCounter = waveCounter + 1;

			bulletTable[2] = baseTimer - (counterTimeDecrease*waveCounter) + (math.random() * randomInfluence);
			bulletTable[3] = x;
			bulletTable[4] = y;
			bulletTable[5] = rotSpeed + rotSpeedIncrease;
			bulletTable[6] = 0;
			bulletTable[7 + waveCounter-1] = bone;



		end
	else
		if(waveTimer > timerlimit)then
			if(waveCounter <= 1)then
				--do end wave stuff
				if(toggleHandAfterEnd == true)then
					Encounter.Call("ToggleHand");
				end
				Encounter.Call("HideEyes");
				EndWave();
				return;
			end

			local bone = bulletTable[7 + waveCounter - 1];
			hand.MoveToAbs(bone.absx, bone.absy);

			bulletTable[2] = 0.5;
			bulletTable[3] = bone.absx;
			bulletTable[4] = bone.absy;
			hand.sprite.rotation = bone.sprite.rotation;
			bulletTable[5] = 0;

			bone.Remove();

			waveCounter = waveCounter - 1;
			waveTimer = 0;
		end
	end
	return transition;
end

function WaveBurstWarmup(bulletArr,targetX,targetY)
	local hand = bulletArr[1];
	local x = bulletArr[2];
	local y = bulletArr[3];
	local rotSpeed = bulletArr[4];
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

	if(waveTimer > 0.75)then
		hand.Remove();
		local arm = CreateProjectileAbs("Happy/tempSprites/attacks/burstHandDug",x,y);
		arm.sprite.SetPivot(0,1);
		arm.sprite.Scale(1.6,1.4);
		bulletArr = {};
		waveData = 1;
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
	if(waveData == 0)then		--first phase (hand in ground)
		WaveBurstWarmup(bulletArr,437,209);
	elseif(waveData == 1)then
		for k in pairs (bulletArr) do
			bulletArr[k] = nil
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
		waveData = 2;
	elseif(waveData == 2)then
		local timer = bulletArr[2] + Time.dt;
		bulletArr[2] = timer;
		local partSystem = bulletArr[3];
		if(timer < travelTime )then
			local burstAmount = bulletArr[1];
			for i=0,burstAmount-1 do
				local index = 4 + i*2;
				local arm = bulletArr[index+1];
				arm[1].MoveTo( bulletArr[index], arm[1].y + travelDistance * Time.dt/travelTime );
				arm[2].MoveTo( bulletArr[index], arm[2].y + travelDistance * Time.dt/travelTime );
			end

		elseif(timer > travelTime + 1.0)then
			Encounter.Call("ToggleHand");
			Encounter.Call("HideEyes");
			EndWave();
		end
		partSystem.UpdateParticles();
	end
end

function UpdateWave5()

end

function UpdateWave6()

end

function UpdateWave7()

end

function Update()
	waveTimer = waveTimer + Time.dt;
	if(waveState == 0)then
		if(waveTimer > 1)then
			CreateWave();
			waveTimer = 0;
			waveState = 1;
		end
	elseif(waveState == 1)then
		if(waveType == 1)then
			UpdateLasers(waveBullets1,10,false,2,0.75);
		elseif(waveType == 2)then		--tentacle thing in bounds
			UpdateWaveBoneExtrude(waveBullets1, 1.5, 0.3, 0.5, 10, 5, Player.absx, Player.absy);
		elseif(waveType == 3)then	--tentacle thing out of bounds

			local x = Player.absx;

			if(waveData == 0 and waveCounter >= 2 )then
				x = x + 640;
			end

			if(UpdateWaveBoneExtrude(
				waveBullets1, 			--ref bullets
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
				{104,112}				--possibility lengths
			) == true and waveData == 0 )then
				waveData = 1;
			end
		elseif(waveType == 4)then	--burst arms
			UpdateWaveBoneBurst(waveBullets1,1500, 1.5,Arena.height/8,Arena.height*3/8);
		elseif(waveType == 5)then	--head both tentacle
			UpdateWaveBoneExtrude(
				waveBullets1, 			--ref bullets
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
				false
			);
		elseif(waveType == 6)then	--head right tentacle
			if(waveData == 0) then
				UpdateWaveBoneExtrude(
					waveBullets1, 			--ref bullets
					1.1,					--base timer
					0.08,					--counter time decrease
					0,						--random factor
					1,
					5,
					Player.absx,
					Player.absy,
					{
						"Happy/tempSprites/attacks/atkBoneSmall1",
						"Happy/tempSprites/attacks/atkBoneSmall2"
					},
					{36,34},				--possibility lengths
					false
				);
				UpdateWaveBoneExtrude(
					waveBullets2, 			--ref bullets
					1.1,					--base timer
					0.08,					--counter time decrease
					0,	 					--random factor
					1,
					5,
					Player.absx,
					Player.absy,
					{
						"Happy/tempSprites/attacks/atkBoneSmall1",
						"Happy/tempSprites/attacks/atkBoneSmall2"
					},
					{36,34},				--possibility lengths
					false
				);
			end
		elseif(waveType == 7)then	--lasers + burst?
			UpdateWaveBoneBurst(waveBullets1,1500,1.5, -Arena.height*2/8,-Arena.height*3/8);
			UpdateLasers(waveBullets2,10,true,2.5,0.25);
		end
	end

end


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
		waveData = 1;
	end
end
