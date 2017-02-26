
local avalibleFighter = nil
local salvagableWreck = nil
local salvagedLoot = nil
local collectCounter = 0

local fighterT = false

-- this function will be executed every frame on the server only
function updateServer(timeStep)
	--Start looking for a wreck to assign fighters to.
    updateSalvaging(timeStep)

end

function initialize(fighterTargeting)
	fighterT = fighterTargeting or false

end

--Assign a fighter to the salvage.
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
				if salvagableWreck then	
					launchedFighter.selectedObject = salvagableWreck 
				end
			end
		end
    end
end

-- check the sector for an wreck that can be salvaged
-- if there is one, assign salvagableWreck
function findSalvagableWreck()
    local ship = Entity()
    local sector = Sector()	

    salvagableWreck = nil

    local salvage = {sector:getEntitiesByType(EntityType.Wreckage)}
    local nearest = math.huge

    for _, a in pairs(salvage) do
        local dist = distance2(a.translationf, ship.translationf)
        if dist < nearest then
            nearest = dist
            salvagableWreck = a
        end
    end

    if salvagableWreck then
        broadcastInvokeClientFunction("setSalvagedWreck", salvagableWreck.index)
    end

end
	--All in one function, handles each fighter
function localizedFighterTarget()
	local sector = Sector()
	local player = Player()
	
	local salvage = {sector:getEntitiesByType(EntityType.Wreckage)}
	local fighters = {sector:getEntitiesByFaction(player.index)}
	local nearest = math.huge
	
	--Get the fighter first, and see if it has a target
	for _, fighter in pairs(fighters) do
		local launchedFighter = Entity(fighter.index)
		
		if launchedFighter.isFighter
		and launchedFighter.isUnarmedTurret == 1 then
			if launchedFighter.selectedObject == nil
			or launchedFighter.selectedObject.index == nil then
				--Fighter has no target, so find one!
				for _, s in pairs(salvage) do
					local dist = distance2(s.translationf, launchedFighter.translationf)
					if dist < nearest then
						nearest = dist
						launchedFighter.selectedObject = s
					end
				end
			end
		end
	end
end

function clearFighterTargets()
	local sector = Sector()
	local ship = Entity()
	local player = Player()
	
    avalibleFighter = nil
    local fighters = {sector:getEntitiesByFaction(player.index)}
    for _, fighter in pairs(fighters) do
		local launchedFighter = Entity(fighter.index)
		if launchedFighter.isFighter
		and launchedFighter.isUnarmedTurret == 1 then
			if launchedFighter.selectedObject ~= nil then
				launchedFighter.selectedObject = nil
			end
		end
    end
end

function updateSalvaging(timeStep)

    if not valid(salvagableWreck) and not valid(salvagedLoot) then    
		findSalvagableWreck()

    end

	if valid(salvagableWreck) then
		if not fighterT then
			findAvailableFighter()
		elseif localizedFighterTarget() then
			localizedFighterTarget()
		end
    elseif not valid(salvageableWreck) then
		clearFighterTargets()
		print("Terminating script")
		terminate()
	end

end

function setSalvagedWreck(index)
    salvagableWreck = Entity(index)
end

---- this function will be executed every frame on the client only
--function updateClient(timeStep)

--    if valid(salvagableWreck) then
--        drawDebugSphere(salvagableWreck:getBoundingSphere(), ColorRGB(1, 0, 0))
--    end
--end
