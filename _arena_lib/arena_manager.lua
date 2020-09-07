arena_lib.on_load("skywars", function(arena)

  if arena.reset == false then
    minetest.place_schematic(arena.pos1, arena.schematic)
    arena.reset = true
  end

  skywars.place_chests(arena)
  skywars.fill_chests(arena)

end)



arena_lib.on_join("skywars", function(pl_name, arena)

end)



arena_lib.on_start("skywars", function(arena)
  for pl_name in pairs(arena.players) do
    local player = minetest.get_player_by_name(pl_name)

    skywars.generate_HUD(arena, pl_name)
    player:set_physics_override({speed=arena.players[pl_name].speed})
    -- saving original speed
    arena.players[pl_name].speed = player:get_physics_override().speed
  end
  
end)



arena_lib.on_celebration("skywars", function(arena, winner_name)
  for pl_name in pairs(arena.players) do
    skywars.remove_HUD(arena, pl_name)
  end
end)



arena_lib.on_end("skywars", function(arena, players)
  arena.reset = false

  for pl_name in pairs(arena.players) do
    local player = minetest.get_player_by_name(pl_name)
    
    -- restore player's original speed
    player:set_physics_override({speed=arena.players[pl_name].speed})
  end
end)



arena_lib.on_death("skywars", function(arena, pl_name, reason)
  
  if reason.type == "punch" then
    if reason.object ~= nil and reason.object:is_player() then
      local killer = reason.object:get_player_name()

      arena_lib.send_message_players_in_arena(arena, skywars_settings.prefix .. skywars.T("@1 was killed by @2", pl_name, killer))
    end
  else
    arena_lib.send_message_players_in_arena(arena, skywars_settings.prefix .. skywars.T("@1 is dead", pl_name))
  end

  arena_lib.remove_player_from_arena(pl_name, 1)
  skywars.update_player_counter(arena)
end)



arena_lib.on_quit("skywars", function(arena, pl_name)
  skywars.update_player_counter(arena, false)
  skywars.remove_HUD(arena, pl_name)
end)



arena_lib.on_disconnect("skywars", function(arena, pl_name)
  skywars.update_player_counter(arena, false)
end)



arena_lib.on_kick("skywars", function(arena, pl_name)
  skywars.update_player_counter(arena, false)
  skywars.remove_HUD(arena, pl_name)
end)
