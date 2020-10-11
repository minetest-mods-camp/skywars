function skywars.generate_HUD(arena, pl_name)
    local player = minetest.get_player_by_name(pl_name)
    local players_count_
    local players_killed_
    local background_players_counter_ 
    local background_kill_counter_
    local x_pos = 0.45
    local y_pos = 0
    local scale = 3.5
    local distance_x = 45
    local background_width = 32*scale

    background_players_counter_ = player:hud_add({
        hud_elem_type = "image",
        position  = {x = x_pos, y = y_pos},
        offset = {x = distance_x+background_width, y = 50},
        text      = "sw_players_hud.png",
        alignment = { x = 1.0},
        scale     = { x = scale, y = scale},
        number    = 0xFFFFFF,
    })


    background_kill_counter_ = player:hud_add({
        hud_elem_type = "image",
        position  = {x = x_pos, y = y_pos},
        offset = {x = -distance_x, y = 50},
        text      = "sw_kill_counter_hud.png",
        alignment = { x = 1.0},
        scale     = { x = scale, y = scale},
        number    = 0xFFFFFF,
    })

    -- The number of players in the game
    players_count_ = player:hud_add({
        hud_elem_type = "text",
        position  = {x = x_pos, y = y_pos},
        offset = {x = distance_x+background_width+39, y = 50+6},
        text      = tostring(arena.players_amount) .. "/" .. tostring(arena.match_players),
        alignment = { x = 0},
        scale     = { x = 100, y = 100},
        number    = 0xdff6f5,
    })

    -- The number of players killed
    players_killed_ = player:hud_add({
        hud_elem_type = "text",
        position  = {x = x_pos, y = y_pos},
        offset = {x = -distance_x+33, y = 50+5},
        text      = 0,
        alignment = { x = 0},
        scale     = { x = 100, y = 100},
        number    = 0xdff6f5,
    })

    -- Save the huds of each player 
    arena.HUDs[pl_name] = {
        background_players_counter = background_players_counter_,
        players_count = players_count_,
        -- HUD ID, amount of players killed
        players_killed = {players_killed_, 0},
        background_kill_counter = background_kill_counter_
    }

end



function skywars.remove_HUD(arena, pl_name)
    local player = minetest.get_player_by_name(pl_name)
    
    player:hud_remove(arena.HUDs[pl_name].background_players_counter)
    player:hud_remove(arena.HUDs[pl_name].background_kill_counter)
    player:hud_remove(arena.HUDs[pl_name].players_count)
    player:hud_remove(arena.HUDs[pl_name].players_killed[1])
end



function skywars.update_players_counter(arena, players_updated)
    local pl_amount = arena.players_amount
    
    -- if arena.players_amount hasn't been updated yet
    if players_updated == false then
        pl_amount = pl_amount-1
    end

    -- updating the players counter HUD
    for pl_name in pairs(arena.players) do
        local player = minetest.get_player_by_name(pl_name)
        
        if arena.match_players == nil then return end 

        player:hud_change(arena.HUDs[pl_name].players_count, "text", tostring(arena.players_amount) .. "/" .. tostring(arena.match_players))
    end
end