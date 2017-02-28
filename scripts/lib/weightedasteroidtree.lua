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
    return sumResourcesOnTree(getSubTreeForAsteroid(asteroid))
end

function weightedAsteroidTree.isEmpty()
    return head.asteroid == nil
end

function weightedAsteroidTree.buildTree()
    head = popClosest(pointOfOrigin)
    buildSubTree(head)
end

function weightedAsteroidTree.clear()
    head = nil
    weightedAsteroidTree = {}
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

local function sumResourcesOnTree(tree)
    if tree == nil or tree.asteroid == nil then
        return 0
    end
    
    local sum = tree.asteroid:getMineableResources()
    
    for subNode in tree.subNodes do
        sum = sum + sumResourcesOnTree(subNode)
    end
    
    return sum
end

local function popClosest(from)
    local minDistance = math.huge
    local minIndex = 1
    local i = 1
    for asteroid in rawData do
        local currentDistance = distance2(from, asteroid.translationf)
        if currentDistance < minDistance then
            minDistance = currentDistance
            minIndex = i
        end
        i = i + 1
    end
    
    if rawData[minIndex] == nil then
        return nil
    end
    
    local newHead = {}
    newHead.asteroid = rawData[minIndex]
    newHead.subNodes = {}
    
    remove(minIndex)
    
    return newHead
end

local function buildSubTree(headNode)
    if headNode == nil then
        return nil
    end
    
    headNode.subNodes[1] = popClosest(headNode.asteroid.translationf)
    headNode.subNodes[2] = popClosest(headNode.asteroid.translationf)
    
    buildSubTree(headNode.subNodes[1])
    buildSubTree(headNode.subNodes[2])
end

local function remove(index)
    for i = index, rawDataCount - 1 do
        rawData[i] = rawData[i + 1]
    end
    rawDataCount = rawDataCount - 1
end