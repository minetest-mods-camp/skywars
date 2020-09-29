function skywars.block_enderpearl(player, arena)
    if minetest.get_modpath("enderpearl") ~= "" and minetest.get_modpath("enderpearl") ~= nil then
        enderpearl.block_teleport(player, skywars_settings.celebration_time + 10)
    end
end
