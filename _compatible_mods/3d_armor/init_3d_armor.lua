local function get_armor_importance() end


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



minetest.register_on_player_inventory_action(function(player, action, inventory, inventory_info)
    local pl_name = player:get_player_name()

    if minetest.get_modpath("3d_armor") and arena_lib.is_player_in_arena(pl_name, "skywars") then
        -- The armor that the player's taking.
        local armor_itemstack = inventory_info.stack
        if not armor_itemstack then return end
        local armor_name = armor_itemstack:get_name()
        -- The body part that the armor's assigned to, returns nil if it's not an armor.
        local armor_element = armor:get_element(armor_name)

        if action == "put" and armor_element then
            -- A table containing pairs of [armor_element : string] = armor_name : string.
            local player_armor_elements = armor:get_weared_armor_elements(player)
            local equipped_armor = player_armor_elements[armor_element]

            if equipped_armor then
                local armor_importance = get_armor_importance(armor_name)
                local weared_armor_importance = get_armor_importance(equipped_armor)
                -- Returning if the just taken armor is worse or as good as the equipped one.
                if armor_importance <= weared_armor_importance then return end
            end

            armor:equip(player, armor_itemstack)
            minetest.after(0, function() 
                inventory:remove_item("main", ItemStack(armor_name)) 
            end)
        end
    end
end)



function get_armor_importance(armor_name)
    local importance

    if (armor_name:match("wood")) then importance = 1
    elseif (armor_name:match("gold")) then importance = 2
    elseif (armor_name:match("bronze")) then importance = 3
    elseif (armor_name:match("steel")) then importance = 4
    elseif (armor_name:match("diamond")) then importance = 5
    end

    return importance
end