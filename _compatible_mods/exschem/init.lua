function skywars.create_exschem_schematic(sender, pos1, pos2, name, arena)
    local path = minetest.get_worldpath() .."/schems/".. name
 
    exschem.save(pos1, pos2, false, 10, name, 0)
    skywars.print_msg(sender, skywars.T("Schematic @1 created! (Saved in @2)", name, path)) 
end



function skywars.load_exschem_schematic(pos1, schematic)

    exschem.load(pos1, pos1, 0, {}, schematic, 0)
end