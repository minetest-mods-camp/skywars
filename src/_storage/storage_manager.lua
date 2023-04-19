local storage = minetest.get_mod_storage()
local sw_world_folder = minetest.get_worldpath("skywars").."/skywars/"
minetest.mkdir(sw_world_folder)

skywars.st = storage
skywars.maps = {}


function skywars.load_table(file_name)
    if table.indexof(minetest.get_dir_list(sw_world_folder, false), file_name) > 0 then
        return serialize_lib.read_table_from_file(sw_world_folder..file_name)
    else
        return {}
    end
end



function skywars.overwrite_table(file_name, table)
    serialize_lib.write_table_to_file(table, sw_world_folder..file_name)
end



function skywars.save_map(name, complete)
    local m = skywars.maps[name]

    skywars.overwrite_table(name.."_changed_nodes", m.changed_nodes)

    if complete then
        skywars.overwrite_table(name.."_original_nodes", m.original_nodes)
        skywars.overwrite_table(name.."_always_to_be_reset_nodes", m.always_to_be_reset_nodes)
    end
end



function skywars.load_map(name)
    skywars.maps[name] = skywars.maps[name] or {}
    local m = skywars.maps[name]

    m.changed_nodes = skywars.load_table(name.."_changed_nodes")
    m.always_to_be_reset_nodes = skywars.load_table(name.."_always_to_be_reset_nodes")
    m.original_nodes = skywars.load_table(name.."_original_nodes")
end



function skywars.load_maps()
    for i, props in ipairs(arena_lib.mods["skywars"].arenas) do
        skywars.load_map(props.name)
    end
end



minetest.register_on_mods_loaded(function()
    skywars.load_maps()
end)
