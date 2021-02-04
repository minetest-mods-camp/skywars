function skywars.kill_players_out_map(arena)
    for pl_name in pairs(arena.players) do
        local player = minetest.get_player_by_name(pl_name)
        local pl_pos = player:get_pos()
        local map_area = VoxelArea:new{MinEdge = arena.min_pos, MaxEdge = arena.max_pos}

        if not map_area:contains(pl_pos.x, pl_pos.y, pl_pos.z) then
            player:set_hp(0)
        end
    end
end



function skywars.load_mapblocks(arena)
    minetest.load_area(arena.min_pos, arena.max_pos)
    minetest.emerge_area(arena.min_pos, arena.max_pos)
end



minetest.register_node("skywars:barrier", {
    description = skywars.T("Unbreakable without skywars_admin priv transparent node"),
    drawtype = "airlike",
    paramtype = "light",
    sunlight_propagates = true,
    air_equivalent = true,
    drop = "",
    inventory_image = "sw_node_barrier.png",
    wield_image = "sw_node_barrier.png",
    groups = {oddly_breakable_by_hand = 2},
    can_dig = function(pos, player)
        if minetest.get_player_privs(player:get_player_name()).skywars_admin then
            return true
        end
        return false
    end
})



function skywars.iterate_area_nodes(min_pos, max_pos, func)
    for x = 1, max_pos.x - min_pos.x do
        for y = 1, max_pos.y - min_pos.y do
            for z = 1, max_pos.z - min_pos.z do
                local node_pos = {
                    x = min_pos.x+x, 
                    y = min_pos.y+y, 
                    z = min_pos.z+z
                }
                local node = minetest.get_node(node_pos)
                local func_result = func(node, node_pos)

                if func_result then return func_result end
            end
        end
    end
end