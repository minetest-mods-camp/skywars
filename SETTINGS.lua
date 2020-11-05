--[[
                            ! WARNING !
Don't change the variables names if you don't know what you're doing!

(skywars_settings.variable_name = value)
]]

-- The table that stores all the global variables, don't touch this.
skywars_settings = {}



-- ARENA LIB'S SETTINGS --


-- Where players will be teleported when a match ends.
skywars_settings.hub_spawn_point = {x = 81, y = 25, z = 102}

--  The time between the loading state and the start of the match.
skywars_settings.loading_time = 10

-- The time to wait before the loading phase starts. 
-- It gets triggered when the minimium amount of players has been reached to start the queue.
skywars_settings.queue_waiting_time = 10

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


-- The texture background for the kit menu.
skywars_settings.hud_kit_background = "Kits.png"

-- The background width in real coordinates
skywars_settings.background_width = 11

-- The background height in real coordinates
skywars_settings.background_height = 11

-- The x position offset from the background border of the first buttons row 
-- in real coordinates, the bigger it is the righter the row will be placed.
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




-- MAP RESET SYSTEM SETTINGS -- 


-- The amount of nodes to reset each step, the higher you set it the faster
-- it will go, but it will make the server lag more.
skywars_settings.nodes_per_tick = 20




-- ARMOR 3D SETTINGS --


skywars_settings.remove_armors_on_join = true