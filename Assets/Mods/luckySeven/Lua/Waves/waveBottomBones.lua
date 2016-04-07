-- The bouncing bullets attack from the documentation example.
--spawntimer = 0
bullets = nil

function Update()
	if(bullets == nil)then
		--spawn bullets;
		bullets = {};
		
		for i=1,12 do
			local bullet = CreateProjectile(
				"It/boneSmall".. ((i%2)+1),
				(i-6.5) * Arena.width/12,
				-(Arena.height-35) /2 
			)
			bullet.SetVar("hit",true)
			table.insert(bullets,bullet)
		end
	end
	
	local bSpeedX = 40;
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