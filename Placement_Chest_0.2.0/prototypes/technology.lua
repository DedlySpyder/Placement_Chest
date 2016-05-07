data:extend({
  {
    type = "technology",
    name = "placement-chest",
    icon = "__Placement_Chest__/graphics/placement-chest-tech.png",
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "placement-chest"
      }
    },
    prerequisites = {"electronics", "steel-processing"},
    unit =
    {
      count = 40,
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
      },
      time = 15
    },
    order = "a-d-d",
 },
 {
    type = "technology",
    name = "logistic-placement-chest",
    icon = "__Placement_Chest__/graphics/logistic-placement-chest-tech.png",
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "logistic-placement-chest"
      }
    },
    prerequisites = {"placement-chest", "logistic-system"},
    unit =
    {
      count = 150,
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
		{"science-pack-3", 1}
      },
      time = 30
    },
    order = "a-d-e",
 }
})