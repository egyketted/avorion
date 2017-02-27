
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
    if fighterToAsteroidMapping[fighter] then
        fighterToAsteroidMapping[fighter] = findSubNodeToMine(weightedAsteroidTree
              .getSubTreeForAsteroid(fighterToAsteroidMapping[fighter]))
        asteroidToMiningFighterCountMapping[fighterToAsteroidMapping[fighter]] = asteroidToMiningFighterCountMapping[fighterToAsteroidMapping[fighter]] + 1
    else
        local asteroid = weightedAsteroidTree.getHead().asteroid
        fighterToAsteroidMapping[fighter] = asteroid
        if asteroidToMiningFighterCountMapping[asteroid] then
            asteroidToMiningFighterCountMapping[asteroid] = asteroidToMiningFighterCountMapping[asteroid] + 1
        else
            asteroidToMiningFighterCountMapping[asteroid] = 1
        end
    end
    
    fighter.selectedObject = fighterToAsteroidMapping[fighter]
end

local function findSubNodeToMine(asteroidTree)
    local i = 1
    local subNodeResourceValues = {}
    local sumOfSubNodeResourceValues = 0
    
    for subNode in asteroidTree.subNodes do
        local currentSubnodeResourceValue = weightedAsteroidTree.getResourceValueOfSubTreeForAsteroid(subNode.asteroid)
        subNodeResourceValues[i] = currentSubnodeResourceValue
        sumOfSubNodeResourceValues = sumOfSubNodeResourceValues + currentSubnodeResourceValue
        i = i + 1
    end
    
    local totalFighterCountForSubTree = asteroidToMiningFighterCountMapping[asteroidTree.asteroid]
    
    for j = 1, i - 1 do
        local fighterTotalResourceRatio = subNodeResourceValues[j] / sumOfSubNodeResourceValues
        local totalFightersAvailable = asteroidToMiningFighterCountMapping[asteroidTree.asteroid]
        local fightersCountThatShouldMineThis = totalFightersAvailable * fighterTotalResourceRatio
        if asteroidToMiningFighterCountMapping[asteroidTree.subNodes[j].asteroid] == nil then
            asteroidToMiningFighterCountMapping[asteroidTree.subNodes[j].asteroid] = 0
        end
        if asteroidToMiningFighterCountMapping[asteroidTree.subNodes[j].asteroid] + 1 <= fightersCountThatShouldMineThis then
            return asteroidTree.subNodes[j].asteroid
        end
    end
    
    return asteroidTree.subNodes[i - 1].asteroid
end