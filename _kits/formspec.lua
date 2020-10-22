local function select_kit() end
local function create_formspec() end


function skywars.show_kit_selector(pl_name, arena)
    if #arena.kits == 0 then return end
    minetest.show_formspec(pl_name, "skywars:kit_selector", create_formspec(arena))
end



minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "skywars:kit_selector" then
        return
    end

    local pl_name = player:get_player_name()
    local arena = arena_lib.get_arena_by_player(pl_name)
    local kits = skywars.load_table("kits") 

    -- if the pressed button's name is equal to one of the kits in the arena then select it
    for i=1, #arena.kits do
        local kit_name = arena.kits[i]
        if fields[kit_name] then
            select_kit(pl_name, kits[kit_name].items)
            minetest.close_formspec(pl_name, "skywars:kit_selector")
        end
    end
end)



function select_kit(pl_name, kit_items)
    local player_inv = minetest.get_player_by_name(pl_name):get_inventory()

    for i=1, #kit_items do
        player_inv:add_item("main", ItemStack(kit_items[i]))
    end
    minetest.sound_play("sw_kit_selector", { pos = minetest.get_player_by_name(pl_name):get_pos(), to_player = pl_name })
end



function create_formspec(arena)
    local formspec = {
        "formspec_version[3]",
        "size["..skywars_settings.background_width..","..skywars_settings.background_height.."]",
        "position[0.5, 0.5]",
        "anchor[0.5,0.5]",
        "no_prepend[]",
        "bgcolor[#00000000;]",
        "background[0,0;1,1;"..skywars_settings.hud__kit_background..";true]",
        "style_type[image_button;border=false]"
    }
    local buttons_per_row = skywars_settings.buttons_per_row
    local distance_x = skywars_settings.distance_x
    local distance_y = skywars_settings.distance_y
    local offset_x = 0
    local offset_y = 0
    local kits = skywars.load_table("kits") 

    -- generates the formspec buttons
    for i=1, #arena.kits do
        local name = arena.kits[i]
        local x = skywars_settings.starting_x + offset_x
        local y = skywars_settings.starting_y + offset_y

        if kits[name] == nil then
            minetest.log("error", "[Skywars] The arena " .. arena.name .. " is trying to show a kit called " .. name .. ", but it doesn't exist!")
            goto continue
        end

        local kit_items = "" 
        if kits[name].items and kits[name].items[1] then
            -- if offset_x has reached its maximum amount then reset it and increase offset_y
            if offset_x == distance_x * (buttons_per_row-1) then 
                offset_y = offset_y + distance_y
                offset_x = 0
            else
                offset_x = offset_x + distance_x
            end 

            -- generating the kit description (a list of all the items in the kit) 
            for j=1, #kits[name].items do
                local item_name = kits[name].items[j].name

                -- if the string is "mod:item_name" it becomes "item name"
                if string.match(item_name, ":") then
                    local split_name = string.split(item_name, ":")
                    item_name = string.gsub(split_name[2], "_", " ")
                end
                kit_items = kit_items .. "x" .. kits[name].items[j].count .. " " .. item_name .. "\n"
            end

            table.insert(formspec, "image_button["..x..","..y..";"..skywars_settings.buttons_width..","..skywars_settings.buttons_height..";" ..kits[name].texture.. ";"..name..";]")
            table.insert(formspec, "tooltip["..name..";"..minetest.formspec_escape(kit_items).."]")
        end
        
        ::continue::
    end 

    return table.concat(formspec, "")
end