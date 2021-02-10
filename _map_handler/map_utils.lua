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



function skywars.iterate_area_nodes(min_pos, max_pos, func)
    local get_node = minetest.get_node

    for x = 1, max_pos.x - min_pos.x do
        for y = 1, max_pos.y - min_pos.y do
            for z = 1, max_pos.z - min_pos.z do
                local node_pos = {
                    x = min_pos.x+x, 
                    y = min_pos.y+y, 
                    z = min_pos.z+z
                }
                local node = get_node(node_pos)
                local func_result = func(node, node_pos)

                if func_result then return func_result end
            end
        end
    end
end