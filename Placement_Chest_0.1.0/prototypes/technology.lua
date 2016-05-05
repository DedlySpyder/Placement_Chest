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
 }
})