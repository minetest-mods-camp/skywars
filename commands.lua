local mod = "skywars"

ChatCmdBuilder.new("skywars", 
function(cmd)

    cmd:sub("tutorial", 
    function(sender)
        minetest.chat_send_player(sender, [[

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
        rarity: how often it will spawn in chests (the rarity gap between two 
        treasures should be at least of 2)
        preciousness: in which chests it can be put, for example a chest with 
        a preciousness range 2-4 can spawn just items with a preciousness 
        between 2 and 4
        count: the item amount

        /skywars addtreasure <arena name> <item> <rarity (min 2.0, max 
        1000.0)> <preciousness> <count>


        4) Setting the chests in the arena using:

        /skywars addchest <arena name> <min_preciousness> <max_preciousness> 
        <min_treasures_amount (min. 1)> <max_treasures_amount>
        to add a chest use this command at the position you want it to spawn, it 
        will automatically be filled with the right items when the match 
        starts


        5) Saving the map schematic using:

        /skywars pos1
        /skywars pos2
        /skywars createschematic <arena name> <schematic_name>
        in order to automatically reset the map on every match, you have to 
        create a schematic file; to do so, simply specify the corners of the 
        map by facing NORTH (you can press F5 to know where you're facing), 
        and by being sure pos1 Z is SMALLER than pos2 Z (/skywars pos1 and 
        /skywars pos2 to set the two corners).
        !If you overwrite a schematic that you've already created before make 
        sure to reload the server, so that it can be loaded correctly, and 
        remember that the old schematic won't be deleted!


        6) Enabling the arena using

        /skywars enable <arena name>


        Once you've done this you can click the sign and start playing :)
        You can use /help skywars to read all the commands
        To modify the game settings (such as the messages prefix or the
        hub spawn point) you can edit the SETTINGS.lua file
        ]])
    end)

    -- create arena
    cmd:sub("create :arena", function(name, arena_name)
        arena_lib.create_arena(name, "skywars", arena_name)
    end)



    cmd:sub("create :arena :minplayers:int :maxplayers:int", function(name, arena_name, min_players, max_players)
        arena_lib.create_arena(name, "skywars", arena_name, min_players, max_players)
    end)



    -- remove arena
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



    cmd:sub("setspawn :arena", function(name, arena)
        arena_lib.set_spawner(name, "skywars", arena)
    end)



    -- this sets the arena's sign
    cmd:sub("setsign :arena", function(sender, arena)
        arena_lib.set_sign(sender, nil, nil, "skywars", arena)
    end)


    
    -- enter editor mode
    cmd:sub("edit :arena", function(sender, arena)
        arena_lib.enter_editor(sender, "skywars", arena)
    end)



    -- enable and disable arenas
    cmd:sub("enable :arena", function(name, arena)
        arena_lib.enable_arena(name, "skywars", arena)
    end)



    cmd:sub("disable :arena", function(name, arena)
        arena_lib.disable_arena(name, "skywars", arena)
    end)



    --------------------
    -- ! CHEST CMDS ! --
    --------------------

    
    cmd:sub("addtreasure :arena :treasure :rarity:number :preciousness:int :count:int", 
    function(sender, arena_name, treasure_name, rarity, preciousness, count)
        local id, arena = arena_lib.get_arena_by_name("skywars", arena_name)
        
        if arena == nil then
            minetest.chat_send_player(sender, skywars_settings.prefix .. skywars.T("Arena not found!"))
            return
        elseif arena.enabled == true then
            minetest.chat_send_player(sender, skywars_settings.prefix .. skywars.T("@1 must be disabled!", arena_name))
            return
        elseif count <= 0 then
            minetest.chat_send_player(sender, skywars_settings.prefix .. skywars.T("Count has to be greater than 0!"))
            return
        elseif rarity < 2 then
            minetest.chat_send_player(sender, skywars_settings.prefix .. skywars.T("Rarity has to be greater than 2!"))
            return
        elseif ItemStack(treasure_name):is_known() == false then
            minetest.chat_send_player(sender, skywars_settings.prefix .. skywars.T("@1 doesn't exist!", treasure_name))
            return
        end

        table.insert(arena.treasures, {name = treasure_name, rarity = rarity, count = count, preciousness = preciousness})

        minetest.chat_send_player(sender, skywars_settings.prefix .. skywars.T("Treasure added!"))
    end)
    

    
    cmd:sub("removetreasure :arena :treasure", function(sender, arena_name, treasure_name)
        local id, arena = arena_lib.get_arena_by_name("skywars", arena_name)
        local found = false

        if arena == nil then
            minetest.chat_send_player(sender, skywars_settings.prefix .. skywars.T("Arena not found!"))
            return
        elseif arena.enabled == true then
            minetest.chat_send_player(sender, skywars_settings.prefix .. skywars.T("@1 must be disabled!", arena_name))
            return
        end

        for i=1, #arena.treasures do
            if arena.treasures[i].name == treasure_name then
                table.remove(arena.treasures, i)
                found = true
                break
            end 
        end

        arena_lib.change_arena_property(sender, "skywars", arena_name, "treasures", arena.treasures, false)

        if found then minetest.chat_send_player(sender, skywars_settings.prefix .. skywars.T("Treasure removed!"))
        else minetest.chat_send_player(sender, skywars_settings.prefix .. skywars.T("Treasure not found!")) end
    end)



    cmd:sub("copytreasures :fromarena :toarena", function(sender, from, to)
        local id, from_arena = arena_lib.get_arena_by_name("skywars", from)
        local id2, to_arena = arena_lib.get_arena_by_name("skywars", to)
        local found = false

        if from_arena == nil then
            minetest.chat_send_player(sender, skywars_settings.prefix .. skywars.T("First arena not found!"))
            return
        elseif to_arena == nil then
            minetest.chat_send_player(sender, skywars_settings.prefix .. skywars.T("Second arena not found!"))
            return
        elseif from_arena == to_arena then
            minetest.chat_send_player(sender, skywars_settings.prefix .. skywars.T("The arenas must be different!"))
            return
        elseif to_arena.enabled == true then
            minetest.chat_send_player(sender, skywars_settings.prefix .. skywars.T("@1 must be disabled!", to))
            return
        end

        to_arena.treasures = {}
        for i=1, #from_arena.treasures do
            to_arena.treasures[i] = from_arena.treasures[i]
        end

        arena_lib.change_arena_property(sender, "skywars", to, "treasures", to_arena.treasures, false)
        minetest.chat_send_player(sender, skywars_settings.prefix .. skywars.T("@1 treasures have been copied to @2!", from, to))
    end)



    cmd:sub("gettreasures :arena", function(sender, arena_name)
        local id, arena = arena_lib.get_arena_by_name("skywars", arena_name)
        local found = false

        if arena == nil then
            minetest.chat_send_player(sender, skywars_settings.prefix .. skywars.T("Arena not found!"))
            return
        end

        minetest.chat_send_player(sender, skywars_settings.prefix .. skywars.T("TREASURES LIST:"))
        for i=1, #arena.treasures do
            local treasure = arena.treasures[i]
            minetest.chat_send_player(sender, tostring(i) .. ".\n" .. 
                skywars.T(
                    "name: @1 @nrarity: @2 @npreciousness: @3 @ncount: @4",
                    treasure.name, treasure.rarity, treasure.preciousness, treasure.count
                )
            )
        end
    end)



    cmd:sub("addchest :arena :minpreciousness:int :maxpreciousness:int :tmin:int :tmax:int", 
    function(sender, arena_name, min_preciousness, max_preciousness, t_min, t_max)
        local id, arena = arena_lib.get_arena_by_name("skywars", arena_name)
        local pos = vector.floor(minetest.get_player_by_name(sender):get_pos())
        local chest = 
        {
            pos = {x = pos.x, y= pos.y + 1, z = pos.z},
            min_preciousness = min_preciousness, 
            max_preciousness = max_preciousness,
            min_treasures = t_min,
            max_treasures = t_max,
            id = #arena.chests+1
        }

        if arena == nil then
            minetest.chat_send_player(sender, skywars_settings.prefix .. skywars.T("Arena not found!"))
            return
        elseif arena.enabled == true then
            minetest.chat_send_player(sender, skywars_settings.prefix .. skywars.T("@1 must be disabled!", arena_name))
            return
        elseif t_min <= 0 or t_max <= 0 then
            minetest.chat_send_player(sender, skywars_settings.prefix .. skywars.T("The minimum or maximum amount of treasures has to be greater than 0!"))
            return
        end

        minetest.chat_send_player(sender, skywars_settings.prefix .. skywars.T("Chest added!"))
        table.insert(arena.chests, chest)
        arena_lib.change_arena_property(sender, "skywars", arena_name, "chests", arena.chests, false)
    end)


    cmd:sub("getchests :arena", function(sender, arena_name)
        local id, arena = arena_lib.get_arena_by_name("skywars", arena_name)
        local found = false

        if arena == nil then
            minetest.chat_send_player(sender, skywars_settings.prefix .. skywars.T("Arena not found!"))
            return
        end

        minetest.chat_send_player(sender, skywars_settings.prefix .. skywars.T("CHEST LIST:"))
        for i=1, #arena.chests do
            local chest_pos = tostring(arena.chests[i].pos.x) .. " " .. tostring(arena.chests[i].pos.y) .. " " .. tostring(arena.chests[i].pos.z)
            minetest.chat_send_player(sender, skywars.T("ID: @1 - POSITION: @2", arena.chests[i].id, chest_pos))
        end
    end)
    

    
    cmd:sub("removechest :arena :id:int", function(sender, arena_name, chest_id)
        local id, arena = arena_lib.get_arena_by_name("skywars", arena_name)
        local found = false

        if arena == nil then
            minetest.chat_send_player(sender, skywars_settings.prefix .. skywars.T("Arena not found!"))
            return
        elseif arena.enabled == true then
            minetest.chat_send_player(sender, skywars_settings.prefix .. skywars.T("@1 must be disabled!", arena_name))
            return
        end

        for i=1, #arena.chests do
            if arena.chests[i].id == chest_id then
                table.remove(arena.chests, i)
                found = true
                break
            end 
        end
        arena_lib.change_arena_property(sender, "skywars", arena_name, "chests", arena.chests, false)

        if found then
            minetest.chat_send_player(sender, skywars_settings.prefix .. skywars.T("Chest removed!"))
        else
            minetest.chat_send_player(sender, skywars_settings.prefix .. skywars.T("Chest not found!"))
        end
    end)



    ------------------
    -- ! MAP CMDS ! --
    ------------------

    cmd:sub("pos1", function(sender)
        local player = minetest.get_player_by_name(sender)

        player:get_meta():set_string("pos1", minetest.serialize(player:get_pos()))
        minetest.chat_send_player(sender, skywars_settings.prefix .. skywars.T("Position saved!")) 
    end)



    cmd:sub("pos2", function(sender)
        local player = minetest.get_player_by_name(sender)

        player:get_meta():set_string("pos2", minetest.serialize(player:get_pos()))

        minetest.chat_send_player(sender, skywars_settings.prefix .. skywars.T("Position saved!")) 
    end)



    cmd:sub("createschematic :arena :name",
    function(sender, arena_name, name)
        local id, arena = arena_lib.get_arena_by_name("skywars", arena_name)
        local player = minetest.get_player_by_name(sender)
        local pos1 = minetest.deserialize(player:get_meta():get_string("pos1")) 
        local pos2 = minetest.deserialize(player:get_meta():get_string("pos2")) 

        if arena == nil then
            minetest.chat_send_player(sender, skywars_settings.prefix .. skywars.T("Arena not found!"))
            return
        end

        if arena.enabled == true then
            minetest.chat_send_player(sender, skywars_settings.prefix .. skywars.T("@1 must be disabled!", arena_name))
            return
        end

        if pos1 == "" or pos2 == "" then
            minetest.chat_send_player(sender, skywars_settings.prefix .. skywars.T("Pos1 or pos2 are not set!"))
            return
        end

        skywars.create_schematic(sender, {x = pos1.x, y = pos1.y, z = pos1.z}, {x = pos2.x, y = pos2.y, z = pos2.z}, name, arena)

        minetest.chat_send_player(sender, skywars_settings.prefix .. skywars.T("Schematic @1 created! You can use /skywars info @2 to know its folder (see schematic=PATH)", name, arena_name)) 
    end)



    cmd:sub("getpos", function(sender)

        function round(num, numDecimalPlaces)
            return string.format("%." .. (numDecimalPlaces or 0) .. "f", num)
        end

        local pos = minetest.get_player_by_name(sender):get_pos()
        local readable_pos = "[X Y Z] " .. round(pos.x, 1) .. " " .. round(pos.y, 1) .. " " .. round(pos.z, 1)

        minetest.chat_send_player(sender, readable_pos)
    end)

end, {

    description = [[

        Arena_lib:
        - tutorial

        - create <arena name> [min players] [max players]

        - edit <arena name>

        - remove <arena name>

        - info <arena name>

        - list

        - enable <arena name>

        - disable <arena name>


        Skywars commands:
        - addtreasure <arena name> <item> <rarity (min 2.0, max 1000.0)> 
        <preciousness> <count>
        
        - removetreasure <arena name> <treasure name>

        - gettreasures <arena name>

        - copytreasures <(from) arena name> <(to) arena name>: this will copy 
        the first arena treasures in to the second one (! the second one will 
        be overwritten !)

        - addchest <arena name> <min_preciousness> <max_preciousness> 
        <min_treasures_amount (min. 1)> <max_treasures_amount>

        - removechest <id>

        - getchests <arena name>: shows id and position of each chest 

        - pos1

        - pos2

        - createschematic <arena name> <pos1x> <pos1y> <pos1z> <pos2x> <pos2y>
        <pos2z> <schematic_name>

        - getpos
        ]],
    privs = { skywars_admin = true }
})



minetest.register_privilege("skywars_admin", {  
    description = "With this you can use /skywars"
})
  