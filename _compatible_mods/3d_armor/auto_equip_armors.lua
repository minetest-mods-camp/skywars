local function get_armor_importance() end
local on_punch = minetest.registered_entities["__builtin:item"].on_punch 


function skywars.auto_equip_armor(player, armor_itemstack)
    local armor_name = armor_itemstack:get_name()
    local armor_element = armor:get_element(armor_name)
    -- Returning if it isn't an armor.
    if not armor_element then return end
    -- A table containing pairs of [armor_element : string] = armor_name : string.
    local player_armor_elements = armor:get_weared_armor_elements(player)
    local equipped_armor = player_armor_elements[armor_element]
    local inventory = player:get_inventory()

    if equipped_armor then
        local armor_importance = get_armor_importance(armor_name)
        local weared_armor_importance = get_armor_importance(equipped_armor)

        if not armor_importance or not weared_armor_importance then return false end
    
        -- Returning if the just taken armor is worse or as good as the equipped one.
        if armor_importance <= weared_armor_importance then return end
    end

    armor:equip(player, armor_itemstack)

    return true 
end



-- Applying the auto equip system when the player takes an armor from an inventory.
minetest.register_on_player_inventory_action(function(player, action, inventory, inventory_info)
    local pl_name = player:get_player_name()

    if minetest.get_modpath("3d_armor") and arena_lib.is_player_in_arena(pl_name, "skywars") then
        if action == "put" then
            local armor_itemstack = inventory_info.stack
            local armor_name = armor_itemstack:get_name()
            if not armor_itemstack then return end

            if skywars.auto_equip_armor(player, armor_itemstack) then
                minetest.after(0, function() 
                    inventory:remove_item("main", ItemStack(armor_name)) 
                end)
            end
        end
    end
end)



-- Applying the auto equip system when somenone punches on a drop.
minetest.registered_entities["__builtin:item"].on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
    local pos = self.object:get_pos()
    local pl_name = puncher:get_player_name()
    local arena = skywars.get_arena_by_pos(pos)

    if minetest.get_modpath("3d_armor") and arena_lib.is_player_in_arena(pl_name, "skywars") then
        local item = ItemStack(self.itemstring)

        if skywars.auto_equip_armor(puncher, item) then
            self.object:remove()
            return
        end
    end

    on_punch(self, puncher, time_from_last_punch, tool_capabilities, dir)
end



function get_armor_importance(armor_name)
    for material, importance in pairs(skywars_settings.armors_importances) do
        if armor_name:find(material) then
            return importance
        end
    end
end