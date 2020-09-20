--[[local function override_formspec(formspec, original)

    local orig_get = sfinv.pages[original].get
	sfinv.override_page("sfinv:crafting", {
		get = function(self, player, context)
            local fs = orig_get(self, player, context)
            fs = fs:gsub("list[current_player;craft;1%.75%,0%.5;3%,3;]", "list[current_player;craft;1.25,0.5;3,3;]")
            fs = fs:gsub("list[current_player;craftpreview;5%.75,1%.5;1%,1;]", "list[current_player;craftpreview;5.25,1.5;1,1;]")
            fs = fs:gsub("image[1,5%.2;1%,1;gui_hb_bg%.png]", "image[0.5,5.2;1,1;gui_hb_bg.png]")
            fs = fs:gsub("list[current_player;craftpreview;5%.75,1%.5;1%,1;]", "list[current_player;craftpreview;5.25,1.5;1,1;]")
            fs = fs:gsub("list[current_player;craftpreview;5%.75,1%.5;1%,1;]", "list[current_player;craftpreview;5.25,1.5;1,1;]")

			return fs 
		end
    })
end]]



function skywars.activate_hotbar(player)
    local meta = player:get_meta()
    --local formspec = ""

    --meta:set_string("original_formspec", sfinv.pages[original].get)
    meta:set_string("hotbar", player:hud_get_hotbar_image())
    meta:set_int("itemcount", player:hud_get_hotbar_itemcount())
    meta:set_string("hotbar_selected", player:hud_get_hotbar_selected_image())
    
    player:hud_set_hotbar_itemcount(10)
    player:hud_set_hotbar_image("hotbar.png")
    player:hud_set_hotbar_selected_image("hotbar_selected.png")
    
    --override_formspec(formspec, original)
end



function skywars.deactivate_hotbar(player)
    local meta = player:get_meta()
    
    player:hud_set_hotbar_itemcount(meta:get_int("itemcount"))
    player:hud_set_hotbar_image(meta:get_string("hotbar"))
    player:hud_set_hotbar_selected_image(meta:get_string("hotbar_selected"))
end