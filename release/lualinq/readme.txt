ChangeLog
=========

04-Dec-2012: Version 1.2
	o LuaLinq: "from" detects a Lualinq structure and inteprets it correctly
	o LuaLinq: all methods taking a second LuaLinq now can take anything you can feed a "from" method with
	o LuaLinq: "select" method accepts a property name instead of a selector function
	o LuaLinq: "where" method accepts a property name and a value instead of a predicate
	o LuaLinq: private methods are prefixed with an underscore
	o GrimQ: new: reverseFacing, getChampionFromOrdinal, strformat, strsplit
	o GrimQ: added *optional* integrations with JKos framework hooks
	o GrimQ: added AUTO_ALL_SECRETS options to shortcut all secrets to be auto


27-Nov-2012: Version 1.1
	o Includes: distinct, union, except, intersection
	o GrimQ: includeMouse on fromPartyInventory
	o GrimQ: new: fromPartyInventoryEx, fromChampionInventoryEx, fromEntitiesInArea, fromEntitiesAround, fromEntitiesForward, 
			copyItem, moveFromFloorToContainer, moveItemsFromTileToAlcove, fromEntitiesInWorld
	o GrimQ: support for "auto" items - scripting entities containing an autoexec() method, autosecrets, etc.

21-Nov-2012: Version 1.01 
	o Changed all methods to be immutable and return new objects
	  instead of changing the original one.


20-Nov-2012: Version 1.0


