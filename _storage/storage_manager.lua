local storage = minetest.get_mod_storage()


function skywars.load_kits() 
    local kits = minetest.deserialize(storage:get_string("kits"))

    if kits == "" or kits == nil then
        kits = {}
    end

    return kits
end



function skywars.overwrite_kits(kits_table) 
    storage:set_string("kits", minetest.serialize(kits_table))
end