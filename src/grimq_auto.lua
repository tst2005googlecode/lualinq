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
	
	local hooks = from(ntt):where(match("key", "^autohook_")):where(function(fn) return (type(fn.value) == "function"); end)
	
	for hook in hooks:toIterator() do
		local splits = strsplit(hooks.key, "__")
		local target = splits[2]
		local hookname = splits[3]
		
		if (target == nil or hookname == nil) then
			print("Invalid auto-hook ".. ntt.name .. "." .. hookname .. " -> name must be autohook__<target>__<hookname>.")
		elseif (fw == nil or (not USE_JKOS_FRAMEWORK)) then
			print("Can't install autohook: ".. ntt.name .. "." .. hookname .. " -> JKos framework not found or USE_JKOS_FRAMEWORK is false.")
		else
			fw.addHooks(target, ntt.name, { [hookname] = hook.value } )
		end
	end
end


function _jkosAutoStart()
	timers:setLevels(MAXLEVEL) -- change this to amount of levels in your dungeon.
	fw.debug.enabled = DEBUG_MODE
	fwInit:close() --must be called

	_activateAutos()
end





