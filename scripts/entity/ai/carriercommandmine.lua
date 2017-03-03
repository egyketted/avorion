
local avalibleFighter = nil
local minableAsteroid = nil
local asteroidToMiningFighterCount = {}
local asteroidToMiningFighter = {}

-- this function will be executed every frame on the server only
function updateServer(timeStep)
    --Start looking for a asteroids to assign fighters to.
    updateMining(timeStep)

end

--Assign a fighter to the asteroid.
function findAvailableFighter()
    print("Updating fighter targets")
    local sector = Sector()
    local ship = Entity()
    local player = Player()
    
    local asteroids = sector:getEntitiesByType(EntityType.Asteroid)
    if asteroids[1] == nil then
        asteroidToMiningFighterCount = {}
        return
    end
    
    avalibleFighter = nil
    local fighters = sector:getEntitiesByFaction(player.index)
    for _, fighter in pairs(fighters) do
        print("Fighters loop running")
        local launchedFighter = Entity(fighter.index)
        local minableAsteroid = nil
        if launchedFighter.isFighter
        and launchedFighter.isUnarmedTurret == 1 then
            if launchedFighter.selectedObject == nil
            or launchedFighter.selectedObject.index == nil then
                print("Fighter is a miner without target")
                local nearest = math.huge
                --Go after rich asteroids first
                for _, a in pairs(asteroids) do
                    print("Asteroids loop running")
                    local resources = a:getMineableResources()
                    if resources ~= nil and resources > 0 then
                        print("Asteroid has resources")
                        local dist = distance2(a.translationf, launchedFighter.translationf)
                        if asteroidToMiningFighterCount[a] == nil then
                            asteroidToMiningFighterCount[a] = 0
                        end
                        if dist < nearest and resources / (asteroidToMiningFighterCount[a] + 1) > 300 then
                            nearest = dist
                            minableAsteroid = a
                        end
                    end
                end
                if minableAsteroid then    
                    launchedFighter.selectedObject = minableAsteroid 
                    print("Assigning fighter" .. launchedFighter.index .. " to asteroid" .. minableAsteroid.index)
                    if asteroidToMiningFighterCount[minableAsteroid] then
                        asteroidToMiningFighterCount[minableAsteroid] = asteroidToMiningFighterCount[minableAsteroid] + 1
                    else
                        asteroidToMiningFighterCount[minableAsteroid] = 1
                    end
                    
                    if asteroidToMiningFighter[minableAsteroid] then
                        push(launchedFighter, asteroidToMiningFighter[minableAsteroid])
                    else
                        asteroidToMiningFighter[minableAsteroid] = {launchedFighter}
                    end
                end
            end
        end
    end
end

function push(element, array)
    local i = 1
    while array[i] do
        i = i + 1
    end
    array[i] = element
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
    local alreadyInitialized = false
    for asteroid, fighters in pairs(asteroidToMiningFighter) do
        if not valid(asteroid) then
            findAvailableFighter()
            asteroidToMiningFighter[asteroid] = nil
            asteroidToMiningFighterCount[asteroid] = nil
            for ast, count in asteroidToMiningFighterCount do
                local stilValid = false
                for asteroid, fighters in asteroidToMiningFighter do
                    if ast.index == asteroid.index then
                        stilValid = true
                    end
                end
                if not stilValid then
                    asteroidToMiningFighterCount[ast] = nil
                end
            end
        end
        alreadyInitialized = true
    end
    if not alreadyInitialized then
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
