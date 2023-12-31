dofile(minetest.get_modpath("skywars") .. "/SETTINGS.lua")
skywars = {}
skywars.T = minetest.get_translator("skywars")
local disabled_damage_types_ = {}


if skywars_settings.fall_damage_disabled then
  disabled_damage_types_ = {"fall"}
end

arena_lib.register_minigame("skywars", {
  name = "Skywars",
  icon = "skywars_icon.png",
  prefix = skywars_settings.prefix,
  join_while_in_progress = false,
  celebration_time = skywars_settings.celebration_time,
  load_time = skywars_settings.loading_time,
  temp_properties = {
    players_original_amount = 0,
    match_id = -1,
  },
  properties = {
    chests = {},
    treasures = {}, -- Items to put in the chests.
    min_pos = {},
    max_pos = {},
    kits = {},
    is_resetting = false,
    can_enter = true
  },
  can_build = true,
  time_mode = "decremental",
  disabled_damage_types = disabled_damage_types_
})



dofile(minetest.get_modpath("skywars") .. "/src/debug/debug_utils.lua")

dofile(minetest.get_modpath("skywars") .. "/src/queue.lua")

dofile(minetest.get_modpath("skywars") .. "/src/_storage/storage_manager.lua")
dofile(minetest.get_modpath("skywars") .. "/src/nodes.lua")
dofile(minetest.get_modpath("skywars") .. "/src/utils.lua")
dofile(minetest.get_modpath("skywars") .. "/src/_map_handler/map_utils.lua")
dofile(minetest.get_modpath("skywars") .. "/src/_map_handler/map_reset.lua")
dofile(minetest.get_modpath("skywars") .. "/src/_map_handler/map_saving.lua")
dofile(minetest.get_modpath("skywars") .. "/src/_map_handler/chests/chest_setter.lua")
dofile(minetest.get_modpath("skywars") .. "/src/_map_handler/chests/treasures.lua")
dofile(minetest.get_modpath("skywars") .. "/src/_compatible_mods/enderpearl/init_enderpearl.lua")
dofile(minetest.get_modpath("skywars") .. "/src/_compatible_mods/3d_armor/init_3d_armor.lua")
dofile(minetest.get_modpath("skywars") .. "/src/_hud/hud_manager.lua")
dofile(minetest.get_modpath("skywars") .. "/src/commands.lua")
dofile(minetest.get_modpath("skywars") .. "/src/_arena_lib/arena_callbacks.lua")
dofile(minetest.get_modpath("skywars") .. "/src/_kits/formspec.lua")
dofile(minetest.get_modpath("skywars") .. "/src/_kits/kit_items.lua")
dofile(minetest.get_modpath("skywars") .. "/src/_player/auto_equip_items.lua")
