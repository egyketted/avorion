
local asteroidMiningManager = {}

local weightedAsteroidTree = nil
local fighterToAsteroidMapping = {}
local asteroidToMiningFighterCountMapping = {}

function asteroidMiningManager.setAsteroids(asteroids)
    weightedAsteroidTree = asteroids
end

function asteroidMiningManager.hasAsteroids()
    return weightedAsteroidTree ~= nil and not weightedAsteroidTree.isEmpty()
end

function asteroidMiningManager.assignFighterToAsteroid(fighter)
    if (not weightedAsteroidTree.hasAsteroidsLeft()) then
        print("No more asteroids")
        return
    end
	weightedAsteroidTree.reconstructBelovCurrentLevel()
    if fighterToAsteroidMapping[fighter] then
        --fighterToAsteroidMapping[fighter].origAsteroid = nil--TODO remove this when run on real environment
        local subNodeToMine = findSubNodeToMine(weightedAsteroidTree.getSubTreeForAsteroid(fighterToAsteroidMapping[fighter]))
        if subNodeToMine then
            fighterToAsteroidMapping[fighter] = subNodeToMine
            asteroidToMiningFighterCountMapping[fighterToAsteroidMapping[fighter]] = asteroidToMiningFighterCountMapping[fighterToAsteroidMapping[fighter]] + 1
        else
            return
        end
    else
        local asteroidNode = weightedAsteroidTree.getHead()
        fighterToAsteroidMapping[fighter] = asteroidNode
        if asteroidToMiningFighterCountMapping[asteroidNode] then
            asteroidToMiningFighterCountMapping[asteroidNode] = asteroidToMiningFighterCountMapping[asteroidNode] + 1
        else
            asteroidToMiningFighterCountMapping[asteroidNode] = 1
        end
    end
    if fighterToAsteroidMapping[fighter].asteroid and fighterToAsteroidMapping[fighter].asteroid.index then
		fighter.selectedObject = Entity(fighterToAsteroidMapping[fighter].asteroid.index)
		print("Assigned fighter" .. fighter.index .. " to asteroid" .. fighterToAsteroidMapping[fighter].asteroid.index)
	end
	print("Could not find a target for fighter" .. fighter.index)
end

function findSubNodeToMine(asteroidTree)
    local i = 1
    local subNodeResourceValues = {}
    local sumOfSubNodeResourceValues = 0
    
    --for subnode in asteroidTree.subNodes do
    --    i = i +1
    --end
    
    while asteroidTree.subNodes[i] do
        local currentSubnodeResourceValue = weightedAsteroidTree.getResourceValueOfSubTreeForAsteroid(asteroidTree.subNodes[i])
        subNodeResourceValues[i] = currentSubnodeResourceValue
        sumOfSubNodeResourceValues = sumOfSubNodeResourceValues + currentSubnodeResourceValue
        i = i + 1
    end
    
    local totalFighterCountForSubTree = asteroidToMiningFighterCountMapping[asteroidTree]
    
    for j = 1, i - 1 do
        local fighterTotalResourceRatio = subNodeResourceValues[j] / sumOfSubNodeResourceValues
        local totalFightersAvailable = asteroidToMiningFighterCountMapping[asteroidTree]
        local fightersCountThatShouldMineThis = totalFightersAvailable * fighterTotalResourceRatio
        if asteroidToMiningFighterCountMapping[asteroidTree.subNodes[j]] == nil then
            asteroidToMiningFighterCountMapping[asteroidTree.subNodes[j]] = 0
        end
        if asteroidToMiningFighterCountMapping[asteroidTree.subNodes[j]] + 1 <= fightersCountThatShouldMineThis then
            return asteroidTree.subNodes[j]
        end
    end
    
    return asteroidTree.subNodes[i - 1]
end

return asteroidMiningManager