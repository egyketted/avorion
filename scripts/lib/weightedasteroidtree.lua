local weightedAsteroidTree = {}

local head = {}
local rawData = {}
local rawDataCount = 0
local pointOfOrigin = nil

local treeDepth = 1

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
    --local distanceFromHead = distance2(head.asteroid.translationf, asteroid.translationf)
    print("Looking for asteroid" .. asteroid.index .. " in tree")
    return findNodeWithDistanceFromHead(asteroid, {head})
end

function weightedAsteroidTree.getResourceValueOfSubTreeForAsteroid(asteroid)
    return sumResourcesOnTree(weightedAsteroidTree.getSubTreeForAsteroid(asteroid))
end

function weightedAsteroidTree.isEmpty()
    return head == nil or head.asteroid == nil
end

function weightedAsteroidTree.buildTree()
    print("finding head")
    head = popClosest(pointOfOrigin)
    head.level = 1
    head.parentIndex = 0
    print("found head", printNode(head))
    print("finding child nodes")
    buildSubTree({head})
    print("found child nodes")
end

function weightedAsteroidTree.clear()
    head = nil
    weightedAsteroidTree = {}
end

function findNodeWithDistanceFromHead(asteroid, nodesToProcess)
    local currentNode = popFirst(nodesToProcess)
    if currentNode == nil then
        return nil
    end
    if asteroid.index == currentNode.asteroid.index then
        print("Found asteroid" .. asteroid.index)
        return currentNode;
    else
        print("Was looking for asteroid" .. asteroid.index .. " but found asteroid" .. currentNode.asteroid.index)
    end
    local j = 1
    while currentNode.subNodes[j] do
        appendAsLast(currentNode.subNodes[j], nodesToProcess)
        --local currentNodeDistanceFromHead = distance2(head.asteroid.translationf, currentNode.subNodes[j].asteroid.translationf)
        --local isInEpsylonRangeArea = inEpsylonRangeArea(distanceFromHead, currentNodeDistanceFromHead)
        --if isInEpsylonRangeArea == 0 then
        --    return currentNode.subNodes[j]
        --end
    end
    
    return findNodeWithDistanceFromHead(asteroid, nodesToProcess)
end

function inEpsylonRangeArea(distance1, distance2)
    if distance1 == distance2 then --TODO include an epsylon area check
        return 0
    elseif distance1 > distance2 then
        return -1
    else
        return 1
    end
end

function sumResourcesOnTree(tree)
    if tree == nil or tree.asteroid == nil then
        return 0
    end
    
    local sum = tree.asteroid:getMineableResources()
    
    for subNode in tree.subNodes do
        sum = sum + sumResourcesOnTree(subNode)
    end
    
    return sum
end

function popClosest(from)
    local minDistance = math.huge
    local minIndex = 1
    local i = 1
    while i <= rawDataCount do
        local currentDistance = distance2(from, rawData[i].translationf)
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

function buildSubTree(nodesToProcess)
    if rawDataCount <= 0 then
        return nil
    end
    local headNode = popFirst(nodesToProcess)
    
    headNode.subNodes[1] = popClosest(headNode.asteroid.translationf)
    if headNode.subNodes[1] then
        headNode.subNodes[1].level = headNode.level + 1
        headNode.subNodes[1].parentIndex = headNode.asteroid.index
        appendAsLast(headNode.subNodes[1], nodesToProcess)
        print("Found child for depth:" .. headNode.subNodes[1].level, printNode(headNode.subNodes[1])) 
    end
    headNode.subNodes[2] = popClosest(headNode.asteroid.translationf)
    if headNode.subNodes[2] then
        headNode.subNodes[2].level = headNode.level + 1
        headNode.subNodes[2].parentIndex = headNode.asteroid.index
        appendAsLast(headNode.subNodes[2], nodesToProcess)
        print("Found child for depth:" .. headNode.subNodes[1].level, printNode(headNode.subNodes[2]))
    end
    
    buildSubTree(nodesToProcess)
end

function popFirst(nodesToProcess)
    local toReturn = nodesToProcess[1]
    local i = 1
    while nodesToProcess[i] do
        nodesToProcess[i] = nodesToProcess[i + 1]
        i = i + 1
    end
    
    return toReturn
end

function appendAsLast(toAppend, nodesToProcess)
    local i = 1
    while nodesToProcess[i] do
        print("nodesToProcess[" .. i .. "] is not nil")
        i = i + 1
    end
    nodesToProcess[i] = toAppend
end

function remove(index)
    for i = index, rawDataCount - 1 do
        rawData[i] = rawData[i + 1]
    end
    rawData[rawDataCount] = nil
    rawDataCount = rawDataCount - 1
end

function printTree()
    print(printNode(head))
    print(printNode(head.subNodes[1]), printNode(head.subNodes[2]))
    print(printNode(head.subNodes[1].subNodes[1]), printNode(head.subNodes[1].subNodes[2]), printNode(head.subNodes[2].subNodes[1]), printNode(head.subNodes[2].subNodes[2]))
    print(printNode(head.subNodes[1].subNodes[1].subNodes[1]), printNode(head.subNodes[1].subNodes[1].subNodes[2]), printNode(head.subNodes[1].subNodes[2].subNodes[1]), printNode(head.subNodes[1].subNodes[2].subNodes[2]), printNode(head.subNodes[2].subNodes[1].subNodes[1]), printNode(head.subNodes[2].subNodes[1].subNodes[2]), printNode(head.subNodes[2].subNodes[2].subNodes[1]), printNode(head.subNodes[2].subNodes[2].subNodes[2]))
end

function printNode(node)
    local asteroid = node.asteroid
    return "[index=" .. asteroid.index .. ", position=" .. asteroid.translationf .. ", resources=" .. asteroid:getMineableResources() .. ", parentIndex=" .. node.parentIndex .. "]"
end

return weightedAsteroidTree