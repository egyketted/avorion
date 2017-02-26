
package.path = package.path .. ";data/scripts/lib/?.lua"

require ("stringutility")
local AIAction =
{
    Escort = 1,
    Attack = 2,
    FlyThroughWormhole = 3,
    FlyToPosition = 4
}

-- variables for strategy state
targetAction = nil
targetIndex = nil
targetPosition = nil

-- variables for finding the entity index after a sector change
targetFaction = nil
targetName = nil

local numButtons = 0
function ButtonRect(w, h)

    local width = w or 280
    local height = h or 35

    local space = math.floor((window.size.y - 80) / (height + 10))

    local row = math.floor(numButtons % space)
    local col = math.floor(numButtons / space)

    local lower = vec2((width + 10) * col, (height + 10) * row)
    local upper = lower + vec2(width, height)

    numButtons = numButtons + 1

    return Rect(lower, upper)
end
function setAIAction(action, index, position)
    targetAction = action
    targetIndex = index
    targetPosition = position

    local entity = Entity(targetIndex)
    if entity then
        targetFaction = entity.factionIndex
        targetName = entity.name
    end

    if onServer() then
        local player = Player()
        if player then
            invokeClientFunction(player, "setAIAction", action, index, position)
        end
    end
end

function onSectorChanged()
    -- only required on server, client script gets newly created when changing the sector
    local entity
    if targetName then
        -- find new entity index
        entity = Sector():getEntityByFactionAndName(targetFaction, targetName)
    end
    if not entity or entity.index == -1 then
        targetAction = nil
        targetIndex = nil
        targetPosition = nil
        return
    end

    targetIndex = entity.index
end

function initialize()
    if onClient() then
        sync()
    end
end

function sync(dataIn)
    if onClient() then
        if dataIn then
            targetAction = dataIn.action
            targetFaction = dataIn.faction
            targetName = dataIn.name
            targetIndex = dataIn.index
            targetPosition = dataIn.position
        else
            invokeServerFunction("sync")
        end
    else
        assert(callingPlayer)

        local data = {
            action = targetAction,
            faction = targetFaction,
            name = targetName,
            index = targetIndex,
            position = targetPosition
        }
        invokeClientFunction(Player(callingPlayer), "sync", data)
    end
end

-- if this function returns false, the script will not be listed in the interaction window,
-- even though its UI may be registered
function interactionPossible(playerIndex, option)
    -- Only works if your in your own craft
    if Entity().index ~= Player().craftIndex then
        return false
    end

    -- ordering other crafts can only work on your own crafts
    if Faction().index ~= playerIndex then
        return false
    end

    return true
end

-- create all required UI elements for the client side
function initUI()
    local res = getResolution()
	local size = vec2(300, 290)
	
    local menu = ScriptUI()
	--local window = menu:createWindow(Rect(res * 0.5 - size * 0.5, res * 0.5 + size * 0.5)) --Why is the 'local' part breaking the menu when tabs are used?
    window = menu:createWindow(Rect(res * 0.5 - size * 0.5, res * 0.5 + size * 0.5))  
	
    window.caption = "Fighter Orders"
    window.showCloseButton = 1
    window.moveable = 1
	--window.icon = "data/textures/icons/fighter.png" --Sad, does not work =( I want to change it from the puzzle piece icon to something else
	
	menu:registerWindow(window, "Carrier Orders")	
	
	local tabbedWindow = window:createTabbedWindow(Rect(vec2(10, 10), size - 10))

    local tab = tabbedWindow:createTab("Entity", "data/textures/icons/fighter.png", "Ship Commands")
    numButtons = 0

	tab:createButton(ButtonRect(), "Carrier - Idle", "onIdleButtonPressed")
	tab:createButton(ButtonRect(), "Carrier - Salvage", "onCCSButtonPressed")
	tab:createButton(ButtonRect(), "Carrier - Mine", "onCCMButtonPressed")
	local tab = tabbedWindow:createTab("Settings", "data/textures/icons/ship.png", "Fighter Settings")
    numButtons = 0

	fighterTargetingCheckBox = tab:createCheckBox(ButtonRect(), "Limit targets to fighters position", "onLocalAreaChecked")
	fighterTargetingCheckBox.tooltip = "Normally the carrier's position is used to determine where to send the fighter to. This option changes it to the fighters perspective. This option disables the limit fighters option to prevent funkiness"	
	
	--local rect = ButtonRect()
	--local label = tab:createLabel(vec2(rect.lower.x, rect.lower.y + 10), "Limit number of fighters per target", 23)
	--label.size = vec2(280, 35)
	
	--textBox = tab:createTextBox(ButtonRect(), "")
end

function onLocalAreaChecked(index, checked)
end

function onIdleButtonPressed()
    if onClient() then
        invokeServerFunction("onIdleButtonPressed")
        ScriptUI():stopInteraction()
        return
    end

    --if checkCaptain() then
        local ai = ShipAI()
        ai:setIdle()

        removeSpecialOrders()
    --end
end

function onCCSButtonPressed(localFighter)
    if onClient() then
        invokeServerFunction("onCCSButtonPressed", fighterTargetingCheckBox.checked)
        ScriptUI():stopInteraction()
        return
    end
	
	removeSpecialOrders()
	print ("Carrier Command Salvage Activated")
    Entity():addScript("ai/carriercommandsalvage.lua", localFighter)
end

function onCCMButtonPressed()
    if onClient() then
        invokeServerFunction("onCCMButtonPressed")
        ScriptUI():stopInteraction()
        return
    end

        removeSpecialOrders()
		print ("Carrier Command Mine Activated")
        Entity():addScript("ai/carriercommandmine.lua")
end

function removeSpecialOrders()

    local entity = Entity()

    for index, name in pairs(entity:getScripts()) do
        if string.match(name, "data/scripts/entity/ai/") then
            entity:removeScript(index)
        end
    end
end

-- this function will be executed every frame both on the server and the client
--function update(timeStep)
--
--end
--
---- this function gets called every time the window is shown on the client, ie. when a player presses F
--function onShowWindow()
--
--end
--
---- this function gets called every time the window is shown on the client, ie. when a player presses F
--function onCloseWindow()
--
--end
