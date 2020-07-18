--Il necessario per impostare dove sono le chest nelle mappe. Vedi MOBA con gli spawner.
local mod = "skywars"

ChatCmdBuilder.new("skywars", function(cmd)

  cmd:sub("addchest :arena", function(sender, arena_name)
    local id, arena = arena_lib.get_arena_by_name("skywars", arena_name)
    local pos = vector.floor(minetest.get_player_by_name(sender):get_pos())

    table.insert(arena.chests, pos)

  end)

  cmd:sub("removechest :arena", function(sender, arena_name)
    local id, arena = arena_lib.get_arena_by_name("skywars", arena_name)
    local pos = vector.floor(minetest.get_player_by_name(sender):get_pos())

    table.remove(arena.chests, pos)

  end)

end)



function skywars.fill_chests(arena)
  for chest_pos in arena.chests do
    fill_chest_inv(chest_pos, arena)
  end
end

local function fill_chest_inv(chest_pos, arena)
  local t_min = 4  -- minimum amount of treasures found in a chest
  local t_max = 7  -- maximum amount of treasures found in a chest
  local treasure_amount = math.ceil(math.random(t_min, t_max))

  local minp = 0 --scale*4		-- minimal preciousness:   0..4
	local maxp = 10 --scale*4+2.1	-- maximum preciousness: 2.1..6.1

  local treasures = skywars.select_random_treasures(treasure_amount, minp, maxp, arena)

  local meta = minetest.get_meta(chest_pos)
  local inv = meta:get_inventory()

  for i=1, #treasures do
    inv:set_stack("main", i, treasures[i])
  end

end

function skywars.place_chests(arena)
  for chest_pos in arena.chests do
    minetest.set_node(chest_pos, "default:chest")
  end
end
