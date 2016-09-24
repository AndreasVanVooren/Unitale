-- The bouncing bullets attack from the documentation example.
--spawntimer = 0
bullets = {}
warning = nil;
bulletState = 0;
bulletTimer = 0;
onRightSide = 0;

warningDelay = 0.25;
warningTime = 0.75;
bulletSpeed = 1500;

function Update()
	if(bulletState == 0)then
		onRightSide = math.random(2);
		bulletState = 1;
	elseif(bulletState == 1) then
		bulletTimer = bulletTimer + Time.dt;
		if(bulletTimer > warningDelay) then 
			--spawn warning sign
			Audio.PlaySound("Beep");
			warning = CreateProjectile("It/danger1",0,0);	--bug : anim != src dim;
			--DEBUG(warning.sprite.xscale)
			warning.sprite.SetAnimation({"It/danger1", "It/danger2"})
			
			warning.SetVar("hit", false);
			if(onRightSide == 2) then --rightside
				warning.sprite.SetPivot(1,0);
				warning.Move( Arena.width/2, -Arena.height/2 );
			else
				warning.sprite.SetPivot(0,0);
				warning.Move( -Arena.width/2, -Arena.height/2 );
			end
			--DEBUG(warning.sprite.xscale)
			--warning.sprite.Scale(2.5,3.25);
			--DEBUG(warning.sprite.xscale)
			
			--reset timers
			bulletState = 2;
			bulletTimer = 0;
		end
	elseif (bulletState == 2) then
		--show warning sign
		bulletTimer = bulletTimer + Time.dt;
		if(bulletTimer > warningTime) then
			--warning sign ran out, removing
			bulletState = 3;
			warning.Remove();
			warning = nil;
			
			for i=1, 5 do
				local bullet = CreateProjectile("It/bone"..((i%3)+1) ,0,0);--TODO find width of sprite.
				bullet.SetVar("hit", true);
				bullet.SetVar("stoppedMoving", false);
				local x = 0;
				local y = 0;
				
				if(onRightSide == 2)then
					x = Arena.width/2-(10 + 20*(i-1))
				else
					x = -(Arena.width/2-(10 + 20*(i-1)))
				end
				
				if(i%2 == 0) then--is even
					bullet.SetVar("movingDown", false);
					y = -(Arena.height + (i-1)*50);
				else
					bullet.SetVar("movingDown", true);
					y = (Arena.height + (i-1)*50);
				end
				
				bullet.MoveTo(x,y);
				
				table.insert(bullets, bullet);
			end
			bulletTimer = 0;
			
		end
		
	elseif (bulletState == 3) then
		--update loop bullets.
		bulletTimer = bulletTimer + Time.dt;
		for i=1,#bullets do
			local bullet = bullets[i];
			if(bullet.GetVar("stoppedMoving") ~= true) then 
				if(bullet.GetVar("movingDown") == true) then 
					local newY = bullet.y - (bulletSpeed * Time.dt);
					--DEBUG(newY);
					if(newY < 0) then 
						newY = 0; 
						bullet.SetVar("stoppedMoving", true);
						Audio.PlaySound("chack")
						--play chack sound
					end
					bullet.MoveTo(bullet.x, newY);
				else
					local newY = bullet.y + (bulletSpeed * Time.dt);
					if(newY > 0) then
						newY = 0; 
						bullet.SetVar("stoppedMoving", true);
						Audio.PlaySound("chack")
					end
					bullet.MoveTo(bullet.x, newY);
				end
			end
		end
		
		if(bulletTimer > 1.5) then EndWave() end
	end
end

function OnHit(bullet)
	if(bullet.GetVar("hit") == true) then
		--do the hit thing
		Player.Hurt(5);
	end
end