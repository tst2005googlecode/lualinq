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
