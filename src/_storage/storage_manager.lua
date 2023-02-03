local storage = minetest.get_mod_storage()


function skywars.load_table(metadata_name) 
    local metadata = minetest.deserialize(storage:get_string(metadata_name))

    if metadata == "" or metadata == nil then
        metadata = {}
    end

    return metadata
end



function skywars.overwrite_table(metadata_name, table) 
    storage:set_string(metadata_name, minetest.serialize(table))
end
