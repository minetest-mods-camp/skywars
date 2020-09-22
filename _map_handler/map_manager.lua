-- reordering the corner's position so that pos1 is smaller than pos2
local function reorder_positions(pos1, pos2)
    local temp

    if pos1.z > pos2.z then
        temp = pos1.z
        pos1.z = pos2.z
        pos2.z = temp
    end

    if pos1.y > pos2.y then
        temp = pos1.y
        pos1.y = pos2.y
        pos2.y = temp
    end

    if pos1.x > pos2.x then
        temp = pos1.x
        pos1.x = pos2.x
        pos2.x = temp
    end

    return pos1, pos2
     
end



-- Creates the schematic using pos1 (the first corner of the map) and pos2 (the second one)
function skywars.create_schematic(sender, pos1, pos2, name, arena)
    pos1, pos2 = reorder_positions(pos1, pos2)

    if minetest.get_modpath("exschem") then
        skywars.create_exschem_schematic(sender, pos1, pos2, name, arena)
        arena.schematic = name
    else
        local path = minetest.get_worldpath() .. "/" .. name .. ".mts" 
        path = path:gsub("//", "/")
        arena.schematic = path

        minetest.create_schematic(pos1, pos2, nil, path, nil)
        skywars.print_msg(sender, skywars.T("Schematic @1 created! (Saved in @2)", name, path)) 
    end

    arena.pos1 = pos1
    arena.pos2 = pos2
    arena_lib.change_arena_property(sender, "skywars", arena.name, "pos1", pos1) 
    arena_lib.change_arena_property(sender, "skywars", arena.name, "pos2", pos2) 
    arena_lib.change_arena_property(sender, "skywars", arena.name, "schematic", arena.schematic)
end



function skywars.load_schematic(arena)
    if arena.reset == false then
        if minetest.get_modpath("exschem") then
            skywars.load_exschem_schematic(arena.pos1, arena.schematic)
        else
            minetest.place_schematic(arena.pos1, arena.schematic)
        end
        arena.reset = true
    end
end



function skywars.kill_players_out_map(arena)
    for pl_name in pairs(arena.players) do
        local player = minetest.get_player_by_name(pl_name)
        local pl_pos = player:get_pos()
        local map_area = VoxelArea:new{MinEdge = arena.pos1, MaxEdge = arena.pos2}

        if map_area:contains(pl_pos.x, pl_pos.y, pl_pos.z) == false then
            player:set_hp(0)
        end
    end
end