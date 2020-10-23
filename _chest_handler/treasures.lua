-- Select the treasures to put in the chests inventory
local mod = "skywars"
local function treasure_to_itemstack() end


function skywars.reorder_treasures(arena)
	-- sorting the table from the rarest to the least rare treasure
	for j = #arena.treasures, 2, -1 do
		for i = 1, #arena.treasures-1 do
			if arena.treasures[i].rarity < arena.treasures[i+1].rarity then
				local temp = arena.treasures[i]
				arena.treasures[i] = arena.treasures[i + 1] 
				arena.treasures[i + 1] = temp
			end
		end
	end
end



function skywars.select_random_treasures(chest, arena)
	local preciousness_filtered_treasures = {}
	local generated_treasures = {}
	local treasure_amount = math.ceil(math.random(chest.min_treasures, chest.max_treasures))
	local treasures_to_be_generated = treasure_amount

	for i = 1, #arena.treasures do
		local treasure = arena.treasures[i]
		if treasure.preciousness >= chest.min_preciousness and treasure.preciousness <= chest.max_preciousness then
			table.insert(preciousness_filtered_treasures, treasure)
		end
	end

	while #generated_treasures < treasures_to_be_generated and #preciousness_filtered_treasures > 0 do
		for i = 1, treasures_to_be_generated do
			if not generated_treasures[i] then 
				for j = 1, #preciousness_filtered_treasures do
					local random = math.random(1, 100)
					local treasure_itemstack = treasure_to_itemstack(preciousness_filtered_treasures[j])

					if treasure_itemstack and random % (preciousness_filtered_treasures[j].rarity * 10) == 0 then
						table.insert(generated_treasures, treasure_itemstack)
						break
					end
				end
			end
		end
	end

	return generated_treasures
end



function treasure_to_itemstack(treasure)
	local itemstack = {}
	itemstack.name = treasure.name
	itemstack.count = treasure.count

	if ItemStack(itemstack):is_known() == false then
		minetest.log("error","[Skywars Treasures] I was asked to put "..treasure.name.." inside a chest, but it doesn't exist.")
		return nil
	end
	return ItemStack(itemstack)
end