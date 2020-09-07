-- Creates the schematic using pos1 (the first corner of the map) and pos2 (the second one)
function skywars.create_schematic(sender, pos1, pos2, name, arena)
    minetest.create_schematic(pos1, pos2, nil, minetest.get_worldpath() .. "/" .. name .. ".mts", nil)
    arena.schematic = minetest.get_worldpath() .. "/" .. name .. ".mts"

    arena_lib.change_arena_property(sender, "skywars", arena.name, "pos1", pos1) 
    arena_lib.change_arena_property(sender, "skywars", arena.name, "schematic", arena.schematic)
end
