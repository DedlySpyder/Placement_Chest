data:extend({
  {
    type = "container",
    name = "placement-chest",
    icon = "__Placement_Chest__/graphics/icons/placement-chest.png",
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 1, result = "placement-chest"},
    max_health = 200,
    corpse = "small-remnants",
    open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.65 },
    close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7 },
    resistances =
    {
      {
        type = "fire",
        percent = 90
      }
    },
    collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    fast_replaceable_group = "container",
    inventory_size = 10,
    vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
    picture =
    {
	   filename = "__Placement_Chest__/graphics/entities/placement-chest.png",
	   priority = "extra-high",
	   width = 48,
	   height = 34,
	   shift = {0.2, 0},
	} 
  },
  {
    type = "logistic-container",
    name = "logistic-placement-chest",
    icon = "__Placement_Chest__/graphics/icons/logistic-placement-chest.png", 
    flags = {"placeable-player", "player-creation"},
    minable = {hardness = 0.2, mining_time = 0.5, result = "logistic-placement-chest"},
    max_health = 150,
    corpse = "small-remnants",
    collision_box = {{-0.35, -0.35}, {0.35, 0.35}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    fast_replaceable_group = "container",
    inventory_size = 10,
    logistic_mode = "requester",
    open_sound = { filename = "__base__/sound/metallic-chest-open.ogg", volume=0.65 },
    close_sound = { filename = "__base__/sound/metallic-chest-close.ogg", volume = 0.7 },
    picture =
    {
	  layers = 
		{
			{
			  filename = "__Placement_Chest__/graphics/entities/logistic-placement-chest.png",
			  priority = "extra-high",
			  width = 38,
			  height = 32,
			  shift = {0.1, 0}
			},
			{
			  filename = "__Placement_Chest__/graphics/entities/logistic-placement-chest-mask.png",
			  priority = "extra-high",
			  width = 38,
			  height = 32,
			  shift = {0.1, 0},
			  tint = {r = 255, g = 215, b = 0, a = 0.5}
			}
		}
    },
    circuit_wire_max_distance = 7.5
  }
})