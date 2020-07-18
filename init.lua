skywars = {}

arena_lib.register_minigame("skywars", {
  prefix = "[Skywars] ",
  hub_spawn_point = { x = 8, y = 6, z = 4 },
  join_while_in_progress = false,
  celebration_time = 5,
  properties = {
    chests = {},
    treasures = {}, --items da mettere nelle chest
  },
  temp_properties = {
    kill_leader = "",
    first_blood = "",
  },
  player_properties = {
    killstreak = 0,
  }
})


dofile(minetest.get_modpath("skywars") .. "/chatcmdbuilder.lua")
dofile(minetest.get_modpath("skywars") .. "/commands.lua")
dofile(minetest.get_modpath("skywars") .. "/_chest_handler/chest_setter.lua")
dofile(minetest.get_modpath("skywars") .. "/_chest_handler/chest.lua")
dofile(minetest.get_modpath("skywars") .. "/_chest_handler/treasures.lua")
dofile(minetest.get_modpath("skywars") .. "/_map_handler/map_create.lua")
dofile(minetest.get_modpath("skywars") .. "/_map_handler/map_gen.lua")
dofile(minetest.get_modpath("skywars") .. "/_arena_lib/arena_manager.lua")
