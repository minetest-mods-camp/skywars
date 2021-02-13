local function add_privs() end
local function remove_privs() end
local function create_barrier_cage() end
local function keep_teleporting() end
local function drop_items() end
local update_timer_hud = skywars.update_timer_hud
local kill_players_out_map = skywars.kill_players_out_map
local add_node = minetest.add_node
local get_node = minetest.get_node
local remove_node = minetest.remove_node


minetest.register_on_joinplayer(function(player)
  remove_privs(player:get_player_name())
end)



arena_lib.on_load("skywars", function(arena)
  skywars.reset_map(arena)

  for pl_name in pairs(arena.players) do
    local player = minetest.get_player_by_name(pl_name)

    create_barrier_cage(player)
    player:get_inventory():add_item("main", "skywars:kit_selector")
  end

  arena_lib.HUD_send_msg_all(
    "broadcast", 
    arena, 
    skywars.T("Select a kit using the item in your inventory"), 
    skywars_settings.loading_time
  )
end)



arena_lib.on_start("skywars", function(arena)
  arena.players_original_amount = arena.players_amount
  arena.match_id = math.random(1, 9999999999)

  skywars.place_chests(arena)

  for pl_name in pairs(arena.players) do
    local player = minetest.get_player_by_name(pl_name)

    minetest.sound_play("sw_start", {to_player = pl_name})
    add_privs(pl_name)
    skywars.generate_HUD(arena, pl_name)
    player:set_physics_override({
      speed = skywars_settings.player_speed, 
      gravity=1,
      jump=1
    })
    skywars.activate_enderpearl(player, arena)
    player:get_inventory():remove_item("main", "skywars:kit_selector")
  end
end)



arena_lib.on_celebration("skywars", function(arena, winner_name)
  for pl_name in pairs(arena.players) do
    local player = minetest.get_player_by_name(pl_name)
    
    minetest.sound_play("sw_win", {to_player = pl_name})
    remove_privs(pl_name)
    skywars.block_enderpearl(player, arena)
  end

  skywars.reset_map(arena)
end)



arena_lib.on_end("skywars", function(arena, players)
  for pl_name in pairs(players) do
    local player = minetest.get_player_by_name(pl_name)
    
    remove_privs(pl_name) 
    skywars.remove_HUD(arena, pl_name)
    skywars.remove_armor(player)
  end
end)



arena_lib.on_death("skywars", function(arena, pl_name, reason)
  local player = minetest.get_player_by_name(pl_name)

  if reason.type == "punch" then
    if reason.object and reason.object:is_player() then
      local killer = reason.object:get_player_name()
      local killer_health = reason.object:get_hp()

      arena_lib.send_message_in_arena(arena, "players", skywars_settings.prefix .. skywars.T("@1 was killed by @2", pl_name, killer))
      skywars.print_msg(pl_name, skywars.T("@1 killed you with @2 HPs", killer, killer_health))
      skywars.increment_players_killed(killer)
    end
  end

  for pl_name, _ in pairs(arena.players) do
    minetest.sound_play("sw_pl_dead", {to_player = pl_name})
  end

  drop_items(player)
  skywars.block_enderpearl(player, arena)
  skywars.remove_armor(player)
  arena_lib.remove_player_from_arena(pl_name, 1)
  skywars.update_players_counter(arena)
end)



arena_lib.on_prequit("skywars", function(arena, pl_name)
  if arena.in_loading then
    return false
  else
    return true
  end
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
  local fast_enable = pl_name:find("@")
  local arena_lib_translator = minetest.get_translator("arena_lib")
  pl_name = pl_name:gsub("@", "")

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
  
  if not fast_enable then
    skywars.print_msg(pl_name, skywars.T("The enabling process may take a few moments, please wait..."))
    skywars.save_nodes_with_inventories(arena)
  else
    -- arena_lib, usually, sends this message using pl_name passed in the enable function.
    -- but, since there's a "@" at the end of it, it won't get recognized.
    skywars.print_msg(pl_name, arena_lib_translator("Arena @1 successfully enabled", arena.name))
  end

  return true
end)



arena_lib.on_disable("skywars", function(arena, pl_name)
  if arena.is_resetting then 
    skywars.print_error(pl_name, skywars.T("@1 is being reset!", arena.name))
    return false
  end
  
  return true
end)



arena_lib.on_time_tick("skywars", function(arena)
  kill_players_out_map(arena)
  update_timer_hud(arena)
end)



arena_lib.on_timeout("skywars", function(arena)
  arena_lib.load_celebration("skywars", arena, skywars.T("Nobody"))
  arena_lib.send_message_in_arena(arena, "players", skywars_settings.prefix .. skywars.T("Time is out, the match is over!"))
end)



function add_privs(pl_name)
  local privs = minetest.get_player_privs(pl_name)
  local player = minetest.get_player_by_name(pl_name)
  
  -- Preventing players with noclip to fall when placing nodes.
  if privs.noclip then
    player:get_meta():set_string("sw_can_noclip", "true")
    privs.noclip = nil
  else
    player:get_meta():set_string("sw_can_noclip", "false")
  end

  privs[skywars_settings.build_permission] = true

  minetest.set_player_privs(pl_name, privs)
end



function remove_privs(pl_name)
  local privs = minetest.get_player_privs(pl_name)
  local player = minetest.get_player_by_name(pl_name)

  if player:get_meta():get_string("sw_can_noclip") == "true" then
    privs.noclip = true
  end
  if not privs.server and not privs["privs"] then
    privs[skywars_settings.build_permission] = nil
  end

  minetest.set_player_privs(pl_name, privs)
end



function create_barrier_cage(player)
  minetest.after(0.1, function()
    local original_pos = player:get_pos()
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
      local node_pos = vector.round(vector.add(original_pos, relative_pos))

      if get_node(node_pos).name == "air" then 
        add_node(node_pos, {name="skywars:barrier"})
        minetest.after(skywars_settings.loading_time, function()         
          remove_node(node_pos)
        end)
      end
    end

    keep_teleporting(player, original_pos, skywars_settings.loading_time-1)
  end)
end



function drop_items(player)
  local inv = player:get_inventory():get_list("main")
  local noise = 2

  for i, itemstack in pairs(inv) do
    local pl_pos = player:get_pos()
    local random_x = pl_pos.x + math.random() + math.random(-noise-1, noise-1)
    local random_z = pl_pos.z + math.random() + math.random(-noise-1, noise-1)
    local random_pos = {
      x = random_x, 
      y = pl_pos.y,
      z = random_z
    }

    minetest.item_drop(itemstack, player, random_pos)
  end
end



function keep_teleporting(player, pos, seconds, current_second)
  local step = 2
  current_second = current_second or 1

  if current_second > seconds then return end

  minetest.after(step, function()
    player:add_player_velocity(vector.multiply(player:get_player_velocity(), -1))
    player:set_pos(pos)
    keep_teleporting(player, pos, seconds, current_second + step)
  end)
end
