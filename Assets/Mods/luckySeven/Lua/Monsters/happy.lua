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

headKilled = false;
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
			headKilled = true;
			feelsAttacked = true;
		end

		return dmg;
	elseif(GetGlobal("isSprung") == true)then
		-- Compare RateToCenter to deduce which head is hit. Then KILL THAT HEAD.
		local dmg = math.floor(29 + math.random()*2);

		if(headKilled == false)then
			dmg = dmg * 2;
			--feelsAttacked = true;
		end

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
					headKilled = true;
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
					hasDied = true;
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
			hasDied = true;
		end

		local phase2HP = headHealth[2]+headHealth[3]+headHealth[4]+headHealth[5]+headHealth[6]+headHealth[7]
		if(phase2HP <= 0)then
			feelsDeaded = true;
			hasDied = true;
		end

		for i=1,#headHealth do
			if(headHealth[i] <= 0)then
				Encounter.Call("KillHead",i);
				headKilled = true;
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

			batheCount = batheCount+1;
			if(batheCount == 1)then
				BattleDialog({"You bathe It. It starts\rsplashing water on you.",
								"Its heads stop screaming,\rif just for a moment."});
			elseif(batheCount == 2)then
				BattleDialog({"You bathe It some more.\rYou scrub the inside\rof Its skulls.", "It's standing a bit\rmore straight."});
			elseif(batheCount == 3)then
				BattleDialog({"You bathe it even more.\rIts bones sparkle like diamonds.","It looks more... friendly?","The Papalgamate is content."});
				if(headKilled == false)then
					Encounter.Call("AddMercy","Separate");
				end
			else
				BattleDialog({"The Papalgamate is already\rsparkly clean."});
			end

		else
			BattleDialog("It won't let you.");
		end

    elseif command == "RUN" then
		if(headKilled and batheCount >=3)then
			NeutralEnding();
		elseif(hasDied == true and headHealth[1] > 0)then
			NeutralEnding();
		else
			BattleDialog({"Can't run."});
		end
    elseif command == "HUG" then
		if(GetGlobal("isSprung") == true)then
			isHugged = true;
			BattleDialog({"You hug It. Its many limbs\rwrap around you, tickling."});
		else
			BattleDialog({"You try to hug It.\rIt tries to hug you,\rbut It has no arms."});
		end


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

function DoTheBooty()
	Encounter.Call("FadeOutShit");
end

function NeutralEnding()
	BattleDialog({"[noskip][func:DoTheBooty]There's nothing more you can do.\rYou can only run.",
				"[noskip][waitall:2]You run as far as you can.\rAway from the memories.\rAway from the pain.",
				"[noskip][waitall:3][starcolor:f0f0f0][color:f0f0f0]You run until your legs give out.\r[color:e0e0e0]Until your legs disappear.",
				"[noskip][waitall:4][starcolor:d0d0d0][color:d0d0d0]You're disappearing.\r[color:c0c0c0]You're no longer relevant.\r[color:b0b0b0]You're useless.",
				"[noskip][waitall:4][starcolor:909090][color:909090]...",
				"[noskip][waitall:5][starcolor:707070][color:707070]There's nothing more you can do.\r\rIt's time to reset.",
				"[noskip][starcolor:000000][starnovoice][func:State,DONE]"});
	--State("DONE");
end
