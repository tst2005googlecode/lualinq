-- ============================================================
-- BOOTSTRAP CODE
-- ============================================================

-- Thanks marble mouth for this: http://www.grimrock.net/forum/viewtopic.php?f=14&t=5028&p=53889#p53889
function allEntities_patched(level)
	local s = {}
	s["offset"] = 0
	local c = 0
	for i=0,31 do
		for j=0,31 do
			for k in entitiesAt(level,i,j) do
				c = c + 1
				s[c] = k
			end
		end
	end

	local f = function ( s , v )
		local offset = s["offset"] + 1
		s["offset"] = offset
		return s[offset]
	end

	return f , s , nil
end


function _banner()
	logi("GrimQ Version " .. LIB_VERSION_TEXT .. VERSION_SUFFIX .. " - Marco Mastropaolo (Xanathar)")
end

function _jkosAutoStart()
	logi("Starting with jkos-fw integration, stage 2...")
	
	timers:setLevels(MAXLEVEL) 
	fw.debug.enabled = (LOG_LEVEL > 0)
	fwInit:close() 

	_activateAutos()
end

_banner()

if (isWall == nil) then
	loge("This version of GrimQ requires Legend of Grimrock 1.3.6 or later!")
else
	MAXLEVEL = getMaxLevels()

	if (PATCH_ALLENTITIES_BUG) then
		allEntities = allEntities_patched
	end

	if (USE_JKOS_FRAMEWORK) then
		logi("Starting with jkos-fw integration, stage 1...")

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
		logi("Starting with standard bootstrap...")

		spawn("pressure_plate_hidden", party.level, party.x, party.y, 0)
			:setTriggeredByParty(true)
			:setTriggeredByMonster(false)
			:setTriggeredByItem(false)
			:setActivateOnce(true)
			:setSilent(true)
			:addConnector("activate", "grimq", "_activateAutos")
	end
end


















