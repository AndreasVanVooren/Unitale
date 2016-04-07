
local itDialogue = {} --module?
local active = false;
local timer = 0;
local sprites = {};

local bubbleRef = nil;

local lBorder = -30.5;
local rBorder =  41.5;
local tBorder = 42;
local bBorder = -45;

local characters = "abcdefghijklmnopqrstuvwxyz"

function itDialogue.SingleBubble()
	if (active) then return; end
	active = true;
	--DEBUG("Boop")
	bubbleRef = CreateSprite("UI/SpeechBubbles/right");
	bubbleRef.x = 320 + 150;
	bubbleRef.y = 240 + 150;
end

function itDialogue.Update()
	if (not active) then return; end

	timer = timer + Time.dt;
	
	if(timer > 1/30) then
		--spawn new letter
		local cInd = math.random(#characters);
		
		local t = CreateSprite("It/sans/" .. string.sub(characters,cInd,cInd));
		t.SetParent(bubbleRef);
		t.x = math.random(lBorder,rBorder);
		t.y = math.random(bBorder,tBorder);
		t.color = {0,0,0};
		table.insert(sprites,t);
		timer = 0;
		Audio.PlaySound("Voices/v_sans")
	end
end

function itDialogue.Clear()
	if(not active) then return; end
	
	active = false;
	
	for i=1, (#sprites) do
		sprites[i].Remove();
		sprites[i] = nil;
	end
	--DEBUG("Clear sprites");
	
	bubbleRef.Remove();
	bubbleRef = nil;
	--DEBUG("BubbleRef");
end

return itDialogue;