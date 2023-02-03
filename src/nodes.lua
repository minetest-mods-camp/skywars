minetest.register_node("skywars:barrier", {
    description = skywars.T("Unbreakable without skywars_admin priv transparent node"),
    drawtype = "airlike",
    paramtype = "light",
    sunlight_propagates = true,
    air_equivalent = true,
    drop = "",
    inventory_image = "sw_node_barrier.png",
    wield_image = "sw_node_barrier.png",
    groups = {oddly_breakable_by_hand = 2},
    can_dig = function(pos, player)
        if minetest.get_player_privs(player:get_player_name()).skywars_admin then
            return true
        end
        return false
    end
})



minetest.register_node("skywars:test_node", {
    description = "Skywars test node, don't use it!",
    groups = {crumbly=1, soil=1, dig_immediate=3},
    tiles = {"sw_node_test.png"},
})