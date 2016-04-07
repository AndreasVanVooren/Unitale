-- A basic monster script skeleton you can copy and modify for your own creations.
comments = {"Smells like sound.", "NAR_RESPONSE_EXTEND.zip\rcannot be found.", "Flaming gasoline jets out\rfrom its many orifices."}
commands = {"Check","Feed", "Debate", "Love"}
randomdialogue = {"[font:sans][voice:v_sans]why even\nbother?\n\nwhy even\nbother?"}

sprite = "Happy/temp" --Always PNG. Extension is added automatically.
name = "ERR_NAME_NOT_FOUND"
hp = 100
--atk = "#"
--def = "#"
--check = "You can't. It's all going to\rend. It's all going to end."
dialogbubble = "right" -- See documentation for what bubbles you have available.
cancheck = false
canspare = false
--snowThrowCount = 0;
--SetGlobal("angry", false);

-- Happens after the slash animation but before 
function HandleAttack(attackstatus)
    if attackstatus == -1 then
        -- player pressed fight but didn't press Z afterwards
    else
        -- player did actually attack
		hp = hp + attackstatus;
    end
end
 
-- This handles the commands; all-caps versions of the commands list you have above.
function HandleCustomCommand(command)
	if command == "CHECK" then
		BattleDialog({"???_??? ATK -"..math.random(100000000,999999999) ..math.random(100000000,999999999).."\nLooks tasty."});
    elseif command == "FEED" then
		BattleDialog("TODO.");
    elseif command == "DEBATE" then
		BattleDialog({"TODO."});
    elseif command == "LOVE" then
		BattleDialog({"TODO."});
    end
    --currentdialogue = {"[font:sans]" .. currentdialogue[1]}
    --BattleDialog({"You selected " .. command .. "."})
    
end
