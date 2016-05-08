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
		--initial rotation
		
		
		
	elseif(waveType == 3)then	--tentacle thing out of bounds
		
	elseif(waveType == 4)then	--burst arms
		
	elseif(waveType == 5)then	--head left tentacle
		
	elseif(waveType == 6)then	--head right tentacle
		
	elseif(waveType == 7)then	--lasers any
		
	end
	
end

PreInitialize();

function UpdateWave2()
	local possibilities = {
			"Happy/tempSprites/attacks/atkBone1",
			"Happy/tempSprites/attacks/atkBone2",
			"Happy/tempSprites/attacks/atkBone3",
			"Happy/tempSprites/attacks/atkBone4",
		};
	local lengths = {72,104,60,112};

	local hand = waveBullets1[1];
	local timerlimit = waveBullets1[2];
	local x = waveBullets1[3];
	local y = waveBullets1[4];
	local rotSpeed = waveBullets1[5];
	
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
	
	
	if(waveTimer > timerlimit)then
		--CHAKKA
		--if x out of bounds NOW, wrap around
		if(waveCounter > 6) then
			isWaveEnding = true;
			return;
		end
		
		if(x > 650)then
			x = -x;
		elseif(x < -10) then
			x = -x;
		end
		
		local i = math.random(1,#possibilities);
		
		local bone = CreateProjectileAbs(possibilities[i], x,y);
		bone.sprite.SetPivot(0,0.5);
		bone.sprite.rotation = curRot;
		x = x + math.cos( math.rad(curRot) )*lengths[i];
		y = y + math.sin( math.rad(curRot) )*lengths[i];
		hand.MoveToAbs(x, y);
		
		waveCounter = waveCounter + 1;
		
		waveBullets1[2] = 1.5 - (0.3*waveCounter) + (math.random() * 0.5);
		waveBullets1[3] = x;
		waveBullets1[4] = y;
		waveBullets1[5] = rotSpeed + 10;
		
		waveTimer = 0;
		
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
			UpdateWave2();
		elseif(waveType == 3)then	--tentacle thing out of bounds
			UpdateWave3();
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