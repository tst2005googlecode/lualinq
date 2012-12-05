-- ============================================================
-- BOOTSTRAP CODE
-- ============================================================


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
