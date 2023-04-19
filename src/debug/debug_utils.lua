local profiling = {}

function skywars.start_profiling(name)
	profiling[name] = minetest.get_us_time()
end

function skywars.stop_profiling(name)
	minetest.log(name .. " took: " .. minetest.get_us_time()-profiling[name])
end