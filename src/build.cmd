cd /D %LUALINQROOTPATH%
md build
cd src

copy /B /Y lualinq_header.lua +lualinq_froms.lua +lualinq_query.lua +lualinq_conversions.lua +lualinq_terminators.lua ..\build\lualinq.lua

copy /B /Y grimq_header.lua +grimq_enums.lua +grimq_froms.lua +grimq_predicates.lua +grimq_utils.lua +grimq_string.lua +grimq_auto.lua +grimq_bootstrap.lua ..\build\grimq.lua

copy grimqobjects.lua ..\build\grimqobjects.lua

copy grimqunit.lua ..\build\grimq_unit_tests.lua

pause
