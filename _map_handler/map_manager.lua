local function get_arena_by_pos(pos)
    for i, arena in pairs(arena_lib.mods["skywars"].arenas) do
        if arena.pos1.x == nil or arena.pos2.x == nil then goto continue end

        local map_area = VoxelArea:new{MinEdge = arena.pos1, MaxEdge = arena.pos2}
        local serialized_pos = minetest.serialize(pos)

        if map_area:contains(pos.x, pos.y, pos.z) then
            return arena
        end

        ::continue::
    end
end



local function save_block(arena, pos, node)
    local maps = skywars.load_maps()
    local serialized_pos = minetest.serialize(pos)

    if arena and maps[serialized_pos] == nil then

        maps[serialized_pos] = node

        skywars.overwrite_maps(maps)
    end
end



function skywars.reset_map(arena)
    local maps = skywars.load_maps()

    if not maps or maps == "" then return end
    for serialized_pos, node in pairs(maps) do
        local pos = minetest.deserialize(serialized_pos)
        minetest.add_node(pos, node)
    end
    maps = {}
    skywars.overwrite_maps(maps)
end



function skywars.kill_players_out_map(arena)
    for pl_name in pairs(arena.players) do
        local player = minetest.get_player_by_name(pl_name)
        local pl_pos = player:get_pos()
        local map_area = VoxelArea:new{MinEdge = arena.pos1, MaxEdge = arena.pos2}

        if map_area:contains(pl_pos.x, pl_pos.y, pl_pos.z) == false then
            player:set_hp(0)
        end
    end
end



minetest.register_on_placenode(function(pos, newnode, player, oldnode, itemstack, pointed_thing)
    local arena = arena_lib.get_arena_by_player(player:get_player_name())
    save_block(arena, pos, oldnode)

    if arena == nil then 
        arena = get_arena_by_pos(pos)
        if arena and arena.enabled then 
            save_block(arena, pos, oldnode)
        end
    end
end)



minetest.register_on_dignode(function(pos, oldnode, player)
    local arena = arena_lib.get_arena_by_player(player:get_player_name())
    save_block(arena, pos, oldnode)

    if arena == nil then 
        arena = get_arena_by_pos(pos)
        if arena and arena.enabled then 
            save_block(arena, pos, oldnode)
        end
    end
end)



-- minetest.set_node override
local set_node = minetest.set_node
function minetest.set_node(pos, node)
    local arena = get_arena_by_pos(pos)
    local oldnode = minetest.get_node(pos)
    
    if arena and arena.enabled then save_block(arena, pos, oldnode) end

	return set_node(pos, node)
end



function minetest.add_node(pos, node)
    minetest.set_node(pos, node)
end
function minetest.remove_node(pos)
    minetest.set_node(pos, {name="air"})
end