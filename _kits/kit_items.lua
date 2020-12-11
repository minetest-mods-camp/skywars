minetest.register_craftitem("skywars:kit_selector", {
    description = skywars.T("Kit Selector"),
    inventory_image = "kit_selector.png",
    stack_max = 1,
    on_drop = function() return nil end,
    on_use =
        function(_, player, pointed_thing)
            local pl_name = player:get_player_name()
            local arena = arena_lib.get_arena_by_player(pl_name)

            if not arena or not arena.in_loading then return end

            skywars.show_kit_selector(pl_name, arena)
        end
})
