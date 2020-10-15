-- Select the treasures to put in the chests inventory
local mod = "skywars"


function skywars.reorder_treasures(arena)
	-- sorting the table from the rarest to the least rare treasure
	for j=#arena.treasures, 2, -1 do
		for i=1, #arena.treasures-1 do
			if arena.treasures[i].rarity < arena.treasures[i+1].rarity then
				local temp = arena.treasures[i]
				arena.treasures[i] = arena.treasures[i + 1] 
				arena.treasures[i + 1] = temp
			end
		end
	end
end



local function treasure_to_itemstack(treasure)
	local itemstack = {}
	itemstack.name = treasure.name
	itemstack.count = treasure.count

	if ItemStack(itemstack):is_known() == false then
		minetest.log("error","[Skywars Treasures] I was asked to put "..treasure.name.." inside a chest, but it doesn't exist.")
	end
	return ItemStack(itemstack)
end



function skywars.select_random_treasures(treasure_amount, min_preciousness, max_preciousness, arena)
	if treasure_amount == nil or treasure_amount == 0 then treasure_amount = 1 end

	-- helper table
	local p_treasures = {}
	-- copying arena.treasures in p_treasures 
	for i=1, #arena.treasures do
		table.insert(p_treasures, arena.treasures[i])
	end

	if(min_preciousness ~= nil) then
		-- filter out too unprecious treasures
		for t=#p_treasures, 1, -1 do
			if(p_treasures[t].preciousness < min_preciousness) then
				table.remove(p_treasures,t)
			end
		end
	end

	if(max_preciousness ~= nil) then
		-- filter out too precious treasures
		for t=#p_treasures,1,-1 do
			if(p_treasures[t].preciousness > max_preciousness) then
				table.remove(p_treasures,t)
			end
		end
	end

	local treasures = {}
	
	-- while the generated treasures are less then the desired amount
	while #treasures < treasure_amount and #p_treasures > 0 do
		for c=1,treasure_amount do
			-- if there isn't a treasure
			if treasures[c] == nil then 
				for t=1,#p_treasures do
					local random = math.random(1, 100)

					-- if the random number is a multiple of the item rarity then select it
					if random % (p_treasures[t].rarity * 10) == 0 then
						table.insert(treasures, p_treasures[t])
						break
					end
				end
			end
		end
	end

	local itemstacks = {}
	for i=1,#treasures do
		itemstacks[i] = treasure_to_itemstack(treasures[i])
	end
	if #itemstacks < treasure_amount then
		minetest.log("info","[treasurer] I was asked to return "..treasure_amount.." treasure(s) but I could only return "..(#itemstacks)..".")
	end
	return itemstacks
end
