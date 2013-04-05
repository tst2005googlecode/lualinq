-- ============================================================
-- BOOTSTRAP CODE
-- ============================================================

function _banner()
	logi("GrimQ Version " .. LIB_VERSION_TEXT .. VERSION_SUFFIX .. " - Marco Mastropaolo (Xanathar)")
end

-- added by JKos
function activate()
	USE_JKOS_FRAMEWORK = true
	MAXLEVEL = getMaxLevels()
	grimq._activateAutos()
end

_banner()

if (isWall == nil) then
	loge("This version of GrimQ requires Legend of Grimrock 1.3.6 or later!")
else
	MAXLEVEL = getMaxLevels()

	if (not USE_JKOS_FRAMEWORK) then
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


















