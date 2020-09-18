minetest.register_on_mods_loaded(function()
    local mod_exists = false

    for i=1, #minetest.get_modnames() do
        if minetest.get_modnames()[i] == "3d_armor" then 
            mod_exists = true
            break
        end
    end

    if mod_exists then
        dofile(minetest.get_modpath("skywars") .. "/_compatible_mods/_3d_armor/utils.lua")
        dofile(minetest.get_modpath("skywars") .. "/_compatible_mods/_3d_armor/hotbar.lua")
        dofile(minetest.get_modpath("skywars") .. "/_compatible_mods/_3d_armor/armors.lua")
    end
end)