local function save_node() end
local function delete_drops() end
local function async_reset_map() end
local function reset_node_inventory() end

function skywars.load_mapblocks(arena)
    minetest.load_area(arena.min_pos, arena.max_pos)
    minetest.emerge_area(arena.min_pos, arena.max_pos)
end



function skywars.reset_map(arena, debug, debug_data)
    if not arena.enabled or arena.is_resetting then return end

    skywars.load_mapblocks(arena)
    delete_drops(arena)
    async_reset_map(arena, debug, debug_data)
end



function skywars.kill_players_out_map(arena)
    for pl_name in pairs(arena.players) do
        local player = minetest.get_player_by_name(pl_name)
        local pl_pos = player:get_pos()
        local map_area = VoxelArea:new{MinEdge = arena.min_pos, MaxEdge = arena.max_pos}

        if map_area:contains(pl_pos.x, pl_pos.y, pl_pos.z) == false then
            player:set_hp(0)
        end
    end
end



minetest.register_on_placenode(function(pos, newnode, player, oldnode, itemstack, pointed_thing)
    local arena = arena_lib.get_arena_by_player(player:get_player_name())
    save_node(arena, pos, oldnode)

    if arena == nil then 
        arena = skywars.get_arena_by_pos(pos)
        if arena and arena.enabled then 
            save_node(arena, pos, oldnode)
        end
    end
end)



minetest.register_on_dignode(function(pos, oldnode, player)
    local arena = arena_lib.get_arena_by_player(player:get_player_name())
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



function save_node(arena, pos, node)
    local maps = skywars.load_table("maps")
    local serialized_pos = minetest.serialize(pos)

    if not arena then return end
    if not maps then maps = {} end
    if not maps[arena.name] then maps[arena.name] = {} end
    if not maps[arena.name].changed_nodes then maps[arena.name].changed_nodes = {} end

    -- If this block has not been changed yet then save it.
    if maps[arena.name].changed_nodes[serialized_pos] == nil then
        maps[arena.name].changed_nodes[serialized_pos] = node
        skywars.overwrite_table("maps", maps)
    end
end



function delete_drops(arena)
    local min_pos, max_pos = skywars.reorder_positions(arena.min_pos, arena.max_pos)
    local distance_from_center = vector.distance(min_pos, max_pos) / 2
    local map_center = {
        x = (min_pos.x + max_pos.x) / 2, 
        y = (min_pos.y + max_pos.y) / 2, 
        z = (min_pos.z + max_pos.z) / 2
    }
    
    for i, obj in pairs(minetest.get_objects_inside_radius(map_center, distance_from_center)) do
        if not obj:is_player() then
            local props = obj:get_properties()
            local entity_texture = props.textures[1]
            if props.automatic_rotate > 0 and ItemStack(entity_texture):is_known() then
                obj:remove()
            end 
        end
    end
end



function async_reset_map(arena, debug, recursive_data)
    recursive_data = recursive_data or {}

    -- When the function gets called again it uses the same maps table.
    local original_maps = recursive_data.original_maps or skywars.load_table("maps")
    if not original_maps[arena.name] or not original_maps[arena.name].changed_nodes then
        return 
    end

    debug = debug or false
    -- The indexes are useful to count the reset nodes.
    local current_index = 1
    local last_index = recursive_data.last_index or 0
    local original_nodes_to_reset = original_maps[arena.name].changed_nodes
    local nodes_per_tick = recursive_data.nodes_per_tick or skywars_settings.nodes_per_tick
    local initial_time = recursive_data.initial_time or minetest.get_us_time()

    -- Resets a node if it hasn't been reset yet and if it resets more than "nodes_per_tick" 
    -- nodes it invokes this function again after one step.
    arena.is_resetting = true
    for serialized_pos, node in pairs(original_nodes_to_reset) do
        if current_index > last_index then
            local pos = minetest.deserialize(serialized_pos)
            minetest.add_node(pos, node)
            reset_node_inventory(pos)
        end
        -- If more than nodes_per_tick nodes have been reset this cycle.
        if current_index - last_index >= nodes_per_tick then
            minetest.after(0, function()
                async_reset_map(arena, debug, {
                    last_index = current_index, 
                    nodes_per_tick = nodes_per_tick, 
                    original_maps = original_maps, 
                    initial_time = initial_time
                })
            end)
            return
        end

        current_index = current_index + 1
    end
    arena.is_resetting = false

    -- Removing the reset nodes from the current map table to preserve eventual
    -- changes made to the latter during the reset.
    local current_maps = skywars.load_table("maps")
    if not current_maps[arena.name] or not current_maps[arena.name].changed_nodes then
        return 
    end
    local current_nodes_to_reset = current_maps[arena.name].changed_nodes

    for serialized_pos, node in pairs(current_nodes_to_reset) do
        if not original_nodes_to_reset[serialized_pos] then goto continue end
        
        local old_node = original_nodes_to_reset[serialized_pos]
        local pos = minetest.deserialize(serialized_pos)
        local current_node = minetest.get_node(pos)
        local is_old_node_still_reset = (current_node.name == old_node.name)

        -- Checking if the node was modified again DURING the reset process but 
        -- AFTER being reset already.
        if is_old_node_still_reset then
            current_nodes_to_reset[serialized_pos] = nil
        end

        ::continue::
    end
    
    skywars.overwrite_table("maps", current_maps)

    if debug then
        local duration = minetest.get_us_time() - initial_time
        minetest.log("[Skywars Reset Debug] The reset took " .. duration/1000000 .. " seconds!")
    end
end



function reset_node_inventory(pos)
    local location = {type="node", pos = pos}
    local inv = minetest.get_inventory(location)
    if inv then 
        for index, list in ipairs(inv:get_lists()) do
            inv:set_list(list, {}) 
        end
    end
end