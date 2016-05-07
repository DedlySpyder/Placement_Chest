data:extend({
  {
    type = "item",
    name = "placement-chest",
    icon = "__Placement_Chest__/graphics/icons/placement-chest.png",
    flags = {"goes-to-quickbar"},
    subgroup = "storage",
    order = "z[placement-chest]-a[placement-chest]",
    place_result = "placement-chest",
    stack_size = 50
  },
  {
    type = "item",
    name = "logistic-placement-chest",
    icon = "__Placement_Chest__/graphics/icons/logistic-placement-chest.png",
    flags = {"goes-to-quickbar"},
    subgroup = "storage",
    order = "z[placement-chest]-c[logistic-placement-chest]",
    place_result = "logistic-placement-chest",
    stack_size = 50
  }
})