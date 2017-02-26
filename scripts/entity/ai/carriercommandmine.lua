
local avalibleFighter = nil
local minableAsteroid = nil

-- this function will be executed every frame on the server only
function updateServer(timeStep)
	--Start looking for a asteroids to assign fighters to.
    updateMining(timeStep)

end

--Assign a fighter to the asteroid.
function findAvailableFighter()
    local sector = Sector()
	local ship = Entity()
	local player = Player()
	
    avalibleFighter = nil
    local fighters = {sector:getEntitiesByFaction(player.index)}
    for _, fighter in pairs(fighters) do
		local launchedFighter = Entity(fighter.index)
		if launchedFighter.isFighter
		and launchedFighter.isUnarmedTurret == 1 then
			if launchedFighter.selectedObject == nil
			or launchedFighter.selectedObject.index == nil then
				if minableAsteroid then	
					launchedFighter.selectedObject = minableAsteroid 
				end
			end
		end
    end

end

-- check the sector for an asteroid that can be mined.
-- if there is one, assign minableAsteroid
function findMinableAsteroid()
    local ship = Entity()
    local sector = Sector()	

    minableAsteroid = nil

    local asteroids = {sector:getEntitiesByType(EntityType.Asteroid)}
    local nearest = math.huge
	--Go after rich asteroids first
    for _, a in pairs(asteroids) do
		local resources = a:getMineableResources()
        if resources ~= nil and resources > 0 then
			local dist = distance2(a.translationf, ship.translationf)
			if dist < nearest then
				nearest = dist
				minableAsteroid = a
			end
		end
    end	

    if minableAsteroid then
        broadcastInvokeClientFunction("setMinableAsteroid", minableAsteroid.index)
    end
end

function updateMining(timeStep)

    if not valid(minableAsteroid) then
        findMinableAsteroid()
    end

	if valid(minableAsteroid) then
		findAvailableFighter()
    end

end

function setMinableAsteroid(index)
    minableAsteroid = Entity(index)
end

---- this function will be executed every frame on the client only
--function updateClient(timeStep)

--    if valid(salvagableWreck) then
--        drawDebugSphere(salvagableWreck:getBoundingSphere(), ColorRGB(1, 0, 0))
--    end
--end
