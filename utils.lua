function skywars.print_error(player, msg)
    minetest.chat_send_player(player, minetest.colorize("#e6482e", skywars_settings.prefix .. msg))
end
  
  
  
function skywars.print_msg(player, msg)
    minetest.chat_send_player(player, skywars_settings.prefix .. msg)
end



function skywars.get_arena_by_pos(pos)
    for i, arena in pairs(arena_lib.mods["skywars"].arenas) do
        if arena.pos1.x == nil or arena.pos2.x == nil then 
        goto continue 
        end

        reorder_positions(arena.pos1, arena.pos2)
        local map_area = VoxelArea:new{MinEdge = arena.pos1, MaxEdge = arena.pos2}

        if map_area:contains(pos.x, pos.y, pos.z) then
        return arena
        end

        ::continue::
    end
end



-- reordering the corners positions so that pos1 is smaller than pos2
function reorder_positions(pos1, pos2)
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