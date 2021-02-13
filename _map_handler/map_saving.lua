local function save_node() end
local get_inventory = minetest.get_inventory
local hash_node_position = minetest.hash_node_position


minetest.register_on_placenode(function(pos, newnode, player, oldnode, itemstack, pointed_thing)
    local pl_name = player:get_player_name()
    local arena = arena_lib.get_arena_by_player(pl_name)
    if arena_lib.get_mod_by_player(pl_name) ~= "skywars" then return end
    save_node(arena, pos, oldnode)

    if not arena then 
        arena = skywars.get_arena_by_pos(pos)
        if arena and arena.enabled then 
            save_node(arena, pos, oldnode)
        end
    end
end)



minetest.register_on_dignode(function(pos, oldnode, player)
    local pl_name = player:get_player_name()
    local arena = arena_lib.get_arena_by_player(pl_name)
    if arena_lib.get_mod_by_player(pl_name) ~= "skywars" then return end
    save_node(arena, pos, oldnode)

    if arena == nil then 
        arena = skywars.get_arena_by_pos(pos)
        if arena and arena.enabled then 
            save_node(arena, pos, oldnode)
        end
    end
end)



-- Minetest functions overrides.

local set_node = minetest.set_node
local get_node = minetest.get_node
function minetest.set_node(pos, node)
    local arena = skywars.get_arena_by_pos(pos)
    local oldnode = get_node(pos)
    
    if arena and arena.enabled then 
        save_node(arena, pos, oldnode) 
    end

	return set_node(pos, node)
end
function minetest.add_node(pos, node)
    minetest.set_node(pos, node)
end
function minetest.remove_node(pos)
    minetest.set_node(pos, {name="air"})
end

local swap_node = minetest.swap_node
function minetest.swap_node(pos, node)
    local arena = skywars.get_arena_by_pos(pos)
    local oldnode = minetest.get_node(pos)
    
    if arena and arena.enabled then 
        save_node(arena, pos, oldnode) 
    end

    return swap_node(pos, node)
end



function skywars.save_nodes_with_inventories(arena)
    skywars.load_mapblocks(arena)

    local maps = skywars.load_table("maps")
    local manip = minetest.get_voxel_manip()
	local emerged_pos1, emerged_pos2 = manip:read_from_map(arena.min_pos, arena.max_pos)
	local emerged_area = VoxelArea:new({MinEdge=emerged_pos1, MaxEdge=emerged_pos2})
    local original_area = VoxelArea:new({MinEdge=arena.min_pos, MaxEdge=arena.max_pos})
    local get_inventory = minetest.get_inventory
    local hash_node_position = minetest.hash_node_position
    local get_node = minetest.get_node

    initialize_map_data(maps, arena)
    local map = maps[arena.name]
    map.always_to_be_reset_nodes = {}
    map.changed_nodes = {}

    -- Saving every node with an inventory.
	for i in emerged_area:iterp(emerged_pos1, emerged_pos2) do
        local node_pos = emerged_area:position(i)
        local hash_pos = hash_node_position(node_pos)
        local location = {type = "node", pos = node_pos}

        if original_area:containsp(node_pos) and get_inventory(location) then
            local node = get_node(node_pos)

            map.always_to_be_reset_nodes[hash_pos] = true
            map.changed_nodes[hash_pos] = node
        end
	end

    skywars.overwrite_table("maps", maps)
end



function save_node(arena, pos, node)
    local maps = skywars.load_table("maps")
    local hash_pos = hash_node_position(vector.round(pos))

    if not arena then return end
    initialize_map_data(maps, arena)

    -- If this block has not been changed yet then save it.
    if not maps[arena.name].changed_nodes[hash_pos] then
        maps[arena.name].changed_nodes[hash_pos] = node
        skywars.overwrite_table("maps", maps)
    end
end



function initialize_map_data(maps, arena)
    if not maps then maps = {} end
    if not maps[arena.name] then maps[arena.name] = {} end
    if not maps[arena.name].changed_nodes then maps[arena.name].changed_nodes = {} end
    if not maps[arena.name].always_to_be_reset_nodes then maps[arena.name].always_to_be_reset_nodes = {} end
end



--
-- ! LEGACY SUPPORT FOR SERIALIZED POSITIONS.
-- Converting all the serialized positions into
-- hashes.
--
local maps = skywars.load_table("maps")

for arena_name, map in pairs(maps) do
    initialize_map_data(maps, {name = arena_name})

    for pos, node in pairs(map.changed_nodes) do
        if minetest.deserialize(pos) then
            local hash_pos = minetest.hash_node_position(minetest.deserialize(pos))
            map.changed_nodes[pos] = nil
            map.changed_nodes[hash_pos] = node
        end
    end
    for pos, bool in pairs(map.always_to_be_reset_nodes) do
        if type(pos) == "string" then
            local hash_pos = minetest.hash_node_position(minetest.deserialize(pos))
            map.always_to_be_reset_nodes[pos] = nilf
            map.always_to_be_reset_nodes[hash_pos] = bool
        end
    end
end

skywars.overwrite_table("maps", maps)