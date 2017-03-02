local weightedAsteroidTree = {}

local head = {}
local rawData = {}
local rawDataCount = 0
local pointOfOrigin = nil

local treeDepth = 1
local currentDepth = 1

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

function weightedAsteroidTree.getSubTreeForAsteroid(node)
    return findNodeWithDistanceFromHead(node.asteroid, {head})
end

function weightedAsteroidTree.getResourceValueOfSubTreeForAsteroid(asteroid)
    return sumResourcesOnTree(weightedAsteroidTree.getSubTreeForAsteroid(asteroid))
end

function weightedAsteroidTree.isEmpty()
    return head == nil or head.asteroid == nil
end

function weightedAsteroidTree.reconstructBelovCurrentLevel()
	rawData = {}
	local ship = Entity()
    local sector = Sector()
    
    --weightedAsteroidTree.setPointOfOrigin(ship.translationf)

    local asteroids = {sector:getEntitiesByType(EntityType.Asteroid)} -- TODO put back {} around sector:getEntitiesByType(EntityType.Asteroid) when not called from test runner
    --Go after rich asteroids first
    for _, a in pairs(asteroids) do
        local resources = a:getMineableResources()
        if resources ~= nil and resources > 0 then
            weightedAsteroidTree.pushAsteroid(a)
        end
    end

    buildTreeBelovCurrentDepth()
end

function weightedAsteroidTree.buildTree()
    print("finding head")
    head = popClosest(pointOfOrigin)
    head.level = 1
    head.parentIndex = 0
    --print("found head", printNode(head))
    print("finding child nodes")
    buildSubTree({head})
    print("found child nodes")
end

function weightedAsteroidTree.clear()
    head = nil
    weightedAsteroidTree = {}
end

function weightedAsteroidTree.hasAsteroidsLeft()
    return containsValidAsteroid(head)
end

function containsValidAsteroid(node)
    if node.origAsteroid then
        return true
    end
    if node.subNodes then 
        if node.subNodes[1] then
            if node.subNodes[2] then
                return containsValidAsteroid(node.subNodes[1]) or containsValidAsteroid(node.subNodes[2])
            else
                return containsValidAsteroid(node.subNodes[1])
            end
        end
    end
    return false
end

function findNodeWithDistanceFromHead(asteroid, nodesToProcess)
    local currentNode = popFirst(nodesToProcess)
    if currentNode == nil then
        return nil
    end
    if asteroid.index == currentNode.asteroid.index then
        print("Found asteroid" .. asteroid.index)
        return currentNode;
    end
    local j = 1
    while currentNode.subNodes[j] do
        appendAsLast(currentNode.subNodes[j], nodesToProcess)
        j = j + 1
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

function buildTreeBelovCurrentDepth()
	local localDepth = 1
	local previusNodes = {head}
	local buffer = {}
	while localDepth <= currentDepth do
		while previusNodes[1] do
			local node = popFirst(previusNodes)
			local i = 1
			while node.subNodes and node.subNodes[i] do
				appendAsLast(node.subNodes[i], buffer)
				i = i + 1
			end
		end
		localDepth = localDepth + 1
		previusNodes = buffer
		buffer = {}
	end
	currentDepth = currentDepth + 1
	buildSubTree(previusNodes)
end

function sumResourcesOnTree(tree)
    if tree == nil or tree.asteroid == nil then
        return 0
    end
    
    local sum = tree.asteroid.mineableResources
    
    for _, subNode in pairs(tree.subNodes) do
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
    local origAsteroid = rawData[minIndex]
    newHead.origAsteroid = origAsteroid
    local asteroid = {}
    asteroid.index = origAsteroid.index
    asteroid.translationf = origAsteroid.translationf
    asteroid.mineableResources = origAsteroid:getMineableResources()
    newHead.asteroid = asteroid
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
        --print("Found child for depth:" .. headNode.subNodes[1].level, printNode(headNode.subNodes[1])) 
    end
    headNode.subNodes[2] = popClosest(headNode.asteroid.translationf)
    if headNode.subNodes[2] then
        headNode.subNodes[2].level = headNode.level + 1
        headNode.subNodes[2].parentIndex = headNode.asteroid.index
        appendAsLast(headNode.subNodes[2], nodesToProcess)
        --print("Found child for depth:" .. headNode.subNodes[1].level, printNode(headNode.subNodes[2]))
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
    return "[index=" .. asteroid.index .. ", position=" .. asteroid.translationf .. ", resources=" .. asteroid.mineableResources .. ", parentIndex=" .. node.parentIndex .. "]"
end

return weightedAsteroidTree