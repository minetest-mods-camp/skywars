function skywars.generate_HUD(arena, pl_name)
    local player = minetest.get_player_by_name(pl_name)
    local players_count_
    local players_killed_
    local timer_
    local background_players_counter_ 
    local background_kill_counter_
    local background_timer_
    local x_pos = 0.45
    local y_pos = 0
    local scale = 3.5
    local distance_x = 135
    local background_width = 32*scale

    background_players_counter_ = player:hud_add({
        hud_elem_type = "image",
        position  = {x = x_pos, y = y_pos},
        offset = {x = distance_x+background_width, y = 50},
        text      = "sw_players_hud.png",
        alignment = {x = 1.0},
        scale     = {x = scale, y = scale},
        number    = 0xFFFFFF,
    })

    background_kill_counter_ = player:hud_add({
        hud_elem_type = "image",
        position  = {x = x_pos, y = y_pos},
        offset = {x = 0-distance_x, y = 50},
        text      = "sw_kill_counter_hud.png",
        alignment = {x = 1.0},
        scale     = {x = scale, y = scale},
        number    = 0xFFFFFF,
    })

    background_timer_ = player:hud_add({
        hud_elem_type = "image",
        position  = {x = x_pos, y = y_pos},
        offset = {x = background_width/2, y = 50},
        text      = "sw_timer.png",
        alignment = {x = 1.0},
        scale     = {x = scale, y = scale},
        number    = 0xFFFFFF,
    })

    players_count_ = player:hud_add({
        hud_elem_type = "text",
        position  = {x = x_pos, y = y_pos},
        offset = {x = distance_x+background_width+39, y = 50+3},
        text      = tostring(arena.players_amount) .. "/" .. tostring(arena.players_original_amount),
        alignment = {x = 0},
        scale     = {x = 100, y = 100},
        number    = 0xdff6f5,
    })

    players_killed_ = player:hud_add({
        hud_elem_type = "text",
        position  = {x = x_pos, y = y_pos},
        offset = {x = -distance_x+37, y = 50+3},
        text      = 0,
        alignment = {x = 0},
        scale     = {x = 100, y = 100},
        number    = 0xdff6f5,
    })

    timer_ = player:hud_add({
        hud_elem_type = "text",
        position  = {x = x_pos, y = y_pos},
        offset = {x = background_width/2 + 37, y = 50+3},
        text      = "-",
        alignment = {x = 0},
        scale     = {x = 100, y = 100},
        number    = 0xdff6f5,
    })

    arena.HUDs[pl_name] = {
        background_players_counter = background_players_counter_,
        players_count = players_count_,
        players_killed = {id = players_killed_, amount = 0},
        background_kill_counter = background_kill_counter_,
        background_timer = background_timer_,
        timer = timer_
    }

end



function skywars.remove_HUD(arena, pl_name)
    local player = minetest.get_player_by_name(pl_name)
    
    player:hud_remove(arena.HUDs[pl_name].background_players_counter)
    player:hud_remove(arena.HUDs[pl_name].background_kill_counter)
    player:hud_remove(arena.HUDs[pl_name].players_count)
    player:hud_remove(arena.HUDs[pl_name].players_killed.id)
    player:hud_remove(arena.HUDs[pl_name].timer)
    player:hud_remove(arena.HUDs[pl_name].background_timer)
end



function skywars.update_players_counter(arena, players_amount_updated)
    local pl_amount = arena.players_amount
    
    if not players_amount_updated then
        pl_amount = pl_amount-1
    end

    for pl_name in pairs(arena.players) do
        local player = minetest.get_player_by_name(pl_name)

        if arena.players_original_amount == nil then return end 
        
        local players_counter = tostring(arena.players_amount) .. "/" .. tostring(arena.players_original_amount)
        player:hud_change(arena.HUDs[pl_name].players_count, "text", players_counter)
    end
end



function skywars.update_timer_hud(arena)
    for pl_name in pairs(arena.players) do
        local player = minetest.get_player_by_name(pl_name)
        player:hud_change(arena.HUDs[pl_name].timer, "text", arena.current_time)
    end
end