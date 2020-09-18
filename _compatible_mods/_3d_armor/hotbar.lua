function skywars.activate_hotbar(player)
    local meta = player:get_meta()

    meta:set_string("hotbar", player:hud_get_hotbar_image())
    meta:set_int("itemcount", player:hud_get_hotbar_itemcount())
    meta:set_string("hotbar_selected", player:hud_get_hotbar_selected_image())

    player:hud_set_hotbar_itemcount(10)
    player:hud_set_hotbar_image("hotbar.png")
    player:hud_set_hotbar_selected_image("hotbar_selected.png")
end



function skywars.deactivate_hotbar(player)
    local meta = player:get_meta()
    
    player:hud_set_hotbar_itemcount(meta:get_int("itemcount"))
    player:hud_set_hotbar_image(meta:get_string("hotbar"))
    player:hud_set_hotbar_selected_image(meta:get_string("hotbar_selected"))
end
