package.path = package.path .. ";../?.lua;/data/scripts/lib/?.lua;/scripts/lib/?.lua;/lib/?.lua;../data/scripts/lib/?.lua;../scripts/lib/?.lua;../lib/?.lua;data/scripts/lib/?.lua"

local weightedAsteroidTree = require "weightedasteroidtree"
local asteroidMiningManager = require "asteroidminingmanager"

local avalibleFighter = nil
local minableAsteroids = nil

-- this function will be executed every frame on the server only
function updateServer(timeStep)
    --Start looking for a asteroids to assign fighters to.
    updateMining(timeStep)

end

--Assign a fighter to the asteroid.
function mineAsteroids()
    print("Finding target for fighters")
    local sector = Sector()
    local ship = Entity()
    local player = Player()
    
    if not asteroidMiningManager.hasAsteroids() then
        asteroidMiningManager.setAsteroids(weightedAsteroidTree)
    end
    
    avalibleFighter = nil
    local fighters = sector:getEntitiesByFaction(player.index) -- TODO put back {} around sector:getEntitiesByType(EntityType.Asteroid) when not called from test runner
    for _, fighter in pairs(fighters) do
        local launchedFighter = Entity(fighter.index)
        if launchedFighter.isFighter and launchedFighter.isUnarmedTurret == 1 then
            if launchedFighter.selectedObject == nil or launchedFighter.selectedObject.index == nil then
                asteroidMiningManager.assignFighterToAsteroid(launchedFighter)
            end
        end
    end
    print("End finding targets")
    print("Debug mode: unasigning fighters")
    for _, fighter in pairs(fighters) do
        fighter.selectedObject = nil
    end
    print("Debug mode: unasigned fighters")
end

-- check the sector for an asteroid that can be mined.
-- if there is one, assign minableAsteroids
function findMinableAsteroids()
    print("Finding mineable asteroids")
    local ship = Entity()
    local sector = Sector()
    
    weightedAsteroidTree.setPointOfOrigin(ship.translationf)

    local asteroids = sector:getEntitiesByType(EntityType.Asteroid) -- TODO put back {} around sector:getEntitiesByType(EntityType.Asteroid) when not called from test runner
    --Go after rich asteroids first
    for _, a in pairs(asteroids) do
        local resources = a:getMineableResources()
        if resources ~= nil and resources > 0 then
            weightedAsteroidTree.pushAsteroid(a)
        end
    end

    weightedAsteroidTree.buildTree()
    print("Found minable asteroids ", not weightedAsteroidTree.isEmpty())
end

function updateMining(timeStep)

    if weightedAsteroidTree.isEmpty() then
        findMinableAsteroids()
    end

    if not weightedAsteroidTree.isEmpty() then
        mineAsteroids()
    end

end

---- this function will be executed every frame on the client only
--function updateClient(timeStep)

--    if valid(salvagableWreck) then
--        drawDebugSphere(salvagableWreck:getBoundingSphere(), ColorRGB(1, 0, 0))
--    end
--end
