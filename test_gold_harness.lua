local leaders = {
  "FALKNER", "BUGSY", "WHITNEY", "MORTY", "CHUCK", "JASMINE", "PRYCE", "CLAIR",
  "BROCK", "MISTY", "LT_SURGE", "ERIKA", "JANINE", "SABRINA", "BLAINE", "BLUE",
}
local mapsByLeader = {
  FALKNER = "VIOLET_GYM", BUGSY = "AZALEA_GYM", WHITNEY = "GOLDENROD_GYM",
  MORTY = "ECRUTEAK_GYM", CHUCK = "CIANWOOD_GYM", JASMINE = "OLIVINE_GYM",
  PRYCE = "MAHOGANY_GYM", CLAIR = "BLACKTHORN_GYM_1F", BROCK = "PEWTER_GYM",
  MISTY = "CERULEAN_GYM", LT_SURGE = "VERMILION_GYM", ERIKA = "CELADON_GYM",
  JANINE = "FUCHSIA_GYM", SABRINA = "SAFFRON_GYM", BLAINE = "SEAFOAM_GYM",
  BLUE = "VIRIDIAN_GYM",
}

local randomCounter = 0
love = { math = { random = function(n)
  randomCounter = randomCounter + 1
  return 1 + ((randomCounter - 1) % n)
end } }
local callbacks, storage, trainers, maps, npcs = { events = {}, hooks = {} }, {}, {}, {}, {}
local mod
for index, leader in ipairs(leaders) do
  trainers[leader] = {
    index = index,
    trainers = { { index = 1, id = leader .. "1", party = {
      { species = "MON_" .. index, level = 10 + index, item = "BERRY", moves = { "TACKLE" } },
    } } },
  }
  local mapId = mapsByLeader[leader]
  maps[mapId] = { objects = {
    { index = leader == "MISTY" and 2 or 1, sprite = "SPRITE_" .. leader },
    { index = 9, sprite = "SPRITE_TRAINER_" .. index, trainer = { class = index, member = 1 } },
  } }
  npcs[mapId .. ":" .. tostring(leader == "MISTY" and 2 or 1)] = {
    id = mapId .. ":leader", def = {}, setSpriteDef = function(self, def) self.spriteDef = def; return true end,
  }
  npcs[mapId .. ":9"] = {
    id = mapId .. ":trainer", def = { trainer = { class = index, member = 1 } },
    setSpriteDef = function(self, def) self.spriteDef = def; return true end,
  }
end

local options = {
  randomize_gyms = true, randomize_moves = false, randomize_gym_trainers = true,
  randomize_held_items = false, spoiler_log = false, gym_teleport = false,
  return_to_last_point = false, match_leader_type = true, allow_native_stab = true,
  ensure_damaging_move = true,
}
mod = {
  id = "gym_leader_shuffle",
  game = { data = { gen2Maps = {}, pokemon = {}, items = {
    BERRY = { heldEffect = "HELD_BERRY", canToss = true, pocket = "ITEM" },
  } }, save = { flags = {}, inventory = {}, defeatedTrainers = {} }, stack = { push = function() end } },
  options = { define = function(_, schema) callbacks.options = schema end, get = function(_, key) return options[key] end },
  content = {
    trainers = {
      get = function(_, id) return trainers[id] end,
      each = function() return pairs(trainers) end,
    },
    maps = { get = function(_, id) return maps[id] end },
    pokemon = {
      get = function(_, id) return { id = id, evolutions = {}, types = {}, level1Moves = {} } end,
      each = function() return pairs({}) end,
    },
    moves = { get = function() return nil end },
    sprites = { get = function(_, id) return { id = id } end },
    items = { each = function() return pairs(mod.game.data.items) end },
  },
  save = { get = function(_, key) return storage[key] end, set = function(_, key, value) storage[key] = value end },
  world = {
    npc = function(_, mapId, index) return { npc = npcs[mapId .. ":" .. index] } end,
    current = function() return { mapId = "VIOLET_GYM", x = 1, y = 1 } end,
    warpTo = function() return true end,
  },
  hooks = { wrap = function(_, name, fn) callbacks.hooks[name] = fn end },
  events = { on = function(_, name, fn) callbacks.events[name] = fn end },
  log = { info = function() end, warn = function() end, error = function() end },
}

assert(loadfile("/home/ubuntu/gym_leader_shuffle/main.lua"))()(mod)
assert(#callbacks.options == 10, "Gold harness did not receive the expected option schema")
callbacks.hooks["save.new_game"](function(save) return save end, mod.game.save)
callbacks.events["map.entered"]({ mapId = "VIOLET_GYM" })
local mapping = storage.gym_mapping
local assigned = assert(mapping.FALKNER, "Gold leader mapping was not created")
assert(assigned ~= "FALKNER", "Gold mapping must derange the physical leader")
local leaderNpc = npcs["VIOLET_GYM:1"]
assert(leaderNpc.spriteDef and leaderNpc.spriteDef.id ~= "SPRITE_FALKNER", "Gold leader sprite was not replaced")

local dispatched
callbacks.hooks["script.command"](function(_, name, _, cmd) dispatched = cmd; return cmd end,
  { generation = 2, mapId = "VIOLET_GYM", object = 1 }, "loadtrainer", {}, { class = 1, member = 1 })
assert(dispatched and dispatched.class ~= 1, "Gold leader loadtrainer command was not rewritten")
assert(dispatched.member == 1, "Gold leader roster member changed unexpectedly")

local party = callbacks.hooks["trainer.party"](function(_, _, base) return base end,
  assigned, assigned .. "1", { { species = "BASE", level = 1 } })
assert(party[1] and party[1].species ~= "BASE", "Gold leader party was not replaced")
assert(party[1].item == "BERRY", "Gold held item was not preserved on the shuffled leader party")

local trainerNpc = npcs["VIOLET_GYM:9"]
callbacks.events["world.trainer_engaged"]({ npc = trainerNpc })
assert(trainerNpc.def.trainer.class ~= 1, "Gold gym trainer class did not shuffle")
print("gold gym leader shuffle harness: valid")
