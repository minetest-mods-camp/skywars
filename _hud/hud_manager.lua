function skywars.generate_HUD(arena, pl_name)
    local player = minetest.get_player_by_name(pl_name)
    local players_
    local players_killed_
    local background_players_ 
    local background_kill_counter_
  
    background_players_counter_ = player:hud_add({
        hud_elem_type = "image",
        position  = {x = 1, y = 0.45},
        offset = {x = -109, y = 80},
        text      = "sw_players_hud.png",
        alignment = { x = 1.0},
        scale     = { x = 3, y = 3},
        number    = 0xFFFFFF,
    })

    -- The number of players in the game
    players_count_ = player:hud_add({
        hud_elem_type = "text",
        position  = {x = 1, y = 0.45},
        offset = {x = -85, y = 80},
        text      = arena.players_amount,
        alignment = { x = 0},
        scale     = { x = 100, y = 100},
        number    = 0x7d7071,
    })

    background_kill_counter_ = player:hud_add({
        hud_elem_type = "image",
        position  = {x = 1, y = 0.45},
        offset = {x = -109, y = 0},
        text      = "sw_kill_counter_hud.png",
        alignment = { x = 1.0},
        scale     = { x = 3, y = 3},
        number    = 0xFFFFFF,
    })

    -- The number of players killed
    players_killed_ = player:hud_add({
        hud_elem_type = "text",
        position  = {x = 1, y = 0.45},
        offset = {x = -85, y = 0},
        text      = 0,
        alignment = { x = 0},
        scale     = { x = 100, y = 100},
        number    = 0x7d7071,
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

    -- updating the player counter HUD
    for pl_name in pairs(arena.players) do
        local player = minetest.get_player_by_name(pl_name)

        player:hud_change(arena.HUDs[pl_name].players_count, "text", pl_amount)
    end
end