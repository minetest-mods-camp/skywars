for name in pairs(minetest.registered_items) do
    if armor:get_element(name) ~= nil then
        minetest.override_item(name, {
            on_secondary_use = function(itemstack, user)
                local pl_name = user:get_player_name()
                local arena
                if arena_lib.is_player_in_arena(pl_name, "skywars") and arena_lib.get_arena_by_player(pl_name).in_loading == false then
                    skywars.add_armor(minetest.get_player_by_name(pl_name), itemstack:get_name())
                end
            end
        })
    end
end