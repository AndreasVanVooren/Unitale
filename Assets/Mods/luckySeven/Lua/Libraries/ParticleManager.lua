function Lerp(a,b,t)
  return (1-t)*a + t*b;
end

local particleManager = {};
local activeParticleSystems = {};

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

local function CreateSingleParticle(partSystem)
  local possibleSprites = partSystem[1];
  local x = partSystem[4];
  local y = partSystem[5];
  local timer = partSystem[6];
  local xVelMin = partSystem[7];
  local yVelMin = partSystem[8];
  local xVelMax = partSystem[9];
  local yVelMax = partSystem[10];
  local gravity = partSystem[11];
  local minRotSpeed = partSystem[12];
  local maxRotSpeed = partSystem[13];

  local index = math.random(1,#possibleSprites);
  local part = CreateProjectile(possibleSprites[index],x,y);
  part.SetVar("timer",timer);
  part.SetVar("lifeTime",timer);
  part.SetVar("xVelocity",Lerp( xVelMin,xVelMax,math.random() ));
  part.SetVar("yVelocity",Lerp(yVelMin,yVelMax,math.random()));
  part.SetVar("gravity",gravity);
  part.SetVar("rotSpeed",Lerp(minRotSpeed,maxRotSpeed,math.random()));
  return part;
end

local function UpdateSingleParticle(particle)
	if(particle == nil)then return; end
	local posX = particle.x;
	local posY = particle.y;
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
	
	particle.MoveTo(posX,posY);
	particle.sprite.rotation = rotation;
	particle.sprite.alpha = timer / particle.GetVar("lifeTime");
end

function particleManager.UpdateParticles()
  --for each system
  for i=1,#activeParticleSystems do
    local system = activeParticleSystems[i];
    local timer = system[14] - Time.dt;
	system[14] = timer;
    local partCount = system[2];
    --if timer complete and particles left, add newe particle
    if(timer <=0 and partCount > 0)then
      table.insert(system,CreateSingleParticle(system));
      system[2] = partCount - 1;
      system[14] = system[3];
    end
    --update all particles, remove if necessary
    for j=15,#system do
      UpdateSingleParticle(system[j])
    end

  end
end

return particleManager;
