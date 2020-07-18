


local mod = "skywars"

ChatCmdBuilder.new("skywars", function(cmd)

  cmd:sub("create :arena", function(sender, arena_name)
      arena_lib.create_arena(sender, mod, arena_name)
  end)

  cmd:sub("create :arena :minplayers:int :maxplayers:int", function(sender, arena_name, min_players, max_players)
      arena_lib.create_arena(sender, mod, arena_name, min_players, max_players)
  end)

  cmd:sub("create :arena :minplayers:int :maxplayers:int :killcap:int", function(sender, arena_name, min_players, max_players)
      arena_lib.create_arena(sender, mod, arena_name, min_players, max_players)
      local id, arena = arena_lib.get_arena_by_name("moba", arena_name)
  end)

  -- rimozione arene
  cmd:sub("remove :arena", function(sender, arena_name)
      arena_lib.remove_arena(sender, mod, arena_name)
  end)

  -- lista arene
  cmd:sub("list", function(sender)
      arena_lib.print_arenas(sender, mod)
  end)

  -- info su un'arena specifica
  cmd:sub("info :arena", function(sender, arena_name)
      arena_lib.print_arena_info(sender, mod, arena_name)
    end)

  -- info su stats partita
  cmd:sub("score :arena", function(sender, arena_name)
      arena_lib.print_arena_stats(sender, mod, arena_name)
  end)

  -- modifiche arena
  --editor
  cmd:sub("edit :arena", function(sender, arena)
      arena_lib.enter_editor(sender, mod, arena)
  end)

  --inline
    -- cartello arena
    cmd:sub("setsign :arena", function(sender, arena)
        arena_lib.set_sign(sender, nil, nil, mod, arena)
    end)

    -- spawner (ie. deleteall)
    cmd:sub("setspawn :arena :param:text :ID:int", function(sender, arena, param, ID)
        arena_lib.set_spawner(sender, mod, arena, param, ID)
    end)

    cmd:sub("setspawn :arena", function(sender, arena)
        arena_lib.set_spawner(sender, mod, arena)
    end)

  -- abilitazione e disabilitazione arene
  cmd:sub("enable :arena", function(sender, arena)
      arena_lib.enable_arena(sender, mod, arena)
  end)

  cmd:sub("disable :arena", function(sender, arena)
      arena_lib.disable_arena(sender, mod, arena)
  end)

end)
