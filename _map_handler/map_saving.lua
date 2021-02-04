local function save_node() end


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
function minetest.set_node(pos, node)
    local arena = skywars.get_arena_by_pos(pos)
    local oldnode = minetest.get_node(pos)
    
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
	local area = VoxelArea:new({MinEdge=emerged_pos1, MaxEdge=emerged_pos2})
    local nodes = manip:get_data()
    local get_inventory = minetest.get_inventory
    local get_name_from_content_id = minetest.get_name_from_content_id
    local serialize = minetest.serialize
    local get_node = minetest.get_node

    initialize_map_data(maps, arena)
    maps[arena.name].always_to_be_reset_nodes = {}

    -- Saving every node with an inventory.
	for i in area:iterp(emerged_pos1, emerged_pos2) do
        local node_pos = area:position(i)
        local location = {type="node", pos=node_pos}

        if get_inventory(location) then
            local node = get_node(node_pos)
            local serialized_pos = serialize(node_pos)
 
            maps[arena.name].always_to_be_reset_nodes[serialized_pos] = true
            maps[arena.name].changed_nodes[serialized_pos] = node
        end
	end

    skywars.overwrite_table("maps", maps)
end



function save_node(arena, pos, node)
    local maps = skywars.load_table("maps")
    local serialized_pos = minetest.serialize(pos)

    if not arena then return end
    initialize_map_data(maps, arena)

    -- If this block has not been changed yet then save it.
    if maps[arena.name].changed_nodes[serialized_pos] == nil then
        maps[arena.name].changed_nodes[serialized_pos] = node
        skywars.overwrite_table("maps", maps)
    end
end



function initialize_map_data(maps, arena)
    if not maps then maps = {} end
    if not maps[arena.name] then maps[arena.name] = {} end
    if not maps[arena.name].changed_nodes then maps[arena.name].changed_nodes = {} end
    if not maps[arena.name].always_to_be_reset_nodes then maps[arena.name].always_to_be_reset_nodes = {} end
end