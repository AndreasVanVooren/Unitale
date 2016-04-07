--phase 1, create sprite with black

sepFill = nil;
sepGradient = nil;
sepHeart = nil;
--sepBigHeartParent = nil;
sepBigHeartParts = nil;

sepSmallHearts = nil;

eventStarted = false;
eventTimer = 0;

fadeTo = 3/65*60;

soundPlayed = false;
playSoundConst = 17.48564625850340136054421768707483; --as determined by Audacity skillz
locketPlayed = false;
playLocketConst = 22.14643990929705215419501133786848;

bigHeartX = 320;
bigHeartY = 280; 
 
function PlaySeparate()
	if(eventStarted) then return end
	
	--this bool from it_anim
	DisableSpecials()
	
	PlayMusic("SEPARATE");
	
	sepFill = CreateProjectileAbs("separate/fullScreenWhite",320,240);
	sepFill.sprite.color = {0,0,0};
	--sepFill.sprite.alpha = 0;
	
	sepGradient = CreateProjectileAbs("separate/fullScreenGradientWhite",320,240);
	sepGradient.sprite.color = {1,1,1};
	sepGradient.sprite.alpha = 0.001;
	sepGradient.sprite.xscale = 1;
	sepGradient.sprite.yscale = 1;
	--sepGradient.MoveToAbs(320,240);
	
	sepHeart = CreateProjectileAbs("ut-heart",320,100);
	sepHeart.sprite.color = {1,0,0};
	sepHeart.sprite.alpha = 0.001;
	sepHeart.MoveToAbs(320,100);
	
	
	sepBigHeartParts = 
	{
		CreateProjectileAbs("separate/ut-heart_0",bigHeartX,bigHeartY),
		CreateProjectileAbs("separate/ut-heart_1",bigHeartX,bigHeartY),
		CreateProjectileAbs("separate/ut-heart_2",bigHeartX,bigHeartY),
		CreateProjectileAbs("separate/ut-heart_3",bigHeartX,bigHeartY),
		CreateProjectileAbs("separate/ut-heart_4",bigHeartX,bigHeartY),
		CreateProjectileAbs("separate/ut-heart_5",bigHeartX,bigHeartY),
		CreateProjectileAbs("separate/ut-heart_6",bigHeartX,bigHeartY),
		CreateProjectileAbs("separate/ut-heart_7",bigHeartX,bigHeartY),
		CreateProjectileAbs("separate/ut-heart_8",bigHeartX,bigHeartY)
	}
	
	for	i=1, (#sepBigHeartParts) do
		local b = sepBigHeartParts[i];
		--b.SetParent(sepBigHeartParent.sprite);
		--b.SendToTop();
		local x = 0;
		local y = 0;
		repeat
			x = math.random(-40, 40)
			y = math.random(-40, 40)
		until(x*x+y*y > 20*20)
		
		b.SetVar("velX", x);
		b.SetVar("velY", y);
		b.sprite.color = {0,0,0};
		b.sprite.alpha = 0.001;
		
	end
	
	--sepBigHeartParent.MoveToAbs(320,280);
	
	eventStarted = true;
	
	nextwaves = {"waveNull"}
	wavetimer = 99999999999999999;
	
	State("DEFENDING");
end

isChanged = false;
textCounter = 0;
textDelay = 0.1;
localTimer = 0;
linesWritten = 0;

characterIterations =  1;

textX = 30;
textY = 480 - 38.5;
-- last line is line 13


local sentence = "But something changed."

function UpdateChanger()
	if(isChanged == false)then return end;
	
	localTimer = localTimer + Time.dt;
	
	
	
	if(localTimer > textDelay)then
		for i=1,characterIterations do
		localTimer = 0;
		textCounter = textCounter + 1;
			local character = string.sub(sentence, textCounter, textCounter);
		
			if(character ~= " ")then
				
				if(character == ".")then
					
					CreateProjectileAbs("text/dot", textX, textY);
					Audio.PlaySound("Voices/uifont")
					textCounter = textCounter - 8;
					textX = textX - 23 * 7;
					textY = textY - 37;
					textDelay = textDelay - 0.015;
					linesWritten = linesWritten + 1;
					
					if(linesWritten > 13) then
						textX = math.random(0,480);
						textY = math.random(0,480);
						characterIterations = 1 + math.floor((linesWritten-13)/5) ;
						break;
					end
					--textX = 30
				
				else
					--DEBUG("It/text/" .. character)
					CreateProjectileAbs("text/" .. character, textX, textY);
					if(linesWritten < 25) then
						Audio.PlaySound("Voices/uifont")
					else
						QueueUpEnding()
					end
					textX = textX + 23;
				end	
			
			else
				textX = textX + 15;
			end
		end
	end
	--
	if((endingQueued == true) and (Time.time - endingQueuedAtTime) > 1) then
		--DEBUG("I'm done");
		State("DONE");
	end
	
end

endingQueued = false;
endingQueuedAtTime = 0;
function QueueUpEnding()
	if(endingQueued == false)then
		Audio.PlaySound("earrape");
		endingQueued = true;
		endingQueuedAtTime = Time.time;
	end
	--in a couple of seconds, end, IN THIS CASE 1 sec
end

t1 = nil;
t2 = nil;
function UpdateText()
	if(t1 ~= nil) then
	
		local timer = eventTimer - t1.GetVar("Start");
		
		t1.sprite.alpha = math.sin(timer * 0.3) * 1.25;
		
		if(timer > 10 and t2 == nil)then
			t2 = CreateProjectileAbs("separate/text2",320, 240);
			t2.SetVar("Start",eventTimer);
			t2.sprite.alpha = 0;
		end	
		
		if(timer > 12)then
			t1.Remove();
			t1 = nil
		end
	end;
	if(t2 ~= nil) then  
		local timer = eventTimer - t2.GetVar("Start");
		t2.sprite.alpha = math.sin(timer * 0.3) * 1.25;
		
		if(timer > 6)then
			sepHeart.sprite.alpha = math.sin(timer * 0.3) * 1.25;
		end
		
		if(timer > 12)then
			t2.Remove();
			t2 = nil;
			
			--Initialize the change
			isChanged = true;
		end
	end;
	
end

function UpdateSepBullets()
	local xOffSet = bigHeartX + math.random(-7.5, 7.5)*(eventTimer*eventTimer)/(playLocketConst*playLocketConst);
	local yOffSet = bigHeartY + math.random(-7.5, 7.5)*(eventTimer*eventTimer)/(playLocketConst*playLocketConst);

	for	i=1, (#sepBigHeartParts) do
		local b = sepBigHeartParts[i];
		b.sprite.alpha = eventTimer/fadeTo;
		--DEBUG(i .. " " .. eventTimer);
		
		if(locketPlayed == true)then
			local x = b.x;
			local y = b.y;
			
			x = x + b.GetVar("velX") * Time.dt;
			y = y + b.GetVar("velY") * Time.dt;
			
			b.MoveTo(x,y);
			--b.sprite.rotation = b.sprite.rotation + b.GetVar("velY") + b.GetVar("velX") * Time.dt; 
			
		else
			
			b.MoveToAbs(xOffSet,yOffSet);
		end
	end
	
	if(smallHearts ~= nil) then
		for	i = 1 ,(#smallHearts) do
			local b = smallHearts[i];
			local x = b.x;
			local y = b.y;
			
			x = x + b.GetVar("velX") * Time.dt;
			y = y + b.GetVar("velY") * Time.dt;
			b.SetVar("Life",  b.GetVar("Life") - Time.dt);
			b.sprite.alpha = (b.GetVar("Life")+5) * 0.1;
			--DEBUG(b.GetVar("velX") .. "-" .. b.GetVar("velY"))
			b.MoveTo(x,y);
			--b.sprite.rotation = b.sprite.rotation + velY + velX * Time.dt; 
		end
	end
	
end

function clamp(val, minV, maxV)
	return math.min( math.max(minV, val), maxV);
end

function SeparateAnim()
	if(eventStarted == false) then return end
	--DEBUG("FASDFSAD");
	--isChanged = true;
	CoreUpdateLoop();
	UpdateHeartPos();
	UpdateSepBullets();
	UpdateText();
	UpdateChanger();
end

function UpdateHeartPos()
	local xMult = 0;
	local yMult = 0;
	
	if(Input.Left > 0) then
		xMult = xMult-1;
	end
	if(Input.Right > 0) then
		xMult = xMult+1;
	end
	if(Input.Down > 0) then
		yMult=yMult-1;
	end
	if(Input.Up > 0) then
		yMult=yMult+1;
	end
	
	if(Input.Cancel > 0) then
		xMult = xMult/2;
		yMult = yMult/2;
	end
	
	local speed = 100;
	
	local x = sepHeart.absx + speed * xMult * Time.dt;
	local y = sepHeart.absy + speed * yMult * Time.dt;
	
	if(x < 10) 	then x = 10 end;
	if(x > 630) then x = 630 end;
	if(y < 10) 	then y = 10 end;
	if(y > 470) then y = 470 end;
	
	if( not(x< bigHeartX-24 or x>bigHeartX+24 or y < bigHeartY-24 or y > bigHeartY+24) ) then
		if(soundPlayed == false)then --don't do it if it's already charging
			soundPlayed = true;
			eventTimer = playLocketConst;
		end
	end
	
	sepHeart.MoveToAbs(x,y);
end

function CoreUpdateLoop()
	eventTimer = eventTimer + Time.dt;
	
	if(eventTimer >= playSoundConst and soundPlayed == false) then
		Audio.PlaySound("SEPARATECHARGE");
		soundPlayed = true;
	end
	
	if(eventTimer >= playLocketConst and locketPlayed == false) then
		--true separate => MORE SOULS;
		smallHearts = {};
		
		for i = 1, 7 do
			local b = CreateProjectileAbs("separate/ut-heart",bigHeartX,bigHeartY);
			local x = 0;
			local y = 0;
			repeat
				x = math.random(-20, 20)
				y = math.random(-20, 20)
			until(x*x+y*y > 10*10)
			
			b.SetVar("velX", x);
			b.SetVar("velY", y);
			b.SetVar("Life", 3);
			
			table.insert(smallHearts, b);
		end
		--TODO: Insert half heart;
		--text
		t1 = CreateProjectileAbs("separate/text",320, 440);
		t1.SetVar("Start",eventTimer);
		t1.sprite.alpha = 0;
		Audio.PlaySound("SEPARATEBREAK");
		PlayMusic("the locket2");
		locketPlayed = true;
	end
	
	if(locketPlayed == true) then
		sepGradient.sprite.xscale = 1 + math.max(0,(eventTimer - playLocketConst));
		sepGradient.sprite.alpha = 1 - (eventTimer - playLocketConst)/ (playLocketConst/2)
	else
		sepGradient.sprite.xscale = 1 + math.sin(eventTimer);
		sepGradient.sprite.alpha = eventTimer/fadeTo;
	end
	
	Audio.Volume( clamp(  1 - (eventTimer - (playLocketConst*3/2))/(playLocketConst/2)  ,0, 0.75 ) )
	
	if(eventTimer < fadeTo + 1) then
		sepHeart.sprite.alpha = eventTimer/fadeTo;
	end
end
