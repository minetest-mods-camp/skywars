local function get_valid_arena() end
local function get_looking_node_pos() end
local function from_chest_to_string() end
local function from_treasure_to_string() end
local function get_wielded_item() end


ChatCmdBuilder.new("skywars", function(cmd)
    cmd:sub("tutorial", function(sender)
        skywars.print_msg(sender, "You can read it from TUTORIAL.txt in the mod folder.")
    end)



    cmd:sub("create :arena", function(name, arena_name)
        local arena = get_valid_arena(arena_name, name)

        if not arena then return end

        arena_lib.create_arena(name, "skywars", arena.name)
    end)



    cmd:sub("create :arena :minplayers:int :maxplayers:int", function(name, arena_name, min_players, max_players)
        local arena = get_valid_arena(arena_name, name)

        if not arena then return end

        arena_lib.create_arena(name, "skywars", arena.name, min_players, max_players)
    end)



    cmd:sub("remove :arena", function(name, arena_name)
        local arena = get_valid_arena(arena_name, name)

        if not arena then return end

        arena_lib.remove_arena(name, "skywars", arena.name)
    end)

    
    
    cmd:sub("list", function(name)
        local arena = get_valid_arena(arena_name, name)

        if not arena then return end

        arena_lib.print_arenas(arena.name, "skywars")
    end)



    cmd:sub("info :arena", function(name, arena_name)
        local arena = get_valid_arena(arena_name, name)

        if not arena then return end

        arena_lib.print_arena_info(name, "skywars", arena.name)
    end)



    cmd:sub("setspawn :arena", function(name, arena_name)
        local arena = get_valid_arena(arena_name, name)

        if not arena then return end

        arena_lib.set_spawner(name, "skywars", arena.name)
    end)



    cmd:sub("setsign :arena", function(name, arena_name)
        local arena = get_valid_arena(arena_name, name)

        if not arena then return end

        arena_lib.set_sign(name, nil, nil, "skywars", arena.name)
    end)


    
    cmd:sub("edit :arena", function(name, arena_name)
        local arena = get_valid_arena(arena_name, name)

        if not arena then return end

        arena_lib.enter_editor(name, "skywars", arena.name)
    end)



    cmd:sub("enable :arena", function(name, arena_name)
        local arena = get_valid_arena(arena_name, name)

        if not arena then return end

        arena_lib.enable_arena(name, "skywars", arena.name)
    end)



    cmd:sub("disable :arena", function(name, arena_name)
        local arena = get_valid_arena(arena_name, name)

        if not arena then return end

        arena_lib.disable_arena(name, "skywars", arena.name)
    end)



    --------------------
    -- ! CHEST CMDS ! --
    --------------------

    cmd:sub("addtreasure :arena :treasure :count:int :preciousness:int :rarity:number", 
    function(sender, arena_name, treasure_name, count, preciousness, rarity)
        local arena, arena_name = get_valid_arena(arena_name, sender, true)
        
        if not arena then 
            return       
        elseif count < 1 then
            skywars.print_error(sender, skywars.T("Count has to be greater than 0!"))
            return
        elseif rarity < 1 or rarity > 10 then
            skywars.print_error(sender, skywars.T("Rarity has to be between 1 and 10!"))
            return
        elseif ItemStack(treasure_name):is_known() == false then
            skywars.print_error(sender, skywars.T("@1 doesn't exist!", treasure_name))
            return
        end

        local item_id = 1
        if arena.treasures[#arena.treasures] then item_id = arena.treasures[#arena.treasures].id+1 end
        local treasure = {
            name = treasure_name, 
            rarity = rarity, 
            count = count, 
            preciousness = preciousness, 
            id = item_id
        }
        table.insert(arena.treasures, treasure)

        arena_lib.change_arena_property(sender, "skywars", arena_name, "treasures", arena.treasures, false)
        skywars.print_msg(sender, "+ " .. from_treasure_to_string(treasure))

        skywars.reorder_treasures(arena)
    end)
    


    cmd:sub("addtreasure hand :arena :rarity:number :preciousness:int", 
    function(sender, arena_name, preciousness, rarity)
        local arena, arena_name = get_valid_arena(arena_name, sender, true)
        local wielded_itemstack = get_wielded_item(sender)
        local treasure = {}

        if not arena or not wielded_itemstack then 
            return
        elseif rarity < 1 or rarity > 10 then
            skywars.print_error(sender, skywars.T("Rarity has to be between 1 and 10!"))
            return
        end

        local item_id = 1
        if arena.treasures[#arena.treasures] then item_id = arena.treasures[#arena.treasures].id+1 end
        treasure = {
            name = wielded_itemstack.name, 
            rarity = rarity, 
            count = wielded_itemstack.count, 
            preciousness = preciousness, 
            id = item_id
        }
        table.insert(arena.treasures, treasure)

        arena_lib.change_arena_property(sender, "skywars", arena_name, "treasures", arena.treasures, false)
        skywars.print_msg(sender, "+ " .. from_treasure_to_string(treasure))

        skywars.reorder_treasures(arena)
    end)



    cmd:sub("removetreasure hand :arena", 
    function(sender, arena_name)
        local arena, arena_name = get_valid_arena(arena_name, sender, true)
        local found = {true, false} -- the first is used to repeat the for until nothing is found
        local wielded_itemstack = get_wielded_item(sender)

        if not arena or not wielded_itemstack then 
            return
        end

        while found[1] do
            found[1] = false
            for i, treasure in pairs(arena.treasures) do
                if treasure.name == wielded_itemstack.name then
                    table.remove(arena.treasures, i)
                    found[1] = true
                    found[2] = true
                end 
            end
        end
        arena_lib.change_arena_property(sender, "skywars", arena_name, "treasures", arena.treasures, false)

        if found[2] then skywars.print_msg(sender, skywars.T("@1 removed from @2!", wielded_itemstack.name, arena.name))
        else skywars.print_error(sender, skywars.T("Treasure not found!")) end

        skywars.reorder_treasures(arena)
    end)


    
    cmd:sub("removetreasure :arena :treasure", 
    function(sender, arena_name, treasure_name)
        local arena, arena_name = get_valid_arena(arena_name, sender, true)
        local found = {true, false} -- the first is used to repeat the for until nothing is found

        if not arena then 
            return
        end

        while found[1] do
            found[1] = false
            for i, treasure in pairs(arena.treasures) do
                if treasure.name == treasure_name then
                    table.remove(arena.treasures, i)
                    i = i-1
                    found[1] = true
                    found[2] = true
                end 
            end
        end
        arena_lib.change_arena_property(sender, "skywars", arena_name, "treasures", arena.treasures, false)

        if found[2] then skywars.print_msg(sender, skywars.T("@1 removed from @2!", treasure_name, arena_name))
        else skywars.print_error(sender, skywars.T("Treasure not found!")) end

        skywars.reorder_treasures(arena)
    end)



    cmd:sub("removetreasure id :arena :id:int", 
    function(sender, arena_name, treasure_id)
        local arena, arena_name = get_valid_arena(arena_name, sender, true)
        local treasure_name = ""

        if not arena then 
            return
        end

        for i=1, #arena.treasures do
            if arena.treasures[i].id == treasure_id then
                treasure_name = arena.treasures[i].name
                table.remove(arena.treasures, i)
                break
            end 
        end
        arena_lib.change_arena_property(sender, "skywars", arena_name, "treasures", arena.treasures, false)

        if treasure_name ~= "" then skywars.print_msg(sender, skywars.T("@1 removed from @2!", treasure_name, arena_name))
        else skywars.print_error(sender, skywars.T("Treasure not found!")) end

        skywars.reorder_treasures(arena)
    end)



    cmd:sub("copytreasures :fromarena :toarena", 
    function(sender, from, to)
        local from_arena, from = get_valid_arena(from, sender)
        local to_arena, to = get_valid_arena(to, sender, true)

        if not to_arena or not from_arena then
            return
        elseif from_arena == to_arena then
            skywars.print_error(sender, skywars.T("The arenas must be different!"))
            return
        end

        to_arena.treasures = table.copy(from_arena.treasures)

        arena_lib.change_arena_property(sender, "skywars", to, "treasures", to_arena.treasures, false)
        skywars.print_msg(sender, skywars.T("@1 treasures have been copied to @2!", from, to))
    end)



    cmd:sub("gettreasures :arena", 
    function(sender, arena_name)
        local arena = get_valid_arena(arena_name, sender)

        if not arena then 
            return
        end

        skywars.print_msg(sender, skywars.T("Treasures list:"))
        for i=1, #arena.treasures do
            skywars.print_msg(sender, from_treasure_to_string(arena.treasures[i]) .. "\n\n")
        end
    end)



    cmd:sub("searchtreasure :arena :treasure", 
    function(sender, arena_name, treasure_name)
        local arena, arena_name = get_valid_arena(arena_name, sender, true)

        if not arena then 
            return
        end

        skywars.print_msg(sender, skywars.T("Treasures list:"))
        for i=1, #arena.treasures do
            local treasure = arena.treasures[i]
            if treasure.name:match(treasure_name) then
                skywars.print_msg(sender, from_treasure_to_string(treasure)  .. "\n\n")
            end
        end
    end)



    cmd:sub("addchest :minpreciousness:int :maxpreciousness:int :tmin:int :tmax:int", 
    function(sender, min_preciousness, max_preciousness, min_treasures, max_treasures)
        local arena, arena_name = get_valid_arena("@", sender, true)
        local pos = get_looking_node_pos(sender)

        if not pos then 
            return
        elseif not arena then 
            return
        end

        local chest_id = 1
        if arena.chests[#arena.chests] then chest_id = arena.chests[#arena.chests].id+1 end
        local chest = 
        {
            pos = pos,
            min_preciousness = min_preciousness, 
            max_preciousness = max_preciousness,
            min_treasures = min_treasures,
            max_treasures = max_treasures,
            id = chest_id
        }

        if min_treasures <= 0 or max_treasures <= 0 then
            skywars.print_error(sender, skywars.T("The minimum or maximum amount of treasures has to be greater than 0!"))
            return
        end

        for i=1, #arena.chests do
            if vector.equals(arena.chests[i].pos, pos) then
                exists = true
                break
            end 
        end 

        if exists then
            skywars.print_error(sender, skywars.T("The chest already exists!"))
            return
        end
        skywars.print_msg(sender, "+ " .. from_chest_to_string(chest))

        table.insert(arena.chests, chest)
        arena_lib.change_arena_property(sender, "skywars", arena_name, "chests", arena.chests, false)
    end)



    cmd:sub("getchests :arena", 
    function(sender, arena_name)
        local arena = get_valid_arena(arena_name, sender)

        if not arena then 
            return
        end

        skywars.print_msg(sender, skywars.T("Chest list:"))
        for i=1, #arena.chests do
            skywars.print_msg(sender, from_chest_to_string(arena.chests[i]) .. "\n\n")
        end
    end) 
    

    
    cmd:sub("removechest", 
    function(sender)
        local arena, arena_name = get_valid_arena("@", sender, true)
        local found = false
        local pos = get_looking_node_pos(sender)

        if not pos then 
            return
        elseif not arena then 
            return
        end

        for i=1, #arena.chests do
            if vector.equals(arena.chests[i].pos, pos) then
                table.remove(arena.chests, i)
                found = true
                break
            end 
        end
        arena_lib.change_arena_property(sender, "skywars", arena_name, "chests", arena.chests, false)

        if found then
            skywars.print_msg(sender, skywars.T("Chest removed!"))
        else
            skywars.print_error(sender, skywars.T("Chest not found!"))
        end
    end)



    cmd:sub("inspect", 
    function(sender)
        local arena, arena_name = get_valid_arena("@", sender)
        local found = false
        local pos = get_looking_node_pos(sender)

        if not pos then 
            return
        elseif not arena then 
            return
        end

        for i=1, #arena.chests do
            local chest = arena.chests[i]
            if vector.equals(chest.pos, pos) then
                skywars.print_msg(sender, from_chest_to_string(chest) .. "\n\n")
                found = true
                break
            end 
        end

        if not found then
            skywars.print_error(sender, skywars.T("Chest not found!"))
        end
    end)



    cmd:sub("removechest id :arena :id:int", 
    function(sender, arena_name, chest_id)
        local arena, arena_name = get_valid_arena(arena_name, sender, true)
        local found = false
        
        if not arena then 
            return
        end

        for i=1, #arena.chests do
            if arena.chests[i].id == id then
                table.remove(arena.chests, i)
                found = true
                break
            end 
        end
        arena_lib.change_arena_property(sender, "skywars", arena_name, "chests", arena.chests, false)

        if found then
            skywars.print_msg(sender, skywars.T("Chest removed!"))
        else
            skywars.print_error(sender, skywars.T("Chest not found!"))
        end
    end)



    -------------------
    -- ! KITS CMDS ! --
    -------------------

    cmd:sub("createkit :name :texture", 
    function(sender, kit_name, texture)
        local kits = skywars.load_table("kits")

        if kits[kit_name] then
            skywars.print_error(sender, skywars.T("@1 already exists!", kit_name))
            return
        end

        kits[kit_name] = {texture = texture, items={}}
        skywars.overwrite_table("kits", kits) 

        skywars.print_msg(sender, skywars.T("Kit @1 created!", kit_name))
    end)



    cmd:sub("additem :kit :item :count:int", 
    function(sender, kit_name, item_name, item_count)
        local kits = skywars.load_table("kits")
        local itemstack = {}

        if ItemStack(item_name):is_known() == false then
            skywars.print_error(sender, skywars.T("@1 doesn't exist!", item_name))
            return
        elseif kits[kit_name] == nil then
            skywars.print_error(sender, skywars.T("@1 doesn't exist!", kit_name))
            return
        elseif item_count <= 0 then
            skywars.print_error(sender, skywars.T("Count has to be greater than 0!"))
            return
        end
        
        itemstack.name = item_name
        itemstack.count = item_count

        table.insert(kits[kit_name].items, itemstack)
        skywars.overwrite_table("kits", kits) 
        
        skywars.print_msg(sender, skywars.T("@1 added to @2!", item_name, kit_name))
    end)



    cmd:sub("additem hand :kit", 
    function(sender, kit_name)
        local kits = skywars.load_table("kits")
        local wielded_itemstack = get_wielded_item(sender)

        if not wielded_itemstack then 
            return
        elseif kits[kit_name] == nil then
            skywars.print_error(sender, skywars.T("@1 doesn't exist!", kit_name))
            return
        end

        table.insert(kits[kit_name].items, wielded_itemstack)
        skywars.overwrite_table("kits", kits) 
        
        skywars.print_msg(sender, skywars.T("x@1 @2 added to @3!", wielded_itemstack.count, wielded_itemstack.name, kit_name))
    end)



    cmd:sub("deletekit :kit", 
    function(sender, kit_name)
        local kits = skywars.load_table("kits")

        if kits[kit_name] == nil then
            skywars.print_error(sender, skywars.T("@1 doesn't exist!", kit_name))
            return
        end

        kits[kit_name] = nil
        skywars.overwrite_table("kits", kits) 

        skywars.print_msg(sender, skywars.T("Kit @1 deleted!", kit_name))
    end)



    cmd:sub("removeitem hand :kit", 
    function(sender, kit_name)
        local kits = skywars.load_table("kits")
        local wielded_itemstack = get_wielded_item(sender)
        local found = false

        if not wielded_itemstack then 
            return
        elseif kits[kit_name] == nil then
            skywars.print_error(sender, skywars.T("@1 doesn't exist!", wielded_itemstack.name))
            return
        end

        for i=1, #kits[kit_name].items do
            if kits[kit_name].items[i].name == wielded_itemstack.name then
                table.remove(kits[kit_name].items, i)
                found = true
                break 
            end
        end
        skywars.overwrite_table("kits", kits)

        if found then 
            skywars.print_msg(sender, skywars.T("@1 removed from @2!", wielded_itemstack.name, kit_name))
        else
            skywars.print_error(sender, skywars.T("@1 doesn't exist!", wielded_itemstack.name))
        end
    end)



    cmd:sub("removeitem :kit :item", 
    function(sender, kit_name, item_name)
        local kits = skywars.load_table("kits")
        local itemstack = {}
        local found = false

        if kits[kit_name] == nil then
            skywars.print_error(sender, skywars.T("@1 doesn't exist!", kit_name))
            return
        end
        
        itemstack.name = item_name
        itemstack.count = item_count

        for i=1, #kits[kit_name].items do
            if kits[kit_name].items[i].name == item_name then
                table.remove(kits[kit_name].items, i)
                found = true
                break 
            end
        end
        skywars.overwrite_table("kits", kits)

        if found then 
            skywars.print_msg(sender, skywars.T("@1 removed from @2!", item_name, kit_name))
        else
            skywars.print_error(sender, skywars.T("@1 doesn't exist!", item_name))
        end
    end)



    cmd:sub("resetkit :kit", 
    function(sender, kit_name)
        local kits = skywars.load_table("kits")

        if kits[kit_name] == nil then
            skywars.print_error(sender, skywars.T("@1 doesn't exist!", kit_name))
            return
        end

        kits[kit_name].items = {}
        skywars.overwrite_table("kits", kits)

        skywars.print_msg(sender, skywars.T("@1 reset!", kit_name))
    end)



    cmd:sub("getkits", 
    function(sender)
        local kits = skywars.load_table("kits")

        skywars.print_msg(sender, skywars.T("Kits list:"))
        for name in pairs(kits) do
            skywars.print_msg(sender, name)
        end
    end)


    
    cmd:sub("getitems :kit", 
    function(sender, kit_name)
        local kits = skywars.load_table("kits")

        if kits[kit_name] == nil then
            skywars.print_error(sender, skywars.T("@1 doesn't exist!", kit_name))
            return
        end

        skywars.print_msg(sender, skywars.T("@1 items:", kit_name))
        for i=1, #kits[kit_name].items do
            skywars.print_msg(sender, "x" .. kits[kit_name].items[i].count .. " " .. kits[kit_name].items[i].name)            
        end
    end)



    cmd:sub("arenakit add :arena :kit", 
    function(sender, arena_name, kit_name)
        local kits = skywars.load_table("kits")
        local arena, arena_name = get_valid_arena(arena_name, sender, true)

        if not arena then 
            return
        elseif kits[kit_name] == nil then
            skywars.print_error(sender, skywars.T("@1 doesn't exist!", kit_name))
            return
        end

        table.insert(arena.kits, kit_name)

        arena_lib.change_arena_property(sender, "skywars", arena_name, "kits", arena.kits, false)
        skywars.print_msg(sender, skywars.T("@1 added to @2!", kit_name, arena_name))
    end)



    cmd:sub("arenakit remove :arena :kit", 
    function(sender, arena_name, kit_name)
        local kits = skywars.load_table("kits")
        local arena, arena_name = get_valid_arena(arena_name, sender, true)
        local found = false

        if not arena then
            return
        elseif kits[kit_name] == nil then
            skywars.print_error(sender, skywars.T("@1 doesn't exist!", kit_name))
            return
        end

        for i=1, #arena.kits do
            if arena.kits[i] == kit_name then
                table.remove(arena.kits, i)
                found = true
                break
            end 
        end

        arena_lib.change_arena_property(sender, "skywars", arena_name, "kits", arena.kits, false)
        if found then skywars.print_msg(sender, skywars.T("@1 removed from @2!!", kit_name, arena_name)) 
        else skywars.print_error(sender, skywars.T("Kit not found!")) end
    end)



    cmd:sub("copykits :fromarena :toarena", 
    function(sender, from, to)
        local from_arena, from = get_valid_arena(from, sender)
        local to_arena, to = get_valid_arena(to, sender, true)

        if not from_arena or not to_arena then
            return
        elseif from_arena == to_arena then
            skywars.print_error(sender, skywars.T("The arenas must be different!"))
            return
        end

        to_arena.kits = table.copy(from_arena.kits)

        arena_lib.change_arena_property(sender, "skywars", to, "kits", to_arena.kits, false)
        skywars.print_msg(sender, skywars.T("@1 kits have been copied to @2!", from, to))
    end)



    ------------------
    -- ! MAP CMDS ! --
    ------------------

    cmd:sub("pos1 :arena", 
    function(sender, arena_name)
        local player = minetest.get_player_by_name(sender)
        local arena, arena_name = get_valid_arena(arena_name, sender, true)

        if not arena then
            return
        end

        arena.min_pos = player:get_pos()
        arena_lib.change_arena_property(sender, "skywars", arena.name, "min_pos", arena.min_pos) 

        skywars.print_msg(sender, skywars.T("Position saved!")) 
    end)



    cmd:sub("pos2 :arena", 
    function(sender, arena_name)
        local player = minetest.get_player_by_name(sender)
        local arena, arena_name = get_valid_arena(arena_name, sender, true)

        if not arena then
            return
        end

        arena.max_pos = player:get_pos()
        arena_lib.change_arena_property(sender, "skywars", arena.name, "max_pos", arena.max_pos) 

        skywars.print_msg(sender, skywars.T("Position saved!")) 
    end)



    cmd:sub("reset :arena", 
    function(sender, arena_name)
        local player = minetest.get_player_by_name(sender)
        local arena, arena_name = get_valid_arena(arena_name, sender)

        if not arena then
            return
        end
        
        if arena.enabled then
            skywars.reset_map(arena)
            skywars.print_msg(sender, skywars.T("@1 reset!", arena.name)) 
        else
            skywars.print_error(sender, skywars.T("@1 must be enabled!", arena_name))
        end
    end)



    --------------------
    -- ! DEBUG CMDS ! --
    --------------------

    cmd:sub("clearmapstable", 
    function(sender)
        skywars.overwrite_table("maps", {})
        skywars.print_msg(sender, "Maps table reset!") 
    end)
    


    cmd:sub("getpos", 
    function(sender)
        local pos = minetest.get_player_by_name(sender):get_pos()
        local readable_pos = "[X Y Z] " .. minetest.pos_to_string(pos, 1)

        skywars.print_msg(sender, readable_pos)
    end)



    cmd:sub("test reset :arena", 
    function(sender, arena_name)
        local player = minetest.get_player_by_name(sender)
        local arena, arena_name = get_valid_arena(arena_name, sender)

        if not arena then return end

        if arena.enabled then
            local result = skywars.map_reset_test(arena)
            if result then skywars.print_msg(sender, "Reset system working!")
            else skywars.print_error(sender, "Reset system doesn't work!") end
        else
            skywars.print_error(sender, skywars.T("@1 must be enabled!", arena_name))
        end
    end)



    cmd:sub("test asyncspeed :arena", 
    function(sender, arena_name)
        local player = minetest.get_player_by_name(sender)
        local arena, arena_name = get_valid_arena(arena_name, sender)

        if not arena then return end
        skywars.print_msg(sender, "Placing 1000 nodes, the server may lag...")

        if arena.enabled then
            skywars.test_async_speed(arena)
            skywars.print_msg(sender, "Nodes placed at " .. minetest.pos_to_string(arena.min_pos, 0) .. "!")
        else
            skywars.print_error(sender, skywars.T("@1 must be enabled!", arena_name))
        end
    end)
end, {

    description = [[
        (/help skywars)

        Arena_lib:

        - create <arena name> [min players] [max players]
        - edit <arena name>
        - remove <arena name>
        - list
        - enable <arena name>
        - disable <arena name>


        Skywars:

        - tutorial
        - pos1 <arena name>
        - pos2 <arena name>
        - addtreasure <arena name> <item> <count> <preciousness> 
          <rarity (min 1.0, max 10.0)> 
        - addtreasure hand <arena name> <preciousness>
          <rarity (min 1.0, max 10.0)> 
        - gettreasures <arena name>
        - searchtreasure <arena name> <treasure name>: shows all the treasures with that name
        - removetreasure <arena name> <treasure name>: remove all treasures with that name
        - removetreasure hand <arena name>
        - removetreasure id <arena name> <treasure id>
        - copytreasures <(from) arena name> <(to) arena name>
        - addchest <min_preciousness> <max_preciousness> <min_treasures_amount (min. 1)>
          <max_treasures_amount>
        - getchests <arena name>
        - inspect: gives you information about the chest you're looking at
        - removechest
        - removechest id <arena name> <id>
        - reset <arena name>
        - createkit <kit name> <texture name>
        - deletekit <kit name>
        - additem <kit name> <item> <count>
        - additem hand <kit name>
        - removeitem <kit name> <item>
        - removeitem hand <kit name>
        - arenakit add <arena name> <kit name>
        - arenakit remove <arena name> <kit name>
        - getkits
        - resetkit <kit name>
        - getitems <kit name>
        - copykits <(from) arena name> <(to) arena name>


        Debug (don't use them if you don't know what you're doing):

        - clearmapstable: clears the changed nodes table of each map without resetting them
        - getpos
        - test reset <arena name>: tests the reset system, make sure your map is properly reset
          before using it, 'cause it will clear the maps table first
        - test asyncspeed <arena name>: places a 10x10 area full of nodes, useful to test the
          async reset system speed (read the server logs to know the reset speed) 
        ]],
    privs = { skywars_admin = true }
})



minetest.register_privilege("skywars_admin", {  
    description = "With this you can use /skywars"
})



function get_valid_arena(arena_name, sender, property_is_changing)
    local arena = nil 

    if arena_name == "@" then
        local player_pos = minetest.get_player_by_name(sender):get_pos()
        arena = skywars.get_arena_by_pos(player_pos)
        if arena then arena_name = arena.name end
    else
        local id, arena_ = arena_lib.get_arena_by_name("skywars", arena_name)
        arena = arena_
    end

    if not arena then
        skywars.print_error(sender, skywars.T("@1 doesn't exist!", arena_name))
        return nil
    elseif arena_lib.is_arena_in_edit_mode(arena_name) and property_is_changing then 
        skywars.print_error(sender, skywars.T("Nobody must be in the editor!"))
        return nil
    elseif arena.enabled and property_is_changing then
        arena_lib.disable_arena(sender, "skywars", arena_name)
        local couldnt_disable = arena.enabled

        if couldnt_disable then
            skywars.print_error(sender, skywars.T("@1 must be disabled!", arena_name))
            return nil
        end
    end

    return arena, arena_name
end



function get_looking_node_pos(pl_name)
    local player = minetest.get_player_by_name(pl_name)
    local look_dir = player:get_look_dir()
    local pos_head = vector.add(player:get_pos(), {x=0, y=1.5, z=0})
    local result, pos = minetest.line_of_sight(
        vector.add(pos_head, vector.divide(look_dir, 4)), 
        vector.add(pos_head, vector.multiply(look_dir, 10))
    )

    if result then 
        skywars.print_error(pl_name, skywars.T("You're not looking at anything!"))
        return nil
    end

    return pos
end



function from_chest_to_string(chest) 
    local chest_pos = minetest.pos_to_string(chest.pos, 0)
    return skywars.T(
        "ID: @1, position: @2, preciousness: @3-@4, treasures amount: @5-@6",
        chest.id, chest_pos, chest.min_preciousness, chest.max_preciousness,
        chest.min_treasures, chest.max_treasures
    )
end



function from_treasure_to_string(treasure) 
    return skywars.T(
        "ID: @1, name: @2, rarity: @3, preciousness: @4, count: @5",
        treasure.id, treasure.name, treasure.rarity, treasure.preciousness, treasure.count
    )
end



function get_wielded_item(player)
    local item_name = minetest.get_player_by_name(player):get_wielded_item():get_name()
    local item_count = minetest.get_player_by_name(player):get_wielded_item():get_count()
    local itemstack = {}

    if ItemStack(item_name):is_known() == false then
        skywars.print_error(player, skywars.T("@1 doesn't exist!", item_name))
        return nil
    elseif item_name == "" then
        skywars.print_error(player, skywars.T("Your hand is empty!"))
        return nil
    end

    itemstack.name = item_name
    itemstack.count = item_count

    return itemstack
end