-- ------------------------------------------------------------------------
-- This project is developed by Marco Mastropaolo (Xanathar) 
-- as a personal project and is in no way affiliated with Almost Human.
-- You can use this scripts in any Legend of Grimrock dungeon you want; 
-- credits are appreciated though not necessary.
-- ------------------------------------------------------------------------
-- If you want to use this code in a Lua project outside Grimrock, 
-- please refer to the files and license included 
-- at http://code.google.com/p/lualinq/
-- ------------------------------------------------------------------------

---------------------------------------------------------------------------
-- CONFIGURATION OPTIONS                                                 --
---------------------------------------------------------------------------

-- CHANGE THIS ACCORDING TO YOUR DUNGEON!
MAXLEVEL = 1

-- change this if you don't want all secrets to be "auto"
AUTO_ALL_SECRETS = true

-- integrate with jkos framework. Read docs before enabling it.
USE_JKOS_FRAMEWORK = true

-- debug mode
DEBUG_MODE = true


---------------------------------------------------------------------------
-- IMPLEMENTATION BELOW, DO NOT CHANGE
---------------------------------------------------------------------------


-- ============================================================
-- GENERATORS
-- ============================================================

-- Creates a linq data structure from an array without copying the data for efficiency
function fromArrayInstance(collection)
	local self = { }
	
	self.classid_71cd970f_a742_4316_938d_1998df001335 = 1
	
	self.m_Data = collection
	
	self.concat = _concat
	self.select = _select
	self.selectMany = _selectMany
	self.where = _where
	self.whereIndex = _whereIndex
	self.take = _take
	self.skip = _skip
	self.zip = _zip
	
	self.distinct = _distinct 
	self.union = _union
	self.except = _except
	self.intersection = _intersection

	self.first = _first
	self.last = _last
	self.min = _min
	self.max = _max
	self.random = _random

	self.any = _any
	self.all = _all
	self.contains = _contains

	self.count = _count
	self.sum = _sum
	self.average = _average

	self.map = _map
	self.foreach = _foreach
	self.xmap = _xmap


	self.toArray = _toArray
	self.toDictionary = _toDictionary
	self.toIterator = _toIterator
	
	return self
end

-- Tries to autodetect input type and uses the appropriate from method
function from(auto)
	if (auto == nil) then
		return fromNothing()
	elseif (type(auto) == "function") then
		return fromIterator(auto)
	elseif (type(auto) == "table") then
		if (auto["classid_71cd970f_a742_4316_938d_1998df001335"] ~= nil) then
			return auto
		elseif (auto[1] == nil) then
			return fromDictionary(auto)
		elseif (type(auto[1]) == "function") then
			return fromIteratorsArray(auto)
		else
			return fromArrayInstance(auto)
		end
	end
	return fromNothing()
end

-- Creates a linq data structure from an array copying the data first (so that changes in the original
-- table do not reflect here)
function fromArray(array)
	local collection = { }
	for k,v in ipairs(array) do
		table.insert(collection, v)
	end
	return fromArrayInstance(collection)
end

-- Creates a linq data structure from a dictionary (table with non-consecutive-integer keys)
function fromDictionary(dictionary)
	local collection = { }
	
	for k,v in pairs(dictionary) do
		local kvp = {}
		kvp.key = k
		kvp.value = v
		
		table.insert(collection, kvp)
	end
	
	return fromArrayInstance(collection)
end

-- Creates a linq data structure from an iterator returning single items
function fromIterator(iterator)
	local collection = { }
	
	for s in iterator do
		table.insert(collection, s)
	end
	
	return fromArrayInstance(collection)
end

-- Creates a linq data structure from an array of iterators each returning single items
function fromIteratorsArray(iteratorArray)
	local collection = { }

	for _, iterator in ipairs(iteratorArray) do
		for s in iterator do
			table.insert(collection, s)
		end
	end
	
	return fromArrayInstance(collection)
end

-- Creates an empty linq data structure
function fromNothing()
	return fromArrayInstance { }
end

-- ============================================================
-- QUERY METHODS
-- ============================================================

-- Concatenates two collections together
function _concat(self, otherlinq)
	local result = { }

	for idx, value in ipairs(self.m_Data) do
		table.insert(result, value)
	end
	for idx, value in ipairs(otherlinq.m_Data) do
		table.insert(result, value)
	end
	
	return fromArrayInstance(result)
end

-- Replaces items with those returned by the selector function or properties with name selector
function _select(self, selector)
	local result = { }

	if (type(selector) == "function") then
		for idx, value in ipairs(self.m_Data) do
			local newvalue = selector(value)
			if (newvalue ~= nil) then
				table.insert(result, newvalue)
			end
		end
	else 
		for idx, value in ipairs(self.m_Data) do
			local newvalue = value[selector]
			if (newvalue ~= nil) then
				table.insert(result, newvalue)
			end
		end
	end
	
	return fromArrayInstance(result)
end


-- Replaces items with those contained in arrays returned by the selector function
function _selectMany(self, selector)
	local result = { }

	for idx, value in ipairs(self.m_Data) do
		local newvalue = selector(value)
		if (newvalue ~= nil) then
			for ii, vv in ipairs(newvalue) do
				if (vv ~= nil) then
					table.insert(result, vv)
				end
			end
		end
	end
	
	return fromArrayInstance(result)
end

-- Returns a linq data structure where only items for whose the predicate has returned true are included
function _where(self, predicate, refvalue)
	local result = { }

	if (type(predicate) == "function") then
		for idx, value in ipairs(self.m_Data) do
			if (predicate(value)) then
				table.insert(result, value)
			end
		end	
	else 
		for idx, value in ipairs(self.m_Data) do
			if (value[predicate] == refvalue) then
				table.insert(result, value)
			end
		end	
	end
	
	return fromArrayInstance(result)
end

-- Returns a linq data structure where only items for whose the predicate has returned true are included, indexed version
function _whereIndex(self, predicate)
	local result = { }

	for idx, value in ipairs(self.m_Data) do
		if (predicate(idx, value)) then
			table.insert(result, value)
		end
	end	
	
	return fromArrayInstance(result)
end

-- Return a linq data structure with at most the first howmany elements
function _take(self, howmany)
	return self:whereIndex(function(i, v) return i <= howmany; end)
end

-- Return a linq data structure skipping the first howmany elements
function _skip(self, howmany)
	return self:whereIndex(function(i, v) return i > howmany; end)
end

-- Zips two collections together, using the specified join function
function _zip(self, otherlinq, joiner)
	otherlinq = from(otherlinq) 

	local thismax = #self.m_Data
	local thatmax = #otherlinq.m_Data
	local result = {}
	
	if (thatmax < thismax) then thismax = thatmax; end
	
	for i = 1, thismax do
		result[i] = joiner(self.m_Data[i], otherlinq.m_Data[i]);
	end
	
	return fromArrayInstance(result)
end

-- Returns only distinct items, using an optional comparator
function _distinct(self, comparator)
	local result = {}
	
	for idx, value in ipairs(self.m_Data) do
		local found = false

		for _, value2 in ipairs(result) do
			if (comparator == nil) then
				if (value == value2) then found = true; end
			else
				if (comparator(value, value2)) then found = true; end
			end			
		end
	
		if (not found) then
			table.insert(result, value)
		end
	end
	
	return fromArrayInstance(result)
end

-- Returns the union of two collections, using an optional comparator
function _union(self, other, comparator)
	return self:concat(from(other)):distinct(comparator)
end

-- Returns the difference of two collections, using an optional comparator
function _except(self, other, comparator)
	other = from(other)
	return self:where(function (v) return not other:contains(v, comparator) end)
end

-- Returns the intersection of two collections, using an optional comparator
function _intersection(self, other, comparator)
	other = from(other)
	return self:where(function (v) return other:contains(v, comparator) end)
end

-- ============================================================
-- CONVERSION METHODS
-- ============================================================

-- Converts the collection to an array
function _toIterator(self)
	local i = 0
	local n = #self.m_Data
	return function ()
			i = i + 1
			if i <= n then return self.m_Data[i] end
		end
end

-- Converts the collection to an array
function _toArray(self)
	return self.m_Data
end

-- Converts the collection to a table using a selector functions which returns key and value for each item
function _toDictionary(self, keyValueSelector)
	local result = { }

	for idx, value in ipairs(self.m_Data) do
		local key, value = keyValueSelector(value)
		if (key ~= nil) then
			result[key] = value
		end
	end
	
	return result
end

-- ============================================================
-- TERMINATING METHODS
-- ============================================================

-- Return the first item or default if no items in the colelction
function _first(self, default)
	if (#self.m_Data > 0) then
		return self.m_Data[1]
	else
		return default
	end
end

-- Return the last item or default if no items in the colelction
function _last(self, default)
	if (#self.m_Data > 0) then
		return self.m_Data[#self.m_Data]
	else
		return default
	end
end

-- Returns true if any item satisfies the predicate. If predicate is null, it returns true if the collection has at least one item.
function _any(self, predicate)
	if (predicate == nil) then return #self.m_Data > 0; end

	for idx, value in ipairs(self.m_Data) do
		if (predicate(value)) then
			return true
		end
	end
	
	return false
end

-- Returns true if all items satisfy the predicate. If predicate is null, it returns true if the collection is empty.
function _all(self, predicate)
	if (predicate == nil) then return #self.m_Data == 0; end

	for idx, value in ipairs(self.m_Data) do
		if (not predicate(value)) then
			return false
		end
	end
	
	return true
end

-- Returns the number of items satisfying the predicate. If predicate is null, it returns the number of items in the collection.
function _count(self, predicate)
	if (predicate == nil) then return #self.m_Data; end

	local result = 0

	for idx, value in ipairs(self.m_Data) do
		if (predicate(value)) then
			result = result + 1
		end
	end
	
	return false
end

-- Returns a random item in the collection, or default if no items are present
function _random(self, default)
	if (#self.m_Data == 0) then return default; end
	return self.m_Data[math.random(1, #self.m_Data)]
end

-- Returns true if the collection contains the specified item
function _contains(self, item, comparator)
	for idx, value in ipairs(self.m_Data) do
		if (comparator == nil) then
			if (value == item) then return true; end
		else
			if (comparator(value, item)) then return true; end
		end
	end
	return false
end


-- Calls the action for each item in the collection. Action takes 1 parameter: the item value
function _foreach(self, action)
	for idx, value in ipairs(self.m_Data) do
		action(value)
	end
	
	return self
end

-- Calls the accumulator for each item in the collection. Accumulator takes 2 parameters: value and the previous result of 
-- the accumulator itself (firstvalue for the first call) and returns a new result.
function _map(self, accumulator, firstvalue)
	local result = firstvalue

	for idx, value in ipairs(self.m_Data) do
		result = accumulator(value, result)
	end
	
	return result
end

-- Calls the accumulator for each item in the collection. Accumulator takes 3 parameters: value, the previous result of 
-- the accumulator itself (nil on first call) and the previous associated-result of the accumulator(firstvalue for the first call) 
-- and returns a new result and a new associated-result.
function _xmap(self, accumulator, firstvalue)
	local result = nil
	local lastval = firstvalue

	for idx, value in ipairs(self.m_Data) do
		result, lastval = accumulator(value, result, lastval)
	end
	
	return result
end

-- Returns the max of a collection. Selector is called with values and should return a number. Can be nil if collection is of numbers.
function _max(self, selector)
 	if (selector == nil) then 
		selector = function(n) return n; end
	end
  	return self:xmap(function(v, r, l) local res = selector(v); if (l == nil or res > l) then return v, res; else return r, l; end; end, nil)
end

-- Returns the min of a collection. Selector is called with values and should return a number. Can be nil if collection is of numbers.
function _min(self, selector)
	if (selector == nil) then 
		selector = function(n) return n; end
	end
  	return self:xmap(function(v, r, l) local res = selector(v); if (l == nil or res < l) then return v, res; else return r, l; end; end, nil)
end

-- Returns the sum of a collection. Selector is called with values and should return a number. Can be nil if collection is of numbers.
function _sum(self, selector)
	if (selector == nil) then 
		selector = function(n) return n; end
	end
	return self:map(function(n, r) r = r + selector(n); return r; end, 0)
end

-- Returns the average of a collection. Selector is called with values and should return a number. Can be nil if collection is of numbers.
function _average(self, selector)
	local count = self:count()
	if (count > 0) then
		return self:sum(selector) / count
	else
		return 0
	end
end
-- ============================================================
-- ENUMERATIONS
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
				destroyed = false
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
			local done = false
			if (self.container ~= nil) then
				done = false
			elseif (self.slot >= 0) then
				self.champion:removeItem(self.slot)
				self.champion:insertItem(self.slot, newitem)
				done = true
			elseif (ismouse) then
				setMouseItem(nil)
				setMouseItem(newitem)
			end
			return done
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

-- ============================================================
-- PREDICATES
-- ============================================================

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

-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================

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

function isToorumMode()
   local rangerDetected = fromChampions():where(function(c) return (c:getClass() == "Ranger"); end):count()
   local zombieDetected = fromChampions():where(function(c) return ((not c:getEnabled()) and (c:getStatMax("health") == 0)); end):count()
   
   return (rangerDetected >= 1) and (zombieDetected == 3)
end

function dezombifyParty()
	local portraits = { "human_female_01", "human_female_02", "human_male_01", "human_male_02" }
	local genders = { "female", "female", "male", "male" }
	local names = { "Sylyna", "Yennica", "Contar", "Sancsaron" }

	for c in fromChampions():where(function(c) return ((not c:getEnabled()) and (c:getStatMax("health") == 0)); end):toIterator() do
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














	
	
	
	
	
	
	
	
	
	-- ============================================================
-- STRING FUNCTIONS
-- ============================================================


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


-- ============================================================
-- AUTO-OBJECTS
-- ============================================================


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
	
	if (ntt.autohook ~= nil) then
		if (fw == nil or (not USE_JKOS_FRAMEWORK)) then
			print("Can't install autohooks in ".. ntt.id .. " -> JKos framework not found or USE_JKOS_FRAMEWORK is false.")
			return
		end

		for hooktable in from(ntt.autohook):toIterator() do
			local target = hooktable.key
			local hooks = from(hooktable.value):where(function(fn) return (type(fn.value) == "function"); end)
			
			for hook in hooks:toIterator() do
				local hookname = hook.key
				print("Adding hook for: ".. ntt.id .. "." .. hookname .. " ...")
				fw.addHooks(target, ntt.id .. "_" .. target .. "_" .. hookname, { [hookname] = hook.value } )
			end
		end
	end
end






-- ============================================================
-- BOOTSTRAP CODE
-- ============================================================

function _jkosAutoStart()
	timers:setLevels(MAXLEVEL) 
	fw.debug.enabled = DEBUG_MODE
	fwInit:close() 

	_activateAutos()
end

if (USE_JKOS_FRAMEWORK) then
	spawn("script_entity", party.level, 1, 1, 0, "logfw_init")
		:setSource([[
			function main()
			end
		]])
		
	spawn("LoGFramework", party.level,1,1,0,'fwInit')
	fwInit:open() 

	spawn("pressure_plate_hidden", party.level, party.x, party.y, 0)
		:setTriggeredByParty(true)
		:setTriggeredByMonster(false)
		:setTriggeredByItem(false)
		:setActivateOnce(true)
		:setSilent(true)
		:addConnector("activate", "grimq", "_jkosAutoStart")
else
	spawn("pressure_plate_hidden", party.level, party.x, party.y, 0)
		:setTriggeredByParty(true)
		:setTriggeredByMonster(false)
		:setTriggeredByItem(false)
		:setActivateOnce(true)
		:setSilent(true)
		:addConnector("activate", "grimq", "_activateAutos")
end

expected = { }
expindex = 1
array = { "ciao", "hello", "au revoir" }
array2 = { "arrivederci", "goodbye", "bonjour" }
array3 = { { say="ciao", lang="ita" },  { say="hello", lang="eng" },  }
testname = ""
allok = true


function assertneq(v1, v2)
	if (v1 == v2) then
		print("ERROR!! TEST FAILED " .. testname .. " -> " .. tostring(v1) .. " != ".. tostring(v2))
		allok = false
	end
end

function asserteq(v1, v2)
	if (v1 ~= v2) then
		print("ERROR!! TEST FAILED " .. testname .. " -> " .. tostring(v1) .. " == ".. tostring(v2))
		allok = false
	end
end

function assertArray(v)
	asserteq(v, expected[expindex])
	expindex = expindex + 1
end

function assertArrayBegin(tx)
	expected = tx
	expindex = 1
end

function assertArrayEnd()
	asserteq(#expected, expindex - 1)
end

function autoexec()
	print("===============================================================")

	testname = "Test #" ..  1
	assertArrayBegin(array)
	grimq.from(array)
		:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  2
	assertArrayBegin({4, 5, 9})
		grimq.from(array)
			:select(function(v) return #v; end)
			:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  3
	assertArrayBegin({"ciao", 4, "hello", 5, "au revoir", 9})
	grimq.from(array)
		:selectMany(function(v) return { v, #v }; end)
			:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  4
	assertArrayBegin({ "HELLO", "AU REVOIR"})
		grimq.from(array)
			:where(function(v) return #v >= 5; end)
			:select(function(v) return string.upper(v); end)
			:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  5
	assertArrayBegin({ "ciao", "au revoir"})
		grimq.from(array)
			:whereIndex(function (i, v) return ((i % 2)~=0); end)
			:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  5
	assertArrayBegin({ "ciao", "hello"})
	grimq.from(array)
		:take(2)
			:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  6
	assertArrayBegin({ "ciao", "hello", "au revoir", "arrivederci", "goodbye", "bonjour"})
		grimq.from(array)
			:concat(grimq.from(array2))
			:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  7
	assertArrayBegin({ "ciao/arrivederci", "hello/goodbye", "au revoir/bonjour"})
		grimq.from(array)
			:zip(grimq.from(array2), function(a,b) return a .. "/" .. b; end)
			:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  8
	assertneq(grimq.from(array):random(), nil)

	testname = "Test #" ..  9
	asserteq(grimq.from(array):first(), "ciao")

	testname = "Test #" ..  10
	asserteq(grimq.from(array):last(), "au revoir")

	testname = "Test #" ..  11
	asserteq(grimq.from(array):any(function(v) return #v > 5; end), true)

	testname = "Test #" ..  12
	asserteq(grimq.from(array):all(function(v) return #v > 5; end), false)

	testname = "Test #" ..  13
	asserteq(grimq.from(array):any(function(v) return #v > 15; end), false)

	testname = "Test #" ..  14
	asserteq(grimq.from(array):contains("hello"), true)

	testname = "Test #" ..  15
	asserteq(grimq.from(array):contains("qweqhello"), false)

	testname = "Test #" ..  16
	asserteq(grimq.from(array):sum(function(e) return #e; end), 18)

	testname = "Test #" ..  17
	asserteq(grimq.from(array):average(function(e) return #e; end), 6)

	testname = "Test #" ..  18
	assertArrayBegin({ "ciao", "hello", "au revoir"})
		grimq.from({ "ciao", "ciao", "ciao", "hello", "au revoir", "ciao", "hello", "au revoir"})
			:distinct()
			:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  19
	assertArrayBegin({ "ciao", "yeah", "hello", "au revoir"})
		grimq.from({ "ciao", "ciao", "yeah"})
			:union(grimq.from(array))
			:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  20
	assertArrayBegin({ "yeah"})
		grimq.from({ "ciao", "yeah", "hello", "au revoir"})
			:except(grimq.from(array))
			:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  21
	assertArrayBegin({ "ciao", "hello"})
		grimq.from({ "ciao", "yeah", "hello", })
			:intersection(array)
			:foreach(assertArray)
	assertArrayEnd()

	testname = "Test #" ..  22
	assertArrayBegin({ "ciao" })
		grimq.from(array3)
			:where("lang", "ita")
			:select("say")
			:foreach(assertArray)
	assertArrayEnd()

	if (allok) then
		print("ALL TESTS PASSED!")
	end

end













