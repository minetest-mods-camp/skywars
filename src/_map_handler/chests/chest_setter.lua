local function fill_chests() end
local function generate_particles() end

function skywars.place_chests(arena)
  local add_node = minetest.add_node

  for i=1, #arena.chests do
    add_node(arena.chests[i].pos, {name="default:chest"})
  end
  fill_chests(arena)
end



function skywars.generate_chest_id(arena)
	local max_id = 1
	
	for i = 1, #arena.chests do
		if arena.chests[i].id > max_id then
			max_id = arena.chests[i].id
		end
	end

	return max_id+1
end



function fill_chests(arena)
  local get_meta = minetest.get_meta
  local select_random_treasures = skywars.select_random_treasures

  for i, chest in pairs(arena.chests) do
    local treasures = select_random_treasures(chest, arena)
    local meta = get_meta(chest.pos)
    local inv = meta:get_inventory()

    inv:set_list("main", {})
    for i=1, #treasures do
      inv:set_stack("main", i, treasures[i])
    end
    
    generate_particles(chest.pos)
  end
end



function generate_particles(pos)
  minetest.add_particlespawner({
      amount = 7,
      time = 0.25,
      minpos = vector.add({x=0, y=-0.3, z=0}, pos),
      maxpos = vector.add({x=0, y=0, z=0}, pos),
      minvel = {x=-2, y=0.5, z=-2},
      maxvel = {x=2, y=1, z=2},
      minacc = {x=-2, y=0.5, z=-2},
      maxacc = {x=2, y=1, z=2},
      minexptime = 1,
      maxexptime = 1.5,
      minsize = 5.5,
      maxsize = 6.5,
      texture = "particle_chest_filled.png",
  })
end