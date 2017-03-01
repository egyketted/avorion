package.path = package.path .. ";data/scripts/entity/ai/?.lua;scripts/entity/ai/?.lua;entity/ai/?.lua"

local minerScript = require "carriercommandmine"
local math = require "math"

EntityType = {}
EntityType.Asteroid = 0

local asteroids = {}
for i = 1, 100 do
    local asteroid = {}
    local asteroidResource = math.random(0, math.huge)
    function asteroid:getMineableResources()
        return 10--asteroidResource
    end
    asteroid.index = i
    asteroid.translationf = 10 * i--math.random(10, 1000)
    asteroids[i] = asteroid
end

local fighters = {}
for j = 1, 83 do
    local fighter = {}
    fighter.index = j
    fighter.selectedObject = nil
    fighter.isFighter = true
    fighter.isUnarmedTurret = 1
    fighters[j] = fighter
end

function Entity()
    local ship = {}
    
    ship.translationf = 10
    
    return ship
end

function Entity(index)
    if index then
        return fighters[index]
    else
        local ship = {}
        ship.index = "ship"
        ship.translationf = 10
        return ship
    end
end

function Sector()
    local sector = {}
    function sector:getEntitiesByFaction(index)
        return fighters
    end
    
    function sector:getEntitiesByType(type)
        return asteroids
    end
    sector.index = "sector"
    return sector
end

function Player()
    local player = {}
    player.index = "player"
    
    return player
end

function distance2(point1, point2)
    local dist = point1 - point2
    if (dist < 0) then
        dist = dist * -1
    end
    
    return dist
end

local numRuns = 1000
local z = 1
while z <= numRuns do
    updateServer(10)
    z = z + 1
end

