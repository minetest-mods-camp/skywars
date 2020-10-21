-- This sets the map chests
local mod = "skywars"
local function fill_chest_inv() end


function skywars.fill_chests(arena)
  for i=1, #arena.chests do
    fill_chest_inv(arena.chests[i], arena)
  end
end



function skywars.place_chests(arena)
  for i=1, #arena.chests do
    minetest.add_node(arena.chests[i].pos, {name="default:chest"})
  end
end



function fill_chest_inv(chest, arena)
  local t_min = chest.min_treasures
  local t_max = chest.max_treasures
  local treasure_amount = math.ceil(math.random(t_min, t_max))
  local minp = chest.min_preciousness
	local maxp = chest.max_preciousness
  -- returns an itemstacks table that contains the chosen treasures
  local treasures = skywars.select_random_treasures(treasure_amount, minp, maxp, arena)
  local meta = minetest.get_meta(chest.pos)
  local inv = meta:get_inventory()

  inv:set_list("main", {})
  for i=1, #treasures do
    inv:set_stack("main", i, treasures[i])
  end
end