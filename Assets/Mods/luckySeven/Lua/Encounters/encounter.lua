-- An animation demo with a rotating Sans head.
music = "Happy_Intro" --Always OGG. Extension is added automatically. Remove the first two lines for custom music.
encountertext = "Everything's H A P P Y ." --Modify as necessary. It will only be read out in the action select screen.
nextwaves = {"waveBones"}
wavetimer = 4.0
arenasize = {155, 130}

enemies = {"happy"}

enemypositions = {{0,0},{-50, 80},{50, -80},{-50, -80},{50, 80}}

happyAnim = nil;
dialogue = nil

-- A custom list with attacks to choose from. Actual selection happens in EnemyDialogueEnding(). Put here in case you want to use it.
possible_attacks = {
"waveBones", 
"waveHeart",
"waveGaster",
"waveBottomBones"}

hasSpeech = false;

function EnteringState(newState, oldState)
	if(oldState == "ITEMMENU") then
	
	elseif(oldState == "ACTIONSELECT") then
	
	end
	
	if (newState == "ENEMYDIALOGUE") then 
		if(not hasSpeech) then
			State("DEFENDING");
		else
			
		end
	elseif(newState == "ACTIONSELECT")then
		
	end
	
	--DEBUG(encountertext);
end


function EncounterStarting()
    --Include the animation Lua file. It's important you do this in EncounterStarting, because you can't create sprites before the game's done loading.
    --Be careful that you use different variable names as you have here, because the encounter's will be overwritten otherwise!
    --You can also use that to your benefit if you want to share a bunch of variables with multiple encounters.
    --require "Animations/it_anim" 
	happyAnim = require "Animations/happy_anim";
	require "Animations/separate_anim" ;
	--dialogue =  require "Animations/itDialogue_anim"
	
	--enemypositions[1] = {0, 0};
	enemies[1].Call("SetActive",true);
	Player.name = "";
	--Player.lv = 1;
	maxhp = 16 + 4 * Player.lv;
end

successes = 0;
codeTimer = 0;
function Konami()
	
	if(codeTimer > 0)then
		codeTimer = codeTimer - Time.dt;
	elseif (successes <= 10)then
		successes = 0;
	end

	if(successes == 0 and Input.Up == 1) then
		successes = 1;
		codeTimer = 0.5;
	elseif(successes == 1 and Input.Up == 1) then
		successes = 2;
		codeTimer = 0.5;
	elseif(successes == 2 and Input.Down == 1) then
		successes = 3;
		codeTimer = 0.5;
	elseif(successes == 3 and Input.Down == 1) then
		successes = 4;
		codeTimer = 0.5;
	elseif(successes == 4 and Input.Left == 1) then
		successes = 5;
		codeTimer = 0.5;
	elseif(successes == 5 and Input.Right == 1) then
		successes = 6;
		codeTimer = 0.5;
	elseif(successes == 6 and Input.Left == 1) then
		successes = 7;
		codeTimer = 0.5;
	elseif(successes == 7 and Input.Right == 1) then
		successes = 8;
		codeTimer = 0.5;
	elseif(successes == 8 and Input.Cancel == 1) then
		successes = 9;
		codeTimer = 0.5;
	elseif(successes == 9 and Input.Confirm == 1) then
		successes = 10;
		codeTimer = 0.5;
	elseif(successes == 10 and Input.Menu == 1) then
		DEBUG("Konami");
		successes = 11
		AddItem("CHARA", "OtherItm");
	elseif((
	Input.Up == 1 or 
	Input.Down == 1 or
	Input.Left == 1 or 
	Input.Right == 1 or
	Input.Confirm == 1 or 
	Input.Cancel == 1 or
	Input.Menu == 1 )and successes <= 10)then
		successes = 0;
	end
	
	
end

function Update()
	SeparateAnim();
	Konami();
	
	if(happyAnim ~= nil)then
		happyAnim.Update();
	end
	
end

function EnemyDialogueEnding()
    -- Good location to fill the 'nextwaves' table with the attacks you want to have simultaneously.
    -- This example line below takes a random attack from 'possible_attacks'.
	local wave = possible_attacks[math.random(#possible_attacks)]
	
	--if(GetGlobal("angry") == true) then 
	--	wave = wave .. "Angry";
	--end
    nextwaves = { wave }
	
end

function EnemyDialogueStarting()
	--if(enemies[1].GetVar("SpecialDialog"))
	--State("DEFENDING")
end

function PlayMusic(name)
	if(music ~= name)then
			--Audio.LoadFile("mus_HELP_tale_it");
			music = name
			Audio.LoadFile(music);
		end
end

function DefenseEnding() --This built-in function fires after the defense round ends.
	
	encountertext = RandomEncounterText() --This built-in function gets a random encounter text from a random enemy.
	
end

function HandleSpare()
	isdfd = nil;
	isdfd.Perform();

     --State("ENEMYDIALOGUE")
	 --CloseEye();
end

items = {}; --use items like dictionary : items["KEY"] = "Value"
items["DIO"] = "TotesItm";

function HandleItem(ItemID)
	
	if(ItemID == "DOGTEST1")then
		--Locket, this is how you end battle.
		--music ="the locket"
		--Audio.LoadFile(music);
		
		PlayMusic("the locket")
		
		--PlaySeparate();
		--return;
		
		BattleDialog({
				"You hold the Locket in the air.\r[w:8]\nWith a deep breath...",
				"...you choke on the foul air."
			});
		
			--State("ACTIONSELECT")
			--encountertext = "The Sanstrosity seems content."
		--BattleDialog({
		--	"You hold the Locket in the air.\r[w:8]\nWith a deep breath...",
		--	"...you reach out to the SOULS.",
		--	"[noskip][novoice][func:PlaySeparate]"
		--});
		
	elseif(ItemID == "DOGTEST2")then
		--Generic healing item (Spider cider equivalent)
		if(itemUsed[2] == false) then
			if(Player.hp < maxhp) then
				BattleDialog({
				"[noskip]You drink up the cider spiders.",
				"[noskip]The spiders crawl down\ryour esophagus...",
				"[noskip][waitall:2]Into your stomach...",
				"[noskip][waitall:4]Where the acids...\r[waitall:0][color:1A0000][novoice]NONONONONONONONONONONONONONONO\r[voice:default][waitall:4][color:ffffff]boil them alive.",
				"[noskip][waitall:8]...[waitall:2]Your HP[waitall:8]...[func:Heal,24]"
				});
				itemUsed[2] = true;
			else
				BattleDialog("You feel fine.\nYou'll leave the spiders alone...\r[waitall:8]...for now...")
				toItems = true;
			end
		
			
		else
			if(Player.hp < maxhp) then
				BattleDialog({
					"You asked the spiders for help.",
					"[waitall:2]But nobody came..."
				});
			else
				BattleDialog("Your craving for spiders\rwas already sated.");
				
			end
			toItems = true;
		end
	elseif(ItemID == "DOGTEST3")then
		--Generic healing item (Spider Donut equivalent)
		if(itemUsed[3] == false) then
			if(Player.hp < maxhp) then
				BattleDialog({
					"You look through the hole\rof the Donut Donut.",
					"[waitall:2]You notice only darkness...\r[color:1A0000][novoice][waitall:0]HELP ME HELP ME HELP ME HELP ME\r[voice:default][waitall:2][color:ffffff]dark, yet darker.",
					"[waitall:4]You gaze into the abyss...\nThe abyss gazes back.",
					"[noskip][waitall:8]...[waitall:2]Your HP[waitall:8]...[func:Heal,24]"
				});
				itemUsed[3] = true;
			else
				BattleDialog("You cannot yet comprehend\rthe form of the Donut Donut.")
				toItems = true;
			end
		else
			if(Player.hp < maxhp) then
			BattleDialog({
				"You shout into the\rDonut Donut for help.",
				"But nobody came..."
			});
			else
				BattleDialog("You do not yet desire\rthe darkness.")
				
			end
			toItems = true;
		end
	elseif(ItemID == "DOGTEST4")then
		--Generic healing item (Monster Candy equivalent)
		if(itemUsed[4] == false) then
			if(Player.hp < maxhp) then
				BattleDialog({
					"[noskip]You eat the Candy Monster.\n[w:4][func:Heal,10]It was delicious!",
					"A faint screaming is heard from\rinside your stomach.\n[w:4][func:Hurt,1]It's less delicious!",
					
				});
				itemUsed[4] = true;
			else
				BattleDialog("The Candy Monster looks\rtoo adorable.[w:4]\nYou don't eat the Candy Monster.")
				toItems = true;
			end
		else
			--if(Player.hp < maxhp) then
			BattleDialog({
				"The Candy Monster is goop now."
			});
			toItems = true;
			--else
				--BattleDialog("You do not yet desire\rthe darkness.")
			--end
		end
	elseif(ItemID == "DOGTEST5")then
		--Do stuff
		if(itemUsed[5] == false) then
			if(Player.hp < maxhp) then
				BattleDialog({
					"[noskip]ERROR: ITEM_NOTHING_USE_DESC\rNOT FOUND.[func:Heal,0]"
					
				});
				itemUsed[5] = true;
			else
				BattleDialog("ERROR: ITEM_NOTHING_NOUSE_DESC\rNOT FOUND.")
				toItems = true;
			end
		else
			--if(Player.hp < maxhp) then
			BattleDialog({
				"ERROR: NOTHING NOT FOUND.[w:20]\rNOTHING NOT FOUND.[w:20][waitall:0]\rNOTHING NOT FOUND.\rNOTHING NOT FOUND.\rNOTHING NOT FOUND.\rNOTHING NOT FOUND.\rNOTHING NOT FOUND.\rNOTHING NOT FOUND.\r"
			});
			toItems = true;
			--else
				--BattleDialog("You do not yet desire\rthe darkness.")
			--end
		end
	elseif(ItemID == "DOGTEST6")then
		--It is I, DIO!!!
		if(itemUsed[6] == false) then
			if(Player.hp < maxhp) then
				BattleDialog(
				{
					"You ingest your laughter.",
					"[waitall:2]Tastes like lies...[w:6]\rand [waitall:4][color:ff0000]determination.",
					"[noskip][waitall:8]...[waitall:2]Your HP[waitall:8]...[func:Heal,666]"
				});
				itemUsed[6] = true;
			else
				BattleDialog("You can still muster a chuckle.");
				toItems = true;
			end
		else
			BattleDialog({
				"[noskip][waitall:4][func:DisableSpecials][func:FadeToGrey][func:StopVibrating]How can you consume your soul...",
				"[novoice][noskip][func:DarknessCometh][waitall:6][color:ff0000]When you don't have one?[w:40][func:DieDark]"
			});
		end
	elseif(ItemID == "DOGTEST7")then
		--Kills you.
		
		local num = math.random(3);
		if(num == 1)then
			BattleDialog("[noskip][waitall:0][color:ffff00]According to all known laws of aviation,\rthere is no way a bee should be able to fly.\rIts wings are too small to get its fat little body off the ground[func:DieLoser].");
		elseif (num == 2)then
			BattleDialog("[noskip][waitall:0][color:ffff00]Yellow, [color:808080]black, [color:ffff00]yellow, [color:808080]black.\r[color:ffff00]Yellow, [color:808080]black, [color:ffff00]yellow, [color:808080]black.\r[color:ffffff]Ooh, [color:ffff00]black [color:ffffff]and [color:808080]yellow!\r[color:ffffff]Let's shake it up a little.[func:DieLoser]");
		--elseif (num == 3) then		--commented out due to not 
			--BattleDialog("[noskip][waitall:0]HAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHA\rHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHA\rHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHA\rHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHA\rHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHAHA[func:DieLoser].");
		elseif (num == 3) then
			BattleDialog("[noskip][waitall:0][color:ff0000]NO!!! NOT THE BEES!!! NOT THE BEES!!!\rAAAAAAAAAAAAAAAAAAAAAAAH!!!\rTHEY'RE IN MY EYES! MY EYES! AAAAAAA\rAAAAAAAAAAAAAAAAAAAAAAAAAAAH![func:DieLoser].");
		end
		--Player.hp = 0;
	elseif(ItemID == "DIO") then
		BattleDialog({"You were expecting an item...", "But it was me, DIO!"});
	elseif(ItemID == "CHARA") then
		BattleDialog({"You were expecting an item...", "But it was me, CHARA!"});
		RemoveItem(ItemID);
	end
    --BattleDialog({"Selected item " .. ItemID .. "."})
	if(toItems)then
		--State("ITEMSELECT")
	end
end

function PauseAudio()
	Audio.Pause()
end

function ResumeAudio()
	Audio.Unpause()
end

function OnHit(bullet)
	
end

function Hurt(amount)
	--DEBUG("OK" .. amount)
	Audio.PlaySound("hurtsound");
	Player.hp = Player.hp - amount;
end

function Heal(amount)
	--DEBUG("OK" .. amount)
	Audio.PlaySound("healsound");
	Player.hp = Player.hp + amount;
end

function Spare()
	State("DONE");
end

function DieDark()
	local c =CreateProjectile("It/chara",0,200);
	c.sprite.alpha = 0.1;
	Player.hp = 0;
	--Player.name = "#@XX!0";
end

function DieLoser()
	Player.hp = 0;
	Player.name = "#@XX!0";
end

--usually done at endgame
function DisableSpecials()
	disableSpecials = true;
end