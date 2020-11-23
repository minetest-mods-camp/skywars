dofile(minetest.get_modpath("skywars") .. "/SETTINGS.lua")
skywars = {}
skywars.T = minetest.get_translator("skywars")
local disabled_damage_types_ = {}


if skywars_settings.fall_damage_disabled then
  disabled_damage_types_ = {"fall"}
end

arena_lib.register_minigame("skywars", {
  prefix = skywars_settings.prefix,
  join_while_in_progress = false,
  celebration_time = skywars_settings.celebration_time,
  load_time = skywars_settings.loading_time,
  temp_properties = {
    HUDs = {},
    players_original_amount = 0,
  },
  properties = {
    chests = {},
    treasures = {}, -- Items to put in the chests.
    min_pos = {},
    max_pos = {},
    kits = {},
    is_resetting = false
  },
  time_mode = 2,
  disabled_damage_types = disabled_damage_types_
})



dofile(minetest.get_modpath("skywars") .. "/chatcmdbuilder.lua")
dofile(minetest.get_modpath("skywars") .. "/utils.lua")
dofile(minetest.get_modpath("skywars") .. "/_tests/map_reset.lua")
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
