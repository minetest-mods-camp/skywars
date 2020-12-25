local function save_node() end


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



function skywars.save_nodes_with_inventories(arena)
    local maps = skywars.load_table("maps")
    initialize_map_data(maps, arena)
    skywars.overwrite_table("maps", maps)

    skywars.iterate_area_nodes(arena.min_pos, arena.max_pos, function(node, node_pos)
        local location = {type="node", pos=node_pos}
        local node_inv = minetest.get_inventory(location)

        if node_inv then
            save_node(arena, node_pos, node, "has_inventory")
        end
    end)
end



function save_node(arena, pos, node, has_inventory)
    local maps = skywars.load_table("maps")
    local serialized_pos = minetest.serialize(pos)

    if not arena then return end
    initialize_map_data(maps, arena)

    -- If this block has not been changed yet then save it.
    if maps[arena.name].changed_nodes[serialized_pos] == nil then
        if has_inventory then
            maps[arena.name].always_to_be_reset_nodes[serialized_pos] = true
        end
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