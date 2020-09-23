ChatCmdBuilder.new("skywars", 
function(cmd)
    cmd:sub("tutorial", 
    function(sender)
        skywars.print_msg(sender, [[

        (If you find it uncomfortable to read the tutorial from the chat
        you can read it from a file in the mod folder called TUTORIAL.txt)

        These are the steps to follow in order to create and configure an 
        arena:


        1) Creating the arena using:

        /skywars create <arena name> [min players] [max players]
        where min players is equal to the minimun amount of players to make 
        the arena start, and max players to the maximum amount of players that
        an arena can have.


        2) Editing the arena using:

        /skywars edit <arena name>
        in this menu you can add spawn points and set up the sign to enter the
        arena: the spawn points are where the players will spawn when they 
        enter the arena, while the sign is just the way to enter it (by 
        clicking it).


        3) Setting the arena treasures (the items that can spawn in the 
        chests):
        item: the item name
        rarity: how often it will spawn in chests
        preciousness: in which chests it can be put, for example a chest with 
        a preciousness range 2-4 can spawn just items with a preciousness 
        between 2 and 4
        count: the item amount

        /skywars addtreasure <arena name> <item> <count> <rarity (min 1.0, max 
        10.0)> <preciousness>

        You can also use: 
        /skywars addtreasure hand <arena name> <rarity (min 1.0, max 10.0)> 
        <preciousness>
        this will get the item name and count from the one in your hand.


        4) Setting the chests in the arena using:

        /skywars addchest <arena name> <min_preciousness> <max_preciousness> 
        <min_treasures_amount (min. 1)> <max_treasures_amount>
        to add a chest that will be filled with the right treasures when the match
        starts, this will set the position to the node you're looking at (not over it).

        You can also use: 

        /skywars addchest pos <arena name> <min_preciousness> <max_preciousness> 
        <min_treasures_amount (min. 1)> <max_treasures_amount>
        this will set the position over the node you're standing on.


        5) Saving the map schematic using:

        /skywars pos1
        /skywars pos2
        /skywars createschematic <arena name> <schematic_name>
        in order to automatically reset the map on every match, you have to 
        create a schematic file; to do so, simply specify the corners of the 
        map by using /skywars pos1 and /skywars pos2.
        !If you overwrite a schematic that you've already created before
        or you delete an arena make sure to reload the server/delete the old
        schematic, because the old one won't be deleted!

        
        6) (Optional) Creating and setting the kits using: 

        /skywars createkit <kit name> <texture name>: texture name is the texture
        that the kit button will have in the selector menu at the start of the match,
        it must be a file name that you put in the <SKYWARS MOD FOLDER>/textures folder.

        /skywars additem <kit name> <item> <count>: with this you can add items to it
        or
        /skywars additem hand <kit name>

        /skywars arenakit add <arena name> <kit name>: each arena has a "kits" property
        that contains the choosable kits, with this command you add one to it


        7) Enabling the arena using

        /skywars enable <arena name>


        Once you've done this you can click the sign and start playing :).
        You can use /help skywars to read all the commands.
        To modify the game settings (such as the messages prefix or the
        hub spawn point) you can edit the SETTINGS.lua file.
        ]])
    end)



    cmd:sub("create :arena", function(name, arena_name)
        arena_lib.create_arena(name, "skywars", arena_name)
    end)



    cmd:sub("create :arena :minplayers:int :maxplayers:int", function(name, arena_name, min_players, max_players)
        arena_lib.create_arena(name, "skywars", arena_name, min_players, max_players)
    end)



    cmd:sub("remove :arena", function(name, arena_name)
        arena_lib.remove_arena(name, "skywars", arena_name)
    end)

    
    
    -- list of the arenas
    cmd:sub("list", function(name)
        arena_lib.print_arenas(name, "skywars")
    end)



    -- info on a specific arena
    cmd:sub("info :arena", function(name, arena_name)
        arena_lib.print_arena_info(name, "skywars", arena_name)
    end)



    -- this sets the spawns using the player position
    cmd:sub("setspawn :arena", function(name, arena)
        arena_lib.set_spawner(name, "skywars", arena)
    end)



    cmd:sub("setsign :arena", function(sender, arena)
        arena_lib.set_sign(sender, nil, nil, "skywars", arena)
    end)


    
    cmd:sub("edit :arena", function(sender, arena)
        arena_lib.enter_editor(sender, "skywars", arena)
    end)



    cmd:sub("enable :arena", function(name, arena)
        arena_lib.enable_arena(name, "skywars", arena)
    end)



    cmd:sub("disable :arena", function(name, arena)
        arena_lib.disable_arena(name, "skywars", arena)
    end)



    --------------------
    -- ! CHEST CMDS ! --
    --------------------

    cmd:sub("addtreasure :arena :treasure :count:int :rarity:number :preciousness:int", 
    function(sender, arena_name, treasure_name, count, rarity, preciousness )
        local id, arena = arena_lib.get_arena_by_name("skywars", arena_name)
        
        if arena_lib.is_arena_in_edit_mode(arena_name) then 
            skywars.print_error(sender, skywars.T("Nobody must be in the editor!"))
            return 
        elseif arena == nil then
            skywars.print_error(sender, skywars.T("Arena not found!"))
            return
        elseif arena.enabled == true then
            arena_lib.disable_arena(sender, "skywars", arena_name)
            if arena.enabled == true then
                skywars.print_error(sender, skywars.T("@1 must be disabled!", arena_name))
                return
            end
        elseif count <= 0 then
            skywars.print_error(sender, skywars.T("Count has to be greater than 0!"))
            return
        elseif rarity < 1 then
            skywars.print_error(sender, skywars.T("Rarity has to be greater than 0!"))
            return
        elseif rarity > 10 then
            skywars.print_error(sender, skywars.T("Rarity has to be smaller than 11!"))
            return
        elseif ItemStack(treasure_name):is_known() == false then
            skywars.print_error(sender, skywars.T("@1 doesn't exist!", treasure_name))
            return
        end

        local item_id = 1
        if arena.treasures[#arena.treasures] then item_id = arena.treasures[#arena.treasures].id+1 end
        table.insert(arena.treasures, {
            name = treasure_name, 
            rarity = rarity, 
            count = count, 
            preciousness = preciousness, 
            id = item_id
        })

        arena_lib.change_arena_property(sender, "skywars", arena_name, "treasures", arena.treasures, false)
        skywars.print_msg(sender, skywars.T("x@1 @2 added to @3 with @4 rarity and @5 preciousness!", 
            count, treasure_name, arena_name, rarity, preciousness
        ))

        
    end)
    


    cmd:sub("addtreasure hand :arena :rarity:number :preciousness:int", 
    function(sender, arena_name, rarity, preciousness)
        local id, arena = arena_lib.get_arena_by_name("skywars", arena_name)
        local treasure_name = minetest.get_player_by_name(sender):get_wielded_item():get_name()
        local count = minetest.get_player_by_name(sender):get_wielded_item():get_count()

        if arena_lib.is_arena_in_edit_mode(arena_name) then 
            skywars.print_error(sender, skywars.T("Nobody must be in the editor!"))
            return 
        elseif arena == nil then
            skywars.print_error(sender, skywars.T("Arena not found!"))
            return
        end
        if arena.enabled == true then
            arena_lib.disable_arena(sender, "skywars", arena_name)
            if arena.enabled == true then
                skywars.print_error(sender, skywars.T("@1 must be disabled!", arena_name))
                return
            end
        end
        if rarity < 1 then
            skywars.print_error(sender, skywars.T("Rarity has to be greater than 0!"))
            return
        elseif rarity > 10 then
            skywars.print_error(sender, skywars.T("Rarity has to be smaller than 11!"))
            return
        elseif treasure_name == "" then
            skywars.print_error(sender, skywars.T("Your hand is empty!"))
            return
        end

        local item_id = 1
        if arena.treasures[#arena.treasures] then item_id = arena.treasures[#arena.treasures].id+1 end
        table.insert(arena.treasures, {
            name = treasure_name, 
            rarity = rarity, 
            count = count, 
            preciousness = preciousness, 
            id = item_id
        })

        arena_lib.change_arena_property(sender, "skywars", arena_name, "treasures", arena.treasures, false)
        skywars.print_msg(sender, skywars.T("x@1 @2 added to @3 with @4 rarity and @5 preciousness!", 
            count, treasure_name, arena_name, rarity, preciousness
        ))
    end)

    
    cmd:sub("removetreasure :arena :treasure", function(sender, arena_name, treasure_name)
        local id, arena = arena_lib.get_arena_by_name("skywars", arena_name)
        local found = {true, false} -- the first is used to repeat the for until nothing is found

        if arena_lib.is_arena_in_edit_mode(arena_name) then 
            skywars.print_error(sender, skywars.T("Nobody must be in the editor!"))
            return 
        elseif arena == nil then
            skywars.print_error(sender, skywars.T("Arena not found!"))
            return
        elseif arena.enabled == true then
            arena_lib.disable_arena(sender, "skywars", arena_name)
            if arena.enabled == true then
                skywars.print_error(sender, skywars.T("@1 must be disabled!", arena_name))
                return
            end
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
    end)



    cmd:sub("removetreasure id :arena :id:int", function(sender, arena_name, treasure_id)
        local id, arena = arena_lib.get_arena_by_name("skywars", arena_name)
        local treasure_name = ""

        if arena_lib.is_arena_in_edit_mode(arena_name) then 
            skywars.print_error(sender, skywars.T("Nobody must be in the editor!"))
            return 
        elseif arena == nil then
            skywars.print_error(sender, skywars.T("Arena not found!"))
            return
        elseif arena.enabled == true then
            arena_lib.disable_arena(sender, "skywars", arena_name)
            if arena.enabled == true then
                skywars.print_error(sender, skywars.T("@1 must be disabled!", arena_name))
                return
            end
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
    end)



    cmd:sub("copytreasures :fromarena :toarena", function(sender, from, to)
        local id, from_arena = arena_lib.get_arena_by_name("skywars", from)
        local id2, to_arena = arena_lib.get_arena_by_name("skywars", to)
        local found = false


        if from_arena == nil then
            skywars.print_error(sender, skywars.T("First arena not found!"))
            return
        elseif to_arena == nil then
            skywars.print_error(sender, skywars.T("Second arena not found!"))
            return
        elseif from_arena == to_arena then
            skywars.print_error(sender, skywars.T("The arenas must be different!"))
            return
        elseif to_arena.enabled == true then
            arena_lib.disable_arena(sender, "skywars", arena_name)
            if to_arena.enabled == true then
                skywars.print_error(sender, skywars.T("@1 must be disabled!", to))
                return
            end
        end

        to_arena.treasures = {}
        for i=1, #from_arena.treasures do
            to_arena.treasures[i] = from_arena.treasures[i]
        end
        arena_lib.change_arena_property(sender, "skywars", to, "treasures", to_arena.treasures, false)
        
        skywars.print_msg(sender, skywars.T("@1 treasures have been copied to @2!", from, to))
    end)



    cmd:sub("gettreasures :arena", function(sender, arena_name)
        local id, arena = arena_lib.get_arena_by_name("skywars", arena_name)
        local found = false

        if arena_lib.is_arena_in_edit_mode(arena_name) then 
            skywars.print_error(sender, skywars.T("Nobody must be in the editor!"))
            return 
        elseif arena == nil then
            skywars.print_error(sender, skywars.T("Arena not found!"))
            return
        end

        skywars.print_msg(sender, skywars.T("Treasures list:"))
        for i=1, #arena.treasures do
            local treasure = arena.treasures[i]
            skywars.print_msg(sender, "ID: " .. arena.treasures[i].id .. ".\n" .. 
                skywars.T(
                    "name: @1 @nrarity: @2 @npreciousness: @3 @ncount: @4",
                    treasure.name, treasure.rarity, treasure.preciousness, treasure.count
                ) .. "\n\n"
            )
        end
    end)



    cmd:sub("searchtreasure :arena :treasure", function(sender, arena_name, treasure_name)
        local id, arena = arena_lib.get_arena_by_name("skywars", arena_name)

        if arena_lib.is_arena_in_edit_mode(arena_name) then 
            skywars.print_error(sender, skywars.T("Nobody must be in the editor!"))
            return 
        elseif arena == nil then
            skywars.print_error(sender, skywars.T("Arena not found!"))
            return
        end

        skywars.print_msg(sender, skywars.T("Treasures list:"))
        for i=1, #arena.treasures do
            local treasure = arena.treasures[i]
            if treasure.name == treasure_name then
                skywars.print_msg(sender, "ID: " .. arena.treasures[i].id .. ".\n" .. 
                    skywars.T(
                        "name: @1 @nrarity: @2 @npreciousness: @3 @ncount: @4",
                        treasure.name, treasure.rarity, treasure.preciousness, treasure.count
                    ) .. "\n\n"
                )
            end
        end
    end)



    cmd:sub("addchest pos :arena :minpreciousness:int :maxpreciousness:int :tmin:int :tmax:int", 
    function(sender, arena_name, min_preciousness, max_preciousness, t_min, t_max)
        local id, arena = arena_lib.get_arena_by_name("skywars", arena_name)
        local pos = vector.round(minetest.get_player_by_name(sender):get_pos())
        local exists = false
        local chest_id = 1

        if arena.chests[#arena.chests] then chest_id = arena.chests[#arena.chests].id+1 end
        local chest = 
        {
            pos = pos,
            min_preciousness = min_preciousness, 
            max_preciousness = max_preciousness,
            min_treasures = t_min,
            max_treasures = t_max,
            id = chest_id
        }

        if arena_lib.is_arena_in_edit_mode(arena_name) then 
            skywars.print_error(sender, skywars.T("Nobody must be in the editor!"))
            return 
        elseif arena == nil then
            skywars.print_error(sender, skywars.T("Arena not found!"))
            return
        end
        if arena.enabled == true then
            arena_lib.disable_arena(sender, "skywars", arena_name)
            if arena.enabled == true then
                skywars.print_error(sender, skywars.T("@1 must be disabled!", arena_name))
                return
            end
        end
        if t_min <= 0 or t_max <= 0 then
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

        skywars.print_msg(sender, skywars.T("Chest added!"))
        table.insert(arena.chests, chest)
        arena_lib.change_arena_property(sender, "skywars", arena_name, "chests", arena.chests, false)
    end)



    cmd:sub("addchest :arena :minpreciousness:int :maxpreciousness:int :tmin:int :tmax:int", 
    function(sender, arena_name, min_preciousness, max_preciousness, t_min, t_max)
        local id, arena = arena_lib.get_arena_by_name("skywars", arena_name)
        local player = minetest.get_player_by_name(sender)
        local look_dir = player:get_look_dir()
        local pos_head = vector.add(player:get_pos(), {x=0, y=1.5, z=0})
        local result, pos = minetest.line_of_sight(vector.add(pos_head, vector.divide(look_dir, 4)), vector.add(pos_head, vector.multiply(look_dir, 10)))
        local exists = false

        if result then 
            skywars.print_error(sender, skywars.T("You're not looking at anything!")) 
            return
        end

        local chest_id = 1
        if arena.chests[#arena.chests] then chest_id = arena.chests[#arena.chests].id+1 end
        local chest = 
        {
            pos = pos,
            min_preciousness = min_preciousness, 
            max_preciousness = max_preciousness,
            min_treasures = t_min,
            max_treasures = t_max,
            id = chest_id
        }

        if arena_lib.is_arena_in_edit_mode(arena_name) then 
            skywars.print_error(sender, skywars.T("Nobody must be in the editor!"))
            return 
        elseif arena == nil then
            skywars.print_error(sender, skywars.T("Arena not found!"))
            return
        end
        if arena.enabled == true then
            arena_lib.disable_arena(sender, "skywars", arena_name)
            if arena.enabled == true then
                skywars.print_error(sender, skywars.T("@1 must be disabled!", arena_name))
                return
            end
        end
        if t_min <= 0 or t_max <= 0 then
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

        skywars.print_msg(sender, skywars.T("Chest added!"))
        table.insert(arena.chests, chest)
        arena_lib.change_arena_property(sender, "skywars", arena_name, "chests", arena.chests, false)
    end)



    cmd:sub("getchests :arena", function(sender, arena_name)
        local id, arena = arena_lib.get_arena_by_name("skywars", arena_name)
        local found = false

        if arena_lib.is_arena_in_edit_mode(arena_name) then 
            skywars.print_error(sender, skywars.T("Nobody must be in the editor!"))
            return 
        elseif arena == nil then
            skywars.print_error(sender, skywars.T("Arena not found!"))
            return
        end

        skywars.print_msg(sender, skywars.T("Chest list:"))
        for i=1, #arena.chests do
            local chest_pos = tostring(arena.chests[i].pos.x) .. " " .. tostring(arena.chests[i].pos.y) .. " " .. tostring(arena.chests[i].pos.z)
            skywars.print_msg(sender, skywars.T("ID: @1 - POSITION: @2", arena.chests[i].id, chest_pos))
        end
    end)
    

    
    cmd:sub("removechest :arena", function(sender, arena_name)
        local id, arena = arena_lib.get_arena_by_name("skywars", arena_name)
        local found = false
        local player = minetest.get_player_by_name(sender)
        local look_dir = player:get_look_dir()
        local pos_head = vector.add(player:get_pos(), {x=0, y=1.5, z=0})
        local result, pos = minetest.line_of_sight(vector.add(pos_head, vector.divide(look_dir, 4)), vector.add(pos_head, vector.multiply(look_dir, 10)))

        if result then 
            skywars.print_error(sender, skywars.T("You're not looking at anything!"))
            return
        end

        if arena_lib.is_arena_in_edit_mode(arena_name) then 
            skywars.print_error(sender, skywars.T("Nobody must be in the editor!"))
            return 
        elseif arena == nil then
            skywars.print_error(sender, skywars.T("Arena not found!"))
            return
        elseif arena.enabled == true then
            arena_lib.disable_arena(sender, "skywars", arena_name)
            if arena.enabled == true then
                skywars.print_error(sender, skywars.T("@1 must be disabled!", arena_name))
                return
            end
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



    cmd:sub("removechest id :arena :id:int", function(sender, arena_name, chest_id)
        local id, arena = arena_lib.get_arena_by_name("skywars", arena_name)
        local found = false
        
        if arena_lib.is_arena_in_edit_mode(arena_name) then 
            skywars.print_error(sender, skywars.T("Nobody must be in the editor!"))
            return 
        elseif arena == nil then
            skywars.print_error(sender, skywars.T("Arena not found!"))
            return
        elseif arena.enabled == true then
            arena_lib.disable_arena(sender, "skywars", arena_name)
            if arena.enabled == true then
                skywars.print_error(sender, skywars.T("@1 must be disabled!", arena_name))
                return
            end
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
        local kits = skywars.load_kits()

        if kits[kit_name] ~= nil then
            skywars.print_error(sender, skywars.T("@1 already exists!", kit_name))
            return
        end

        kits[kit_name] = {texture = texture, items={}}
        skywars.overwrite_kits(kits) 

        skywars.print_msg(sender, skywars.T("Kit @1 created!", kit_name))
    end)



    cmd:sub("additem :kit :item :count:int", 
    function(sender, kit_name, item_name, item_count)
        local kits = skywars.load_kits()
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
        skywars.overwrite_kits(kits) 
        
        skywars.print_msg(sender, skywars.T("@1 added to @2!", item_name, kit_name))
    end)



    cmd:sub("additem hand :kit", 
    function(sender, kit_name)
        local kits = skywars.load_kits()
        local item_name = minetest.get_player_by_name(sender):get_wielded_item():get_name()
        local item_count = minetest.get_player_by_name(sender):get_wielded_item():get_count()
        local itemstack = {}

        if ItemStack(item_name):is_known() == false then
            skywars.print_error(sender, skywars.T("@1 doesn't exist!", item_name))
            return
        elseif kits[kit_name] == nil then
            skywars.print_error(sender, skywars.T("@1 doesn't exist!", kit_name))
            return
        elseif item_name == "" then
            skywars.print_error(sender, skywars.T("Your hand is empty!"))
            return
        end
        
        itemstack.name = item_name
        itemstack.count = item_count

        table.insert(kits[kit_name].items, itemstack)
        skywars.overwrite_kits(kits) 
        
        skywars.print_msg(sender, skywars.T("@1 added to @2!", item_name, kit_name))
    end)



    cmd:sub("deletekit :kit", 
    function(sender, kit_name)
        local kits = skywars.load_kits()

        if kits[kit_name] == nil then
            skywars.print_error(sender, skywars.T("@1 doesn't exist!", kit_name))
            return
        end

        kits[kit_name] = nil
        skywars.overwrite_kits(kits) 

        skywars.print_msg(sender, skywars.T("Kit @1 deleted!", kit_name))
    end)



    cmd:sub("removeitem :kit :item", 
    function(sender, kit_name, item_name)
        local kits = skywars.load_kits()
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
        skywars.overwrite_kits(kits)

        if found then 
            skywars.print_msg(sender, skywars.T("@1 removed from @2!", item_name, kit_name))
        else
            skywars.print_error(sender, skywars.T("@1 doesn't exist!", item_name))
        end
    end)



    cmd:sub("resetkit :kit", 
    function(sender, kit_name)
        local kits = skywars.load_kits()

        if kits[kit_name] == nil then
            skywars.print_error(sender, skywars.T("@1 doesn't exist!", kit_name))
            return
        end

        kits[kit_name].items = {}
        skywars.overwrite_kits(kits)

        skywars.print_msg(sender, skywars.T("@1 resetted!", kit_name))
    end)



    cmd:sub("getkits", 
    function(sender)
        local kits = skywars.load_kits()

        skywars.print_msg(sender, skywars.T("Kits list:"))
        for name in pairs(kits) do
            skywars.print_msg(sender, name)
        end
    end)


    
    cmd:sub("getitems :kit", 
    function(sender, kit_name)
        local kits = skywars.load_kits()

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
        local kits = skywars.load_kits()
        local id, arena = arena_lib.get_arena_by_name("skywars", arena_name)

        if arena_lib.is_arena_in_edit_mode(arena_name) then 
            skywars.print_error(sender, skywars.T("Nobody must be in the editor!"))
            return 
        elseif arena == nil then
            skywars.print_error(sender, skywars.T("Arena not found!"))
            return
        end
        if arena.enabled == true then
            arena_lib.disable_arena(sender, "skywars", arena_name)
            if arena.enabled == true then
                skywars.print_error(sender, skywars.T("@1 must be disabled!", arena_name))
                return
            end
        end
        if kits[kit_name] == nil then
            skywars.print_error(sender, skywars.T("@1 doesn't exist!", kit_name))
            return
        end

        table.insert(arena.kits, kit_name)

        arena_lib.change_arena_property(sender, "skywars", arena_name, "kits", arena.kits, false)
        skywars.print_msg(sender, skywars.T("@1 added to @2!", kit_name, arena_name))
    end)



    cmd:sub("arenakit remove :arena :kit", 
    function(sender, arena_name, kit_name)
        local kits = skywars.load_kits()
        local id, arena = arena_lib.get_arena_by_name("skywars", arena_name)
        local found = false

        if arena_lib.is_arena_in_edit_mode(arena_name) then
            skywars.print_error(sender, skywars.T("Nobody must be in the editor!"))
            return 
        elseif arena == nil then
            skywars.print_error(sender, skywars.T("Arena not found!"))
            return
        end
        if arena.enabled == true then
            arena_lib.disable_arena(sender, "skywars", arena_name)
            if arena.enabled == true then
                skywars.print_error(sender, skywars.T("@1 must be disabled!", arena_name))
                return
            end
        end
        if kits[kit_name] == nil then
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



    cmd:sub("copykits :fromarena :toarena", function(sender, from, to)
        local id, from_arena = arena_lib.get_arena_by_name("skywars", from)
        local id2, to_arena = arena_lib.get_arena_by_name("skywars", to)
        local found = false


        if from_arena == nil then
            skywars.print_error(sender, skywars.T("First arena not found!"))
            return
        elseif to_arena == nil then
            skywars.print_error(sender, skywars.T("Second arena not found!"))
            return
        elseif from_arena == to_arena then
            skywars.print_error(sender, skywars.T("The arenas must be different!"))
            return
        elseif to_arena.enabled == true then
            arena_lib.disable_arena(sender, "skywars", arena_name)

            if to_arena.enabled == true then
                skywars.print_error(sender, skywars.T("@1 must be disabled!", to))
                return
            end
        end

        to_arena.kits = {}
        for i=1, #from_arena.kits do
            to_arena.kits[i] = from_arena.kits[i]
        end

        arena_lib.change_arena_property(sender, "skywars", to, "kits", to_arena.kits, false)
        skywars.print_msg(sender, skywars.T("@1 kits have been copied to @2!", from, to))
    end)



    ------------------
    -- ! MAP CMDS ! --
    ------------------

    cmd:sub("pos1", function(sender)
        local player = minetest.get_player_by_name(sender)

        player:get_meta():set_string("pos1", minetest.serialize(player:get_pos()))
        skywars.print_msg(sender, skywars.T("Position saved!")) 
    end)



    cmd:sub("pos2", function(sender)
        local player = minetest.get_player_by_name(sender)

        player:get_meta():set_string("pos2", minetest.serialize(player:get_pos()))
        skywars.print_msg(sender, skywars.T("Position saved!")) 
    end)



    cmd:sub("createschematic :arena :name",
    function(sender, arena_name, name)
        local id, arena = arena_lib.get_arena_by_name("skywars", arena_name)
        local player = minetest.get_player_by_name(sender)
        local pos1 = minetest.deserialize(player:get_meta():get_string("pos1")) 
        local pos2 = minetest.deserialize(player:get_meta():get_string("pos2")) 

        if arena_lib.is_arena_in_edit_mode(arena_name) then 
            skywars.print_error(sender, skywars.T("Nobody must be in the editor!"))
            return 
        elseif arena == nil then
            skywars.print_error(sender, skywars.T("Arena not found!"))
            return
        end
        if arena.enabled == true then
            arena_lib.disable_arena(sender, "skywars", arena_name)
            if arena.enabled == true then
                skywars.print_error(sender, skywars.T("@1 must be disabled!", arena_name))
                return
            end
        end
        if pos1 == "" or pos2 == "" then
            skywars.print_error(sender, skywars.T("Pos1 or pos2 are not set!"))
            return
        end

        skywars.create_schematic(sender, {x = pos1.x, y = pos1.y, z = pos1.z}, {x = pos2.x, y = pos2.y, z = pos2.z}, name, arena)
    end)



    cmd:sub("getpos", function(sender)

        function round(num, numDecimalPlaces)
            return string.format("%." .. (numDecimalPlaces or 0) .. "f", num)
        end

        local pos = minetest.get_player_by_name(sender):get_pos()
        local readable_pos = "[X Y Z] " .. round(pos.x, 1) .. " " .. round(pos.y, 1) .. " " .. round(pos.z, 1)

        skywars.print_msg(sender, readable_pos)
    end)

end, {

    description = [[
        (Use /help skywars)

        Arena_lib:

        - create <arena name> [min players] [max players]
        - edit <arena name>
        - remove <arena name>
        - info <arena name>
        - list
        - enable <arena name>
        - disable <arena name>


        Skywars commands:
        - tutorial
        - addtreasure <arena name> <item> <count> <rarity (min 1.0, max 10.0)> 
        <preciousness> 
        - addtreasure hand <arena name> <rarity (min 1.0, max 10.0)> 
        <preciousness>
        - removetreasure <arena name> <treasure name>: remove all treasures with than name
        - removetreasure id <arena name> <treasure id>
        - gettreasures <arena name>
        - searchtreasure <arena name> <treasure name>: shows all the treasures with that name
        - copytreasures <(from) arena name> <(to) arena name>
        - addchest <arena name> <min_preciousness> <max_preciousness> 
        <min_treasures_amount (min. 1)> <max_treasures_amount>
        - addchest pos <arena name> <min_preciousness> <max_preciousness> 
        <min_treasures_amount (min. 1)> <max_treasures_amount>
        - removechest
        - removechest id <id>
        - getchests <arena name>
        - pos1
        - pos2
        - createschematic <arena name> <schematic_name>
        - getpos
        - createkit <kit name> <texture name>
        - deletekit <kit name>
        - additem <kit name> <item> <count>
        - additem hand <kit name>
        - removeitem <kit name> <item>
        - arenakit add <arena> <kit name>
        - arenakit remove <arena> <kit name>
        - getkits
        - resetkit <kit name>
        - getitems <kit name>
        - copykits <arena1> <arena2>
        ]],
    privs = { skywars_admin = true }
})



minetest.register_privilege("skywars_admin", {  
    description = "With this you can use /skywars"
})
  