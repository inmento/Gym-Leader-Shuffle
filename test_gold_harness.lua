local callbacks, storage, trainers, maps, npcs = { events = {}, hooks = {} }, {}, {}, {}, {}
local activeGame = rawget(_G, "GYM_LEADER_SHUFFLE_TEST_GAME") or "gold"
assert(activeGame == "gold" or activeGame == "silver", "Gen 2 harness requires Gold or Silver")

package.preload["src.core.GameVersion"] = function()
  return {
    get = function() return activeGame end,
    generation = function(id)
      assert(id == activeGame, "Gym Leader Shuffle must classify the active Gen 2 version")
      return 2
    end,
  }
end
package.preload["src.render.SpriteRenderer"] = function()
  return { new = function(def, id) return { def = def, id = id } end }
end

local leaders = {
  "FALKNER", "BUGSY", "WHITNEY", "MORTY", "CHUCK", "JASMINE", "PRYCE", "CLAIR",
  "BROCK", "MISTY", "LT_SURGE", "ERIKA", "JANINE", "SABRINA", "BLAINE", "BLUE",
}
local leaderMaps = {
  FALKNER="VIOLET_GYM", BUGSY="AZALEA_GYM", WHITNEY="GOLDENROD_GYM", MORTY="ECRUTEAK_GYM",
  CHUCK="CIANWOOD_GYM", JASMINE="OLIVINE_GYM", PRYCE="MAHOGANY_GYM", CLAIR="BLACKTHORN_GYM_1F",
  BROCK="PEWTER_GYM", MISTY="CERULEAN_GYM", LT_SURGE="VERMILION_GYM", ERIKA="CELADON_GYM",
  JANINE="FUCHSIA_GYM", SABRINA="SAFFRON_GYM", BLAINE="SEAFOAM_GYM", BLUE="VIRIDIAN_GYM",
}
local leaderClasses = { FALKNER=1, BUGSY=3, WHITNEY=2, MORTY=4, CHUCK=7, JASMINE=6, PRYCE=5, CLAIR=8,
  BROCK=17, MISTY=18, LT_SURGE=19, ERIKA=21, JANINE=26, SABRINA=35, BLAINE=46, BLUE=64 }
local intro = { FALKNER="56:41e0", BUGSY="55:4e83", WHITNEY="57:4122", MORTY="52:516b", CHUCK="5d:53ee",
  JASMINE="51:419a", PRYCE="51:545d", CLAIR="53:40f3", BROCK="5a:40cb", MISTY="54:45cc",
  LT_SURGE="59:4c99", ERIKA="5e:5ec9", JANINE="5c:424f", SABRINA="61:4180", BLAINE="53:51ba", BLUE="5f:4057" }

for index, leader in ipairs(leaders) do
  local mapId = leaderMaps[leader]
  local objectIndex = leader == "MISTY" and 2 or 1
  trainers[leader] = {
    index = leaderClasses[leader],
    parties = { [1] = { { species = "MON_" .. leader, level = 10 + index, item = "BERRY" } } },
  }
  maps[mapId] = { objects = {
    { index = objectIndex, sprite = "SPRITE_" .. leader },
    { index = 9, sprite = "SPRITE_GYM_TRAINER_" .. leader,
      trainer = { class = leaderClasses[leader], member = 1,
        seenText = "SEEN_" .. leader, winText = "WIN_" .. leader } },
  } }
  npcs[mapId .. ":" .. tostring(objectIndex)] = { id = mapId .. ":leader", def = { index = objectIndex } }
  npcs[mapId .. ":9"] = { id = mapId .. ":trainer", def = { index = 9,
    trainer = { class = leaderClasses[leader], member = 1, seenText = "SEEN_" .. leader, winText = "WIN_" .. leader } } }
end

love = { math = { random = function(n) return n > 1 and n - 1 or 1 end } }
local options = {
  gold_shuffle = true, gold_trainers = true, gold_moves = false, gold_held = false,
  gold_spoiler_action = false, gold_warp_action = false, gold_return_action = false,
}
local game = { data = { gen2Maps = {}, items = { BERRY = { heldEffect = "HELD_BERRY", canToss = true, pocket = "ITEM" } }, pokemon = {} },
  save = { defeatedTrainers = {}, options = { modOptions = {} } },
  stack = { push = function() end, pop = function() end } }
local mod = {
  id = "gym_leader_shuffle", game = game,
  options = { define = function(_, schema) callbacks.options = schema end, get = function(_, key) return options[key] end },
  content = {
    trainers = { get = function(_, id) return trainers[id] end, each = function() return pairs(trainers) end },
    maps = { get = function(_, id) return maps[id] end },
    pokemon = { get = function() return { evolutions = {} } end, each = function() return pairs({}) end },
    items = { each = function() return pairs(game.data.items) end },
    sprites = { get = function(_, id) return { id = id } end },
  },
  save = { get = function(_, key) return storage[key] end, set = function(_, key, value) storage[key] = value end },
  world = {
    npc = function(_, mapId, index) return { npc = npcs[mapId .. ":" .. tostring(index)] } end,
    current = function() return { mapId = "VIOLET_GYM", x = 1, y = 1 } end,
    warpTo = function() return true end,
  },
  hooks = { wrap = function(_, name, fn) callbacks.hooks[name] = fn end },
  events = { on = function(_, name, fn) callbacks.events[name] = fn end },
  log = { info = function() end, warn = function() end, error = function() end },
}

assert(loadfile("main.lua"))()(mod)
assert(#callbacks.options == 7, "current Gold option schema was not registered")
callbacks.hooks["save.new_game"](function(save) return save end, game.save)
local mapping = assert(storage.gold_gym_mapping, "Gold leader mapping was not created")
local visitor = assert(mapping.FALKNER, "Violet Gym visitor was not assigned")
assert(visitor ~= "FALKNER", "Gold leader mapping must derange physical leaders")
callbacks.events["map.entered"]({ mapId = "VIOLET_GYM" })
assert(npcs["VIOLET_GYM:1"].def.sprite == "SPRITE_" .. visitor,
  "Gold leader sprite was not replaced")
assert(npcs["VIOLET_GYM:9"].def.trainer.seenText ~= "SEEN_FALKNER",
  "Gold gym NPC source dialogue was not replaced")

local dispatchedText, dispatchedBattle
callbacks.hooks["script.command"](function(_, _, _, cmd) dispatchedText = cmd; return cmd end,
  { scriptKey = "56:412f" }, "writetext", {}, { text = intro.FALKNER })
assert(dispatchedText and dispatchedText.text == intro[visitor],
  "Gold leader intro dialogue did not follow the visiting leader")
callbacks.hooks["script.command"](function(_, _, _, cmd) dispatchedBattle = cmd; return cmd end,
  { scriptKey = "56:412f" }, "loadtrainer", {}, { class = 1, member = 1 })
assert(dispatchedBattle and dispatchedBattle.class == leaderClasses[visitor] and dispatchedBattle.member == 1,
  "Gold leader battle command did not follow the visiting leader")

local party = callbacks.hooks["trainer.party"](function(_, _, base) return base end,
  leaderClasses[visitor], 1, { { species = "BASE", level = 1 } })
assert(party[1] and party[1].species == "MON_" .. visitor,
  "Gold leader party was not projected from the visitor's source party")
assert(party[1].level == 11, "Gold leader party was not scaled to the physical gym's level")

print(activeGame .. " gym shuffle intro-dialogue, NPC-dialogue, sprite, battle, and scaling harness: valid")
