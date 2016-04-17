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

animRef = nil;

isHugged = false;
batheCount = 0;

headHealth = {111,111,111,111,111,111,111};

--Comes before damage is actually calculated, and can replace damage calculation entirely
--Parameters :
--	+ rateToCenter => The position ratio of the target cursor relative to the center of the UI thing. Goes from -1 (left) to 1 (right)
--Return values : 
--	+ void (end function without returning a value, or do return;) => Use default behaviour
--	+ nil (explicitly state return nil;) => Miss target;
--  + number (eg. return 5) => damage taken, in the future damage healed, but this isn't implemented yet.
--		=> The damage value is automatically rounded to the nearest integer value.
--  + anything else (eg. return "Bepis") => throws error.
function HandlePreAttack(rateToCenter)
	--This line of code is to change behaviour when you don't press the Z button in time.
	--if(not(rateToCenter < math.huge and rateToCenter > -math.huge and rateToCenter == rateToCenter))then
	--	DEBUG("To infinity");
	--end
	
	-- Compare RateToCenter to deduce which head is hit. Then KILL THAT HEAD.
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
    end
end
 
-- This handles the commands; all-caps versions of the commands list you have above.
function HandleCustomCommand(command)
	if command == "CHECK" then
		BattleDialog({"???_??? ATK -"..math.random(100000000,999999999) ..math.random(100000000,999999999)..math.random(100000000,999999999).."\nLooks tasty."});
    elseif command == "BATHE" then
		if(isHugged) then
			BattleDialog("TODO.");
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
