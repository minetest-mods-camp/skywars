local function add_privs() end
local function remove_privs() end
local function create_glass_cage() end


minetest.register_on_joinplayer(function(player)
  remove_privs(player:get_player_name())
end)



arena_lib.on_load("skywars", function(arena)
  skywars.load_mapblocks(arena)
  skywars.reset_map(arena)

  for pl_name in pairs(arena.players) do
    local player = minetest.get_player_by_name(pl_name)

    skywars.show_kit_selector(pl_name, arena)
    create_glass_cage(player)
  end
end)



arena_lib.on_start("skywars", function(arena)
  arena.players_original_amount = arena.players_amount

  skywars.reset_map(arena)
  skywars.place_chests(arena)

  for pl_name in pairs(arena.players) do
    local player = minetest.get_player_by_name(pl_name)

    add_privs(pl_name)
    skywars.generate_HUD(arena, pl_name)
    player:set_physics_override({
      speed = skywars_settings.player_speed, 
      gravity=1, 
      jump=1
    })
    skywars.activate_enderpearl(player, arena)
  end
end)



arena_lib.on_celebration("skywars", function(arena, winner_name)
  for pl_name in pairs(arena.players) do
    local player = minetest.get_player_by_name(pl_name)

    remove_privs(pl_name)
    skywars.remove_HUD(arena, pl_name)
    skywars.remove_armor(player)
  end
end)



arena_lib.on_end("skywars", function(arena, players)
  for pl_name in pairs(arena.players) do
    local player = minetest.get_player_by_name(pl_name)
    
    remove_privs(pl_name)
    skywars.remove_armor(player)
    skywars.block_enderpearl(player, arena)
  end

  skywars.reset_map(arena)
end)



arena_lib.on_death("skywars", function(arena, pl_name, reason)
  local player = minetest.get_player_by_name(pl_name)

  if reason.type == "punch" then
    if reason.object and reason.object:is_player() then
      local killer = reason.object:get_player_name()

      arena_lib.send_message_players_in_arena(arena, skywars_settings.prefix .. skywars.T("@1 was killed by @2", pl_name, killer))
      arena.HUDs[killer].players_killed.amount = arena.HUDs[killer].players_killed.amount + 1 
      reason.object:hud_change(arena.HUDs[killer].players_killed.id, "text", tostring(arena.HUDs[killer].players_killed.amount))
    end
  end

  remove_privs(pl_name)

  skywars.remove_armor(player)
  arena_lib.remove_player_from_arena(pl_name, 1)
  skywars.update_players_counter(arena)
end)



arena_lib.on_quit("skywars", function(arena, pl_name)
  local player = minetest.get_player_by_name(pl_name)

  remove_privs(pl_name)

  skywars.update_players_counter(arena, false)
  skywars.remove_HUD(arena, pl_name)
  skywars.remove_armor(player)
  skywars.block_enderpearl(player, arena)
end)



arena_lib.on_disconnect("skywars", function(arena, pl_name)
  local player = minetest.get_player_by_name(pl_name)
  skywars.update_players_counter(arena, false)
end)



arena_lib.on_kick("skywars", function(arena, pl_name) 
  local player = minetest.get_player_by_name(pl_name)

  remove_privs(pl_name)
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
  elseif arena.min_pos.x == nil or arena.max_pos.x == nil then
    skywars.print_error(pl_name, skywars.T("You didn't set the map corners!"))
    return false
  end

  return true
end)



arena_lib.on_timer_tick("skywars", function(arena)
  if arena.current_time % 3 == 0 then
    skywars.kill_players_out_map(arena)
  end
end)



arena_lib.on_timeout("skywars", function(arena)
  arena_lib.load_celebration("skywars", arena, skywars.T("Nobody"))
  arena_lib.send_message_players_in_arena(arena, skywars_settings.prefix .. skywars.T("Time is out, the match is over!"))
end)



function add_privs(pl_name)
  local privs = minetest.get_player_privs(pl_name)
  local player = minetest.get_player_by_name(pl_name)
  
  -- preventing players with noclip to fall when placing nodes
  if privs.noclip then
    player:get_meta():set_string("sw_can_noclip", "true")
    privs.noclip = nil
  else
    player:get_meta():set_string("sw_can_noclip", "false")
  end

  if skywars_settings.build_permission ~= "" then
    if privs[skywars_settings.build_permission] then
      player:get_meta():set_string("sw_can_build", "true")
    else 
      player:get_meta():set_string("sw_can_build", "false")
    end
    privs[skywars_settings.build_permission] = true
  end

  minetest.set_player_privs(pl_name, privs)
end



function remove_privs(pl_name)
  local privs = minetest.get_player_privs(pl_name)
  local player = minetest.get_player_by_name(pl_name)

  if player:get_meta():get_string("sw_can_noclip") == "true" then
    privs.noclip = true
  end
  if player:get_meta():get_string("sw_can_build") == "false" then
    privs[skywars_settings.build_permission] = nil
  end

  minetest.set_player_privs(pl_name, privs)
end



function create_glass_cage(player)
  minetest.after(0.1, function()
    local pl_pos = player:get_pos()
    local glass_nodes = {
      {x = 0, y = -1, z = 0},
      {x = 0, y = -2, z = 0},
      {x = 1, y = 1, z = 0},
      {x = -1, y = 1, z = 0},
      {x = 0, y = 1, z = 1},
      {x = 0, y = 1, z = -1},
      {x = 0, y = 2, z = 0}
    }

    player:set_physics_override({gravity=0, jump=0})
    player:add_player_velocity(vector.multiply(player:get_player_velocity(), -1))

    for _, relative_pos in pairs(glass_nodes) do
      local node_pos = vector.round(vector.add(pl_pos, relative_pos))
      if minetest.get_node(node_pos).name == "air" then 
        minetest.add_node(node_pos, {name="default:glass"})
      end
    end
    
    -- teleports the player back in the glass
    minetest.after(1, function()
      player:set_pos(pl_pos)
    end)
    minetest.after(2, function()
      player:set_pos(pl_pos)
    end)
  end)
end