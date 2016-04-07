-- The bouncing bullets attack from the documentation example.
--spawntimer = 0
gasters = nil
bullets = nil

--0, intro
--1, crack and fire,
--2, zoom
state = 0;
timer = 0;
direction = 0;

timeToPos = 0.5;

--function GetSmoothedValBetweenVals(initial, target, curTime, destTime)
--	--on the curve you put stuff?
--	--formula : tPos = a (t-end)^2 + final
--	--a = (s-f) * (1/t)^2
--	local a = (initial - target) / (destTime * destTime);
--	local x = (curTime - destTime);
--	return a * (x*x) + target;
--end

function EaseOutSquare(start,target,curTime,destTime)
	local changeNeg = start-target;
	local rate = curTime/destTime;
	return changeNeg * rate * (rate-2) + start;
end

function EaseOutExp(start,target,curTime,destTime)
	local change = target-start;
	local t = 2*curTime/(destTime) ;
	
	if(t < 1) then
		return change/2 * math.pow(2,10*(t-1))+start;
	end
	t = t -1;
	return change/2 * (-math.pow(2,-10*t)+2)+start;
	--return 
end

--Math.easeOutQuad = function (curtime, start, change, destTime) {
--	t /= d;
--	return -c * t*(t-2) + b;
--};

function GasterPre()
	if(timer >= 0.2)then
		timer = 0;
		state = 1;
	end
end

function GasterIntro()
	--init
	if(gasters == nil)then
		Audio.PlaySound("gasterCharge");
		--Comes from bottom
		local gaster1 = CreateProjectile("It/gaster/neutral", 0,-(Arena.height/2 + 200));
		gaster1.SetVar("initPosX", 0);
		gaster1.SetVar("tgtPosX", -(Arena.width/2 + 60));
		gaster1.SetVar("initPosY", -(Arena.height/2 + 200))
		gaster1.SetVar("tgtPosY", 0);
		gaster1.SetVar("tgtRot", -90);
		
		local gaster2 = CreateProjectile("It/gaster/neutral", (Arena.width/2 + 320),(Arena.height/2 + 200));
		gaster2.SetVar("initPosX", (Arena.width/2 + 320));
		gaster2.SetVar("initPosY", (Arena.height/2 + 200));
		gaster2.SetVar("tgtPosX", (Arena.width/2 + 60));
		gaster2.SetVar("tgtPosY", 0);
		gaster2.SetVar("tgtRot", 90);
		
		
		gasters = {
			gaster1,
			gaster2
		};
	end
	--update loop
	
	for i=1,(#gasters) do
		if(timer > timeToPos+0.01)then break; end
	
		local g = gasters[i];
		-- x and y in arena space;
		local x = EaseOutSquare( g.GetVar("initPosX"), g.GetVar("tgtPosX"), timer, timeToPos);
		local y = EaseOutSquare( g.GetVar("initPosY"), g.GetVar("tgtPosY"), timer, timeToPos);
		local rot = EaseOutSquare( 0, g.GetVar("tgtRot"), timer, timeToPos);
		
		g.MoveTo(x,y);
		g.sprite.rotation = rot;
	end
	if(timer >= timeToPos *2)then
		timer = 0;
		state = 2;
		--DEBUG("boop")
	end
end

breaking = false;
broken = false;
function GasterAnimBreak()
	--setAnimation
	if(breaking == false)then
		Audio.PlaySound("bones");
		for i=1,(#gasters) do
			local g = gasters[i];
			--set to crack
			g.sprite.SetAnimation({
				"It/gaster/gasterCrack0",
				"It/gaster/gasterCrack1",
				"It/gaster/gasterBrainsSettle",
				"It/gaster/gasterBrains"
			});
		end
		breaking = true;
	end
	
	if(timer > 8/30 - 0.001 and bullets == nil)then
		--DO NOT SCALE SINCE SCALING ALWAYS FUCKS UP EVERYTHING
		bullets = {};
		Audio.PlaySound("gasterBlast");
		for i=1,30 do
		
		local laserFade = CreateProjectile("It/gaster/blastGlow",0,0);
		laserFade.sprite.SetAnimation({"It/gaster/blastGlow","It/gaster/blastGlow2"});
		laserFade.sprite.alpha = 0.7;
		laserFade.SendToBottom();
		
		local laserHit = CreateProjectile("It/gaster/blast",0,0);
		laserHit.SetVar("hit",true);
		laserHit.sprite.SetAnimation({"It/gaster/blast","It/gaster/blast2"});
		
		local laserColl = CreateProjectile("It/gaster/blastSep",0,0);
		laserColl.SetVar("hit",true);
		laserColl.sprite.SetAnimation({"It/gaster/blastSep","It/gaster/blastSep2"});
		
		
		
		table.insert(bullets,laserFade);
		table.insert(bullets,laserHit);
		table.insert(bullets,laserColl);
		
		end
		
	end
	
	if(timer > 4/30 - 0.001 and broken == false)then
		broken = true;
		
		for i=1,(#gasters) do
			local g = gasters[i];
			g.sprite.StopAnimation();
			g.sprite.Set("It/gaster/gasterBrains");
		end
	end
	
	if(timer > 0.5) then
		--Verify the direction here, since the player isn't retarded 
		--and has probably moved away from the blast now.
		if(Player.y > 0) then	--is above (arena space)
			direction = -1;	--go down
		else
			direction = 1; -- go up
		end
		--advance state
		timer = 0;
		state = 3;
	end
	
end

function GasterMove()
	if(gasters == nil or bullets == nil) then
		DEBUG("NO BULLETS");
		return;
	end
	
	local bulletSpeed = 40;
	--local dTime = Time.dt;
	local disp = bulletSpeed * direction * Time.dt;
	
	for i=1, (#gasters) do
		local g = gasters[i];
		local x = g.x;
		local y = g.y;
		y = y + disp;
		g.MoveTo(x,y);
	end
	
	for i=1, (#bullets) do
		local b = bullets[i];
		local x = b.x;
		local y = b.y;
		y = y + disp;
		b.MoveTo(x,y);
	end
	
	--if at the end
	if(math.abs(gasters[1].y) > Arena.height/2)then
		EndWave();
	end
end

function Update()
	
	timer = timer + Time.dt;
	
	if(state == 0)then
		GasterPre();
	elseif (state == 1) then
		GasterIntro();
	elseif (state == 2) then
		GasterAnimBreak();
	elseif(state == 3) then
		GasterMove();
	end
	
end

function OnHit(bullet)
	if(bullet.GetVar("hit") == true) then
		--do the hit thing
		Player.Hurt(9);
	end
end