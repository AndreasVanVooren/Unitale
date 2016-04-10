local happyAnim = {};

--note anchors and pivots are all values I got by fucking around in the Unity editor
local legs  = CreateSprite("Happy/tempSprites/legs");
--torso.SetAnchor(0.5,0);
legs.SetPivot(0.5,0);
legs.MoveTo(320,240);

local torso = CreateSprite("Happy/tempSprites/torso");
torso.SetAnchor(0.455,1);
torso.SetPivot(0.37,0);
torso.SetParent(legs);
torso.MoveTo(0,0);

local torsEye = CreateSprite("Happy/tempSprites/torsEye");
--torso.SetAnchor(0.455,1);
--torso.SetPivot(0.37,0);
torsEye.SetParent(torso);
torsEye.MoveTo(-14.4,-6.8);

local head  = CreateSprite("Happy/tempSprites/head");
head.SetAnchor(0.4,0.79);
head.SetPivot(0.56,0.11);
head.SetParent(torso);
head.MoveTo(0,0);

legs.Scale(1.5,1.5);

local swaying = false;

local function GentleSway()
	if(swaying) then
		torso.rotation = math.sin(Time.time * math.pi *(76/60) /4 ) * 10;
		head.rotation = (math.sin(Time.time * math.pi *(76/60) /4 )+1) * 5;
	else
		if (torso.rotation < 0) then
			torso.rotation = torso.rotation + Time.dt;
			if(torso.rotation > 0) then
				torso.rotation = 0;
			end
		elseif (torso.rotation > 0) then
			torso.rotation = rotation - Time.dt;
			if(torso.rotation < 0) then
				torso.rotation = 0;
			end
		end
		if (head.rotation < 0) then
			head.rotation = head.rotation + Time.dt;
			if(head.rotation > 0) then
				head.rotation = 0;
			end
		elseif (head.rotation > 0) then
			head.rotation = rotation - Time.dt;
			if(head.rotation < 0) then
				head.rotation = 0;
			end
		end
	end
end

function happyAnim.Update()
	GentleSway();
end

return happyAnim;