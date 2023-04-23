--[[
                            ! WARNING !
Don't change the variables names if you don't know what you're doing!

(skywars_settings.variable_name = value)
]]

-- The table that stores all the global variables, don't touch this.
skywars_settings = {}



-- ARENA LIB'S SETTINGS --


--  The time between the loading state and the start of the match.
skywars_settings.loading_time = 10

-- The time between the end of the match and the respawn at the hub.
skywars_settings.celebration_time = 5

-- What's going to appear in most of the lines printed by skywars.
skywars_settings.prefix = "Skywars > "

-- The players walking speed when they're playing a match.
skywars_settings.player_speed = 1.5

-- true = on/false = off (case sensitive).
skywars_settings.fall_damage_disabled = true

-- The name of the permission to allow players to break nodes
-- (if there's none just set it to "").
skywars_settings.build_permission = "build"




-- HUDS SETTINGS --


-- Real coordinates:
-- a unit of measurement which is roughly around 64 pixels, but
-- varies based on the screen density and scaling settings of the client.


-- The background width in real coordinates
skywars_settings.background_width = 11

-- The background height in real coordinates
skywars_settings.background_height = 11

-- The x position offset from the background border of the first buttons row
-- in real coordinates, the bigger it is the righter the row will be placed.
--[[
              1.7
       |------|--------------------> x
       |      |
	   |  * * * Background  * * *
       |  *   |                 *
       |  *   |                 *  
   6.6 ---*-- Button1 Button2   *  --> FIRST ROW
       |  *   Button3 Button4   *
       |  *                     *
       |  *                     *
       |  * * * * * * * * * * * *
       |
	   \/ y     
]]
skywars_settings.starting_x = 1.7

-- The y position offset from the background border of the first buttons row
-- in real coordinates, the bigger it is the lower the row will be placed.
skywars_settings.starting_y = 6.6

-- The horizontal distance between buttons in real coordinates.
skywars_settings.distance_x = 3.1

-- The vertical distance between buttons in real coordinates.
skywars_settings.distance_y = 3

-- The amount of buttons in a row.
skywars_settings.buttons_per_row = 3

-- The buttons width in real coordinates.
skywars_settings.buttons_width = 1.8

-- The buttons height in real coordinates.
skywars_settings.buttons_height = 1.6




-- AUTO EQUIP. SYSTEM --


-- The items importances that are used by the auto equip system:
-- when a player takes an item from a chest, if it has a greater
-- importance and it's in the same group of the one in the hotbar,
-- the latter gets replaced.
skywars_settings.items_importances = {
    pickaxe = {
        ["default:pick_wood"] = 0,
        ["default:pick_stone"] = 1,
        ["default:pick_bronze"] = 2,
        ["default:pick_steel"] = 3,
        ["default:pick_diamond"] = 4,
        ["default:pick_mese"] = 5,
    },
    sword = {
        ["default:sword_wood"] = 0,
        ["default:sword_stone"] = 1,
        ["default:sword_bronze"] = 2,
        ["default:sword_steel"] = 3,
        ["default:sword_diamond"] = 4,
        ["default:sword_mese"] = 5,
    },
    shovel = {
        ["default:shovel_wood"] = 0,
        ["default:shovel_stone"] = 1,
        ["default:shovel_bronze"] = 2,
        ["default:shovel_steel"] = 3,
        ["default:shovel_diamond"] = 4,
        ["default:shovel_mese"] = 5,
    },
    axe = {
        ["default:axe_wood"] = 0,
        ["default:axe_stone"] = 1,
        ["default:axe_bronze"] = 2,
        ["default:axe_steel"] = 3,
        ["default:axe_diamond"] = 4,
        ["default:axe_mese"] = 5,
    }
}




-- MAP RESET SYSTEM SETTINGS --


-- The amount of nodes to reset each step, the higher you set it the faster
-- it will go, but it will make the server lag more.
skywars_settings.nodes_per_tick = 40


-- The amount of mapblocks to scan for when searching for modified nodes in
-- your arenas. The higher you set it the faster it will detect modification
-- but if you set a value that's too high the server will stutter.
skywars_settings.max_processed_mapblocks_per_iteration = 6



-- ARMOR 3D SETTINGS --


skywars_settings.remove_armors_on_join = true

-- The armors importances that are used by the auto equip system:
-- when a player takes an armor from a chest, if it has a greater
-- importance that the already equipped one, the latter gets replaced.
-- If the armor name contains one of this materials then the
-- corresponding importance will be associated with it.
skywars_settings.armors_importances = {
    ["cactus"] = 0,
    ["wood"] = 1,
    ["gold"] = 2,
    ["bronze"] = 3,
    ["steel"] = 4,
    ["mithril"] = 5,
    ["diamond"] = 6
}