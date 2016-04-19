--OnWaveStart doesn't exist?
--DEBUG("Bepis");

waveTimer = 0;
waveState = 0;	--0 = just started, 1 = recentering
waveType = 0;

waveBullets1 = {};

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
		
		table.insert(waveBullets1,hand);
		
	elseif(waveType == 3)then	--tentacle thing out of bounds
		
	elseif(waveType == 4)then	--burst arms
		
	elseif(waveType == 5)then	--head left tentacle
		
	elseif(waveType == 6)then	--head right tentacle
		
	elseif(waveType == 7)then	--lasers any
		
	end
	
end

PreInitialize();

function UpdateWave2()
	
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