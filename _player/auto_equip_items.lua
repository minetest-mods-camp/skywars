local function compare_items() end
local function get_item_importance() end
local function get_first_empty_slot() end
local on_punch = minetest.registered_entities["__builtin:item"].on_punch 


function skywars.auto_equip_item(player, picked_itemstack, picked_itemstack_slot)
    local inventory = player:get_inventory()
    local hotbar = inventory:get_list("main")

    for hotbar_slot, hotbar_itemstack in ipairs(hotbar) do
        if hotbar_slot > player:hud_get_hotbar_itemcount() or hotbar_itemstack:get_name() == "" then 
            break 
        end

        local picked_item_name = picked_itemstack:get_name()
        local hotbar_item_name = hotbar_itemstack:get_name()
        local best_item_name = compare_items(hotbar_item_name, picked_item_name)
        -- Returning if the picked item is in the hotbar already.
        if not picked_item_name == hotbar_item_name then return end

        if best_item_name == picked_item_name then
            local first_empty_slot = picked_itemstack_slot or get_first_empty_slot(hotbar)
            if not first_empty_slot then return end  -- Returning if the inventory is full.

            hotbar[hotbar_slot] = picked_itemstack
            hotbar[first_empty_slot] = hotbar_itemstack
            inventory:set_list("main", hotbar)
            
            return true
        end
    end
end



-- Applying the auto equip system when the player takes an item from an inventory.
minetest.register_on_player_inventory_action(function(player, action, inventory, inventory_info)
    local pl_name = player:get_player_name()

    if arena_lib.is_player_in_arena(pl_name, "skywars") then
        if action == "put" then
            local picked_itemstack = inventory_info.stack
            skywars.auto_equip_item(player, picked_itemstack, inventory_info.index)
        end
    end
end)



-- Applying the auto equip system when somenone punches on a drop.
minetest.registered_entities["__builtin:item"].on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
    local pos = self.object:get_pos()
    local pl_name = puncher:get_player_name()

    if arena_lib.is_player_in_arena(pl_name, "skywars") then
        local itemstack = ItemStack(self.itemstring)

        if skywars.auto_equip_item(puncher, itemstack) then
            self.object:remove()
            return
        end
    end

    on_punch(self, puncher, time_from_last_punch, tool_capabilities, dir)
end



function compare_items(item1, item2)
    local item1_category, item1_importance = get_item_importance(item1)
    local item2_category, item2_importance = get_item_importance(item2)

    if item1_category and item2_category then
        if item1_category == item2_category then
            if item1_importance > item2_importance then return item1
            elseif item1_importance < item2_importance then return item2 end
        end
    end
end



function get_item_importance(item_name)
    for category, importances in pairs(skywars_settings.items_importances) do
        local importance = importances[item_name]
        if importance then return category, importance end
    end
end



function get_first_empty_slot(list)
    for i, itemstack in ipairs(list) do
        if itemstack:get_name() == "" then return i end
    end
end