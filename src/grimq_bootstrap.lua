-- ============================================================
-- BOOTSTRAP CODE
-- ============================================================

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
