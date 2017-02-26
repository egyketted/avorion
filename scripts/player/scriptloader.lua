if onServer then
package.path = package.path .. ";data/scripts/player/?.lua"

	function initialize()
		Player():registerCallback("onShipChanged", "onShipChanged") --Checks for the scripts existence each time the player changes ships
		Player():registerCallback("onSectorEntered", "onSectorEntered") --Removes old scripts from NPC ships
		Server():registerCallback("onPlayerLogOff", "onPlayerLogOff") -- Used to remove scripts on logout from a server
	end

	function onShipChanged(playerIndex, craftIndex)
		local player = Player(playerIndex)
		local sector = Sector()
		--Get all entities part of the players faction
		local entities = {sector:getEntitiesByFaction(player.index)}
		
		for _, entity in pairs(entities) do
			if not entity.isDrone then
				if not entity:hasScript("data/scripts/entity/carriercraftorders.lua") then				
					entity:addScript("data/scripts/entity/carriercraftorders.lua")
					--entity:addScript("data/scripts/entity/entitydbg.lua")
				end
			end
		end	
	end
	
	function onSectorEntered(playerIndex)
		local player = Player(playerIndex)
		print("CCS: Player", player.name, "Entered Sector, checking NPC ships")
		local sector = Sector()
		--Get all entities owned by the player
		local entities = {sector:getEntitiesByScript("carriercraftorders.lua")}
		--local entities = {sector:getEntitiesByFaction(player.index)}
		--Get all npc ship entities
		--local NPCS = {sector:getEntitiesByType(EntityType.Ship)}
		
		local count = 0
		--print("CCS: Removing scripts from", player.name, "Ships")
		for _, entity in pairs(entities) do
			local faction = Faction(entity.factionIndex)
			if not faction.isPlayer then				
				print("Removing scripts from entity", entity.name)
				--Remove the salvage script if present
				entity:removeScript("data/scripts/entity/ai/carriercommandsalvage.lua")
				--Remove the mining script if present
				entity:removeScript("data/scripts/entity/ai/carriercommandmine.lua")
				--Remove the Carrier orders menu				
				entity:removeScript("data/scripts/entity/carriercraftorders.lua")
				count = count + 1
			end
		end
		print("CSS: Cleaned up", count, "entities")		
	end
	
	function onPlayerLogOff(playerIndex)
		local player = Player(playerIndex)
		print("CCS: Player", player.name, "Logged out, cleaning up")
		local sector = Sector()
		--Get all entities owned by the player
		local entities = {sector:getEntitiesByScript("carriercraftorders.lua")}
		--local entities = {sector:getEntitiesByFaction(player.index)}
		--Get all npc ship entities
		--local NPCS = {sector:getEntitiesByType(EntityType.Ship)}
		
		local count = 0
		print("CCS: Removing scripts from", player.name, "Ships")
		for _, entity in pairs(entities) do
			local faction = Faction(entity.factionIndex)
			if entity.factionIndex == player.index
				or not faction.isPlayer then				
				print("Removing scripts from entity", entity.name)
				--Remove the salvage script if present
				entity:removeScript("data/scripts/entity/ai/carriercommandsalvage.lua")
				--Remove the mining script if present
				entity:removeScript("data/scripts/entity/ai/carriercommandmine.lua")
				--Remove the Carrier orders menu				
				entity:removeScript("data/scripts/entity/carriercraftorders.lua")
				count = count + 1
			end
		end
		print("CCS: Cleanup for player", player.name, "finished")
		print("CSS: Cleaned up", count, "entities")		
		
	end
	
end