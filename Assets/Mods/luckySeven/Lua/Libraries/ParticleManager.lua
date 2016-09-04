--function Lerp(a,b,t)
--  return (1-t)*a + t*b;
--end

local particleManager = {};
local activeParticleSystems = {};

--index list. prevents me from having to find all the indices in the functions when adding a new member to the array.
local spriteI = 1;
local partCountI = 2;
local partGapI = 3;
local absolute = 4;
local initXI = 5;
local initYI = 6;
local lifeI = 7;
local xVelMinI = 8;
local yVelMinI = 9;
local xVelMaxI = 10;
local yVelMaxI = 11;
local gravI = 12;
local rotVMinI = 13;
local rotVMaxI = 14;
local timeI = 15;
local partStart = 16;

function particleManager.CreateParticles(possibleSprites,
                                         startPosX,
                                         startPosY,
                                         timeBetweenParticles,
                                         lifeTime,
                                         xMinStartVelocity,
                                         yMinStartVelocity,
                                         xMaxStartVelocity,
                                         yMaxStartVelocity,
                                         gravity,
                                         minRotSpeed,
                                         maxRotSpeed,
                                         particleCount)
  local system = {possibleSprites,
                  particleCount,
                  timeBetweenParticles,
                  false,
                  startPosX,
                  startPosY,
                  lifeTime,
                  xMinStartVelocity,
                  yMinStartVelocity,
                  xMaxStartVelocity,
                  yMaxStartVelocity,
                  gravity,
                  minRotSpeed,
                  maxRotSpeed,
                  0                     --initialTimer
                }
  table.insert(activeParticleSystems,system);
  return system;
end

function particleManager.CreateParticlesAbs(possibleSprites,
                                            startPosX,
                                            startPosY,
                                            timeBetweenParticles,
                                            lifeTime,
                                            xMinStartVelocity,
                                            yMinStartVelocity,
                                            xMaxStartVelocity,
                                            yMaxStartVelocity,
                                            gravity,
                                            minRotSpeed,
                                            maxRotSpeed,
                                            particleCount)
  local system = {possibleSprites,
                  particleCount,
                  timeBetweenParticles,
                  true,
                  startPosX,
                  startPosY,
                  lifeTime,
                  xMinStartVelocity,
                  yMinStartVelocity,
                  xMaxStartVelocity,
                  yMaxStartVelocity,
                  gravity,
                  minRotSpeed,
                  maxRotSpeed,
                  0                     --initialTimer
                }
  table.insert(activeParticleSystems,system);
  return system;
end

function particleManager.EndSystem(system);

end

local function CreateSingleParticle(partSystem,absolute)
  local possibleSprites = partSystem[spriteI];
  local x = partSystem[initXI];
  local y = partSystem[initYI];
  local timer = partSystem[lifeI];
  local xVelMin = partSystem[xVelMinI];
  local yVelMin = partSystem[yVelMinI];
  local xVelMax = partSystem[xVelMaxI];
  local yVelMax = partSystem[yVelMaxI];
  local gravity = partSystem[gravI];
  local minRotSpeed = partSystem[rotVMinI];
  local maxRotSpeed = partSystem[rotVMaxI];

  local index = math.random(1,#possibleSprites);
  local part = nil;
  if(absolute)then
      part = CreateProjectileAbs(possibleSprites[index],x,y);
  else
      part = CreateProjectile(possibleSprites[index],x,y);
  end
  part.SetVar("timer",timer);
  part.SetVar("lifeTime",timer);
  part.SetVar("xVelocity",math.random(xVelMin,xVelMax));
  part.SetVar("yVelocity",math.random(yVelMin,yVelMax));
  part.SetVar("gravity",gravity);
  part.SetVar("rotSpeed",math.random(minRotSpeed,maxRotSpeed));
  return part;
end

local function UpdateSingleParticle(particle, absolute)
	if(particle == nil)then return; end
	local posX = 0;
	local posY = 0;
    if(absolute)then
        posX = particle.absx;
        posY = particle.absy;
    else
        posX = particle.x;
        posY = particle.y;
    end
	local timer = particle.GetVar("timer") - Time.dt;
	local xVelocity = particle.GetVar("xVelocity");
	local yVelocity = particle.GetVar("yVelocity");
	local gravity = particle.GetVar("gravity");
	local rotation = particle.sprite.rotation;
	local rotSpeed = particle.GetVar("rotSpeed");

	particle.SetVar("timer",timer);
	if(timer <= 0)then
		particle.Remove();
		return false;
	end

	yVelocity = yVelocity + gravity * Time.dt;
	particle.SetVar("yVelocity",yVelocity);

	posX = posX + (xVelocity * Time.dt);
	posY = posY + (yVelocity * Time.dt);
	rotation = rotation + (rotSpeed * Time.dt);
    if(absolute)then
        particle.MoveToAbs(posX,posY);
    else
        particle.MoveTo(posX,posY);
    end
	particle.sprite.rotation = rotation;
	particle.sprite.alpha = timer / particle.GetVar("lifeTime");
end

function particleManager.UpdateParticles()
  --for each system
  for i=1,#activeParticleSystems do
    local system = activeParticleSystems[i];
    local timer = system[timeI] - Time.dt;
	system[timeI] = timer;
    local partCount = system[partCountI];
    --if timer complete and particles left, add newe particle
    if(timer <=0 and partCount > 0)then
      table.insert(system,CreateSingleParticle(system, system[absolute]));
      system[partCountI] = partCount - 1;
      system[timeI] = system[partGapI];
    end
    --update all particles, remove if necessary
    for j=partStart,#system do
      UpdateSingleParticle(system[j],system[absolute])
    end

  end
end

return particleManager;
