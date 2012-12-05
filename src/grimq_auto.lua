-- ============================================================
-- AUTO-OBJECTS
-- ============================================================


function _activateAutos()
	if (AUTO_ALL_SECRETS) then
		fromAllEntitiesInWorld():where("name", "secret"):foreach(_initializeAutoSecret)
	else
		fromAllEntitiesInWorld():where(match("id", "^auto_secret")):foreach(_initializeAutoSecret)
	end

	fromAllEntitiesInWorld():where("name", "auto_printer"):foreach(_initializeAutoHudPrinter)
	fromAllEntitiesInWorld():where(match("name", "^auto_")):where(isTorchHolder):foreach(function(auto) if (not auto:hasTorch()) then auto:addTorch(); end; end)
	fromAllEntitiesInWorld():where(match("name", "^auto_")):where(isAlcoveOrAltar):foreach(moveItemsFromTileToAlcove)
	fromAllEntitiesInWorld():where(isScript):foreach(_initializeAutoScript)
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
	local text = g_HudPrinters[source.id]
	if (text ~= nil) then
		hudPrint(strformat(text))
	end
end

-- NEW
function _initializeAutoScript(ntt)
	if (ntt.autoexec ~= nil) then
		ntt:autoexec();
	end
	
	if (ntt.autohook ~= nil) then
		if (fw == nil or (not USE_JKOS_FRAMEWORK)) then
			print("Can't install autohooks in ".. ntt.id .. " -> JKos framework not found or USE_JKOS_FRAMEWORK is false.")
			return
		end

		for hooktable in from(ntt.autohook):toIterator() do
			local target = hooktable.key
			local hooks = from(hooktable.value):where(function(fn) return (type(fn.value) == "function"); end)
			
			for hook in hooks:toIterator() do
				local hookname = hook.key
				print("Adding hook for: ".. ntt.id .. "." .. hookname .. " ...")
				fw.addHooks(target, ntt.id .. "_" .. target .. "_" .. hookname, { [hookname] = hook.value } )
			end
		end
	end
end






