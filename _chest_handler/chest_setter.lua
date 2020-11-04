local function fill_chests() end


function skywars.place_chests(arena)
  for i=1, #arena.chests do
    minetest.add_node(arena.chests[i].pos, {name="default:chest"})
  end
  fill_chests(arena)
end



function fill_chests(arena)
  for i, chest in pairs(arena.chests) do
    local treasures = skywars.select_random_treasures(chest, arena)
    local meta = minetest.get_meta(chest.pos)
    local inv = meta:get_inventory()

    inv:set_list("main", {})
    for i=1, #treasures do
      inv:set_stack("main", i, treasures[i])
    end
  end
end