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

    -- If the pressed button name is equal to one of the kits in the arena then select it.
    for i = 1, #arena.kits do
        local kit_name = arena.kits[i]
        if fields[kit_name] then
            select_kit(pl_name, kits[kit_name])
            minetest.close_formspec(pl_name, "skywars:kit_selector")
        end
    end
end)



function select_kit(pl_name, kit)
    local player_inv = minetest.get_player_by_name(pl_name):get_inventory()

    for i=1, #kit.items do
        player_inv:add_item("main", ItemStack(kit.items[i]))
    end
    minetest.sound_play("sw_kit_selector", {pos = minetest.get_player_by_name(pl_name):get_pos(), to_player = pl_name})
end



function create_formspec(arena)
    local settings = skywars_settings
    local formspec = {
        "formspec_version[3]",
        "size["..settings.background_width..","..settings.background_height.."]",
        "position[0.5, 0.5]",
        "anchor[0.5,0.5]",
        "no_prepend[]",
        "bgcolor[#00000000;]",
        "background[0,0;1,1;"..settings.hud_kit_background..";true]",
        "style_type[image_button;border=false]"
    }
    local buttons_per_row = settings.buttons_per_row
    local distance_x = settings.distance_x
    local distance_y = settings.distance_y
    local offset_x = 0
    local offset_y = 0
    local kits = skywars.load_table("kits") 

    -- Generates the formspec buttons.
    for i=1, #arena.kits do
        local kit_name = arena.kits[i]
        local kit = kits[kit_name]
        local x = settings.starting_x + offset_x
        local y = settings.starting_y + offset_y
        local kit_items = "" 

        if not kit then
            minetest.log(
                "error", 
                "[Skywars] The arena " .. arena.name .. " is trying to show a kit called " .. kit_name .. ", but it doesn't exist!"
            )
            goto continue
        end

        if kit.items and kit.items[1] then
            -- If offset_x has reached its maximum amount then reset it and increase offset_y.
            if offset_x == distance_x * (buttons_per_row-1) then 
                offset_y = offset_y + distance_y
                offset_x = 0
            else
                offset_x = offset_x + distance_x
            end 

            -- Generating the kit description (a list of all the items in the kit).
            for j = 1, #kit.items do
                local item_name = kit.items[j].name

                -- If the string is "mod:item_name" it becomes "item name".
                if string.match(item_name, ":") then
                    local split_name = string.split(item_name, ":")
                    item_name = string.gsub(split_name[2], "_", " ")
                end
                kit_items = kit_items.."x"..kit.items[j].count.." ".. item_name.."\n"
            end

            table.insert(formspec, "image_button["..x..","..y..";"..settings.buttons_width..","..settings.buttons_height..";" .. kit.texture.. ";"..kit_name..";]")
            table.insert(formspec, "tooltip["..kit_name..";"..minetest.formspec_escape(kit_items).."]")
        end
        
        ::continue::
    end 

    return table.concat(formspec, "")
end