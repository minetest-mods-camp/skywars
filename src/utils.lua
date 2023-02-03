function skywars.print_error(pl_name, msg)
    minetest.chat_send_player(pl_name, minetest.colorize("#e6482e", skywars_settings.prefix .. msg))
end



function skywars.print_msg(pl_name, msg)
    minetest.chat_send_player(pl_name, skywars_settings.prefix .. msg)
end



function skywars.get_arena_by_pos(pos)
    for i, arena in pairs(arena_lib.mods["skywars"].arenas) do
        if arena.min_pos.x == nil or arena.max_pos.x == nil then goto continue end

        skywars.reorder_positions(arena.min_pos, arena.max_pos)
        local map_area = VoxelArea:new{MinEdge = arena.min_pos, MaxEdge = arena.max_pos}

        if map_area:contains(pos.x, pos.y, pos.z) then
            return arena
        end

        ::continue::
    end
end



-- Reordering the corners positions so that min_pos is smaller than max_pos.
function skywars.reorder_positions(min_pos, max_pos)
    local temp

    if min_pos.z > max_pos.z then
        temp = min_pos.z
        min_pos.z = max_pos.z
        max_pos.z = temp
    end

    if min_pos.y > max_pos.y then
        temp = min_pos.y
        min_pos.y = max_pos.y
        max_pos.y = temp
    end

    if min_pos.x > max_pos.x then
        temp = min_pos.x
        min_pos.x = max_pos.x
        max_pos.x = temp
    end

    return min_pos, max_pos
end