local function async_reset_map() end
local function reset_node_inventory() end
local function get_node_from_data() end

local on_step = minetest.registered_entities["__builtin:item"].on_step
minetest.registered_entities["__builtin:item"].match_id = -2
minetest.registered_entities["__builtin:item"].last_age = 0
local hash_node_position = minetest.hash_node_position
local add_node = minetest.add_node
local get_node = minetest.get_node
local get_inventory = minetest.get_inventory
local get_name_from_content_id = minetest.get_name_from_content_id
local string_to_pos = minetest.string_to_pos
local get_position_from_hash = minetest.get_position_from_hash


function skywars.reset_map(arena, debug, debug_data)
    if not arena.enabled or arena.is_resetting then return end

    skywars.load_mapblocks(arena)
    async_reset_map(arena, debug, debug_data)
end



-- Removing drops based on the match_id. 
minetest.registered_entities["__builtin:item"].on_step = function(self, dtime, moveresult)
    -- Returning if it passed less than 1s from the last check.
    if self.age - self.last_age < 1 then
        on_step(self, dtime, moveresult)
        return
    end

    local pos = self.object:get_pos()
    local arena = skywars.get_arena_by_pos(pos)
    self.last_age = self.age

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
    local maps = skywars.maps
    if not maps[arena.name] or not maps[arena.name].changed_nodes then
        return
    end

    -- The indexes are useful to count the reset nodes.
    local current_index = 1
    local last_index = recursive_data.last_index or 0
    local nodes_to_reset = maps[arena.name].changed_nodes
    local nodes_per_tick = recursive_data.nodes_per_tick or skywars_settings.nodes_per_tick
    local initial_time = recursive_data.initial_time or minetest.get_us_time()

    -- Resets a node if it hasn't been reset yet and, if it resets more than "nodes_per_tick" 
    -- nodes, invokes this function again after one step.
    arena.is_resetting = true
    for string_pos, node_data in pairs(nodes_to_reset) do
        local node = get_node_from_data(node_data)
        
        local pos = string_to_pos(string_pos)

        if not maps[arena.name].always_to_be_reset_nodes[string_pos] then
            nodes_to_reset[string_pos] = nil
        end

        add_node(pos, node)

        reset_node_inventory(pos)

        -- If more than nodes_per_tick nodes have been reset this cycle.
        if current_index - last_index >= nodes_per_tick then
            minetest.after(0, function()
                async_reset_map(arena, debug, {
                    last_index = current_index,
                    nodes_per_tick = nodes_per_tick,
                    initial_time = initial_time
                })
            end)
            return
        end

        current_index = current_index + 1
    end
    arena.is_resetting = false

    if debug then
        local duration = minetest.get_us_time() - initial_time
        minetest.log("[Skywars Reset Debug] The reset took " .. duration/1000000 .. " seconds!")
    end

    skywars.save_map(arena.name)
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


function get_node_from_data(node_data)
    return {name=get_name_from_content_id(node_data[1]), param2=node_data[2] or 0}
end


minetest.register_on_mods_loaded(function()
    for i, arena in pairs(arena_lib.mods["skywars"].arenas) do
      arena.is_resetting = false
    end
end)
