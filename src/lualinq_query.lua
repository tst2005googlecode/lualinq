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

