-- A basic monster script skeleton you can copy and modify for your own creations.
comments = {
	"It's tearing at itself.", 
	"Piercing screams echo through\rthe area.", 
	"It undulates rhythmically.",
	"Smells like rotting meat.",
	"The snow is falling."
};

commands = {"Check","Bathe", "Run", "Hug"};
randomdialogue = {"[font:sans][voice:v_sans]why even\nbother?\n\nwhy even\nbother?"};

sprite = "empty"; --Always PNG. Extension is added automatically.
name = "ERR_NAME_NOT_FOUND";
hp = 777;
--atk = "#"
--def = "#"
--check = "You can't. It's all going to\rend. It's all going to end."
dialogbubble = "right"; -- See documentation for what bubbles you have available.
cancheck = false;
canspare = false;
--snowThrowCount = 0;

SetGlobal("isSprung", false);

isHugged = false;
batheCount = 0;

headHealth = {111,111,111,111,111,111,111};

feelsAttacked = false;
feelsDeaded = false;
hasDied = false;

--Comes before damage is actually calculated, and can replace damage calculation entirely
--Parameters :
--	+ rateToCenter => The position ratio of the target cursor relative to the center of the UI thing. Goes from -1 (left) to 1 (right)
--Return values : 
--	+ void (end function without returning a value, or do return;) => Use default behaviour
--	+ nil (explicitly state return nil;) => Miss target;
--  + number (eg. return 5) => damage taken, in the future damage healed, but this isn't implemented yet.
--		=> The damage value is automatically rounded to the nearest integer value.
--  + anything else (eg. return string "Bepis") => throws error.
function HandlePreAttack(rateToCenter)
	--This line of code is to change behaviour when you don't press the Z button in time.
	--if(not(rateToCenter < math.huge and rateToCenter > -math.huge and rateToCenter == rateToCenter))then
	--	DEBUG("To infinity");
	--end
	
	--keep standard on miss behaviour
	if(not(rateToCenter < math.huge and rateToCenter > -math.huge and rateToCenter == rateToCenter))then
		return nil;
	end
	
	if(GetGlobal("isSprung") == false)then
		--just do normal calculations
		
		local mult = (2-math.abs(rateToCenter));
		if(math.abs(rateToCenter) < 12/115)then
			mult = 2.2;
		end
		
		local dmg = math.ceil ( (29 + math.random()*2) * mult);
		
		headHealth[1] = headHealth[1] - dmg;
		
		if(headHealth[1] <= 0)then
			dmg = dmg + headHealth[1];
			headHealth[1] = 0;
			
			--animRef.KillHead(1);
			
			feelsAttacked = true;
		end
			
		return dmg;
	elseif(GetGlobal("isSprung") == true)then
		-- Compare RateToCenter to deduce which head is hit. Then KILL THAT HEAD.
		local dmg = math.floor(29 + math.random()*2);
		
		local ind = 0;
		if(rateToCenter > -0.934 and rateToCenter < -0.814)then
			ind = 2;
		elseif(rateToCenter > -0.536 and rateToCenter < -0.426)then
			ind = 3;
		elseif(rateToCenter > -0.27 and rateToCenter < -0.106)then
			ind = 4;
		elseif(rateToCenter > 0.142 and rateToCenter < 0.326)then
			ind = 5;
		elseif(rateToCenter > 0.484 and rateToCenter < 0.614)then
			ind = 6;
		elseif(rateToCenter > 0.80 and rateToCenter < 0.926)then
			ind = 7;
		end
		
		if(ind ~= 0)then
		
			if(headHealth[ind] > 0)then
				headHealth[ind] = headHealth[ind] - dmg;
				if(headHealth[ind] <= 0)then
					dmg = dmg + headHealth[ind];
					headHealth[ind] = 0;
				end
				
				hp = headHealth[1]+
					headHealth[2]+
					headHealth[3]+
					headHealth[4]+
					headHealth[5]+
					headHealth[6]+
					headHealth[7];
		
				if(hp == 0)then
					feelsDeaded = true;
				end
				
				return dmg;
			else
				return nil;
			end
		else
			return nil;
		end
	end
	
	return "YOU DUN FUCKED UP"
end

-- Happens after the slash animation but before 
function HandleAttack(attackstatus)
    if attackstatus == -1 then
        -- player pressed fight but didn't press Z afterwards
    else
        -- player did actually attack
		--hp = hp + attackstatus;
		--isHugged
		
		
		hp = headHealth[1]+
			 headHealth[2]+
			 headHealth[3]+
			 headHealth[4]+
			 headHealth[5]+
			 headHealth[6]+
			 headHealth[7];
		
		if(hp == 0)then
			feelsDeaded = true;
		end
			
		for	i=1, (#headHealth) do
			if(headHealth[i] <= 0)then
				Encounter.Call("KillHead",i);
			end
		end
		
		Encounter.Call("Shake",0.5);
    end
end
 
function Cheat()
	headHealth[2] = 0;
	headHealth[3] = 0;
	headHealth[4] = 0;
	headHealth[5] = 1;
	headHealth[6] = 0;
	headHealth[7] = 0;
	for	i=1, (#headHealth) do
		if(headHealth[i] <= 0)then
			Encounter.Call("KillHead",i);
		end
	end
end
 
-- This handles the commands; all-caps versions of the commands list you have above.
function HandleCustomCommand(command)
	if command == "CHECK" then
		BattleDialog({"???_??? ATK -"..math.random(100000000,999999999) ..math.random(100000000,999999999)..math.random(100000000,999999999).."\nLooks tasty."});
    elseif command == "BATHE" then
		if(isHugged) then
			BattleDialog("TODO.");
			batheCount = batheCount+1;
			if(batheCount >= 2)then
				AddMercy("Separate");
			end
			
		else
			BattleDialog("It won't let you.");
		end
		
    elseif command == "RUN" then
		BattleDialog({"TODO."});
    elseif command == "HUG" then
		isHugged = true;
		BattleDialog({"TODO."});
    end
    --currentdialogue = {"[font:sans]" .. currentdialogue[1]}
    --BattleDialog({"You selected " .. command .. "."})
    
end

--Empty onDeath to get the battle dialog playing
function OnDeath()
	Encounter.Call("State", "ENEMYDIALOGUE");
	hasDied = true;
	AddMercy("Consume");
end
