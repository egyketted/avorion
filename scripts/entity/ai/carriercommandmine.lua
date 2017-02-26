
local avalibleFighter = nil
local minableAsteroids = nil

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
				if minableAsteroids then	
					launchedFighter.selectedObject = minableAsteroids 
				end
			end
		end
    end

end

-- check the sector for an asteroid that can be mined.
-- if there is one, assign minableAsteroids
function findminableAsteroids()
    local ship = Entity()
    local sector = Sector()	

    minableAsteroids = {}

    local asteroids = {sector:getEntitiesByType(EntityType.Asteroid)}
    local nearest = math.huge
	--Go after rich asteroids first
	local i = 1
    for _, a in pairs(asteroids) do
		local resources = a:getMineableResources()
        if resources ~= nil and resources > 0 then
			minableAsteroids[i] = a
			i = i +1
			end
		end
    end	

    if i > 1 then
		for j = 1, i do
			local dist_j = distance2(minableAsteroids[j].translationf, ship.translationf)
			local currentMinDist = dist_j
			local currentMinIndex =  j
			for k = j, i do
				local dist_k = distance2(minableAsteroids[k].translationf, ship.translationf)
				if dist_k < currentMinDist then
					currentMinDist = dist_k
					currentMinIndex = k
				end
			end
			if currentMinIndey ~= j then
				local tmp = minableAsteroids[j]
				minableAsteroids[j] = minableAsteroids[currentMinIndex]
				minableAsteroids[currentMinIndex] = tmp
			end
		end
        broadcastInvokeClientFunction("setminableAsteroids", minableAsteroids, i)
    end
end

function updateMining(timeStep)

	local candidateAsteroid = findFirst(minableAsteroids)
    if not valid(candidateAsteroid) then
        findminableAsteroids()
    end

	if valid(candidateAsteroid) then
		findAvailableFighter()
    end

end

function findFirst(asteroids)
	if asteroids == nil then
		return nil
	end
	local i = 1
	while asteroids[i] == nil and i < 100000 do
		i = i + 1
	end
	if i >= 10000 then
		return nil
	end
	
	return asteroids[i]
end

function setminableAsteroids(sortedMinableAsteroids, count)
	if minableAsteroids == nil then
		minableAsteroids = {}
	end
	for i = 1, count - 1 do
		minableAsteroids[i] = Entity(sortedMinableAsteroids[i].index)
	end
end

---- this function will be executed every frame on the client only
--function updateClient(timeStep)

--    if valid(salvagableWreck) then
--        drawDebugSphere(salvagableWreck:getBoundingSphere(), ColorRGB(1, 0, 0))
--    end
--end
