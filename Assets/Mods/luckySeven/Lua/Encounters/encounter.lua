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
consumeAnim = nil;
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
	consumeAnim = require "Animations/consume_anim";
	--dialogue =  require "Animations/itDialogue_anim"

	--enemypositions[1] = {0, 0};
	--enemies[1].Call("SetActive",true);
	--enemies[1].SetVar("animRef", happyAnim);
	Player.name = "";
	local name = 4;
	--Player.lv = 1;
	maxhp = 16 + 4 * Player.lv;
end

successes = 0;
codeTimer = 0;
fullSuccess = false;
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
		--DEBUG("Konami");
		successes = 11;
		fullSuccess = true;
		--AddItem("CHARA", "OtherItm");
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
local playTrack = false;
function Update()
	SeparateAnim();
	Konami();

	if(happyAnim ~= nil)then
		happyAnim.Update();
	end

	if(consumeAnim ~= nil)then
		consumeAnim.Update();
	end

	if(Input.Menu == 1)then
		--enemies[1].Call("Cheat");
		--PlaySeparate();
		--Player.hp = 20;
		if(consumeAnim ~= nil)then
			consumeAnim.StartConsume();
		end

	end

end

function EnemyDialogueEnding()
    -- Good location to fill the 'nextwaves' table with the attacks you want to have simultaneously.
    -- This example line below takes a random attack from 'possible_attacks'.

	if(GetGlobal("isSprung") == false or enemies[1].GetVar("hasDied") == true or enemies[1].GetVar("batheCount") >= 3)then
		wave = "waveNull";
		wavetimer = 0;
	elseif(enemies[1].GetVar("headKilled") == true)then
		wave = "waveCombatAngry";
		wavetimer = 999;
	else
		wave = "waveCombat";
		wavetimer = 999;
	end
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

		--PlayMusic("the locket")

		--PlaySeparate();
		--return;
		StartTempMusic("the locket");
		--still in first phase
		if(GetGlobal("isSprung") == false)then
			BattleDialog({"The locket whispers to you...\r[waitall:4][color:ffffc0]Make It remember...\r[color:ffc0c0]Or make It undone...","[func:StopTempMusic][func:State,ENEMYDIALOGUE]"});
		--is ded
		elseif(enemies[1].GetVar("hasDied") == true)then
			BattleDialog({"The locket whispers to you...\r[waitall:4][color:ff0000]Show it the mercy it deserves...","[func:StopTempMusic][func:State,ENEMYDIALOGUE]"});
		--has been attacked, and a head has been killed
		elseif(enemies[1].GetVar("headKilled") == true)then
			--but the player reached the end of mercy route.
			if(enemies[1].GetVar("batheCount") >= 3)then
				BattleDialog({"The locket whispers to you...\r[waitall:4][color:c0c000]You tried your best.\rNow you can only leave.","[func:StopTempMusic][func:State,ENEMYDIALOGUE]"});
			--but player decided to hug anyway
			elseif(enemies[1].GetVar("isHugged") == true)then
				BattleDialog({"The locket questions\ryour judgement, but remains\rsilent otherwise.","[func:StopTempMusic][func:State,ENEMYDIALOGUE]"});
			--player is bashing his fokken 'ead in
			else
				BattleDialog({"The locket whispers to you...\r[waitall:4][color:ffa0a0]The game has changed.\rAim with care.","[func:StopTempMusic][func:State,ENEMYDIALOGUE]"});
			end
		--no head is kill, end of mercy route
		elseif(enemies[1].GetVar("batheCount") >= 3)then
			BattleDialog({"The locket whispers to you...\r[waitall:4][color:ffff00]It is time. You know what to do.","[func:StopTempMusic][func:State,ENEMYDIALOGUE]"});
		--no bathes yet, but hugged
		elseif(enemies[1].GetVar("isHugged") == true)then
			BattleDialog({"The locket whispers to you...\r[waitall:4][color:ffff30]Tidy for the big day...","[func:StopTempMusic][func:State,ENEMYDIALOGUE]"});
		--no bathes, not hugged, no heads killed, second phase
		else
			BattleDialog({"The locket whispers to you...\r[waitall:4][color:ffffa0]So alone... So cold...","[func:StopTempMusic][func:State,ENEMYDIALOGUE]"});
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
		if(Player.hp < maxhp) then
			BattleDialog({
			"[noskip]You drink up the cider spiders.",
			"[noskip]The spiders crawl down\ryour esophagus...",
			"[noskip][waitall:2]Into your stomach...",
			"[noskip][waitall:4]Where the acids...\r[waitall:0][color:1A0000][novoice]NONONONONONONONONONONONONONONO\r[voice:default][waitall:4][color:ffffff]boil them alive.",
			"[noskip][waitall:8]...[waitall:2]Your HP[waitall:8]...[func:Heal,24]"
			});
			RemoveItem(ItemID);
		else
			BattleDialog("You feel fine.\nYou'll leave the spiders alone...\r[waitall:8]...for now...")
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
		if(enemies[1].GetVar("headKilled") == true and enemies[1].GetVar("batheCount") >= 3)then
			NeutralEnding();
		elseif(enemies[1].GetVar("hasDied") == true and enemies[1].GetVar("headHealth")[1] > 0)then
			NeutralEnding();
		else
			BattleDialog({"You try to run...", "But there's no escape..."});
		end
	elseif(mercyID == "Separate")then

		PlayMusic("the locket")

		--PlaySeparate();
		--return;
		BattleDialog({
					"You hold the Locket in the air.\r[w:8]\nWith a deep breath...",
					"...you reach out to the SOULS.",
						"[noskip][novoice][func:PlaySeparate]"--playseparate
				});

	elseif(mercyID == "Consume")then
		PlayMusic("the locket")
		BattleDialog({
					"You hold the Locket in the air.\r[w:8]\nWith a deep breath...",
					"...you reach for the SOULS.",
						"[noskip][novoice][func:State,DONE]"--playseparate
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
	--All heads dead
	if(enemies[1].GetVar("hasDied") == true)then
		--first head still intact
		if(enemies[1].GetVar("headHealth")[1] > 0)then
			BattleDialog("Too late for mercy.");
		else
			BattleDialog("[starcolor:ff0000][color:ff0000]Don't even bother.");
		end

	elseif(GetGlobal("isSprung") == false)then
		BattleDialog({
				"[noskip][waitall:3][func:PREPrepareSpring]You show mercy to It.[w:6]\n[func:PrepareSpring]It seems to remember something...",
				happyIntro
		});
	elseif(enemies[1].GetVar("headKilled") == true)then
		if(enemies[1].GetVar("batheCount")>=2)then
			BattleDialog({"It doesn't want your mercy...\rYou can only run..."
			});
		else
			BattleDialog({"It doesn't want your mercy..."
			});
		end
	else
		BattleDialog({"It doesn't look like\rit's working..."
		});
	end
end

function PREPrepareSpring()
	Audio.FadeOut(1.25);
end

function PrepareSpring()
	Audio.FadeOut(1.25);
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
	happyAnim.HideEye(1);
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
	--wavetimer = 999;	--gonna manually end wave;
	--possible_attacks = {"waveCombatAngry"};
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

function StartTempMusic(name)
	Audio.Crossfade(name);
end

function StopTempMusic()
	if(GetGlobal("isSprung") == false)then
		Audio.Crossfade("Happy_Intro",0.75,1);
	else
		Audio.Crossfade("Happy_Loop",0.75,1);
	end
end

function NeutralEnding()
	BattleDialog({"[noskip][func:FadeOutShit]There's nothing more you can do.\rYou can only run.",
		"[noskip][waitall:2]You run as far as you can.\rAway from the memories.\rAway from the pain.",
		"[noskip][waitall:3][starcolor:f0f0f0][color:f0f0f0]You run until your legs give out.\r[color:e0e0e0]Until your legs disappear.",
		"[noskip][waitall:4][starcolor:d0d0d0][color:d0d0d0]You're disappearing.\r[color:c0c0c0]You're no longer relevant.\r[color:b0b0b0]You're useless.",
		"[noskip][waitall:4][starcolor:909090][color:909090]...",
		"[noskip][waitall:5][starcolor:707070][color:707070]There's nothing more you can do.\r\rIt's time to reset.",
		"[noskip][starcolor:000000][func:State,DONE]"});
	--State("DONE");
end

function FadeOutShit()
	DEBUG("ASFDS");
	happyAnim.FadeToBlack(0.1);
	Audio.FadeOut(1);
end
