data:extend({
  {
    type = "container",
    name = "placement-chest",
    icon = "__Placement_Chest__/graphics/placement-chest-icon.png",
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
		layers = 
		  {
			{
			   filename = "__Placement_Chest__/graphics/steel-chest.png",
			   priority = "high",
			   width = 48,
			   height = 34,
			   shift = {0.2, 0},
			   tint = {r = 1}
			},
			{
			   filename = "__Placement_Chest__/graphics/steel-chest-mask.png",
			   priority = "extra-high",
			   width = 48,
			   height = 34,
			   shift = {0.2, 0}
			},
		  }
	} 
  }	
})