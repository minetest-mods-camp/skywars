dofile(minetest.get_modpath("skywars") .. "/SETTINGS.lua")

skywars = {}
skywars.T = minetest.get_translator("skywars")


local disabled_damage_types_ = {}
if skywars_settings.fall_damage_disabled then
  disabled_damage_types_ = {"fall"}
end

arena_lib.register_minigame("skywars", {
  prefix = skywars_settings.prefix,
  hub_spawn_point = skywars_settings.hub_spawn_point,
  join_while_in_progress = false,
  celebration_time = skywars_settings.celebration_time,
  load_time = skywars_settings.loading_time,
  queue_waiting_time = skywars_settings.queue_waiting_time,
  temp_properties = {
    HUDs = {},
    -- the original amount of players in the arena
    match_players = 0,
  },
  properties = {
    chests = {},
    treasures = {}, -- items to put in the chests
    pos1 = {},
    pos2 = {},
    kits = {}
  },
  time_mode = 2,
  disabled_damage_types = disabled_damage_types_
})



dofile(minetest.get_modpath("skywars") .. "/chatcmdbuilder.lua")
dofile(minetest.get_modpath("skywars") .. "/_compatible_mods/enderpearl/init_enderpearl.lua")
dofile(minetest.get_modpath("skywars") .. "/_compatible_mods/3d_armor/init_3d_armor.lua")
dofile(minetest.get_modpath("skywars") .. "/_storage/storage_manager.lua")
dofile(minetest.get_modpath("skywars") .. "/_hud/hud_manager.lua")
dofile(minetest.get_modpath("skywars") .. "/commands.lua")
dofile(minetest.get_modpath("skywars") .. "/_chest_handler/chest_setter.lua")
dofile(minetest.get_modpath("skywars") .. "/_chest_handler/treasures.lua")
dofile(minetest.get_modpath("skywars") .. "/_map_handler/map_manager.lua")
dofile(minetest.get_modpath("skywars") .. "/_arena_lib/arena_callbacks.lua")
dofile(minetest.get_modpath("skywars") .. "/_kits/formspec.lua")



---------------
-- ! UTILS ! --
---------------

function skywars.print_error(player, msg)
  minetest.chat_send_player(player, minetest.colorize("#e6482e", skywars_settings.prefix .. msg))
end



function skywars.print_msg(player, msg)
  minetest.chat_send_player(player, skywars_settings.prefix .. msg)
end



function skywars.get_arena_by_pos(pos)
  for i, arena in pairs(arena_lib.mods["skywars"].arenas) do
    if arena.pos1.x == nil or arena.pos2.x == nil then 
      minetest.log("Arena " .. arena.name .. " corners not set")
      goto continue 
    end
    
    reorder_positions(arena.pos1, arena.pos2)
    local map_area = VoxelArea:new{MinEdge = arena.pos1, MaxEdge = arena.pos2}

    minetest.log("Arena " .. arena.name .. " corners: " .. minetest.pos_to_string(arena.pos1, 1) .. " " .. minetest.pos_to_string(arena.pos2, 1))

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