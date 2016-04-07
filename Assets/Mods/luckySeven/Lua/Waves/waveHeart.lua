-- The bouncing bullets attack from the documentation example.
--spawntimer = 0
bullets = {}

gravity = -300;
yVelocity = 0;

xSpeed = 100;
yJump = 200;
playerX = 0;
playerY = 0;
isFloored = false;

function Update()
    Player.sprite.color = {0,0,1};
	MovePlayer();
	
end

function MovePlayer()
	Player.SetControlOverride(true);

	local x = playerX;
	local y = playerY;
	local dt = Time.dt;
	
	if(Input.Left > 0)then
		x = x - xSpeed * dt;
	end
	if(Input.Right > 0)then
		x = x + xSpeed * dt;
	end
	
	
	yVelocity = yVelocity + gravity * dt;
	
	y = y + yVelocity * dt;
	
	if(y < -Arena.height/2 + 8)then
		y = -Arena.height/2 + 7 --we ignore walls, but just to make sure.
		isFloored = true;
	end
	
	if(Input.Up > 0)then
		--check if floored.
		if(isFloored) then
			yVelocity = yJump;
			isFloored = false;
		end
	end
	--move in the arena, with collisions enabled
	Player.MoveTo(x, y, false);
	
	--set to the new positions
	playerX = Player.x;
	playerY = Player.y;
end

function OnHit(bullet)
	if(bullet.GetVar("hit") == true) then
		--do the hit thing
		Player.Hurt(math.random(3,5));
	end
end