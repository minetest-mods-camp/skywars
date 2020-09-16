--[[
                            ! WARNING !
Don't change the variables' names if you don't know what you're doing

(skywars_settings.variable_name = value)
]]



-- ARENA LIB'S SETTINGS --

-- The table that stores all the global variables, don't touch this.
skywars_settings = {}

-- Where players will be teleported when a match ends.
skywars_settings.hub_spawn_point = {x = -177, y = 8.5, z = 247}

--  The time between the loading state and the start of the match.
skywars_settings.loading_time = 10

-- The time to wait before the loading phase starts. It gets triggered when the minimium amount of players has been reached to start the queue.
skywars_settings.queue_waiting_time = 10

-- The time between the end of the match and the respawn at the hub.
skywars_settings.celebration_time = 3

-- What's going to appear in most of the lines printed by murder.
skywars_settings.prefix = "Skywars > "

-- The players walking speed when ther're playing a match
skywars_settings.player_speed = 1

-- The match duration in seconds
skywars_settings.timer = 600




-- HUDS SETTINGS --


--[[ COORDINATES SYSTEM
For X and Y, 0.0 and 1.0 represent opposite edges of the game window, for example:
    * [0.0, 0.0] is the top left corner of the game window
    * [1.0, 1.0] is the bottom right of the game window
    * [0.5, 0.5] is the center of the game window
--]]



-- The texture background for the kit menu
skywars_settings.hud__kit_background = "Kits.png"

-- The width of the bacgkround texture in real coordinates,
-- a unit of measurement which is roughly around 64 pixels, but 
-- varies based on the screen density and scaling settings of the client
skywars_settings.background_width = 12

-- The height of the bacgkround texture in real coordinates
skywars_settings.background_height = 12

-- The x position of the first buttons row
skywars_settings.starting_x = 1.7

-- The y position of the first buttons row
skywars_settings.starting_y = 6.9

-- The horizontal distance betweek buttons in real coordinates 
skywars_settings.distance_x = 3.4

-- The vertical distance betweek buttons in real coordinates
skywars_settings.distance_y = 3

-- The amount of buttons in a row
skywars_settings.buttons_per_row = 3

-- The buttons width in real coordinates
skywars_settings.buttons_width = 2.2

-- The buttons height in real coordinates
skywars_settings.buttons_height = 2

