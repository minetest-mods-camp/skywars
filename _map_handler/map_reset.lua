local function delete_drops() end
local function async_reset_map() end
local function reset_node_inventory() end
local get_position_from_hash =  minetest.get_position_from_hash
local hash_node_position = minetest.hash_node_position
local deserialize = minetest.deserialize
local add_node = minetest.add_node
local get_node = minetest.get_node
local get_inventory = minetest.get_inventory
local on_step = minetest.registered_entities["__builtin:item"].on_step
minetest.registered_entities["__builtin:item"].match_id = -2


function skywars.reset_map(arena, debug, debug_data)
    if not arena.enabled or arena.is_resetting then return end

    skywars.load_mapblocks(arena)
    async_reset_map(arena, debug, debug_data)
end



-- Removing drops based on the match_id. 
minetest.registered_entities["__builtin:item"].on_step = function(self, dtime, moveresult)
    local pos = self.object:get_pos()
    local arena = skywars.get_arena_by_pos(pos)

    if arena and arena.match_id then
        -- If the drop has not been initializated yet.
        if self.match_id == -2 then 
            self.match_id = arena.match_id
        elseif self.match_id ~= arena.match_id then
            self.object:remove()
            return
        end
    elseif arena then
        self.object:remove()
        return
    end

    on_step(self, dtime, moveresult)
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
    for hash_pos, node in pairs(original_nodes_to_reset) do
        if current_index > last_index then
            local pos = get_position_from_hash(hash_pos)

            add_node(pos, node)
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

    for hash_pos, node in pairs(current_nodes_to_reset) do
        local always_to_be_reset = original_maps[arena.name].always_to_be_reset_nodes[hash_pos]
        if not original_nodes_to_reset[hash_pos] or always_to_be_reset then
            goto continue
        end
        
        local old_node = original_nodes_to_reset[hash_pos]
        local pos = get_position_from_hash(hash_pos)

        local current_node = get_node(pos)
        local is_old_node_still_reset = (current_node.name == old_node.name)

        -- Checking if the node was modified again DURING the reset process but 
        -- AFTER being reset already.
        if is_old_node_still_reset then
            current_nodes_to_reset[hash_pos] = nil
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
    local inv = get_inventory(location)
    if inv then 
        for index, list in ipairs(inv:get_lists()) do
            inv:set_list(list, {}) 
        end
    end
end



minetest.register_on_mods_loaded(function() 
    for i, arena in pairs(arena_lib.mods["skywars"].arenas) do
      arena.is_resetting = false
    end
end)