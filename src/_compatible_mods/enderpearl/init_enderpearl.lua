function skywars.block_enderpearl(player, arena)
    if minetest.get_modpath("enderpearl") then
        enderpearl.block_teleport(player, skywars_settings.celebration_time + 10)
    end
end



function skywars.activate_enderpearl(player, arena)
    if minetest.get_modpath("enderpearl") then
        enderpearl.block_teleport(player, 0)
    end
end