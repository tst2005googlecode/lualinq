ChangeLog
=========

23-Jan-2013: Version 1.3.2
	o GrimQ: Fixed (hopefully) all corner cases
	o GrimQ: Extended items generalized to extended entities
	o GrimQ: findEx(id) – equivalent of findEntity, but works also for items in inventory or mouse cursor and returns an extended entity instead
	o GrimQ: getEx(entity) – returns the extended entity from an entity
	o GrimQ: fromContainerItemEx - returns a grimq structure filled with extended entities of the contents of a container


23-Jan-2013: Version 1.3 / 1.3.1
	o GrimQ: Now requires LoG 1.3.6 or later
	o GrimQ: Simplified setup - no need to set MAXLEVEL any longer
	o GrimQ: Fixed issues on destroy and replace methods for inventory management
	o GrimQ: loadItem and copyItem now preserve scroll images and container slots
	o GrimQ: loadItem now allows an id to be passed 
	o GrimQ: setLogLevel to dynamically change the log level at runtime
	o GrimQ: directionFromPos(fromx, fromy, tox, toy) - returns a facing value given starting and end positions
	o GrimQ: directionFromDelta(dx, dy) - returns a direction given the differences in x and y (the opposite of getForward)
	o GrimQ: destroy(entity) - can be called on any item and most entities and automatically destroys the entity in the best way, without concerns about where the entity is or what the entity is
	o GrimQ: replace(entity, entityToSpawn, desiredId) - can be called on any item and most entities and automatically replace the entity with another in the best way, without concerns about where the entity is or what the entity is
	o GrimQ: find(id) - equivalent of findEntity, but works also for items in inventory or mouse cursor
	o GrimQ: gameover() - kills the party (equivalent to destroy(party))
	o GrimQ: isContainerOrAlcove(entity) - returns true if entity is either a container or an alcove/altar




04-Dec-2012: Version 1.2
	o LuaLinq: "from" detects a Lualinq structure and inteprets it correctly
	o LuaLinq: all methods taking a second LuaLinq now can take anything you can feed a "from" method with
	o LuaLinq: "select" method accepts a property name instead of a selector function
	o LuaLinq: "where" method accepts a property name and a value instead of a predicate
	o LuaLinq: private methods are prefixed with an underscore
	o GrimQ: new: reverseFacing, getChampionFromOrdinal, strformat, string methods
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


