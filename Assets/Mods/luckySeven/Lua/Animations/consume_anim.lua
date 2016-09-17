local consume = {};

local back = nil;

local conGradient = nil;

local bigHeartX = 320;
local bigHeartY = 280;

local conBigHeartChunks = nil;

local conSmallHeart = nil;

local eventStarted = false;
local eventTimer = 0;
local eventState = 0;

local misterKojimaSan = false;

function consume.StartConsume(kojimaSuccess)
    if(eventStarted) then return end
    misterKojimaSan = false or kojimaSuccess;

    Audio.LoadFile("SEPARATE");
    Audio.Pitch(0.5);

    back = CreateSprite("separate/fullscreenWhite");
    back.MoveToAbs(320,240);
    back.layer = "Default";
    back.color = {0,0,0};
    back.alpha = 1;

    conGradient = CreateSprite("separate/fullscreenGradientWhite");
    conGradient.MoveToAbs(320,240);
    conGradient.layer = "Default";
    conGradient.color = {236/255,208/255,212/255};
    conGradient.alpha = 0;

    conBigHeartChunks = {
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
    for i=1,#conBigHeartChunks do
        --conBigHeartChunks[i].canCollideWithProjectiles = true;
        conBigHeartChunks[i].sprite.layer = "Default";
        conBigHeartChunks[i].sprite.color = {0,0,0};
        conBigHeartChunks[i].sprite.alpha = 0;
    end

    conSmallHeart = CreateProjectileAbs("separate/ut-heart",320,100);
    --conSmallHeart.canCollideWithProjectiles = true;
    conSmallHeart.sprite.layer = "Default";
    conSmallHeart.sprite.color = {1,0,0};
    conSmallHeart.sprite.alpha = 0;

    eventStarted = true;

    nextwaves = {"waveNull"}
	wavetimer = 99999999999999999;

	State("DEFENDING");
end

local canMoveHeart = true;
local timeSinceLastHeartMove = 0;

local initNumChunks = 9;

local firstText = nil;

local chara = nil;

function consume.SpawnChara()

end

local function SpawnCharaLoc()
    consume.SpawnChara();
end

--state 0, fade in, move heart up.
--state 1, eat heart
--state 2 : something changed.
--state 3 : chara. BattleDialog handles text, but consume_anim handles chara face.
local function ChangeStatePrep(x)
    eventState = x;
    eventTimer = 0;
    if(x == 1)then
        --flag some shit? set wavetimer to 0;
        canMoveHeart = false;
        initNumChunks = #conBigHeartChunks;
    elseif(x == 2)then
        --destroy gradient, destroy
        --conSmallHeart.Remove();
        --conSmallHeart = nil;

        conGradient.Remove();
        conGradient = nil;

        conBigHeartChunks = nil;

        firstText = CreateSprite("separate/text2");
        firstText.SetPivot(0.5,1);
        firstText.MoveToAbs(320,480);
        firstText.layer = "Default";
    elseif(x == 3)then
        --create chara sprite, submit battledialog, go to battledialog;
        BattleDialog({
            "[noskip][novoice][starcolor:000000]Sup bitch, I'm Chara,\ryou're a great partner,\rbladibladiyeehaw.",
            "[noskip][func:State,DONE]"
        });
    end
end

local function UpdateHeartPos()
    if(not canMoveHeart)then return end

    local yMult = 0;

    if(Input.Up > 0)then
        yMult = 1;
        timeSinceLastHeartMove = 0;
    elseif(timeSinceLastHeartMove > 2)then
        yMult = 0.5;
    else
        timeSinceLastHeartMove = timeSinceLastHeartMove + Time.dt;
    end

    if(Input.Cancel > 0 and timeSinceLastHeartMove < 2) then
		yMult = yMult/2;
	end

    local speed = 80;

    local y = conSmallHeart.absy + speed * yMult * Time.dt;

    if(y > bigHeartY)then
        y = bigHeartY;
        ChangeStatePrep(1);
        canMoveHeart = false;
    end

    conSmallHeart.MoveToAbs(conSmallHeart.absx,y);
end

local function UpdateState0()
    local alpha = eventTimer;
    if(alpha > 1)then
        alpha = 1;
    end

    conGradient.alpha = alpha;
    conGradient.xscale = 1 + 0.05*math.sin(eventTimer);

    for i=1,#conBigHeartChunks do
        conBigHeartChunks[i].sprite.alpha = alpha;
    end

    conSmallHeart.sprite.alpha = alpha;

    UpdateHeartPos();
end

local timeToEat = 1.5;
local firstBite = true;
local function EatUpdate()
    local xScale = conGradient.xscale;
    if(xScale < 1)then
        xScale = xScale + Time.dt * 0.08 * (#conBigHeartChunks)/initNumChunks;
    end
    conGradient.xscale = xScale;

    if(eventTimer > timeToEat)then
        timeToEat = math.random(1.2,1.8);
        eventTimer = 0;
        firstBite = false;
        local index = math.random(#conBigHeartChunks);
        conBigHeartChunks[index].Remove();
        table.remove(conBigHeartChunks,index);
        if(#conBigHeartChunks <= 0)then
            if(misterKojimaSan)then
                --DEBUG("Yiss");
                ChangeStatePrep(3);
            else
                --DEBUG("Naw");
                ChangeStatePrep(2);
            end
        end
        conGradient.xscale = (#conBigHeartChunks)/initNumChunks;
    end


    if(not firstBite)then
        local shakeTimer = 0.5;
        local shakeDelta = 1 - (eventTimer / shakeTimer);
        if(shakeDelta < 0)then
            shakeDelta = 0;
        end
        local xOffset = bigHeartX + math.random(-7.5,7.5) * shakeDelta;
        local yOffset = bigHeartY + math.random(-7.5,7.5) * shakeDelta;

        for i=1,#conBigHeartChunks do
            if(conBigHeartChunks[i] ~= nil)then
                conBigHeartChunks[i].MoveToAbs(xOffset,yOffset);
            end
        end
    end
end

local isChanged = false;
local textCounter = 0;
local textDelay = 0.1;
local localTimer = 0;
local linesWritten = 0;

local characterIterations =  1;

local textX = 30;
local textY = 480 - 38.5;
-- last line is line 13
local sentence = "But something changed."

local endingQueued = false;
local endingQueuedAtTime = 0;
local function QueueUpEnding()
	if(endingQueued == false)then
		Audio.PlaySound("earrape");
		endingQueued = true;
		endingQueuedAtTime = Time.time;
	end
	--in a couple of seconds, end, IN THIS CASE 1 sec
end

--Totally not copy pasted from separate anim
local function SomethingChanged()
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

local function PostConsumeStandard()
    if(isChanged)then
        SomethingChanged()

    else
        if(firstText == nil)then return end
        local alpha =  1-(eventTimer/0.5) + 1.25;
        firstText.alpha = alpha;
        if(eventTimer > 2 --[[1.25 + 0.5 + 0.25]])then
            firstText.Remove();
            firstText = nil;
            isChanged = true;
        end
    end
end

local spawnedHeartacle = false;
local function HeartAche()
    --  2r x 6u
    local shakeDelay = 0.5;
    local timeToBurst = 1.5;
    local shakeEnd = 2.0;
    local hideTime = 2.5;
    local endState = 3.5;

    if(eventTimer < timeToBurst)then
        local shakeFrac =  math.min(eventTimer - shakeDelay, 0) / (timeToBurst - shakeDelay);
        local x = bigHeartX + math.random(-3, 3) * shakeFrac;
        local y = bigHeartY + math.random(-3, 3) * shakeFrac;
        conSmallHeart.MoveToAbs(x,y);
    elseif(eventTimer < hideTime)then
        if(not spawnedHeartacle)then
            spawnedHeartacle = true;
            --was gonna remove it, but setting the sprite is more efficient than destroying and reinstantiating.S
            conSmallHeart.Set("ut-heart-tentacle");
            conSmallHeart.MoveToAbs(bigHeartX + 2, bigHeartY + 6);
        end

        local shakeFrac = 1 - ( math.min(eventTimer - timeToBurst, 0) / (shakeEnd - timeToBurst) );
        local x = bigHeartX + 2 + math.random(-3, 3) * shakeFrac;
        local y = bigHeartY + 6 + math.random(-3, 3) * shakeFrac;
        conSmallHeart.MoveToAbs(x,y);
    elseif(eventTimer > hideTime and conSmallHeart ~= nil)then
        conSmallHeart.Remove();
        conSmallHeart = nil;
    elseif(eventTimer > endState)then
        if(misterKojimaSan)then
            ChangeStatePrep(3);
        else
            State("DONE");
        end
    end
end

local function CharaUpdate()
    --basically, get the chara sprite, and add some noise.

end

function consume.Update()
    if(not eventStarted) then return end
    eventTimer = eventTimer + Time.dt;

    if (eventState == 0)then
        UpdateState0()
    elseif(eventState == 1)then
        EatUpdate();
    elseif(eventState == 2)then
        --PostConsumeStandard();
        HeartAche();
    elseif(eventState == 3)then
        CharaUpdate();
    end
end

return consume;
