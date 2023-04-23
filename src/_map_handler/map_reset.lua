local function async_reset_map() end
local function reset_node_inventory() end
local function get_node_from_data() end

local on_step = minetest.registered_entities["__builtin:item"].on_step
minetest.registered_entities["__builtin:item"].match_id = -2
minetest.registered_entities["__builtin:item"].last_age = 0
local add_node = minetest.add_node
local get_inventory = minetest.get_inventory



function skywars.reset_map(arena, debug, debug_data)
    if not arena.enabled or arena.is_resetting then return end
    local arena_area = VoxelArea:new({MinEdge=arena.min_pos, MaxEdge=arena.max_pos})

    Queue.sort(skywars.maps[arena.name].changed_nodes, function (a, b)
        return arena_area:position(a[1]).y > arena_area:position(b[1]).y
    end)
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

    local nodes_to_reset = maps[arena.name].changed_nodes
    local nodes_per_tick = recursive_data.nodes_per_tick or skywars_settings.nodes_per_tick
    local initial_time = recursive_data.initial_time or minetest.get_us_time()

    local arena_area = VoxelArea:new({MinEdge=arena.min_pos, MaxEdge=arena.max_pos})

    -- Resets a node if it hasn't been reset yet and, if it resets more than "nodes_per_tick" 
    -- nodes, invokes this function again after one step.
    arena.is_resetting = true
    for reset_nodes = 0, nodes_per_tick+1 do
        if Queue.size(nodes_to_reset) <= 0 then break end

        local node_data = Queue.popleft(nodes_to_reset)
        local i = node_data[1]
        nodes_to_reset.tracked_elems[i] = nil
        local node = get_node_from_data(node_data[2])
        local pos = arena_area:position(i)

        add_node(pos, node)

        reset_node_inventory(pos)

        -- If more than nodes_per_tick nodes have been reset this cycle.
        if reset_nodes == nodes_per_tick then
            minetest.after(0, function()
                async_reset_map(arena, debug, {
                    nodes_per_tick = nodes_per_tick,
                    initial_time = initial_time
                })
            end)
            return
        end
    end
    arena.is_resetting = false

    skywars.save_map(arena.name)

    if debug then
        local duration = minetest.get_us_time() - initial_time
        minetest.log("[Skywars Reset Debug] The reset took " .. duration/1000000 .. " seconds!")

        return duration
    end

    -- to remove flowing fluids
    minetest.after(2, function ()
        if Queue.size(nodes_to_reset) > 0 then
            skywars.reset_map(arena, debug)
        end
    end)
end



function reset_node_inventory(pos)
    local location = {type="node", pos = pos}
    local inv = get_inventory(location)
    if inv then
        for _, list in ipairs(inv:get_lists()) do
            inv:set_list(list, {})
        end
    end
end


function get_node_from_data(node_data)
    return {name=node_data[1], param2=node_data[2] or 0}
end


minetest.register_on_mods_loaded(function()
    for i, arena in pairs(arena_lib.mods["skywars"].arenas) do
      arena.is_resetting = false
    end
end)
