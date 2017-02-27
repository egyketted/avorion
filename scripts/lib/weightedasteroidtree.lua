local weightedAsteroidTree = {}

local head = {}
local rawData = {}
local rawDataCount = 0
local pointOfOrigin = nil

function weightedAsteroidTree.setPointOfOrigin(newPointOfOrigin)
    pointOfOrigin = newPointOfOrigin
end

function weightedAsteroidTree.pushAsteroid(asteroid)
    rawDataCount = rawDataCount + 1
    rawData[rawDataCount] = asteroid
end

function weightedAsteroidTree.getHead()
    return head
end

function weightedAsteroidTree.getSubTreeForAsteroid(asteroid)
    local distanceFromHead = distance2(head.asteroid.translationf, asteroid.translationf)
    return findNodeWithDistanceFromHead(distanceFromHead, head)
end

function weightedAsteroidTree.getResourceValueOfSubTreeForAsteroid(asteroid)
end

function weightedAsteroidTree.isEmpty()
    return head.asteroid == nil
end

function weightedAsteroidTree.buildTree()
end

function weightedAsteroidTree.clear()
end

local function findNodeWithDistanceFromHead(distanceFromHead, currentNode)
    if currentNode.subNodes == nil then
        return nil
    end
    for subNode in currentNode.subNodes do
        local currentNodeDistanceFromHead = distance2(head.asteroid.translationf, subNode.asteroid.translationf)
        local isInEpsylonRangeArea = inEpsylonRangeArea(distanceFromHead, currentNodeDistanceFromHead)
        if isInEpsylonRangeArea == 0 then
            return subNode
        elseif isInEpsylonRangeArea == 1 then
            return nil
        end
    end
    
    local i = 1
    local nodesFoundOnSubTrees = {}
    for subNode in currentNode.subNodes do
        nodesFoundOnSubTrees[i] = findNodeWithDistanceFromHead(distanceFromHead, subNode)
    end
    for subNode in nodesFoundOnSubTrees do
        if subNode then
            return subNode
        end
    end
    
    return nil
end

local function inEpsylonRangeArea(distance1, distance2)
    if distance1 == distance2 then --TODO include an epsylon area check
        return 0
    elseif distance1 > distance2 then
        return -1
    else
        return 1
    end
end