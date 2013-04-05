-- ============================================================
-- BOOTSTRAP CODE
-- ============================================================

function _banner()
	logi("GrimQ Version " .. LIB_VERSION_TEXT .. VERSION_SUFFIX .. " - Marco Mastropaolo (Xanathar)")
end

-- added by JKos
function activate()
	logi("Starting with jkos-fw bootstrap...")
	grimq._activateJKosFw()
end

_banner()

MAXLEVEL = getMaxLevels()

if (isWall == nil) then
	loge("This version of GrimQ requires Legend of Grimrock 1.3.6 or later!")
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


















