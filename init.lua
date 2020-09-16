dofile(minetest.get_modpath("skywars") .. "/SETTINGS.lua")

skywars = {}
skywars.T = minetest.get_translator("skywars")

arena_lib.register_minigame("skywars", {
  prefix = skywars_settings.prefix,
  hub_spawn_point = skywars_settings.hub_spawn_point,
  join_while_in_progress = false,
  celebration_time = skywars_settings.celebration_time,
  loading_time = skywars_settings.loading_time,
  queue_waiting_time = skywars_settings.queue_waiting_time,
  temp_properties = {
    HUDs = {},
    match_players = 0,
    time_passed = 0
  },
  properties = {
    chests = {},
    treasures = {}, -- items to put in the chests
    schematic = "",
    pos1 = {},
    pos2 = {},
    reset = false,
    kits = {}
  },
  player_properties = {
    speed = skywars_settings.player_speed
  },
  timer = skywars_settings.timer
})



dofile(minetest.get_modpath("skywars") .. "/chatcmdbuilder.lua")
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
