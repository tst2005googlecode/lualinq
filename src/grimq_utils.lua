-- ============================================================
-- UTILITY FUNCTIONS
-- ============================================================

-- saves an item into the table
function saveItem(item, slot)
   local itemTable = { }
   itemTable.id = item.id
   itemTable.name = item.name
   itemTable.stackSize = item:getStackSize()
   itemTable.fuel = item:getFuel()
   itemTable.charges = item:getCharges()
   itemTable.scrollText = item:getScrollText()
   itemTable.scrollImage = item:getScrollImage()
   itemTable.slot = slot
   
	for j = 1, CONTAINERITEM_MAXSLOTS do
		if (item:getItem(j) ~= nil) then
			if (itemTable.subItems == nil) then itemTable.subItems = {}; end
			table.insert(itemTable.subItems, saveItem(item:getItem(j), j))
		end
	end
   
   return itemTable
end

-- loads an item from the table
function loadItem(itemTable, level, x, y, facing, id)
   local spitem = nil
   if (level ~= nil) then
	  spitem = spawn(itemTable.name, level, x, y, facing, id)
   else
	  spitem = spawn(itemTable.name, nil, nil, nil, nil, id)
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
      
   if itemTable.scrollImage ~= nil then
	  spitem:setScrollImage(itemTable.scrollImage)
   end
   
   spitem:setFuel(itemTable.fuel)
   
   if (itemTable.subItems ~= nil) then
	  for _, subTable in pairs(itemTable.subItems) do
		 local subItem = loadItem(subTable)
		 if (subTable.slot ~= nil) then
			spitem:insertItem(subTable.slot, subItem)
		 else
			spitem:addItem(subItem)
		 end
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

g_ToorumMode = nil
function isToorumMode()
	if (g_ToorumMode == nil) then
		local rangerDetected = fromChampions():where(function(c) return (c:getClass() == "Ranger"); end):count()
		local zombieDetected = fromChampions():where(function(c) return ((not c:getEnabled()) and (c:getStatMax("health") == 0)); end):count()

		g_ToorumMode = (rangerDetected >= 1) and (zombieDetected == 3)
	end
	
	return g_ToorumMode
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

function setLogLevel(level)
	LOG_LEVEL = level
end

-- 1.3
function directionFromPos(fromx, fromy, tox, toy)
	local dx = tox - fromx
	local dy = toy - fromy
	return directionFromDelta(dx, dy)
end

function directionFromDelta(dx, dy)
	if (dx > dy) then dy = 0; else dx = 0; end

	if (dy < 0) then return 0; 
	elseif (dx > 0) then return 1;
	elseif (dy > 0) then return 2;
	else return 3; end
end

function find(id)
	local entity = findEntity(id)
	if (entity ~= nil) then	return entity; end
	
	entity = fromPartyInventory(true, inventory.all, true):where("id", id):first()
	if (entity ~= nil) then	return entity; end
	
	local containers = fromAllEntitiesInWorld()
				:where(isItem)
				:selectMany(function(i) return from(i:containedItems()):toArray(); end)
	
	entity = containers
		:where(function(ii) return ii.id == id; end)
		:first()
	
	if (entity ~= nil) then	return entity; end
		
	entity = containers
		:selectMany(function(i) return from(i:containedItems()):toArray(); end)
		:where(function(ii) return ii.id == id; end)
		:first()
		
	return entity
end

function getEx(entity)
	-- entity isn't in world, try inventory
	local itemInInv = fromPartyInventoryEx(true, inventory.all, true)
		:where(function(i) return i.entity == entity; end)		
		:first()
		
	if (itemInInv ~= nil) then
		return itemInInv
	end
	
	-- inventory failed, we try alcoves and containers
	-- if we don't have an entity level, we in an obscure "item in sack in alcove" scenario
	if (entity.level == nil) then
		local topcontainers = fromAllEntitiesInWorld():where(isContainerOrAlcove)
		
		local container = topcontainers
						:where(function(a) return from(a:containedItems()):where(function(ii) return ii == entity; end):any(); end)
						:first()
						
		if (container ~= nil) then
			local itemInInv = fromContainerItemEx(container)
				:where(function(i) return i.entity == entity; end)		
				:first()					
				
			return itemInInv
		end
		
		container = topcontainers
						:selectMany(function(i) return from(i:containedItems()):toArray(); end)
						:where(function(a) return from(a:containedItems()):where(function(ii) return ii == entity; end):any(); end)
						:first()
						
		if (container ~= nil) then
			local itemInInv = fromContainerItemEx(container)
				:where(function(i) return i.entity == entity; end)		
				:first()					
				
			return itemInInv
		else
			logw("findAndCallback can't find item " .. entity.id)
			return
		end
	end
	
	-- we are in classic alcove or container scenario here
	local alcoveOrContainer = from(entitiesAt(entity.level, entity.x, entity.y))
		:where(isContainerOrAlcove)
		:where(function(a) return from(a:containedItems()):where(function(ii) return ii == entity; end):any(); end)
		:first()
		
	if (alcoveOrContainer ~= nil) then
		if (isAlcoveOrAltar(alcoveOrContainer)) then
			return _createExtEntity(-1, entity, nil, nil, false, -1, alcoveOrContainer, nil)
		else
			local itemInInv = fromContainerItemEx(alcoveOrContainer)
				:where(function(i) return i.entity == entity; end)		
				:first()					
				
			return itemInInv		
		end
	end
	
	-- the simplest case sadly happens last
	local wentity = findEntity(entity.id)
	
	if (wentity ~= nil) then	
		return _createExtEntity(-1, entity, nil, nil, false, -1, nil, true)
	end
	
	logw("findAndCallback can't find entity " .. entityid)
end

function gameover()
	damageTile(party.level, party.x, party.y, party.facing, 64, "physical", 100000000)
end

function findEx(entityid)
	local entity = find(entityid)
	
	if (entity == nil) then 
		return nil
	end
	
	local ex = getEx(entity)
	
	return ex
end

function replace(entity, entityToSpawn, desiredId)
	local ex = getEx(entity)
	
	if (ex ~= nil) then
		ex:replace(entityToSpawn, desiredId)
	end
end

function destroy(entity)
	local ex = getEx(entity)
	
	if (ex ~= nil) then
		ex:destroy()
	end
end






	
	
	
	
	
	
	
	
	
	