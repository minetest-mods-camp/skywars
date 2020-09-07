function skywars.generate_HUD(arena, pl_name)
    local player = minetest.get_player_by_name(pl_name)
    local players_
    local background_ 

  
    background_ = player:hud_add({
        hud_elem_type = "image",
        position  = {x = 1, y = 1},
        offset = {x = -109, y = -32},
        text      = "sw_players_hud.png",
        alignment = { x = 1.0},
        scale     = { x = 3, y = 3},
        number    = 0xFFFFFF,
    })

    -- The number of players in the game
    players_ = player:hud_add({
        hud_elem_type = "text",
        position  = {x = 1, y = 1},
        offset = {x = -85, y = -32},
        text      = arena.players_amount,
        alignment = { x = 0},
        scale     = { x = 100, y = 100},
        number    = 0x7d7071,
    })

    -- Save the huds of each player 
    arena.HUDs[pl_name] = {background = background_, players = players_}

end



function skywars.remove_HUD(arena, pl_name)
    local player = minetest.get_player_by_name(pl_name)

    player:hud_remove(arena.HUDs[pl_name].background)
    player:hud_remove(arena.HUDs[pl_name].players)
end



function skywars.update_player_counter(arena, players_updated)
    local pl_amount = arena.players_amount
    
    -- if arena.players_amount hasn't been updated yet
    if players_updated == false then
        pl_amount = pl_amount-1
    end

    -- updating the player counter HUD
    for pl_name in pairs(arena.players) do
        local player = minetest.get_player_by_name(pl_name)

        player:hud_change(arena.HUDs[pl_name].players, "text", pl_amount)
    end
end
