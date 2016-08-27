--OnWaveStart doesn't exist?
--DEBUG("Bepis");

waveTimer = 0;
waveState = 0;	--0 = just started, 1 = recentering
waveType = 0;
waveCounter = 0;

waveBullets1 = {};
isWaveEnding = false;


function PreInitialize()
	waveType = math.random(2,2);
	waveState = 0;
	Encounter.Call("ToggleSway",false);
end

function CreateWave()
	waveCounter = 0;
	waveTimer = 0;
	if(waveType == 2)then		--tentacle thing in bounds

		--disable hand
		Encounter.Call("ToggleHand");

		--this has to be hardcoded, reason being fuck you.
		local initX = 395.867095947266;
		local initY = 279.202453613281;
		local hand = CreateProjectileAbs("Happy/tempSprites/hand1",initX,initY);
		hand.sprite.SetPivot(0.1571406, 0.17743);
		hand.sprite.Scale(1.6,1.6);

		--wave 2 pattern : hand ref, time to chuck,x pos, y pos, rotation speed
		waveBullets1 = {hand, 1.5 + (math.random() * 0.5) ,initX, initY, 30}

	elseif(waveType == 3)then	--tentacle thing out of bounds

		--disable hand
		Encounter.Call("ToggleHand");

		--this has to be hardcoded, reason being fuck you.
		local initX = 395.867095947266;
		local initY = 279.202453613281;
		local hand = CreateProjectileAbs("Happy/tempSprites/hand1",initX,initY);
		hand.sprite.SetPivot(0.1571406, 0.17743);
		hand.sprite.Scale(1.6,1.6);

		--wave 2 pattern : hand ref, time to chuck,x pos, y pos, rotation speed
		waveBullets1 = {hand, 1.5 + (math.random() * 0.5) ,initX, initY, 30}

	elseif(waveType == 4)then	--burst arms

	elseif(waveType == 5)then	--head left tentacle

	elseif(waveType == 6)then	--head right tentacle

	elseif(waveType == 7)then	--lasers any

	end

end

PreInitialize();

function UpdateWaveBoneExtrude(bulletTable, repeatCount, targetX, targetY)
	local possibilities = {
			"Happy/tempSprites/attacks/atkBone1",
			"Happy/tempSprites/attacks/atkBone2",
			"Happy/tempSprites/attacks/atkBone3",
			"Happy/tempSprites/attacks/atkBone4",
		};
	local lengths = {72,104,60,112};

	local hand = bulletTable[1];
	local timerlimit = bulletTable[2];
	local x = bulletTable[3];
	local y = bulletTable[4];
	local rotSpeed = bulletTable[5];

	hand.MoveToAbs( x + math.random(-2,2), y + math.random(-2,2));
	local curRot = hand.sprite.rotation;

	local vecX = (Player.absx - x);
	local vecY = (Player.absy - y);
	local length = math.sqrt((vecX * vecX) + (vecY * vecY));
	local vCos = vecX/length;
	local vSin = vecY/length;
	local angle = math.deg( math.atan2(vSin,vCos) );

	DEBUG ("RotSpeed : ".. rotSpeed);

	while (angle < -180) do
		angle = angle + 360;
	end
	while (angle >= 180) do
		angle = angle - 360;
	end
	DEBUG ("Angle 2nd pass : ".. angle);

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

	DEBUG ("Cur rot : ".. curRot);

	hand.sprite.rotation = curRot;

	if(isWaveEnding ~= true)then
		if(waveTimer > timerlimit)then
			--CHAKKA
			--if x out of bounds NOW, wrap around

			if(waveCounter >= repeatCount) then
				isWaveEnding = true;
				bulletTable[2] = 2.0;
				bulletTable[5] = 0;
				return;
			end

			if(x > 650)then
				x = -x;
			elseif(x < -10) then
				x = -x;
			end

			local i = math.random(1,#possibilities);

			local bone = CreateProjectileAbs(possibilities[i], math.fmod(x,640),math.fmod(y,480));
			bone.sprite.SetPivot(0,0.5);
			bone.sprite.rotation = curRot;
			x = x + math.cos( math.rad(curRot) )*lengths[i];
			y = y + math.sin( math.rad(curRot) )*lengths[i];
			hand.MoveToAbs(math.fmod(x,640), math.fmod(y,480));

			waveCounter = waveCounter + 1;

			bulletTable[2] = 1.5 - (0.3*waveCounter) + (math.random() * 0.5);
			bulletTable[3] = x;
			bulletTable[4] = y;
			bulletTable[5] = rotSpeed + 10;
			waveBullets1[6 + waveCounter-1] = bone;

			waveTimer = 0;

		end
	else
		if(waveTimer > timerlimit)then
			if(waveCounter <= 0)then
				--do end wave stuff
				Encounter.Call("ToggleHand");
				EndWave();
				return;
			end

			local bone = waveBullets[6 + waveCounter - 1];
			hand.MoveToAbs(bone.absx, bone.absy);

			bulletTable[2] = 0.75;
			bulletTable[3] = bone.absx;
			bulletTable[4] = bone.absy;
			bulletTable[5] = 0;

			bone.Remove();

			waveCounter = waveCounter - 1;
			waveTimer = 0;
		end
	end
end

function UpdateWave3()

end

function UpdateWave4()

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
		if(waveType == 2)then		--tentacle thing in bounds
			UpdateWaveBoneExtrude(waveBullets1, 5, Player.absx, Player.absy);
		elseif(waveType == 3)then	--tentacle thing out of bounds
			UpdateWaveBoneExtrude(waveBullets1, 6, Player.absx + 640, Player.absy);
		elseif(waveType == 4)then	--burst arms
			UpdateWave4();
		elseif(waveType == 5)then	--head left tentacle
			UpdateWave5();
		elseif(waveType == 6)then	--head right tentacle
			UpdateWave6();
		elseif(waveType == 7)then	--lasers any
			UpdateWave7();
		end
	end

end


function OnHit(bullet)
	Player.Hurt(6);
end
