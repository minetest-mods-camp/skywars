local function find_changed_nodes() end
local function process_mapblock_queue() end
local function initialize_map_data() end

local get_position_from_hash = minetest.get_position_from_hash
local changed_mapblocks_queue = Queue.new()
local get_voxel_manip = minetest.get_voxel_manip
local get_name_from_content_id = minetest.get_name_from_content_id



minetest.register_on_mapblocks_changed(function(modified_blocks, modified_block_count)
    for pos, _ in pairs(modified_blocks) do
        pos = get_position_from_hash(pos)
        pos = pos*16
        local arena = skywars.get_arena_by_pos(pos)

        if not arena then goto continue end

        local arena_area = VoxelArea:new({MinEdge=arena.min_pos, MaxEdge=arena.max_pos})
        local i = arena_area:indexp(pos)

        if (not arena) or (not arena.enabled) or arena.is_resetting or Queue.is_tracked(changed_mapblocks_queue, i) then
            goto continue
        end

        Queue.pushright(changed_mapblocks_queue, {arena, pos}, i)

        ::continue::
    end
end)


function process_mapblock_queue()
    for i=1, skywars_settings.max_processed_mapblocks_per_iteration, 1 do
        local node = Queue.popleft(changed_mapblocks_queue)
        if not node then break end

        changed_mapblocks_queue.track_keys[node[1]] = nil
        find_changed_nodes(node[1], node[2])
    end

    minetest.after(0, process_mapblock_queue)
end
process_mapblock_queue()



function skywars.save_map_nodes(arena)
    skywars.load_mapblocks(arena)

    local maps = skywars.maps
    local manip = get_voxel_manip()
	
    local emerged_pos1, emerged_pos2 = manip:read_from_map(arena.min_pos, arena.max_pos)
    arena.min_pos = emerged_pos1
    arena.max_pos = emerged_pos2

    local data = manip:get_data()
    local params2 = manip:get_param2_data()

	local emerged_area = VoxelArea:new({MinEdge=emerged_pos1, MaxEdge=emerged_pos2})

    initialize_map_data(maps, arena)
    local map = maps[arena.name]
    map.changed_nodes = Queue.new()
    map.original_nodes = {}

    -- Saving every node in the map.
	for i in emerged_area:iterp(emerged_pos1, emerged_pos2) do
        local p = emerged_area:position(i)
        local node_name = get_name_from_content_id(data[i])
        local param2 = params2[i]
        if param2 == 0 then param2 = nil end
        
        local node = {node_name, param2}

        if node_name ~= "air" and node_name ~= "ignore" and node_name ~= "unknown" then
            map.original_nodes[i] = node
        end
	end

    skywars.save_map(arena.name, "complete")
end



-- this won't be used when performance is needed
function skywars.get_map_node_at(arena, pos)
    local area = VoxelArea:new({MinEdge=arena.min_pos, MaxEdge=arena.max_pos})
    local original_nodes = skywars.maps[arena.name].original_nodes

    local i = area:indexp(pos)
    return i, original_nodes[i] or {"air"}
end



function initialize_map_data(maps, arena)
    if not maps then maps = {} end
    if not maps[arena.name] then maps[arena.name] = {} end
    if not maps[arena.name].original_nodes then maps[arena.name].original_nodes = {} end
    if not maps[arena.name].changed_nodes then maps[arena.name].changed_nodes = {} end
end



function find_changed_nodes(arena, p1)
    local maps = skywars.maps
    local manip = get_voxel_manip()
    local p2 = vector.add(p1, 15)
	p1, p2 = manip:read_from_map(p1, p2)

    local data = manip:get_data()

	local emerged_area = VoxelArea:new({MinEdge=p1, MaxEdge=p2})
	local arena_area = VoxelArea:new({MinEdge=arena.min_pos, MaxEdge=arena.max_pos})

    local map = maps[arena.name]

    -- Checking which nodes changed
	for i in emerged_area:iterp(p1, p2) do
        local p = emerged_area:position(i)
        local node_name = get_name_from_content_id(data[i])
        local i = arena_area:indexp(p)
        local original_node = map.original_nodes[i] or {"air"}

        if node_name ~= original_node[1] and not Queue.is_tracked(map.changed_nodes, i) then
            map.changed_nodes[i] = original_node
            Queue.pushright(map.changed_nodes, {i, original_node}, i)
        end
	end
end



minetest.register_on_placenode(function(pos, newnode, player, oldnode)
    local arena = skywars.get_arena_by_pos(pos)
    if not arena then return end

    local i, node = skywars.get_map_node_at(arena, pos)
    Queue.pushright(skywars.maps[arena.name].changed_nodes, {i, node}, i)
end)



minetest.register_on_dignode(function(pos, oldnode, player)
    local arena = skywars.get_arena_by_pos(pos)
    if not arena then return end

    local i, node = skywars.get_map_node_at(arena, pos)
    Queue.pushright(skywars.maps[arena.name].changed_nodes, {i, node}, i)
end)



-- Minetest functions overrides.

local set_node = minetest.set_node
function minetest.set_node(pos, node)
    local arena = skywars.get_arena_by_pos(pos)
    
    if arena and arena.enabled and not arena.is_resetting then
        local i, node = skywars.get_map_node_at(arena, pos)
        Queue.pushright(skywars.maps[arena.name].changed_nodes, {i, node}, i)
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
    
    if arena and arena.enabled and not arena.is_resetting then
        local i, node = skywars.get_map_node_at(arena, pos)
        Queue.pushright(skywars.maps[arena.name].changed_nodes, {i, node}, i)
    end

    return swap_node(pos, node)
end
