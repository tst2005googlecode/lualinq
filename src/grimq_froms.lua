-- ============================================================
-- LUALINQ GENERATORS
-- ============================================================

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

