local get_player_by_name = minetest.get_player_by_name


function skywars.kill_players_out_map(arena)
    for pl_name in pairs(arena.players) do
        local player = get_player_by_name(pl_name)
        local pl_pos = player:get_pos()
        local min_pos = vector.add(arena.min_pos, 5)
        local max_pos = vector.subtract(arena.max_pos, 5)
        local map_area = VoxelArea:new{MinEdge = min_pos, MaxEdge = max_pos}

        if not map_area:contains(pl_pos.x, pl_pos.y, pl_pos.z) then
            player:set_hp(0)
        end
    end
end



function skywars.load_mapblocks(arena)
    minetest.load_area(arena.min_pos, arena.max_pos)
    minetest.emerge_area(arena.min_pos, arena.max_pos)
end