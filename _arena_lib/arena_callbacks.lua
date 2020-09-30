arena_lib.on_load("skywars", function(arena)
  skywars.reset_map(arena)
  minetest.after(skywars_settings.loading_time, function()
    skywars.reset_map(arena)
    skywars.place_chests(arena)
    skywars.fill_chests(arena)
    -- trying to prevent the lava-water reaction or whatever happens
    -- after the first reset from modifing the map 
  end)
  
  for pl_name in pairs(arena.players) do
    local player = minetest.get_player_by_name(pl_name)
    local pl_pos = player:get_pos()

    -- preventing players with noclip to fall when placing blocks
    if minetest.check_player_privs(pl_name, {noclip=true}) then
      local privs = minetest.get_player_privs(pl_name)
      player:get_meta():set_int("noclip", 2)
      privs.noclip = nil
      minetest.set_player_privs(pl_name, privs)
    end

    local function set_glass(relative_pos)
      local node_pos = vector.round(vector.add(player:get_pos(), relative_pos))

      if minetest.get_node(node_pos).name == "air" then 
        minetest.add_node(node_pos, {name="default:glass"})

        minetest.after(skywars_settings.loading_time, function() 
          minetest.add_node(node_pos, {name="air"})
        end)
      end
    end

    -- puts glass nodes around the player
    set_glass({x = 0,y = -1,z = 0})
    set_glass({x = 0,y = -2,z = 0})
    set_glass({x = 1,y = 1,z = 0})
    set_glass({x = -1,y = 1,z = 0})
    set_glass({x = 0,y = 1,z = 1})
    set_glass({x = 0,y = 1,z = -1})

    skywars.show_kit_selector(pl_name, arena)
    minetest.after(0.1, function()
      player:set_physics_override({gravity=0, jump=0})
      player:add_player_velocity(vector.multiply(player:get_player_velocity(), -1))
    end)

    -- teleports the player back to in the glass
    minetest.after(1, function()
      player:set_pos(pl_pos)
    end)
  end
end)



arena_lib.on_start("skywars", function(arena)
  arena.match_players = arena.players_amount

  for pl_name in pairs(arena.players) do
    local player = minetest.get_player_by_name(pl_name)

    skywars.generate_HUD(arena, pl_name)
    player:set_physics_override({speed=arena.players[pl_name].speed, gravity=1, jump=1})
    -- saving original speed
    arena.players[pl_name].speed = player:get_physics_override().speed
  end
  
end)



arena_lib.on_celebration("skywars", function(arena, winner_name)
  for pl_name in pairs(arena.players) do
    local player = minetest.get_player_by_name(pl_name)

    if player:get_meta():get_int("noclip") == 2 then
      local privs = minetest.get_player_privs(pl_name)
      privs.noclip = true
      minetest.set_player_privs(pl_name, privs)
    end

    skywars.remove_HUD(arena, pl_name)
    skywars.remove_armor(player)
  end
end)



arena_lib.on_end("skywars", function(arena, players)
  for pl_name in pairs(arena.players) do
    local player = minetest.get_player_by_name(pl_name)
    
    if player:get_meta():get_int("noclip") == 2 then
      local privs = minetest.get_player_privs(pl_name)
      privs.noclip = true
      minetest.set_player_privs(pl_name, privs)
    end

    skywars.remove_armor(player)
    -- restore player's original speed
    player:set_physics_override({speed=arena.players[pl_name].speed})
    skywars.block_enderpearl(player, arena)
  end
end)



arena_lib.on_death("skywars", function(arena, pl_name, reason)
  local player = minetest.get_player_by_name(pl_name)

  if reason.type == "punch" then
    if reason.object ~= nil and reason.object:is_player() then
      local killer = reason.object:get_player_name()

      arena_lib.send_message_players_in_arena(arena, skywars_settings.prefix .. skywars.T("@1 was killed by @2", pl_name, killer))
      -- arena.HUDs[killer].players_killed[1] == HUD ID
      -- arena.HUDs[killer].players_killed[2] == players amount
      reason.object:hud_change(arena.HUDs[killer].players_killed[1], "text", tostring(arena.HUDs[killer].players_killed[2] + 1))
    end
  end

  if player:get_meta():get_int("noclip") == 2 then
    local privs = minetest.get_player_privs(pl_name)
    privs.noclip = true
    minetest.set_player_privs(pl_name, privs)
  end

  skywars.remove_armor(player)
  arena_lib.remove_player_from_arena(pl_name, 1)
  skywars.update_players_counter(arena)
end)



arena_lib.on_quit("skywars", function(arena, pl_name)
  local player = minetest.get_player_by_name(pl_name)

  if player:get_meta():get_int("noclip") == 2 then
    local privs = minetest.get_player_privs(pl_name)
    privs.noclip = true
    minetest.set_player_privs(pl_name, privs)
  end

  skywars.update_players_counter(arena, false)
  skywars.remove_HUD(arena, pl_name)
  skywars.remove_armor(player)
  skywars.block_enderpearl(player, arena)
end)



arena_lib.on_disconnect("skywars", function(arena, pl_name)
  local player = minetest.get_player_by_name(pl_name)

  if player:get_meta():get_int("noclip") == 2 then
    local privs = minetest.get_player_privs(pl_name)
    privs.noclip = true
    minetest.set_player_privs(pl_name, privs)
  end

  skywars.update_players_counter(arena, false)
  skywars.remove_armor(player)
end)



arena_lib.on_kick("skywars", function(arena, pl_name) 
  local player = minetest.get_player_by_name(pl_name)

  if player:get_meta():get_int("noclip") == 2 then
    local privs = minetest.get_player_privs(pl_name)
    privs.noclip = true
    minetest.set_player_privs(pl_name, privs)
  end

  skywars.update_players_counter(arena, false)
  skywars.remove_HUD(arena, pl_name)
  skywars.remove_armor(player)
  skywars.block_enderpearl(player, arena)
end)



arena_lib.on_enable("skywars", function(arena, pl_name)
  if arena.treasures[1] == nil then
    skywars.print_error(pl_name, skywars.T("You didn't set the treasures!"))
    return false
  elseif arena.chests[1] == nil then
    skywars.print_error(pl_name, skywars.T("You didn't set the chests!"))
    return false
  elseif arena.pos1.x == nil or arena.pos2.x == nil then
    skywars.print_error(pl_name, skywars.T("You didn't set the map corners!"))
    return false
  end

  return true
end)



arena_lib.on_timer_tick("skywars", function(arena)
  arena.time_passed = arena.time_passed + 1

  if arena.time_passed % 5 == 0 then
    skywars.kill_players_out_map(arena)
  end
end)



arena_lib.on_timeout("skywars", function(arena)
  arena_lib.load_celebration("skywars", arena, skywars.T("Nobody"))

  arena_lib.send_message_players_in_arena(arena, skywars_settings.prefix .. skywars.T("Time is out, the match is over!"))
end)