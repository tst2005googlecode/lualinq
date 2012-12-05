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














	
	
	
	
	
	
	
	
	
	