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


