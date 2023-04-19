local function find_changed_nodes() end
local function process_mapblock_queue() end

local pos_to_string = minetest.pos_to_string
local get_position_from_hash = minetest.get_position_from_hash
local changed_mapblocks_queue = {}
local hash_node_position = minetest.hash_node_position


minetest.register_on_mapblocks_changed(function(modified_blocks, modified_block_count)
    for pos, _ in pairs(modified_blocks) do
        pos = get_position_from_hash(pos)
        pos = pos*16
        local arena = skywars.get_arena_by_pos(pos)
        
        if not arena or not arena.enabled or arena.is_resetting then goto continue end

        changed_mapblocks_queue[pos] = arena

        ::continue::
    end
end)


function process_mapblock_queue()
    for pos, arena in pairs(changed_mapblocks_queue) do
        find_changed_nodes(arena, pos)
        changed_mapblocks_queue[pos] = nil
    end

    minetest.after(4, process_mapblock_queue)
end
process_mapblock_queue()



function skywars.save_map_nodes(arena)
    skywars.load_mapblocks(arena)

    local maps = skywars.maps
    local manip = minetest.get_voxel_manip()
	local emerged_pos1, emerged_pos2 = manip:read_from_map(arena.min_pos, arena.max_pos)
    local data = manip:get_data()
    local params2 = manip:get_param2_data()

	local emerged_area = VoxelArea:new({MinEdge=emerged_pos1, MaxEdge=emerged_pos2})
    local original_area = VoxelArea:new({MinEdge=arena.min_pos, MaxEdge=arena.max_pos})
    local get_inventory = minetest.get_inventory

    initialize_map_data(maps, arena)
    local map = maps[arena.name]
    map.always_to_be_reset_nodes = {}
    map.changed_nodes = {}
    map.original_nodes = {}

    -- Saving every node in the map.
	for i in emerged_area:iterp(emerged_pos1, emerged_pos2) do
        local p = emerged_area:position(i)
        local node_id = data[i]
        local param2 = params2[i]
        if param2 == 0 then param2 = nil end
        
        local string_pos = pos_to_string(p)
        local location = {type = "node", pos = p}
        local node = {node_id, param2}

        if original_area:containsp(p) and get_inventory(location) then
            map.always_to_be_reset_nodes[string_pos] = true
            map.changed_nodes[string_pos] = node
        end

        if not (node_id == minetest.CONTENT_AIR) then
            map.original_nodes[string_pos] = node
        end
	end

    skywars.save_map(arena.name, "complete")
end



function initialize_map_data(maps, arena)
    if not maps then maps = {} end
    if not maps[arena.name] then maps[arena.name] = {} end
    if not maps[arena.name].original_nodes then maps[arena.name].original_nodes = {} end
    if not maps[arena.name].changed_nodes then maps[arena.name].changed_nodes = {} end
    if not maps[arena.name].always_to_be_reset_nodes then maps[arena.name].always_to_be_reset_nodes = {} end
end



function find_changed_nodes(arena, p1)
    local maps = skywars.maps
    local manip = minetest.get_voxel_manip()
    local p2 = vector.add(p1, 15)
	p1, p2 = manip:read_from_map(p1, p2)

    local data = manip:get_data()

	local emerged_area = VoxelArea:new({MinEdge=p1, MaxEdge=p2})

    local map = maps[arena.name]

    -- Checking which nodes changed
	for i in emerged_area:iterp(p1, p2) do
        local p = emerged_area:position(i)
        local node_id = data[i]
        local string_pos = pos_to_string(p)
        local original_node = map.original_nodes[string_pos] or {minetest.CONTENT_AIR, 0}

        if not (node_id == original_node[1]) then
            map.changed_nodes[string_pos] = original_node
        end
	end
end
