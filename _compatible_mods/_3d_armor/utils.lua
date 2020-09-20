local slot_type = {[0] = "feet", [1] = "legs", [2] = "torso", [3] = "head"}


local function move_armor_to_slot(player, armor_name)
    local armor_type = armor:get_element(armor_name)
    local slots = player:hud_get_hotbar_itemcount()
    local inv = player:get_inventory()

    -- if the armor is equal to one of the slot types then switch the items
    for i=0, 4 do
        if armor_type == slot_type[i] then
            local wielded_armor = inv:get_stack("main", slots-i)

            inv:set_stack("main", slots-i, ItemStack(armor_name))
            minetest.after(0, function() inv:set_stack("main", player:get_wield_index(), wielded_armor) end)
        end
    end
end



local function get_weared_armor(player)
    local pl_name, armor_inv = armor:get_valid_player(player, "[add_armor_inventory]")
    local weared_armor = {} -- "type" = "armor"

    -- Stores the weared armor types and items  
    for i=1, armor_inv:get_size("armor") do
        local item_name = armor_inv:get_stack("armor", i):get_name()
        local type = armor:get_element(item_name)

        if type ~= nil then
            weared_armor[type] = item_name
        end
    end

    return weared_armor 
end



function skywars.add_armor(player, armor_name, update_slots)
    local pl_name, armor_inv = armor:get_valid_player(player, "[add_armor_inventory]")

    if not pl_name then
        return
    elseif armor:get_element(armor_name) == nil then
        return
    end

    local weared_armor = get_weared_armor(player)
    local armor_type = armor:get_element(armor_name) -- (the type is called element by 3d_armor)

    -- Checks if there's an armor with this type already
    if weared_armor[armor_type] ~= nil then
        armor_inv:remove_item("armor", ItemStack(weared_armor[armor_type]))
    end
    armor_inv:add_item("armor", ItemStack(armor_name))
    if update_slots == nil or update_slots then move_armor_to_slot(player, armor_name) end
    
    armor:set_player_armor(player)
    armor:save_armor_inventory(player)
end



function skywars.remove_all_armor(player)
    local name, armor_inv = armor:get_valid_player(player, "[remove_all]")
    
	if not name then
		return
    end
    
	armor_inv:set_list("armor", {})
	armor:set_player_armor(player)
    armor:save_armor_inventory(player)
end



function skywars.remove_armor(player, armor_name)
    local pl_name, armor_inv = armor:get_valid_player(player, "[add_armor_inventory]")

    if not pl_name then
        return
    elseif armor:get_element(armor_name) == nil then
        return
    end

    armor_inv:remove_item("armor", ItemStack(armor_name))
    
    armor:set_player_armor(player)
    armor:save_armor_inventory(player)
end



function skywars.apply_armor_slots(player)
    local name, armor_inv = armor:get_valid_player(player, "[apply_slots]")
	if not name then return end
    local slots = player:hud_get_hotbar_itemcount()
    local inv = player:get_inventory()
    local weared_armor = get_weared_armor(player)  -- "type" = "armor"
    local function get_armor_type(slot_offset) return armor:get_element(inv:get_stack("main", slots-slot_offset):get_name()) end
    
    -- iterate over each armor slot
    for slot = 0, 4 do
        -- if the slot is empty remove that armor type, otherwise add the armor that it contains
        if get_armor_type(slot) == nil and weared_armor[slot_type[slot]] ~= nil then
            skywars.remove_armor(player, weared_armor[slot_type[slot]])
        -- if the slot contains an armor and it is the same as the slot type equip it
        elseif get_armor_type(slot) ~= nil and get_armor_type(slot) == slot_type[slot] then
            skywars.add_armor(player, inv:get_stack("main", slots-slot):get_name(), false)
        end
    end
    
end