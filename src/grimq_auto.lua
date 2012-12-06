-- ============================================================
-- AUTO-OBJECTS
-- ============================================================


function _activateAutos()
	-- cache is toorum mode result, so that we remember being toorum after party is manipulated
	local toorummode = isToorumMode()
	logv("Toorum mode: ".. tostring(toorummode))
	
	logv("Starting auto-secrets... (AUTO_ALL_SECRETS is " .. tostring(AUTO_ALL_SECRETS) .. ")")
	if (AUTO_ALL_SECRETS) then
		fromAllEntitiesInWorld():where("name", "secret"):foreach(_initializeAutoSecret)
	else
		fromAllEntitiesInWorld():where(match("id", "^auto_secret")):foreach(_initializeAutoSecret)
	end

	logv("Starting auto-printers...")
	fromAllEntitiesInWorld():where("name", "auto_printer"):foreach(_initializeAutoHudPrinter)

	logv("Starting auto-torches...")
	fromAllEntitiesInWorld():where(match("name", "^auto_")):where(isTorchHolder):foreach(function(auto) if (not auto:hasTorch()) then auto:addTorch(); end; end)

	logv("Starting auto-alcoves...")
	fromAllEntitiesInWorld():where(match("name", "^auto_")):where(isAlcoveOrAltar):foreach(moveItemsFromTileToAlcove)

	logv("Starting autoexec scripts...")
	fromAllEntitiesInWorld():where(isScript):foreach(_initializeAutoScript)
	
	logi("Started.")
end

function _initializeAutoSecret(auto)
	local plate = spawn("pressure_plate_hidden", auto.level, auto.x, auto.y, auto.facing)
		:setTriggeredByParty(true)
		:setTriggeredByMonster(false)
		:setTriggeredByItem(false)
		:setSilent(true)
		:setActivateOnce(true)
		:addConnector("activate", auto.id, "activate")
end

function _initializeAutoHudPrinter(auto)
	local plate = spawn("pressure_plate_hidden", auto.level, auto.x, auto.y, auto.facing)
		:setTriggeredByParty(true)
		:setTriggeredByMonster(false)
		:setTriggeredByItem(false)
		:setSilent(true)
		:setActivateOnce(true)
		:addConnector("activate", "grimq", "execHudPrinter")

	g_HudPrinters[plate.id]	= auto:getScrollText()
	auto:destroy()
end

g_HudPrinters = { }

function execHudPrinter(source)
	logv("Executing hudprinter " .. source.id)
	local text = g_HudPrinters[source.id]
	if (text ~= nil) then
		hudPrint(strformat(text))
	else
		logw("Auto-hud-printer not found in hudprinters list: " .. source.id)
	end
end

-- NEW
function _initializeAutoScript(ntt)
	if (ntt.autoexec ~= nil) then
		logv("Executing autoexec of " .. ntt.id .. "...)")
		ntt:autoexec();
	end
	
	if (ntt.autohook ~= nil) then
		if (fw == nil or (not USE_JKOS_FRAMEWORK)) then
			loge("Can't install autohooks in ".. ntt.id .. " -> JKos framework not found or USE_JKOS_FRAMEWORK is false.")
			return
		end

		for hooktable in from(ntt.autohook):toIterator() do
			local target = hooktable.key
			local hooks = from(hooktable.value):where(function(fn) return (type(fn.value) == "function"); end)
			
			for hook in hooks:toIterator() do
				local hookname = hook.key
				logv("Adding hook for: ".. ntt.id .. "." .. hookname .. " ...")
				fw.addHooks(target, ntt.id .. "_" .. target .. "_" .. hookname, { [hookname] = hook.value } )
			end
		end
	end
end






