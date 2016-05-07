require "defines"
require "config"

--Initialize the global table
script.on_init(function()
	global.placementChest = doesPlacementChestTableExistOrCreate(global.placementChest)
	placementChestConnectionTable = {}
end)

--Check on an entity being built
function entityBuilt(event)
	local entity = event.created_entity
	
	--Check is a placement chest was created
	if isPlacementChest(entity) then
		--Obtain its position
		local positionX = entity.position.x
		local positionY = entity.position.y
		local placementPosition
		
		--Find the position that it will place entities
		if (place_direction == "south") then
			placementPosition = {x = positionX, y = positionY+1}
		elseif (place_direction == "west") then
			placementPosition = {x = positionX-1, y = positionY}
		elseif (place_direction == "east") then
			placementPosition = {x = positionX+1, y = positionY}
		elseif (place_direction == "north") then
			placementPosition = {x = positionX, y = positionY-1}
		end
		
		table.insert(global.placementChest, {
												entity=entity, 
												placementPosition=placementPosition
											})
		debugLog("Added chest: ".. #global.placementChest)
	end
end

script.on_event(defines.events.on_robot_built_entity, entityBuilt)
script.on_event(defines.events.on_built_entity, entityBuilt)

--Check on entity being destroyed or deconstructed
function entityDestroyed(event)
	local entity = event.entity
	
	--Check is a placement chest was destroyed
	if isPlacementChest(entity) then
		if (global.placementChest ~= nil) then
			--Find the destroyed chest in the table
			for _, currentChest in ipairs(global.placementChest) do
				if (currentChest.entity == entity) then
					--Remove it from the table
					local newFunction = function (arg) return arg.entity == entity end --Function that returns true or false if the entities match
					global.placementChest = removeFromTable(newFunction, global.placementChest)
					debugLog("Deleted chest: " .. #global.placementChest)
				end
			end
		end
	end
end

--Removes an entity from the global table
--Works by adding everything except the old entry to a new table and overwritting the old table
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

--On Tick event handler
function onTick(event)
	
	--Trigger the event every [Interval] seconds (60 ticks per second)
	tick = game.tick % 60*interval_between_placement 
	if (tick == 0) then
		activateChests()
	end
end
script.on_event(defines.events.on_tick, onTick)

function activateChests()
	--Interate through the global table
	for _, currentChest in ipairs(global.placementChest) do
		local chestEntity = currentChest.entity
		--Verify that the chest has contents
		if chestEntity.has_items_inside() then
			debugLog("Contains something")
			--Get the inventory
			local inventory = chestEntity.get_inventory(defines.inventory.chest)
			
			--Iterate through the chest inventory
			for index=1,#inventory,1 do
				local item = inventory[index]
				--Verify that the item is readable
				if (item ~= nil and item.valid and item.valid_for_read) then
					local itemName = item.name
					local force = chestEntity.force
					local surface = chestEntity.surface
					debugLog("Can place?:"..itemName)
					
					--For placing blueprints
					if (itemName == "blueprint") then
						debugLog("Found blueprint")
						placeBlueprint(item, currentChest.placementPosition, surface, force)
						break
					end
					
					--For placing entities
					--Get the prototype
					local entityPrototype = item.prototype.place_result
					
					--Verify the prototype
					if (entityPrototype ~= nil and entityPrototype.valid) then
						local placedEntityPosition = getPlacedEntityPosition(entityPrototype, currentChest.placementPosition)
						
						--Verify it can be placed
						if surface.can_place_entity{name=itemName, position=placedEntityPosition, force=force} then
							local createdEntity = surface.create_entity{name=itemName, position=placedEntityPosition, force=force}--, direction=place_orientation}
							
							--Support for Avatars mod
							if (createdEntity.name == "avatar") then
								remote.call("Avatars_avatar_placement", "addAvatar", createdEntity)
							end
							
							--Remove 1 of the item from the chest
							chestEntity.remove_item({name = itemName})
							break
						end
					end
				end
			end
		end
	end
end

--Placement Chest check
function isPlacementChest(entity)
	local name = entity.name
	if (name == "placement-chest" or name == "smart-placement-chest" or name == "logistic-placement-chest") then
		return true
	else
		return false
	end
end

--Place the blueprint
function placeBlueprint(blueprint, placementPosition, surface, force)
	--Make sure it is set-up
	if blueprint.is_blueprint_setup then
		local blueprintEntities = blueprint.get_blueprint_entities()
		
		--Sometimes is still blank after the other check
		if (blueprintEntities == nil) then return false end
		local adjustment = getBlueprintAdjustment(blueprintEntities)
		
		--Make sure the connection table is clear
		global.placementChestConnectionTable = {entity=nil, connections=nil}
		
		--Iterate through the entities based on the settings
		if (place_direction == "south") then
			for _, currentEntity in ipairs(blueprintEntities) do
				--Find the position of this entity
				local position = {(placementPosition.x)+(currentEntity.position.x), (placementPosition.y)+(currentEntity.position.y)+adjustment}
				placeGhost(currentEntity, surface, position, force)
			end
			return true
		elseif (place_direction == "west") then
			for _, currentEntity in ipairs(blueprintEntities) do
				--Find the position of this entity
				local position = {(placementPosition.x)+(currentEntity.position.x)-adjustment, (placementPosition.y)+(currentEntity.position.y)}
				placeGhost(currentEntity, surface, position, force)
			end
			
		elseif (place_direction == "east") then
			for _, currentEntity in ipairs(blueprintEntities) do
				--Find the position of this entity
				local position = {(placementPosition.x)+(currentEntity.position.x)+adjustment, (placementPosition.y)+(currentEntity.position.y)}
				placeGhost(currentEntity, surface, position, force)
			end
			
		elseif (place_direction == "north") then
			for _, currentEntity in ipairs(blueprintEntities) do
				--Find the position of this entity
				local position = {(placementPosition.x)+(currentEntity.position.x), (placementPosition.y)+(currentEntity.position.y)-adjustment}
				placeGhost(currentEntity, surface, position, force)
			end
		end
		
		--Create the connections
		if (global.placementChestConnectionTable ~= nil) then
			connectGhosts()
		end
		
		--Clear the connection table
		global.placementChestConnectionTable = {}
	end
end

--Place the ghosts
function placeGhost(currentEntity, surface, position, force)
	--Check for collision
	if (surface.can_place_entity{
									name=currentEntity.name, 
									position=position, 
									direction=currentEntity.direction, 
									force=force, 
								}) then
		--Place the ghost
		local entity = surface.create_entity{
								name="entity-ghost", 
								position=position,
								force=force,
								inner_name=currentEntity.name,
								direction=currentEntity.direction,
								request_filters=currentEntity.request_filters,
								conditions=currentEntity.conditions,
								entity_number=currentEntity.entity_number,
								filters=currentEntity.filters,
								recipe=currentEntity.recipe,
								type=currentEntity.type,
								bar=currentEntity.bar
							 }
		--Check if the ghost needed connections
		if (currentEntity.connections ~= nil) then
			--Index the information by the entity_number
			global.placementChestConnectionTable[currentEntity.entity_number] =					{
							entity=entity, 
							connections=currentEntity.connections
						}
			debugLog("Added to connection table: "..global.placementChestConnectionTable[currentEntity.entity_number].entity.name.." #"..currentEntity.entity_number)
		end
		debugLog("Placed Ghost")
	end
end

--Connect the ghosts
function connectGhosts()
	--Iterate through each entity that needs a connection
	for i, connectionEntity in pairs(global.placementChestConnectionTable) do
		debugLog("Connection table: "..i.." "..connectionEntity.entity.name)
		
		--Iterate through the circuits
		for index, circuit in pairs(connectionEntity.connections) do
		
			--Check for green connections
			if (circuit.green ~= nil) then
				debugLog("Found green connection(s)")
				for _, greenConnection in pairs(circuit.green) do
					--Look up the target entity
					local connectionTarget = global.placementChestConnectionTable[greenConnection.entity_id]
					--Make sure that target still exists (can be caused by the ghost being destroyed upon entity construction)
					if (connectionTarget ~= nil and connectionTarget.entity ~= nil) then
						connectionEntity.entity.connect_neighbour({
															wire=defines.circuitconnector.green,
															target_entity=connectionTarget.entity,
															source_circuit_id=index,
															target_circuit_id=greenConnection.circuit_id
														 })
					end
				end
			end
			
			--Check for red connections
			if (circuit.red ~= nil) then
				debugLog("Found red connection(s)")
				for _, redConnection in pairs(circuit.red) do
					--Look up the target entity
					local connectionTarget = global.placementChestConnectionTable[redConnection.entity_id]
					--Make sure that target still exists (can be caused by the ghost being destroyed upon entity construction)
					if (connectionTarget ~= nil and connectionTarget.entity ~= nil) then
						connectionEntity.entity.connect_neighbour({
															wire=defines.circuitconnector.red,
															target_entity=connectionTarget.entity,
															source_circuit_id=index,
															target_circuit_id=redConnection.circuit_id
														 })
						
					end
				end
			end
		end
	end
end
--Connections are formed like this:
--connections = {[#] = {green = {}, red = {}}, [#]...}

--Creates a printable position
function printPosition(entity)
	local position = "(" ..math.floor(entity.position.x) ..", " ..math.floor(entity.position.y) ..")"
	return position
end
--debugLog("#:"..currentEntity.entity_number.." name:"..currentEntity.name.."position: "..printPosition(currentEntity))


--top left is -x -y // top right is +x -y
--bottom left is -x +y // bottom right is +x +y
--Find the adjustment needed to place the blueprint
function getBlueprintAdjustment(blueprintEntities)
	local closestEntity = blueprintEntities[1]
	
	--Determine the settings first, then loop (otherwise there would be an extra if statement ever loop)
	if (place_direction == "south") then
		--Find the entity that will be closest to the chest
		for _, currentEntity in ipairs(blueprintEntities) do
			if (currentEntity.position.y < closestEntity.position.y) then
				closestEntity = currentEntity
			end
		end
		
		--Find the adjustment for the closest entity's collision box
		local collisionBoxAdjustment = math.floor(math.abs(game.get_item_prototype(closestEntity.name).place_result.collision_box.left_top.y))
		
		--Add the collision box to the position of the entity
		return math.abs(closestEntity.position.y) + collisionBoxAdjustment
		
	elseif (place_direction == "west") then
		--Find the entity that will be closest to the chest
		for _, currentEntity in ipairs(blueprintEntities) do
			if (currentEntity.position.x > closestEntity.position.x) then
				closestEntity = currentEntity
			end
		end
		
		--Find the adjustment for the closest entity's collision box
		local collisionBoxAdjustment = math.floor(math.abs(game.get_item_prototype(closestEntity.name).place_result.collision_box.right_bottom.x))
		
		--Add the collision box to the position of the entity
		return math.abs(closestEntity.position.x) + collisionBoxAdjustment
		
	elseif (place_direction == "east") then
		--Find the entity that will be closest to the chest
		for _, currentEntity in ipairs(blueprintEntities) do
			if (currentEntity.position.x < closestEntity.position.x) then
				closestEntity = currentEntity
			end
		end
		
		--Find the adjustment for the closest entity's collision box
		local collisionBoxAdjustment = math.floor(math.abs(game.get_item_prototype(closestEntity.name).place_result.collision_box.left_top.x))
		
		--Add the collision box to the position of the entity
		return math.abs(closestEntity.position.x) + collisionBoxAdjustment
		
	elseif (place_direction == "north") then
		--Find the entity that will be closest to the chest
		for _, currentEntity in ipairs(blueprintEntities) do
			if (currentEntity.position.y > closestEntity.position.y) then
				closestEntity = currentEntity
			end
		end
		
		--Find the adjustment for the closest entity's collision box
		local collisionBoxAdjustment = math.floor(math.abs(game.get_item_prototype(closestEntity.name).place_result.collision_box.right_bottom.y))
		
		--Find the adjustment for the closest entity's collision box
		return math.abs(closestEntity.position.y) + collisionBoxAdjustment
	end
end

--Adjust the placement position by the entity's collision box
function getPlacedEntityPosition(prototype, placementPosition)
	local newPosition
	if (place_direction == "south") then
		local adjustment = math.floor(math.abs(prototype.collision_box.left_top.y))
		newPosition = {placementPosition.x, placementPosition.y+adjustment}
	elseif (place_direction == "west") then
		local adjustment = math.floor(math.abs(prototype.collision_box.right_bottom.x))
		newPosition = {placementPosition.x-adjustment, placementPosition.y}
	elseif (place_direction == "east") then
		local adjustment = math.floor(math.abs(prototype.collision_box.left_top.x))
		newPosition = {placementPosition.x+adjustment, placementPosition.y}
	elseif (place_direction == "north") then
		local adjustment = math.floor(math.abs(prototype.collision_box.right_bottom.y))
		newPosition = {placementPosition.x, placementPosition.y-adjustment}
	end
	return newPosition
end

--Make sure that table exists
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