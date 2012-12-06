cd /D %LUALINQROOTPATH%
md build
cd src

copy /B /Y lualinq_log.lua +lualinq_ctor.lua +lualinq_froms.lua +lualinq_query.lua +lualinq_conversions.lua +lualinq_terminators.lua "%TEMP%\lualinq_temp.lua"

copy /B /Y lualinq_header.lua +"%TEMP%\lualinq_temp.lua" ..\build\lualinq.lua

copy /B /Y "%TEMP%\lualinq_temp.lua" +grimq_enums.lua +grimq_froms.lua +grimq_predicates.lua +grimq_utils.lua +grimq_string.lua +grimq_auto.lua +grimq_bootstrap.lua "%TEMP%\grimq_temp.lua"

copy /B /Y grimq_header.lua +"%TEMP%\grimq_temp.lua" ..\build\grimq.lua

copy /B /Y grimq_dbg_header.lua +"%TEMP%\grimq_temp.lua" +grimqunit.lua ..\build\grimq_debug.lua


copy /B /Y grimq_header.lua +"%TEMP%\lualinq_temp.lua" +grimq_enums.lua +grimq_froms.lua +grimq_predicates.lua +grimq_utils.lua +grimq_string.lua +grimq_auto.lua +grimq_bootstrap.lua ..\build\grimq.lua

copy grimqobjects.lua ..\build\grimqobjects.lua

copy grimqunit.lua ..\build\grimq_unit_tests.lua

pause
