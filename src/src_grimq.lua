-- ============================================================
-- DOMAIN SPECIFICS 
-- ============================================================

-- Enumeration of all the inventory slots
inventory = 
{
	head = 1,
	torso = 2,
	legs = 3,
	feet = 4,
	cloak = 5,
	neck = 6,
	handl = 7,
	handr = 8,
	gauntlets = 9,
	bracers = 10,
	
	hands = { 7, 8 },
	backpack = { 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31 },
	armor = { 1, 2, 3, 4, 5, 6, 9 },
	all = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31 },
}

-- Enumeration of all the direction/facing values
facing = 
{
	north = 0,
	east = 1,
	south = 2,
	west = 3
}


-- Returns a grimq structure containing all champions
function fromChampions()
	local collection = { }
	for i = 1, 4 do
		collection[i] = party:getChampion(i)
	end
	return fromArrayInstance(collection)
end

-- Returns a grimq structure containing all enabled and alive champions
function fromAliveChampions()
	local collection = { }
	for i = 1, 4 do
		local c = party:getChampion(i)
		if (c:isAlive() and c:getEnabled()) then
			collection[i] = c
		end
	end
	return fromArrayInstance(collection)
end

-- Returns a grimq structure containing all the items in the champion's inventory
-- 		champion => the specified champion to which the inventory is returned
--		[recurseIntoContainers] => true, to recurse into sacks, crates, etc.
--		[inventorySlots] => nil, or a table of integers to limit the search to the specified slots
--		[includeMouse] => if true, the mouse item is included in the search
function fromChampionInventory(champion, recurseIntoContainers, inventorySlots, includeMouse)
	if (inventorySlots == nil) then
		inventorySlots = inventory.all
	end

	local collection = { }
	for i = 1, #inventorySlots do
		local item = champion:getItem(i)
		
		if (item ~= nil) then
			table.insert(collection, item)
			
			if (recurseIntoContainers) then
				for subItem in item:containedItems() do			
					table.insert(collection, subItem)
				end
			end
		end
	end
	
	if (includeMouse and (getMouseItem() ~= nil)) then
		table.insert(collection, getMouseItem())
	end
	
	return fromArrayInstance(collection)
end

-- Returns a grimq structure containing all the items in the party inventory
--		[recurseIntoContainers] => true, to recurse into sacks, crates, etc.
--		[inventorySlots] => nil, or a table of integers to limit the search to the specified slots
--		[includeMouse] => if true, the mouse item is included in the search
function fromPartyInventory(recurseIntoContainers, inventorySlots, includeMouse)
	return fromChampions():selectMany(function(v) return fromChampionInventory(v, recurseIntoContainers, inventorySlots, includeMouse):toArray(); end)
end

-- [private] Creates an item object
function _createItemObject(_slotnumber, _item, _champion, _container, _ismouse, _containerSlot)
	return {
		slot = _slotnumber,
		item = _item,
		champion = _champion,
		container = _container,
		ismouse = _ismouse,
		containerSlot = _containerSlot,
		
		destroy = function(self)
			local destroyed = false
			
			if (self.container ~= nil) then
				if (tryhard == true) then
					self.champion:removeItem(self.slot)
					destroyed = true
				end
				self.container:removeItem(self.item)
				destroyed = true
			elseif (self.slot >= 0) then
				self.champion:removeItem(self.slot)
				destroyed = true
			elseif (ismouse) then
				setMouseItem(nil)
				destroyed = true
			end
			return destroyed
		end,
		
		replace = function(self, newitem, tryhard)
			if (self.container ~= nil) then
				self.container:removeItem(self.item)
				self.container:addItem(newitem)
			elseif (self.slot >= 0) then
				self.champion:removeItem(self.slot)
				self.champion:insertItem(self.slot, newitem)
			elseif (ismouse) then
				setMouseItem(nil)
				setMouseItem(newitem)
			else 
				self.item:destroy()
				newitem:destroy()
			end
		end
	}
end

-- Returns a grimq structure containing item objects in the champion's inventory
-- 		champion => the specified champion to which the inventory is returned
--		[recurseIntoContainers] => true, to recurse into sacks, crates, etc.
--		[inventorySlots] => nil, or a table of integers to limit the search to the specified slots
--		[includeMouse] => if true, the mouse item is included in the search
function fromChampionInventoryEx(champion, recurseIntoContainers, inventorySlots, includeMouse)
	if (inventorySlots == nil) then
		inventorySlots = inventory.all
	end

	local collection = { }
	for i = 1, #inventorySlots do
		local item = champion:getItem(i)
		
		if (item ~= nil) then
			table.insert(collection, _createItemObject(i, item, champion, nil, false, -1))
			
			if (recurseIntoContainers) then
				for subItem in item:containedItems() do			
					table.insert(collection, _createItemObject(-1, subItem, champion, item, false, i))
				end
			end
		end
	end
	
	if (includeMouse and (getMouseItem() ~= nil)) then
		table.insert(collection, _createItemObject(-1, getMouseItem(), nil, nil, true, -1))
	end
	
	return fromArrayInstance(collection)
end

-- Returns a grimq structure containing all the item-objects in the party inventory
--		[recurseIntoContainers] => true, to recurse into sacks, crates, etc.
--		[inventorySlots] => nil, or a table of integers to limit the search to the specified slots
--		[includeMouse] => if true, the mouse item is included in the search
function fromPartyInventoryEx(recurseIntoContainers, inventorySlots, includeMouse)
	return fromChampions():selectMany(function(v) return fromChampionInventoryEx(v, recurseIntoContainers, inventorySlots, includeMouse):toArray(); end)
end

-- Returns a grimq structure cotaining all the entities in the dungeon
function fromAllEntitiesInWorld()
	local itercoll = { }
	
	for i = 1, MAXLEVEL do
		table.insert(itercoll, allEntities(i))
	end
	
	return fromIteratorsArray(itercoll)
end

-- Returns a grimq structure cotaining all the entities in an area
function fromEntitiesInArea(level, x1, y1, x2, y2, skipx, skipy)
	local itercoll = { }
	if (skipx == nil) then skipx = -10000; end
	if (skipy == nil) then skipy = -10000; end
	
	local stepx = 1
	if (x1 > x2) then stepx = -1; end

	local stepy = 1
	if (x1 > x2) then stepy = -1; end
	
	for x = x1, x2, stepx do
		for y = y1, y2, stepy do
			if (skipx ~= x) and (skipy ~= y) then
				table.insert(itercoll, entitiesAt(level, x, y))
			end
		end
	end
	
	return fromIteratorsArray(itercoll)
end

function fromEntitiesAround(level, x, y, radius, includecenter)
	if (radius == nil) then radius = 1; end
	
	if (includecenter == nil) or (not includecenter) then
		return fromEntitiesInArea(level, x - radius, y - radius, x + radius, y + radius, x, y)
	else
		return fromEntitiesInArea(level, x - radius, y - radius, x + radius, y + radius)
	end
end

function fromEntitiesForward(level, x, y, facing, distance, includeorigin)
	if (distance == nil) then distance = 1; end
	local dx, dy = getForward(facing)
	local dx = dx * distance
	local dy = dy * distance

	if (includeorigin == nil) or (not includeorigin) then
		return fromEntitiesInArea(x, y, x + dx, y + dy, x, y)
	else
		return fromEntitiesInArea(x, y, x + dx, y + dy, x, y)
	end
end

function isMonster(entity)
	return entity.setAIState ~= nil
end

function isItem(entity)
	return entity.getWeight ~= nil
end

function isAlcoveOrAltar(entity)
	return entity.getItemCount ~= nil
end

function isDoor(entity)
	return (entity.setDoorState ~= nil)
end

function isLever()
	return (entity.getLeverState ~= nil) 
end

function isLock(entity)
	return (entity.setOpenedBy ~= nil) and (entity.setDoorState == nil)
end

function isPit(entity)
	return (entity.setPitState ~= nil)
end

function isSpawner(entity)
	return (entity.setSpawnedEntity ~= nil)
end

function isScript(entity)
	return (entity.setSource ~= nil)
end

function isPressurePlate(entity)
	return (entity.isDown ~= nil)
end

function isTeleport(entity)
	return (entity.setChangeFacing ~= nil)
end

function isTimer(entity)
	return (entity.setTimerInterval ~= nil)
end

function isTorchHolder(entity)
	return (entity.hasTorch ~= nil)
end

function isWallText(entity)
	return (entity.getWallText ~= nil)
end

function match(attribute, namepattern)
	return function(entity) 
		return string.find(entity[attribute], namepattern) ~= nil
	end
end

function has(attribute, value)
	return function(entity) 
		return entity[attribute] == value
	end
end

-- saves an item into the table
function saveItem(item)
   local itemTable = { }
   itemTable.name = item.name
   itemTable.stackSize = item:getStackSize()
   itemTable.fuel = item:getFuel()
   itemTable.charges = item:getCharges()
   itemTable.scrollText = item:getScrollText()
   
   local idx = 0
   for subItem in item:containedItems() do
	  if (idx == 0) then
		 itemTable.subItems = { }
	  end
	  
	  itemTable.subItems[idx] = saveItem(subItem)
	  idx = idx + 1
   end
   
   return itemTable
end

-- loads an item from the table
function loadItem(itemTable, level, x, y, facing)
   local spitem = nil
   if (level ~= nil) then
	  spitem = spawn(itemTable.name, level, x, y, facing)
   else
	  spitem = spawn(itemTable.name)
   end
   if itemTable.stackSize > 0 then
	  spitem:setStackSize(itemTable.stackSize)
   end
   if itemTable.charges > 0 then
	  spitem:setCharges(itemTable.charges)
   end            
   
   if itemTable.scrollText ~= nil then
	  spitem:setScrollText(itemTable.scrollText)
   end
   
   spitem:setFuel(itemTable.fuel)
   
   if (itemTable.subItems ~= nil) then
	  for _, subTable in pairs(itemTable.subItems) do
		 local subItem = loadItem(subTable)
		 spitem:addItem(subItem, false)
	  end
   end
   
   return spitem
end

-- Creates a copy of an item
function copyItem(item)
	return loadItem(saveItem(item))
end

-- Moves an item to a container/alcove
function moveFromFloorToContainer(alcove, item)
	alcove:addItem(copyItem(item))
	item:destroy()
end

function moveItemsFromTileToAlcove(alcove)
	from(entitiesAt(alcove.level, alcove.x, alcove.y))
		:where(isItem)
		:foreach(function(i) 
			alcove:addItem(copyItem(i)); 
			i:destroy(); 
		end)
end

function _activateAutos()
	if (AUTO_ALL_SECRETS) then
		fromAllEntitiesInWorld():where("name", "secret"):foreach(_initializeAutoSecret)
	else
		fromAllEntitiesInWorld():where(match("id", "^auto_secret")):foreach(_initializeAutoSecret)
	end

	fromAllEntitiesInWorld():where("name", "auto_printer"):foreach(_initializeAutoHudPrinter)
	fromAllEntitiesInWorld():where(match("name", "^auto_")):where(isTorchHolder):foreach(function(auto) if (not auto:hasTorch()) then auto:addTorch(); end; end)
	fromAllEntitiesInWorld():where(match("name", "^auto_")):where(isAlcoveOrAltar):foreach(moveItemsFromTileToAlcove)
	fromAllEntitiesInWorld():where(isScript):foreach(_initializeAutoScript)
end

function _initializeAutoSecret(auto)
	local plate = spawn("pressure_plate_hidden", auto.level, auto.x, auto.y, auto.facing)
		:setTriggeredByParty(true)
		:setTriggeredByMonster(false)
		:setTriggeredByItem(false)
		:setSilent(true)
		:setActivateOnce(true)
		:addConnector("activate", auto.id, "activate")
end

function _initializeAutoHudPrinter(auto)
	local plate = spawn("pressure_plate_hidden", auto.level, auto.x, auto.y, auto.facing)
		:setTriggeredByParty(true)
		:setTriggeredByMonster(false)
		:setTriggeredByItem(false)
		:setSilent(true)
		:setActivateOnce(true)
		:addConnector("activate", "grimq", "execHudPrinter")

	g_HudPrinters[plate.id]	= auto:getScrollText()
	auto:destroy()
end

g_HudPrinters = { }

function execHudPrinter(source)
	local text = g_HudPrinters[source.id]
	if (text ~= nil) then
		hudPrint(strformat(text))
	end
end


-- NEW
function _initializeAutoScript(ntt)
	if (ntt.autoexec ~= nil) then
		ntt:autoexec();
	end
	
	local hooks = from(ntt):where(match("key", "^autohook_")):where(function(fn) return (type(fn.value) == "function"); end)
	
	for hook in hooks:toIterator() do
		local splits = strsplit(hooks.key, "__")
		local target = splits[2]
		local hookname = splits[3]
		
		if (target == nil or hookname == nil) then
			print("Invalid auto-hook ".. ntt.name .. "." .. hookname .. " -> name must be autohook__<target>__<hookname>.")
		elseif (fw == nil or (not USE_JKOS_FRAMEWORK)) then
			print("Can't install autohook: ".. ntt.name .. "." .. hookname .. " -> JKos framework not found or USE_JKOS_FRAMEWORK is false.")
		else
			fw.addHooks(target, ntt.name, { [hookname] = hook.value } )
		end
	end
end

function isToorumMode()
   local rangerDetected = fromChampions():where(function(c) return (c:getClass() == "Ranger"); end):count()
   local zombieDetected = fromChampions():where(function(c) return ((not c:getEnabled()) and (c:getStatMax("health") == 0)); end):count()
   
   return (rangerDetected >= 1) and (zombieDetected == 3)
end


function dezombifyParty()
	local portraits = { "human_female_01", "human_female_02", "human_male_01", "human_male_02" }
	local genders = { "female", "female", "male", "male" }
	local names = { "Sylyna", "Yennica", "Contar", "Sancsaron" }

	for c in fromChampions():where(function(c) return ((not c:getEnabled()) and (c:getStatMax("health") == 0)); end):toIterator()
		c:setStatMax("health", 25)
		c:setStatMax("energy", 10)
		c:setPortrait("assets/textures/portraits/" .. portraits[i] .. ".tga")
		c:setName(names[i])
		c:setSex(genders[i])
	end
end


function reverseFacing(facing)
	return (facing + 2) % 4;
end


function getChampionFromOrdinal(ord)
	return grimq.fromChampions():where(function(c) return c:getOrdinal() == ord; end):first()
end

-- $1.. $9 -> replaces with func parameters
-- $champ1..$champ4 -> replaces with name of champion of slot x
-- $CHAMP1..$CHAMP4 -> replaces with name of champion in ordinal x
-- $rchamp -> random champion, any
-- $RCHAMP -> random champion, alive
function strformat(text, ...)
	local args = {...}
	
	for i, v in ipairs(args) do
		text = string.gsub(text, "$" .. i, tostring(v))
	end
	
	for i = 1, 4 do
		local c = party:getChampion(i)
		
		local name = c:getName()
		text = string.gsub(text, "$champ" .. i, name)
		
		local ord = c:getOrdinal()
		text = string.gsub(text, "$CHAMP" .. ord, name)
	end
	
	text = string.gsub(text, "$rchamp", fromChampions():select(function(c) return c:getName(); end):random())
	text = string.gsub(text, "$RCHAMP", fromAliveChampions():select(function(c) return c:getName(); end):random())
	
	return text
end

-- from http://snippets.luacode.org/?p=snippets/Split_a_string_into_a_list_5
function strsplit(s,re)
	local i1 = 1
	local ls = {}
	
	if not re then re = '%s+' end
	if re == '' then return {s} end
	while true do
		local i2,i3 = s:find(re,i1)
		if not i2 then
			local last = s:sub(i1)
			if last ~= '' then table.insert(ls,last) end
			if #ls == 1 and ls[1] == '' then
				return {}
			else
				return ls
			end
		end
		table.insert(ls,s:sub(i1,i2-1))
		i1 = i3+1
	end
end

-- see http://lua-users.org/wiki/StringRecipes
function strstarts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

-- see http://lua-users.org/wiki/StringRecipes
function strends(String,End)
   return End=='' or string.sub(String,-string.len(End))==End
end

function strmatch(value, pattern)
	return string.find(value, pattern) ~= nil
end


function _jkosAutoStart()
	timers:setLevels(MAXLEVEL) -- change this to amount of levels in your dungeon.
	fw.debug.enabled = DEBUG_MODE
	fwInit:close() --must be called

	_activateAutos()
end


if (USE_JKOS_FRAMEWORK) then
	spawn("script_entity", party.level, 1, 1, 0, "logfw_init")
		:setSource([[
			function main()
				grimq._jkosAutoStart()
			end
		]])
		
	spawn("LoGFramework", party.level,1,1,0,'fwInit')
	fwInit:open() 
else
	spawn("pressure_plate_hidden", party.level, party.x, party.y, 0)
		:setTriggeredByParty(true)
		:setTriggeredByMonster(false)
		:setTriggeredByItem(false)
		:setActivateOnce(true)
		:setSilent(true)
		:addConnector("activate", "grimq", "_activateAutos")
end












	
	
	
	
	
	
	
	
	
	