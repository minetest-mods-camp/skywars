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
skywars_settings.loading_time = 5

-- The time to wait before the loading phase starts. It gets triggered when the minimium amount of players has been reached to start the queue.
skywars_settings.queue_waiting_time = 10

-- The time between the end of the match and the respawn at the hub.
skywars_settings.celebration_time = 3

-- What's going to appear in most of the lines printed by murder.
skywars_settings.prefix = "Skywars > "

-- Whether to show the players nametags while in game.
-- false = don't / true = do
skywars_settings.show_nametags = false

-- Whether to allow players to use the builtin minimap function.
skywars_settings.show_minimap = false

-- The players walking speed when ther're playing a match
skywars_settings.player_speed = 1

