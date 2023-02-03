minetest.register_on_joinplayer(function(player)
    if skywars_settings.remove_armors_on_join and minetest.get_modpath("3d_armor") then
      minetest.after(5, function() armor:remove_all(player) end)
    end
end)



function skywars.remove_armor(player)
    if minetest.get_modpath("3d_armor") then
        armor:remove_all(player)
    end
end



dofile(minetest.get_modpath("skywars") .. "/src/_compatible_mods/3d_armor/auto_equip_armors.lua")