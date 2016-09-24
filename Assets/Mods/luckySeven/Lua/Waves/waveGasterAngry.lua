-- The bouncing bullets attack from the documentation example.
--spawntimer = 0
gasters = nil
bullets = nil

--0, intro
--1, crack and fire,
--2, zoom
state = 0;
timer = 0;
dirX = 0;
dirY = 0;

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
	if(start == target) then return start; end
	local changeNeg = start-target;
	local rate = curTime/destTime;
	return changeNeg * rate * (rate-2) + start;
end

function EaseOutExp(start,target,curTime,destTime)
	if(start == target) then return start; end
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

function CreateGaster(posX,posY,tgtX,tgtY,tgtRot,movesHor)
	local gaster = CreateProjectile("It/gaster/neutral", posX,posY);
		gaster.SetVar("initPosX", posX);
		gaster.SetVar("tgtPosX", tgtX);
		gaster.SetVar("initPosY", posY);
		gaster.SetVar("tgtPosY", tgtY);
		gaster.SetVar("tgtRot", tgtRot);
		gaster.SetVar("movesHor", movesHor);
	return gaster;
end

function GasterIntro()
	--init
	if(gasters == nil)then
		Audio.PlaySound("gasterCharge");
		--Comes from bottom
		--local gaster1 = CreateProjectile("It/gaster/neutral", 0,-(Arena.height/2 + 200));
		--gaster1.SetVar("initPosX", 0);
		--gaster1.SetVar("tgtPosX", );
		--gaster1.SetVar("initPosY", )
		--gaster1.SetVar("tgtPosY", 0);
		--gaster1.SetVar("tgtRot", -90);
		--gaster1.SetVar("movesHor", false);
		local gaster1 = CreateGaster(
			0,
			-(Arena.height/2 + 200),
			-(Arena.width/2 + 60),
			0,
			-90,
			false
		);
		
		--local gaster2 = CreateProjectile("It/gaster/neutral", (Arena.width/2 + 320),(Arena.height/2 + 200));
		--gaster2.SetVar("initPosX", (Arena.width/2 + 320));
		--gaster2.SetVar("initPosY", (Arena.height/2 + 200));
		--gaster2.SetVar("tgtPosX", (Arena.width/2 + 60));
		--gaster2.SetVar("tgtPosY", 0);
		--gaster2.SetVar("tgtRot", 90);
		--gaster2.SetVar("movesHor", false);
		local gaster2 = CreateGaster(
			(Arena.width/2 + 320),
			(Arena.height/2 + 200),
			(Arena.width/2 + 60),
			0,
			90,
			false
		);
		
		--local gaster3 = CreateProjectile("It/gaster/neutral", -(Arena.width/2 + 320),(Arena.height/2 + 200));
		--gaster3.SetVar("initPosX", -(Arena.width/2 + 320));
		--gaster3.SetVar("initPosY", (Arena.height/2 + 200));
		--gaster3.SetVar("tgtPosX", 0);
		--gaster3.SetVar("tgtPosY", (Arena.height/2 + 60));
		--gaster3.SetVar("tgtRot", 180);
		--gaster3.SetVar("movesHor", true);
		local gaster3 = CreateGaster(
			-(Arena.width/2 + 320),
			(Arena.height/2 + 200),
			0,
			(Arena.height/2 + 60),
			180,
			true
		);
		
		local gaster4 = CreateProjectile("It/gaster/neutral", -(Arena.width/2 + 60),-(Arena.height/2 + 200));
		gaster4.SetVar("initPosX", -(Arena.width/2 + 60));
		gaster4.SetVar("initPosY", -(Arena.height/2 + 200));
		gaster4.SetVar("tgtPosX", 0);
		gaster4.SetVar("tgtPosY", -(Arena.height/2 + 60));
		gaster4.SetVar("tgtRot", 0);
		gaster4.SetVar("movesHor", true);
		
		gasters = {
			gaster1,
			gaster2,
			gaster3,
			gaster4
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
	if(timer >= timeToPos *1.1)then
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
		local laserFade = CreateProjectile("It/gaster/blastGlow",0,0);
		laserFade.SetVar("movesHor", false);
		laserFade.sprite.SetAnimation({"It/gaster/blastGlow","It/gaster/blastGlow2"});
		laserFade.sprite.alpha = 0.7;
		laserFade.SendToBottom();
		
		local laserHit = CreateProjectile("It/gaster/blast",0,0);
		laserHit.SetVar("movesHor", false);
		laserHit.SetVar("hit",true);
		laserHit.sprite.SetAnimation({"It/gaster/blast","It/gaster/blast2"});
		
		local laserColl = CreateProjectile("It/gaster/blastSep",0,0);
		laserColl.SetVar("movesDiag", false);
		laserColl.SetVar("hit",true);
		laserColl.sprite.SetAnimation({"It/gaster/blastSep","It/gaster/blastSep2"});
		
		local laserFade2 = CreateProjectile("It/gaster/blastGlowHor",0,0);
		laserFade2.SetVar("movesHor", true);
		laserFade2.sprite.SetAnimation({"It/gaster/blastGlowHor","It/gaster/blastGlow2Hor"});
		laserFade2.sprite.alpha = 0.7;
		laserFade2.SendToBottom();
		
		local laserHit2 = CreateProjectile("It/gaster/blastHor",0,0);
		laserHit2.SetVar("movesHor", true);
		laserHit2.SetVar("hit",true);
		laserHit2.sprite.SetAnimation({"It/gaster/blastHor","It/gaster/blast2Hor"});
		
		local laserColl2 = CreateProjectile("It/gaster/blastSepHor",0,0);
		laserColl2.SetVar("movesDiag", true);
		laserColl2.SetVar("hit",true);
		laserColl2.sprite.SetAnimation({"It/gaster/blastSepHor","It/gaster/blastSep2Hor"});
		
		laserColl.SendToTop();
		laserColl2.SendToTop();
		
		Audio.PlaySound("gasterBlast");
		
		bullets = {
			laserFade,
			laserHit,
			laserColl,
			laserFade2,
			laserHit2,
			laserColl2
		};
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
		--Verify the dirX here, since the player isn't retarded 
		--and has probably moved away from the blast now.
		if(Player.y > 0) then	--is above (arena space)
			dirY = 1;	--go up
		else
			dirY = -1; -- go down
		end
		if(Player.x > 0) then	--is right (arena space)
			dirX = 1;	--go right
		else
			dirX = -1; -- go left
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
	
	local bSpeedX = Arena.width/5; -- = 4/10* width / 2
	local bSpeedY = Arena.height/5;
	local dTime = Time.dt;
	local dispY = bSpeedY * dirY * dTime;
	local dispX = bSpeedX * dirX * dTime;
	
	for i=1, (#gasters) do
		local g = gasters[i];
		local x = g.x;
		local y = g.y;
		if(g.GetVar("movesHor") == true)then
			x = x + dispX;
		elseif(g.GetVar("movesDiag") ~= nil)then
			x = x + dispX;
			y = y + dispY;
		else
			y = y + dispY;
		end
		g.MoveTo(x,y);
	end
	
	for i=1, (#bullets) do
		local b = bullets[i];
		local x = b.x;
		local y = b.y;
		if(b.GetVar("movesHor") == true)then
			x = x + dispX;
		elseif(b.GetVar("movesDiag") ~= nil)then
			x = x + dispX;
			y = y + dispY;
		else
			y = y + dispY;
		end
		b.MoveTo(x,y);
	end
	
	--if at the end
	if(math.abs(gasters[1].y) > Arena.height/2-(16+9) or math.abs(gasters[3].x) > Arena.width/2-(16+9))then
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