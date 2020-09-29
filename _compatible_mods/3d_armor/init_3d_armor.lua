minetest.register_on_joinplayer(function(player)
    if skywars_settings.remove_armors_on_join and minetest.get_modpath("3d_armor") then
      minetest.after(4, function() armor:remove_all(player) end)
    end
end)



function skywars.remove_armor(player)
    if minetest.get_modpath("3d_armor") then
        armor:remove_all(player)
    end
end
