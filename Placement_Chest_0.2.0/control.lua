require "defines"
require "config"

script.on_init(function()
	global.placementChest = doesPlacementChestTableExistOrCreate(global.placementChest)
end)

--Check on an entity being built
function entityBuilt(event)
	local entity = event.created_entity
	
	if isPlacementChest(entity) then
		local positionX = entity.position.x
		local positionY = entity.position.y
		local placementPosition
		if (place_direction == "south") then
			placementPosition = {x = positionX, y = positionY+1}
		elseif (place_direction == "west") then
			placementPosition = {x = positionX-1, y = positionY}
		elseif (place_direction == "east") then
			placementPosition = {x = positionX+1, y = positionY}
		elseif (place_direction == "north") then
			placementPosition = {x = positionX, y = positionY-1}
		end
		table.insert(global.placementChest, {entity=entity, placementPosition=placementPosition}) --entity=nil, placementPosition=nil
		debugLog("Added chest: ".. #global.placementChest)
	end
end

script.on_event(defines.events.on_robot_built_entity, entityBuilt)
script.on_event(defines.events.on_built_entity, entityBuilt)

--Check on entity being destroyed or deconstructed
function entityDestroyed(event)
	local entity = event.entity
	
	if isPlacementChest(entity) then
		if (global.placementChest ~= nil) then
			for _, currentChest in ipairs(global.placementChest) do
				if (currentChest.entity == entity) then
					local newFunction = function (arg) return arg.entity == entity end --Function that returns true or false if the entities match
					global.placementChest = removeFromTable(newFunction, global.placementChest)
					debugLog("Deleted chest: " .. #global.placementChest)
				end
			end
		end
	end
end

function removeFromTable(func, chestTable)
	if (chestTable == nil) then return nil end
	local newTable = {}
	for _, row in ipairs(chestTable) do
		if not func(row) then table.insert(newTable, row) end
	end
	return newTable
end

script.on_event(defines.events.on_preplayer_mined_item, entityDestroyed)
script.on_event(defines.events.on_robot_pre_mined, entityDestroyed)
script.on_event(defines.events.on_entity_died, entityDestroyed)

function onTick(event)
	tick = game.tick % 60*interval_between_placement --how many ticks per second??
	
	if (tick == 0) then
		for _, currentChest in ipairs(global.placementChest) do
			local chestEntity = currentChest.entity
			if chestEntity.has_items_inside() then
				debugLog("Contains something")
				local inventory = chestEntity.get_inventory(defines.inventory.chest)
				for item, _ in pairs(inventory.get_contents()) do
					debugLog("Can place?:"..item)
					local force = chestEntity.force
					local surface = chestEntity.surface
					
					
					
					local entityPrototype = game.get_item_prototype(item).place_result
					if (entityPrototype ~= nil) then
						local placedEntityPosition = getPlacedEntityPosition(entityPrototype, currentChest.placementPosition)
						if surface.can_place_entity{name=item, position=placedEntityPosition, force=force} then
							local createdEntity = surface.create_entity{name=item, position=placedEntityPosition, force=force}
							
							if (createdEntity.name == "avatar") then
								remote.call("Avatars_avatar_placement", "addAvatar", createdEntity)
							end
							
							chestEntity.remove_item({name = item})
							return
						end
					end
				end
			end
		end
	end
end
script.on_event(defines.events.on_tick, onTick)

function isPlacementChest(entity)
	if (entity.name == "placement-chest") then
		return true
	else
		return false
	end
end

function getPlacedEntityPosition(prototype, placementPosition)
	local newPosition
	if (place_direction == "south") then
		local adjustment = math.floor(math.abs(prototype.collision_box.left_top.y))
		newPosition = {placementPosition.x, placementPosition.y+adjustment}
		return newPosition
	elseif (place_direction == "west") then
		local adjustment = math.floor(math.abs(prototype.collision_box.right_bottom.x))
		newPosition = {placementPosition.x-adjustment, placementPosition.y}
		return newPosition
	elseif (place_direction == "east") then
		local adjustment = math.floor(math.abs(prototype.collision_box.right_bottom.x))
		newPosition = {placementPosition.x+adjustment, placementPosition.y}
		return newPosition
	elseif (place_direction == "north") then
		local adjustment = math.floor(math.abs(prototype.collision_box.left_top.y))
		newPosition = {placementPosition.x, placementPosition.y-adjustment}
		return newPosition
	end
end

function doesPlacementChestTableExistOrCreate(checkTable)
	if checkTable == nil then
		return {}
	else
		return checkTable
	end
end

--DEBUG messages
function debugLog(message)
	if debug_mode then
		game.player.print(message)
	end
end