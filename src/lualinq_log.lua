-- ============================================================
-- DEBUG TRACER
-- ============================================================

LIB_VERSION_TEXT = "1.4.2"
LIB_VERSION = 142

function _log(level, prefix, text)
	if (level <= LOG_LEVEL) then
		print(prefix .. LOG_PREFIX .. text)
	end
end

function logq(self, method)
	if (LOG_LEVEL >= 3) then
		local items = #self.m_Data
		local dumpdata = "{ "
		
		for i = 1, 3 do
			if (i <= items) then
				if (i ~= 1) then
					dumpdata = dumpdata .. ", "
				end
				dumpdata = dumpdata .. tostring(self.m_Data[i])
			end
		end
		
		if (items > 3) then
			dumpdata = dumpdata .. ", ... }"
		else
			dumpdata = dumpdata .. " }"
		end
	
		logv("after " .. method .. " => " .. items .. " items : " .. dumpdata)
	end
end

function logv(txt)
	_log(3, "[..] ", txt)
end

function logi(txt)
	_log(2, "[ii] ", txt)
end

function logw(txt)
	_log(1, "[W?] ", txt)
end

function loge(txt)
	_log(0, "[E!] ", txt)
end


