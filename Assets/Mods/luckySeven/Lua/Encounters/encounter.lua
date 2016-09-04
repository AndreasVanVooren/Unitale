-- An animation demo with a rotating Sans head.
music = "Happy_Intro" --Always OGG. Extension is added automatically. Remove the first two lines for custom music.
encountertext = "[effect:none]Everything's H A P P Y ." --Modify as necessary. It will only be read out in the action select screen.
nextwaves = {"waveNull"}
wavetimer = 0.0
arenasize = {260, 130}
canRun = false;

enemies = {"happy"}

enemypositions = {{0,0},{-50, 80},{50, -80},{-50, -80},{50, 80}}

happyAnim = nil;
dialogue = nil

-- A custom list with attacks to choose from. Actual selection happens in EnemyDialogueEnding(). Put here in case you want to use it.
possible_attacks = {"waveNull"}

hasSpeech = false;

happyIntro = "[waitall:3][noskip]Everything's [waitall:8][func:Spring]H [func:Spring]A [func:Spring]P [func:Spring]P [func:Spring]Y .";

function EnteringState(newState, oldState)
	if(oldState == "ITEMMENU") then

	elseif(oldState == "ACTIONSELECT") then

	elseif(oldState == "DEFENDING")then
		ToggleSway(true);
	end

	if (newState == "ENEMYDIALOGUE") then
		--DEBUG("ASDFSADF");
		if(enemies[1].GetVar("feelsAttacked") == true)then
			--DEBUG("yee haw");
			enemies[1].SetVar("feelsAttacked",false);
			BattleDialog({
				"[waitall:3][noskip][func:PrepareSpring]You shouldn't have done that.",
				happyIntro
				});
			EnemyDialogueEnding();
		elseif(enemies[1].GetVar("feelsDeaded") == true)then
			enemies[1].SetVar("feelsDeaded",false);
			BattleDialog({
				"[func:Deaded]The end is nigh...",
				});
		elseif(not hasSpeech) then

			EnemyDialogueEnding();
			State("DEFENDING");
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
	--enemies[1].Call("SetActive",true);
	--enemies[1].SetVar("animRef", happyAnim);
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

	if(Input.Menu == 1)then
		--enemies[1].Call("Cheat");
		Player.Hurt(98456946);
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
	Spare();
     --State("ENEMYDIALOGUE")
	 --CloseEye();
end

items = {}; --use items like dictionary : items["KEY"] = "Value"
items["LOCKET"] = "INV_LOCKET";

function HandleItem(ItemID)

	if(ItemID == "LOCKET")then
		--Locket, this is how you end battle.
		--music ="the locket"
		--Audio.LoadFile(music);

		PlayMusic("the locket")

		--PlaySeparate();
		--return;

		if(GetGlobal("isSprung") == false)then
			BattleDialog({"The locket whispers to you...\rMake It remember...\rOr make It undone..."});
		elseif(enemies[1].GetVar("feelsAttacked") == true)then

		elseif(enemies[1].GetVar("hasDied") == true)then
			BattleDialog({"The locket whispers to you...\r[color:FF0000]Show it the mercy it deserves..."});
		elseif(enemies[1].GetVar("isHugged") ~= true)then
			BattleDialog({"The locket whispers to you...\rSo alone... So cold..."});
		elseif(enemies[1].GetVar("batheCount") >= 2)then
			BattleDialog({"The locket whispers to you...\rIt is time. You know what to do."});
		else
			BattleDialog({"The locket whispers to you...\rTidy for the big day..."});
		end

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

customMercy = {"Flee"};

function HandleMercy(mercyID)
	if(mercyID == "Flee")then
		BattleDialog({"You try to run...", "But there's no escape..."});
	elseif(mercyID == "Separate")then

		PlayMusic("the locket")

		--PlaySeparate();
		--return;
		BattleDialog({
					"You hold the Locket in the air.\r[w:8]\nWith a deep breath...",
					"...you reach out to the SOULS.",
						"[noskip][novoice][func:State,DONE]"--playseparate
				});

	elseif(mercyID == "Consume")then
		PlayMusic("Happy_Fuckit")
	    BattleDialog({
	    	"BEPIS",
			"We're still in the process of making of this shit",
	    	"[noskip][novoice][func:State,DONE]"
		});
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
	--State("DONE");
	if(enemies[1].GetVar("hasDied") == true)then
		BattleDialog("Too late for mercy.");
	elseif(GetGlobal("isSprung") == false)then
		BattleDialog({
				"[noskip][waitall:4]You show mercy to It.[w:8]\n[func:PrepareSpring]It seems to remember something...",
				happyIntro
		});
	else
		BattleDialog({"It doesn't look like it's working..."
		});
	end
end

function PrepareSpring()
	Audio.Stop();
	happyAnim.ShowEye(1);
	happyAnim.ToggleSway(false);
	--enableTorseye
end

function ToggleSway(bool)
	happyAnim.ToggleSway(bool);
end

function ToggleHand()
	happyAnim.ToggleHand();
end

function Deaded()
	Audio.LoadFile("Happy_Intro");
	Audio.Pitch(0.5);
	happyAnim.ShowEye(1);
	happyAnim.ToggleSway(false);
	happyAnim.ResetTimer();
	--enableTorseye
	wavetimer = 0;
	possible_attacks = {"waveNull"};
end

function ShowEye2()
	--DEBUG("AFSAFDASF");
	happyAnim.ShowEye(2);
end

function ShowEye3()
	happyAnim.ShowEye(3);
end

function ShowEye4()
	happyAnim.ShowEye(4);
end

function ShowEye5()
	happyAnim.ShowEye(5);
end

function ShowEye6()
	happyAnim.ShowEye(6);
end

function ShowEye7()
	happyAnim.ShowEye(7);
end

function HideEyes()
	happyAnim.HideEye(2);
	happyAnim.HideEye(3);
	happyAnim.HideEye(4);
	happyAnim.HideEye(5);
	happyAnim.HideEye(6);
	happyAnim.HideEye(7);
end

function GetLivingHeads()
	local healths = enemies[1].GetVar("headHealth");
	--we only need heads higher than 2 for this check
	local heads ={}
	for i=2,7 do
		if(healths[i] > 0)then
			table.insert(heads, i);
		end
	end

	return heads;
end

function Spring()
	--DEBUG("sadfasdf");
	happyAnim.SpringUp();
	--change attacks, set wave timer
	wavetimer = 999;	--gonna manually end wave;
	possible_attacks = {"waveCombatAngry"};
end

function KillHead(index)
	happyAnim.KillHead(index);
end

function Shake(amount)
	happyAnim.Shake(amount);
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
