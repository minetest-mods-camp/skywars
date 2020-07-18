--Il necessario per aggiungere items possibili alle chest.
local mod = "skywars"

ChatCmdBuilder.new("skywars", function(cmd)

  cmd:sub("addtreasure :treasure :rarity :preciousness :count :arena", function(sender, treasure_name, rarity, preciousness, count, arena_name)
    local id, arena = arena_lib.get_arena_by_name("skywars", arena_name)

    table.insert(arena.treasures, {name = treasure_name, rarity = rarity, count = count, preciousness = preciousness})

  end)

  cmd:sub("removetreasure :treasure :arena", function(sender, treasure_name, arena_name)
    local id, arena = arena_lib.get_arena_by_name("skywars", arena_name)

    table.remove(arena.treasures, {name = treasure_name, rarity, preciousness})

  end)

end)


function skywars.select_random_treasures(treasure_amount, min_preciousness, max_preciousness, arena)
  if #arena.treasures == 0 and treasure_amount >= 1 then
		minetest.log("info","[treasurer] I was asked to return "..count.." treasure(s) but I can’t return any because no treasure was registered to me.")
		return {}
	end
  if treasure_amount == nil then treasure_amount = 1 end
	local sum = 0
	local cumulate = {}
	local randoms = {}

	-- copy treasures into helper table
	local p_treasures = {}

	for i=1,#arena.treasures do
		table.insert(p_treasures, #arena.treasures[i])
	end


  if(min_preciousness ~= nil) then
		-- filter out too unprecious treasures
		for t=#p_treasures,1,-1 do
			if((p_treasures[t].preciousness) < min_preciousness) then
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

	for t=1,#p_treasures do
		sum = sum + p_treasures[t].rarity
		cumulate[t] = sum
	end
	for c=1,count do
		randoms[c] = math.random() * sum
	end

	local treasures = {}
	for c=1,count do
		for t=1,#p_treasures do
			if randoms[c] < cumulate[t] then
				table.insert(treasures, p_treasures[t])
				break
			end
		end
	end

	local itemstacks = {}
	for i=1,#treasures do
		itemstacks[i] = treasure_to_itemstack(treasures[i])
	end
	if #itemstacks < count then
		minetest.log("info","[treasurer] I was asked to return "..count.." treasure(s) but I could only return "..(#itemstacks)..".")
	end
	return itemstacks
end



local function treasure_to_itemstack(treasure)
	local itemstack = {}
	itemstack.name = treasure.name
	itemstack.count = determine_count(treasure)

	return ItemStack(itemstack)
end


local function determine_count(treasure)
	if(type(treasure.count)=="number") then
		return treasure.count
	else
		local min,max,prob = treasure.count[1], treasure.count[2], treasure.count[3]
		if(prob == nil) then
			return(math.floor(min + math.random() * (max-min)))
		else
			return(math.floor(min + prob() * (max-min)))
		end
	end
end
