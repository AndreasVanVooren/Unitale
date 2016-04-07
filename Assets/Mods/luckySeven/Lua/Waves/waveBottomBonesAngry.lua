-- The bouncing bullets attack from the documentation example.
--spawntimer = 0
bullets = nil

function Update()
	if(bullets == nil)then
		--spawn bullets;
		bullets = {};
		
		for i=1,12 do
			local path = ""
			local y = 0;
			if(i == 1 ) then
				path = "It/boneBig2";
				y = -(Arena.height-90) /2 ;
			else
				path = "It/boneSmall".. ((i%2)+1);
				y = -(Arena.height-35) /2 ;
			end
			
			local bullet = CreateProjectile(
				path,
				(i-6.5) * Arena.width/12,
				y
			)
			bullet.SetVar("hit",true)
			table.insert(bullets,bullet)
			
			if( i == 8) then
				local b = CreateProjectile(
					path,
					(i-6.5) * Arena.width/12,
					-y
				);
				b.sprite.rotation = 180;
				b.SetVar("hit",true);
				table.insert(bullets,b);
			end
		end
	end
	
	local bSpeedX = 100;
	local bDispX = bSpeedX * Time.dt;
	
	for i=1, (#bullets) do
		local b = bullets[i];
		local x = b.x;
		local y = b.y;
		
		x = x + bDispX;
		if(x > (Arena.width+2)/2) then
			x = x- (Arena.width+2);
		end
		
		b.MoveTo(x,y);
	end
end

function OnHit(bullet)
	if(bullet.GetVar("hit") == true) then
		--do the hit thing
		Player.Hurt(5);
	end
end