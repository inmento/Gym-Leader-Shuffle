package.preload["src.render.SpriteRenderer"] = function()
  return { new = function(def, id) return { def = def, id = id } end }
end
local openedText
package.preload["src.render.TextBox"] = function()
  return { new = function(_, text, done) openedText = text; return { done = done } end }
end

local gymIds = {
  "OPP_BROCK", "OPP_MISTY", "OPP_LT_SURGE", "OPP_ERIKA",
  "OPP_KOGA", "OPP_SABRINA", "OPP_BLAINE", "OPP_GIOVANNI",
}
local mapIds = {
  "PEWTER_GYM", "CERULEAN_GYM", "VERMILION_GYM", "CELADON_GYM",
  "FUCHSIA_GYM", "SAFFRON_GYM", "CINNABAR_GYM", "VIRIDIAN_GYM",
}
local trainerParties, maps, npcs = {}, {}, {}
for i, gymId in ipairs(gymIds) do
  trainerParties[gymId] = { parties = { [gymId == "OPP_GIOVANNI" and 3 or 1] = {
    { species = "MON_" .. i, level = 10 + i },
  } } }
  local trainerClass = "OPP_GYM_TRAINER_" .. i
  trainerParties[trainerClass] = { parties = { [1] = {
    { species = "MON_" .. i, level = 5 + i },
  } } }
  maps[mapIds[i]] = {
    label = mapIds[i],
    objects = {
      { index = 1, trainerClass = gymId, trainerParty = gymId == "OPP_GIOVANNI" and 3 or 1,
        sprite = "SPRITE_LEADER_" .. i, text = "TEXT_LEADER_" .. i },
      { index = 2, trainerClass = trainerClass, trainerParty = 1,
        sprite = "SPRITE_TRAINER_" .. i, text = "TEXT_TRAINER_" .. i },
    },
  }
  npcs[mapIds[i] .. ":1"] = { id = mapIds[i] .. ":1", def = {} }
  npcs[mapIds[i] .. ":2"] = { id = mapIds[i] .. ":2", def = {} }
end

local callbacks, storage = { events = {}, hooks = {} }, {}
local warpedTo
local options = {
  randomize_gyms = true, randomize_moves = false, randomize_gym_trainers = true,
  randomize_held_items = false,
  spoiler_log = false, gym_teleport = false, return_to_last_point = false, match_leader_type = true,
  allow_native_stab = true, ensure_damaging_move = true,
}
local randomCounter = 0
love = { math = { random = function(n)
  randomCounter = randomCounter + 1
  return 1 + ((randomCounter - 1) % n)
end } }

local mod = {
  id = "gym_leader_shuffle",
  game = {
    data = { pokemon = {}, text = {}, items = {} },
    save = { flags = {}, inventory = {}, defeatedTrainers = {} },
    stack = { push = function(_, _) end },
  },
  options = {
    define = function(_, schema) callbacks.options = schema end,
    get = function(_, key) return options[key] end,
  },
  content = {
    trainers = { get = function(_, id) return trainerParties[id] end },
    maps = { get = function(_, id) return maps[id] end },
    pokemon = {
      get = function(_, id) return { id = id, evolutions = {}, types = {}, level1Moves = {} } end,
      each = function() return pairs({}) end,
    },
    moves = { get = function() return nil end },
    sprites = { get = function(_, id) return { id = id } end },
    map_scripts = { register = function(_, _, _) end },
  },
  save = {
    get = function(_, key) return storage[key] end,
    set = function(_, key, value) storage[key] = value end,
  },
  world = {
    npc = function(_, mapId, index) return { npc = npcs[mapId .. ":" .. index] } end,
    current = function() return { mapId = "PEWTER_POKECENTER", x = 4, y = 3, facing = "left" } end,
    warpTo = function(_, mapId, x, y, direction, opts)
      warpedTo = { mapId = mapId, x = x, y = y, direction = direction, opts = opts }
      return true
    end,
  },
  hooks = { wrap = function(_, name, fn) callbacks.hooks[name] = fn end },
  events = { on = function(_, name, fn) callbacks.events[name] = fn end },
  log = { info = function() end, warn = function() end, error = function() end },
}

local entry = assert(loadfile("/home/ubuntu/release_100/gym_leader_shuffle/main.lua"))
entry()(mod)
assert(#callbacks.options == 9, "expected stable Gen 1 leader, trainer, spoiler, return, and move options")

callbacks.hooks["save.new_game"](function(save) return save end, mod.game.save)
callbacks.events["map.entered"]({ mapId = "PEWTER_GYM" })
local trainerNpc = npcs["PEWTER_GYM:2"]
assert(trainerNpc.def.trainerClass ~= "OPP_GYM_TRAINER_1", "gym trainer class did not shuffle")
assert(trainerNpc.sprite and trainerNpc.sprite.def.id ~= "SPRITE_TRAINER_1", "gym trainer sprite did not shuffle")

callbacks.events["world.trainer_engaged"]({ npc = trainerNpc })
local party = callbacks.hooks["trainer.party"](function(_, _, base) return base end,
  trainerNpc.def.trainerClass, trainerNpc.def.trainerParty, { { species = "BASE", level = 3 } })
assert(party[1] and party[1].species ~= "BASE", "gym trainer party did not shuffle")

callbacks.events["mod.options_changed"]({ mod = "gym_leader_shuffle", key = "spoiler_log", value = true })
assert(openedText and openedText:find("1/8", 1, true), "spoiler log omitted the first explicit page")
assert(openedText:find("8/8", 1, true), "spoiler log omitted the eighth explicit page")
assert(openedText:find("BOULDER BADGE", 1, true), "spoiler log omitted Boulder Badge")
assert(openedText:find("EARTH BADGE", 1, true), "spoiler log omitted Earth Badge")
local pageCount = 0
for _ in openedText:gmatch("\f") do pageCount = pageCount + 1 end
assert(pageCount == 7, "spoiler log must use eight explicit pages")

callbacks.events["mod.options_changed"]({ mod = "gym_leader_shuffle", key = "gym_teleport", value = true })
assert(warpedTo and warpedTo.mapId == "PEWTER_CITY", "Gym Teleport did not call warpTo for the next gym")
assert(storage.gym_teleport_origin and storage.gym_teleport_origin.mapId == "PEWTER_POKECENTER", "first Gym Teleport did not save the origin")
callbacks.events["mod.options_changed"]({ mod = "gym_leader_shuffle", key = "gym_teleport", value = true })
callbacks.events["mod.options_changed"]({ mod = "gym_leader_shuffle", key = "return_to_last_point", value = true })
assert(warpedTo and warpedTo.mapId == "PEWTER_POKECENTER" and warpedTo.x == 4 and warpedTo.y == 3, "Return to Last Point did not restore the recorded origin")
assert(storage.gym_teleport_origin == nil, "successful return did not clear the saved origin")
print("gym return, spoiler, action, and trainer harness: valid")
