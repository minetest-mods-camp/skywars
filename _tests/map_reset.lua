local function test_not_async_reset() end
local function test_async_reset() end
local function place_nodes_at_arena_edges() end
local function get_nodes_at_arena_edges() end


function skywars.map_reset_test(arena)
    return test_not_async_reset(arena) and test_async_reset(arena)
end



function skywars.test_async_speed(arena)
    skywars.reorder_positions(arena.min_pos, arena.max_pos)
    skywars.load_mapblocks(arena)

    local area_size = 10
    local min_pos = arena.min_pos
    local max_pos = vector.add(min_pos, area_size)

    skywars.iterate_area_nodes(min_pos, max_pos, function(node, node_pos)
        minetest.set_node(node_pos, {name="skywars:test_node"})
    end)

    minetest.after(1, function() skywars.reset_map(arena, true) end)
end



function test_not_async_reset(arena)
    place_nodes_at_arena_edges(arena)

    skywars.reset_map(arena)
    local node1, node2 = get_nodes_at_arena_edges(arena)

    local did_nodes_reset = (node1.name ~= "skywars:test_node" and node2.name ~= "skywars:test_node")
    if not did_nodes_reset then
        minetest.log("[Skywars Test] Reset system doesn't work")
        return false
    end

    return true
end



function test_async_reset(arena)
    place_nodes_at_arena_edges(arena)

    skywars.reset_map(arena, true, {nodes_per_tick = 1})
    local node1, node2 = get_nodes_at_arena_edges(arena)

    local did_just_one_node_reset = (node1.name ~= node2.name)
    if not did_just_one_node_reset then
        minetest.log("[Skywars Test] Async reset system doesn't work")
        return false
    end

    return true
end



function place_nodes_at_arena_edges(arena)
    skywars.reorder_positions(arena.min_pos, arena.max_pos)
    skywars.load_mapblocks(arena)

    local node1, node2 = get_nodes_at_arena_edges(arena)

    if node1.name == "skywars:test_node" then minetest.remove_node(arena.min_pos) end
    if node2.name == "skywars:test_node" then minetest.remove_node(arena.max_pos) end
    skywars.overwrite_table("maps", {})

    minetest.set_node(arena.min_pos, {name="skywars:test_node"})
    minetest.set_node(arena.max_pos, {name="skywars:test_node"})

    node1 = minetest.get_node(arena.min_pos)
    node2 = minetest.get_node(arena.max_pos)
end



function get_nodes_at_arena_edges(arena)
    local node1 = minetest.get_node(arena.min_pos)
    local node2 = minetest.get_node(arena.max_pos)

    return node1, node2
end



minetest.register_node("skywars:test_node", {
    description = "Skywars test block, don't use it!",
    groups = {crumbly=1, soil=1, dig_immediate=3},
    tiles = {"node_test.png"},
})



minetest.register_on_mods_loaded(function() 
    for i, arena in pairs(arena_lib.mods["skywars"].arenas) do
      arena.is_resetting = false
    end
end)