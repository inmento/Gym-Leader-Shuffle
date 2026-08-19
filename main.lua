-- Gym Leader Shuffle
-- Release: 1.0.6
-- Gen 1 Recomp mod API 2
--
-- This mod assigns one of the eight Kanto gym leaders to each gym when a new
-- save is created. The physical gym still awards its normal badge/TM; the
-- visiting leader supplies the battle portrait, overworld sprite, and party.

local SpriteRenderer = require("src.render.SpriteRenderer")

return function(mod)
  -- The active game is known before the mod entry loads. Branch on that stable
  -- engine value instead of guessing from the currently available data tables.
  local GameVersion = require("src.core.GameVersion")
  local playing = GameVersion.get()
  local function isGen2(_)
    return playing == "gold"
  end

  -- Crystal 251 is an optional Gen 1 overhaul. Its early import expands the
  -- live registries and enriches party records; this helper is deliberately
  -- advisory so Gym Leader Shuffle remains fully standalone when absent.
  local function crystal251Active()
    if isGen2() or type(mod.find) ~= "function" then return false end
    local ok, handle = pcall(mod.find, mod, "CRYSTAL_251")
    local exports = ok and type(handle) == "table" and handle.exports or nil
    return type(exports) == "table" and tonumber(exports.dexSize) == 251
  end

  if isGen2() then
    local GYMS = {
      { id="FALKNER", mapId="VIOLET_GYM", objectIndex=1, scriptKey="56:412f", class=1, member=1, sprite="SPRITE_FALKNER", intro="56:41e0", badge="ZEPHYR BADGE", type="FLYING" },
      { id="BUGSY", mapId="AZALEA_GYM", objectIndex=1, scriptKey="55:4d96", class=3, member=1, sprite="SPRITE_BUGSY", intro="55:4e83", badge="HIVE BADGE", type="BUG" },
      { id="WHITNEY", mapId="GOLDENROD_GYM", objectIndex=1, scriptKey="57:400c", class=2, member=1, sprite="SPRITE_WHITNEY", intro="57:4122", badge="PLAIN BADGE", type="NORMAL" },
      { id="MORTY", mapId="ECRUTEAK_GYM", objectIndex=1, scriptKey="52:508f", class=4, member=1, sprite="SPRITE_MORTY", intro="52:516b", badge="FOG BADGE", type="GHOST" },
      { id="CHUCK", mapId="CIANWOOD_GYM", objectIndex=1, scriptKey="5d:5304", class=7, member=1, sprite="SPRITE_CHUCK", intro="5d:53ee", badge="STORM BADGE", type="FIGHTING" },
      { id="JASMINE", mapId="OLIVINE_GYM", objectIndex=1, scriptKey="51:4110", class=6, member=1, sprite="SPRITE_JASMINE", intro="51:419a", badge="MINERAL BADGE", type="STEEL" },
      { id="PRYCE", mapId="MAHOGANY_GYM", objectIndex=1, scriptKey="51:536e", class=5, member=1, sprite="SPRITE_PRYCE", intro="51:545d", badge="GLACIER BADGE", type="ICE" },
      { id="CLAIR", mapId="BLACKTHORN_GYM_1F", objectIndex=1, scriptKey="53:4024", class=8, member=1, sprite="SPRITE_CLAIR", intro="53:40f3", badge="RISING BADGE", type="DRAGON" },
      { id="BROCK", mapId="PEWTER_GYM", objectIndex=1, scriptKey="5a:405f", class=17, member=1, sprite="SPRITE_BROCK", intro="5a:40cb", badge="BOULDER BADGE", type="ROCK" },
      { id="MISTY", mapId="CERULEAN_GYM", objectIndex=2, scriptKey="54:438a", class=18, member=1, sprite="SPRITE_MISTY", intro="54:45cc", badge="CASCADE BADGE", type="WATER" },
      { id="LT_SURGE", mapId="VERMILION_GYM", objectIndex=1, scriptKey="59:4bfc", class=19, member=1, sprite="SPRITE_SURGE", intro="59:4c99", badge="THUNDER BADGE", type="ELECTRIC" },
      { id="ERIKA", mapId="CELADON_GYM", objectIndex=1, scriptKey="5e:5e0b", class=21, member=1, sprite="SPRITE_ERIKA", intro="5e:5ec9", badge="RAINBOW BADGE", type="GRASS" },
      { id="JANINE", mapId="FUCHSIA_GYM", objectIndex=1, scriptKey="5c:40d3", class=26, member=1, sprite="SPRITE_JANINE", intro="5c:424f", badge="SOUL BADGE", type="POISON" },
      { id="SABRINA", mapId="SAFFRON_GYM", objectIndex=1, scriptKey="61:40cf", class=35, member=1, sprite="SPRITE_SABRINA", intro="61:4180", badge="MARSH BADGE", type="PSYCHIC" },
      { id="BLAINE", mapId="SEAFOAM_GYM", objectIndex=1, scriptKey="53:516d", class=46, member=1, sprite="SPRITE_BLAINE", intro="53:51ba", badge="VOLCANO BADGE", type="FIRE" },
      { id="BLUE", mapId="VIRIDIAN_GYM", objectIndex=1, scriptKey="5f:4002", class=64, member=1, sprite="SPRITE_BLUE", intro="5f:4057", badge="EARTH BADGE", type="VARIED" },
    }

    mod.options:define({
      { key="gold_shuffle", label="GOLD SHUFFLE", type="toggle", default=true },
      { key="gold_trainers", label="GOLD GYM NPCS", type="toggle", default=false },
      { key="gold_moves", label="GOLD RANDOM MOVES", type="toggle", default=false },
      { key="gold_held", label="GOLD HELD ITEMS", type="toggle", default=false },
      { key="gold_spoiler_action", label="GOLD SPOILER LOG", type="toggle", default=false },
      { key="gold_warp_action", label="GOLD GYM WARP", type="toggle", default=false },
      { key="gold_return_action", label="GOLD RETURN POINT", type="toggle", default=false },
    })

    local TELEPORTS = {
      FALKNER={ badge="ZEPHYR", mapId="VIOLET_CITY", x=18, y=17 },
      BUGSY={ badge="HIVE", mapId="AZALEA_TOWN", x=10, y=15 },
      WHITNEY={ badge="PLAIN", mapId="GOLDENROD_CITY", x=24, y=7 },
      MORTY={ badge="FOG", mapId="ECRUTEAK_CITY", x=6, y=27 },
      JASMINE={ badge="MINERAL", mapId="OLIVINE_CITY", x=10, y=11 },
      CHUCK={ badge="STORM", mapId="CIANWOOD_CITY", x=8, y=43 },
      PRYCE={ badge="GLACIER", mapId="MAHOGANY_TOWN", x=6, y=13 },
      CLAIR={ badge="RISING", mapId="BLACKTHORN_CITY", x=18, y=11 },
      BROCK={ badge="BOULDER", mapId="PEWTER_CITY", x=16, y=17 },
      MISTY={ badge="CASCADE", mapId="CERULEAN_CITY", x=30, y=23 },
      LT_SURGE={ badge="THUNDER", mapId="VERMILION_CITY", x=10, y=19 },
      ERIKA={ badge="RAINBOW", mapId="CELADON_CITY", x=10, y=29 },
      JANINE={ badge="SOUL", mapId="FUCHSIA_CITY", x=8, y=27 },
      SABRINA={ badge="MARSH", mapId="SAFFRON_CITY", x=34, y=3 },
      BLAINE={ badge="VOLCANO", mapId="ROUTE_20", x=38, y=7 },
      BLUE={ badge="EARTH", mapId="VIRIDIAN_CITY", x=32, y=7 },
    }
    local TELEPORT_ORDER = { "FALKNER", "BUGSY", "WHITNEY", "MORTY", "JASMINE", "CHUCK", "PRYCE", "CLAIR", "BROCK", "MISTY", "LT_SURGE", "ERIKA", "JANINE", "SABRINA", "BLAINE", "BLUE" }
    local RETURN_KEY = "gold_gym_return"

    local BY_ID, BY_MAP, BY_SCRIPT = {}, {}, {}
    for _, gym in ipairs(GYMS) do
      BY_ID[gym.id], BY_MAP[gym.mapId], BY_SCRIPT[gym.scriptKey] = gym, gym, gym
    end

    local CLASS_ID = {}
    for id, trainer in mod.content.trainers:each() do
      if type(trainer) == "table" and trainer.index ~= nil then CLASS_ID[trainer.index] = id end
    end

    local function partyFor(class, member)
      local trainer = mod.content.trainers:get(CLASS_ID[class] or class)
      if trainer and trainer.parties then return trainer.parties[member] end
      for _, row in ipairs(trainer and trainer.trainers or {}) do
        if row.index == member or row.id == member then return row.party end
      end
      return nil
    end

    local function clone(value)
      if type(value) ~= "table" then return value end
      local out = {}
      for key, inner in pairs(value) do out[key] = clone(inner) end
      return out
    end

    local function randomInt(max)
      if love and love.math and love.math.random then return love.math.random(max) end
      return math.random(max)
    end

    local function shuffle(list)
      for i = #list, 2, -1 do
        local j = randomInt(i)
        list[i], list[j] = list[j], list[i]
      end
    end

    local preEvolution
    local function fitSpecies(species, level)
      if not preEvolution then
        preEvolution = {}
        for id, mon in mod.content.pokemon:each() do
          for _, evo in ipairs(mon.evolutions or {}) do
            if evo.method == "LEVEL" and evo.species and evo.level then
              preEvolution[evo.species] = { species=id, level=evo.level }
            end
          end
        end
      end
      local current = species
      for _ = 1, 6 do
        local prior = preEvolution[current]
        if not prior or level >= prior.level then break end
        current = prior.species
      end
      for _ = 1, 6 do
        local mon = mod.content.pokemon:get(current)
        local nextId, nextLevel
        for _, evo in ipairs(mon and mon.evolutions or {}) do
          if evo.method == "LEVEL" and evo.species and evo.level and level >= evo.level
            and (not nextLevel or evo.level < nextLevel) then
            nextId, nextLevel = evo.species, evo.level
          end
        end
        if not nextId then break end
        current = nextId
      end
      return current
    end

    local function heldItemFor(key, original)
      if not (mod.options:get("gold_held") and original) then return original end
      local state = mod.save:get("gold_gym_held_mapping") or {}
      if state[key] then return state[key] end
      local pool = {}
      for itemId, item in mod.content.items:each() do
        if type(itemId) == "string" and type(item) == "table" and item.heldEffect
          and item.heldEffect ~= "HELD_NONE" and item.canToss ~= false
          and item.keyItem ~= true and item.pocket ~= "KEY_ITEM" then
          pool[#pool + 1] = itemId
        end
      end
      table.sort(pool)
      if #pool == 0 then return original end
      state[key] = pool[randomInt(#pool)]
      mod.save:set("gold_gym_held_mapping", state)
      return state[key]
    end

    local function movesFor(species, level)
      if not mod.options:get("gold_moves") then return nil end
      local mon = mod.content.pokemon:get(species)
      local known = {}
      for _, row in ipairs(mon and mon.levelMoves or {}) do
        if row.level <= level then
          known[#known + 1] = row.move
          if #known > 4 then table.remove(known, 1) end
        end
      end
      return #known > 0 and known or nil
    end

    local function scaledParty(source, target, key)
      local out = {}
      for i = 1, #(target or {}) do
        local from = source[math.min(i, #source)] or source[1]
        if from then
          local copy = clone(from)
          copy.level = target[i].level
          copy.species = fitSpecies(copy.species, copy.level)
          local moves = movesFor(copy.species, copy.level)
          if moves then copy.moves = moves end
          copy.item = heldItemFor((key or "party") .. ":" .. tostring(i), copy.item)
          out[#out + 1] = copy
        end
      end
      return out
    end

    local LEADER_PARTIES, GYM_NPCS, NPC_BY_KEY = {}, {}, {}
    for _, gym in ipairs(GYMS) do
      LEADER_PARTIES[gym.id] = partyFor(gym.class, gym.member) or {}
      local map = mod.content.maps:get(gym.mapId)
      GYM_NPCS[gym.id] = {}
      for arrayIndex, object in ipairs(map and map.objects or {}) do
        local index = object.index or arrayIndex
        local trainer = object.trainer
        if index ~= gym.objectIndex and type(trainer) == "table" and trainer.class and trainer.member then
          local record = {
            key=gym.id .. ":" .. tostring(index), gym=gym, objectIndex=index,
            class=trainer.class, member=trainer.member, sprite=object.sprite,
            seenText=trainer.seenText, winText=trainer.winText,
            party=partyFor(trainer.class, trainer.member) or {},
          }
          GYM_NPCS[gym.id][#GYM_NPCS[gym.id] + 1] = record
          NPC_BY_KEY[record.key] = record
        end
      end
    end

    local function mapping()
      if not mod.options:get("gold_shuffle") then return nil end
      local saved = mod.save:get("gold_gym_mapping")
      if type(saved) == "table" then return saved end
      local order = {}
      for i, gym in ipairs(GYMS) do order[i] = gym.id end
      local fixed = true
      while fixed do
        shuffle(order)
        fixed = false
        for i, gym in ipairs(GYMS) do if order[i] == gym.id then fixed=true; break end end
      end
      saved = {}
      for i, gym in ipairs(GYMS) do saved[gym.id] = order[i] end
      mod.save:set("gold_gym_mapping", saved)
      mod.save:set("gold_gym_npc_mapping", nil)
      return saved
    end

    local function npcMapping(leaderMap)
      if not (leaderMap and mod.options:get("gold_trainers")) then return nil end
      local saved = mod.save:get("gold_gym_npc_mapping")
      if type(saved) == "table" then return saved end
      saved = {}
      for _, destination in ipairs(GYMS) do
        local visitor = BY_ID[leaderMap[destination.id]]
        local source = visitor and GYM_NPCS[visitor.id] or {}
        if #source > 0 then
          local order = clone(source)
          shuffle(order)
          for i, record in ipairs(GYM_NPCS[destination.id] or {}) do
            saved[record.key] = order[(i - 1) % #order + 1].key
          end
        end
      end
      mod.save:set("gold_gym_npc_mapping", saved)
      return saved
    end

    local function paint(npc, sprite)
      local def = mod.content.sprites:get(sprite)
      if not (npc and def) then return end
      npc.def.sprite = sprite
      if npc.setSpriteDef then npc:setSpriteDef(def) end
    end

    local function applyMap(mapId)
      local physical = BY_MAP[mapId]
      if not physical then return end
      local leaderMap = mapping()
      local visitor = leaderMap and BY_ID[leaderMap[physical.id]] or physical
      local leader = mod.world:npc(mapId, physical.objectIndex)
      if leader and leader.npc then paint(leader.npc, visitor.sprite) end
      local assignments = npcMapping(leaderMap)
      for _, destination in ipairs(GYM_NPCS[physical.id] or {}) do
        local handle = mod.world:npc(mapId, destination.objectIndex)
        local npc = handle and handle.npc
        local source = assignments and NPC_BY_KEY[assignments[destination.key]]
        if npc and source then
          npc.def.trainer.class, npc.def.trainer.member = source.class, source.member
          npc.def.trainer.seenText, npc.def.trainer.winText = source.seenText, source.winText
          paint(npc, source.sprite)
        end
      end
    end

    local ACTION_OPTIONS = {
      gold_spoiler_action=true,
      gold_warp_action=true,
      gold_return_action=true,
    }

    local function resetTeleportOptions()
      local game = mod.game
      local saved = game and game.save and game.save.options and game.save.options.modOptions
      local stored = saved and (saved[mod.id] or nil)
      local live = game and game.mods and game.mods.modOptions
      local active = live and (live[mod.id] or nil)
      for key in pairs(ACTION_OPTIONS) do
        if stored then stored[key] = false end
        if active then active[key] = false end
      end
    end

    local function closeMenusToWorld()
      local stack = mod.game and mod.game.stack
      if not (stack and stack.pop) then return end
      -- The option event is raised while the mod manager is above Gold's
      -- pause menu. Pop both layers so the warp returns straight to the field.
      stack:pop()
      if stack.top and stack:top() then stack:pop() end
    end

    local function useTeleport()
      local game = mod.game
      local current, err = mod.world:current()
      if not current then mod.log:warn("Gold Gym Warp could not read the current position: %s", tostring(err)); return end
      if not mod.save:get(RETURN_KEY) then mod.save:set(RETURN_KEY, current) end
      local owned = game and game.save and game.save.player and game.save.player.badges or {}
      local target
      for _, id in ipairs(TELEPORT_ORDER) do
        local row = TELEPORTS[id]
        if row and not owned[row.badge] then target = row; break end
      end
      if not target then mod.log:info("Gold Gym Warp: every badge is already owned"); return end
      local ok, warpErr = mod.world:warpTo(target.mapId, target.x, target.y, "up", { arrive="teleport" })
      if not ok then mod.log:warn("Gold Gym Warp failed: %s", tostring(warpErr)); return end
      closeMenusToWorld()
    end

    local function returnTeleport()
      local origin = mod.save:get(RETURN_KEY)
      if type(origin) ~= "table" then mod.log:warn("Gold Return Point: no Gym Warp origin is stored"); return end
      local ok, err = mod.world:warpTo(origin.mapId, origin.x, origin.y, origin.facing or "down", { arrive="teleport" })
      if not ok then mod.log:warn("Gold Return Point failed: %s", tostring(err)); return end
      mod.save:set(RETURN_KEY, nil)
      closeMenusToWorld()
    end

    local pendingLeader, pendingNpc = nil, nil
    local function liveNpcRecord(npc)
      local physical = npc and BY_MAP[npc.mapId]
      if not physical or not npc.def then return nil, nil end
      local destination = NPC_BY_KEY[physical.id .. ":" .. tostring(npc.def.index)]
      local leaderMap = mapping()
      local assignments = npcMapping(leaderMap)
      return destination, assignments and NPC_BY_KEY[assignments[destination and destination.key]]
    end

    mod.hooks:wrap("script.command", function(next, ctx, name, args, cmd)
      local physical = ctx and BY_SCRIPT[ctx.scriptKey]
      local leaderMap = mapping()
      local visitor = physical and leaderMap and BY_ID[leaderMap[physical.id]]
      if not visitor or not cmd then return next(ctx, name, args, cmd) end
      if name == "writetext" and cmd.text == physical.intro then
        local rewritten = clone(cmd)
        rewritten.text = visitor.intro
        return next(ctx, name, args, rewritten)
      end
      if name == "loadtrainer" and cmd.class == physical.class and cmd.member == physical.member then
        pendingLeader = { physical=physical, visitor=visitor }
        local rewritten = clone(cmd)
        rewritten.class, rewritten.member = visitor.class, visitor.member
        return next(ctx, name, args, rewritten)
      end
      return next(ctx, name, args, cmd)
    end)

    mod.events:on("world.trainer_engaged", function(event)
      local destination, source = liveNpcRecord(event and event.npc)
      if destination and source then pendingNpc = { destination=destination, source=source } end
    end)

    mod.hooks:wrap("trainer.party", function(next, trainerClass, partyIndex, party)
      party = next(trainerClass, partyIndex, party)
      if pendingLeader and trainerClass == pendingLeader.visitor.class and partyIndex == pendingLeader.visitor.member then
        local replacement = scaledParty(LEADER_PARTIES[pendingLeader.visitor.id], LEADER_PARTIES[pendingLeader.physical.id], "leader:" .. pendingLeader.physical.id .. ":" .. pendingLeader.visitor.id)
        pendingLeader = nil
        return #replacement > 0 and replacement or party
      end
      if pendingNpc and trainerClass == pendingNpc.source.class and partyIndex == pendingNpc.source.member then
        local replacement = scaledParty(pendingNpc.source.party, pendingNpc.destination.party, "npc:" .. pendingNpc.destination.key .. ":" .. pendingNpc.source.key)
        pendingNpc = nil
        return #replacement > 0 and replacement or party
      end
      return party
    end)

    mod.hooks:wrap("save.new_game", function(next, save)
      save = next(save)
      if mod.options:get("gold_shuffle") then mapping() end
      return save
    end)

    mod.events:on("map.entered", function(event) applyMap(event and event.mapId) end)
    mod.events:on("game.ready", function(event)
      local game = event and event.game or mod.game
      resetTeleportOptions()
      if game and game.world and game.world.map then applyMap(game.world.map.id) end
    end)
    mod.events:on("screen.popped", function() resetTeleportOptions() end)

    mod.events:on("mod.options_changed", function(event)
      local changed = type(event and event.mod) == "table" and event.mod.id or event and event.mod
      if changed ~= mod.id then return end
      if event.key == "gold_spoiler_action" and event.value then
        resetTeleportOptions()
        local leaderMap, pages = mapping(), {}
        for i, physical in ipairs(GYMS) do
          local visitor = leaderMap and BY_ID[leaderMap[physical.id]] or physical
          local visitorName = visitor.id:gsub("_", " ")
          local badgeName = physical.badge:gsub(" BADGE$", "")
          pages[#pages + 1] = string.format("%02d/16 %s\nBADGE %s", i, visitorName, badgeName)
        end
        local TextBox = require("src.render.TextBox")
        local game = mod.game
        if game and game.stack then game.stack:push(TextBox.new(game, table.concat(pages, "\f"))) end
      elseif event.key == "gold_trainers" then
        mod.save:set("gold_gym_npc_mapping", nil)
      elseif ACTION_OPTIONS[event.key] and event.value then
        resetTeleportOptions()
        if event.key == "gold_warp_action" then useTeleport() else returnTeleport() end
      end
    end)

    return
  end

  mod.options:define({
    {
      key = "randomize_gyms",
      type = "toggle",
      label = "SHUFFLE LEADERS",
      default = true,
    },
    {
      key = "randomize_moves",
      type = "toggle",
      label = "SHUFFLE MOVESETS",
      default = false,
    },
    {
      key = "randomize_gym_trainers",
      type = "toggle",
      label = "SHUFFLE TRAINERS",
      default = false,
    },
    {
      key = "spoiler_log",
      type = "toggle",
      label = "OPEN SPOILER LOG",
      default = false,
    },
    {
      key = "gym_teleport",
      type = "toggle",
      label = "GYM WARP (TEST)",
      default = false,
    },
    {
      key = "return_to_last_point",
      type = "toggle",
      label = "RETURN POINT",
      default = false,
    },
    {
      key = "match_leader_type",
      type = "toggle",
      label = "GYM-TYPE MOVES",
      default = true,
    },
    {
      key = "allow_native_stab",
      type = "toggle",
      label = "ALLOW STAB MOVES",
      default = true,
    },
    {
      key = "ensure_damaging_move",
      type = "toggle",
      label = "ENSURE DAMAGE",
      default = true,
    },
  })

  -- Each entry describes the *physical gym slot*. `partyIndex` is the
  -- vanilla party used to establish that gym's target level curve. Giovanni
  -- is party 3 in Viridian Gym; his Rocket Hideout and Silph Co. parties are
  -- never included in the shuffle.
  local GYMS = {
    {
      id = "OPP_BROCK",
      mapId = "PEWTER_GYM",
      objectIndex = 1,
      partyIndex = 1,
      sprite = "SPRITE_SUPER_NERD",
      preBattleText = "_PewterGymBrockPreBattleText",
      adviceText = "_PewterGymBrockPostBattleAdviceText",
      gymType = "ROCK",
    },
    {
      id = "OPP_MISTY",
      mapId = "CERULEAN_GYM",
      objectIndex = 1,
      partyIndex = 1,
      sprite = "SPRITE_BRUNETTE_GIRL",
      preBattleText = "_CeruleanGymMistyPreBattleText",
      adviceText = "_CeruleanGymMistyTM11ExplanationText",
      gymType = "WATER",
    },
    {
      id = "OPP_LT_SURGE",
      mapId = "VERMILION_GYM",
      objectIndex = 1,
      partyIndex = 1,
      sprite = "SPRITE_ROCKER",
      preBattleText = "_VermilionGymLTSurgePreBattleText",
      adviceText = "_VermilionGymLTSurgePostBattleAdviceText",
      gymType = "ELECTRIC",
    },
    {
      id = "OPP_ERIKA",
      mapId = "CELADON_GYM",
      objectIndex = 1,
      partyIndex = 1,
      sprite = "SPRITE_SILPH_WORKER_F",
      preBattleText = "_CeladonGymErikaPreBattleText",
      adviceText = "_CeladonGymErikaPostBattleAdviceText",
      gymType = "GRASS",
    },
    {
      id = "OPP_KOGA",
      mapId = "FUCHSIA_GYM",
      objectIndex = 1,
      partyIndex = 1,
      sprite = "SPRITE_KOGA",
      preBattleText = "_FuchsiaGymKogaBeforeBattleText",
      adviceText = "_FuchsiaGymKogaPostBattleAdviceText",
      gymType = "POISON",
    },
    {
      id = "OPP_SABRINA",
      mapId = "SAFFRON_GYM",
      objectIndex = 1,
      partyIndex = 1,
      sprite = "SPRITE_GIRL",
      preBattleText = "_SaffronGymSabrinaText",
      adviceText = "_SaffronGymSabrinaPostBattleAdviceText",
      gymType = "PSYCHIC",
    },
    {
      id = "OPP_BLAINE",
      mapId = "CINNABAR_GYM",
      objectIndex = 1,
      partyIndex = 1,
      sprite = "SPRITE_MIDDLE_AGED_MAN",
      preBattleText = "_CinnabarGymBlainePreBattleText",
      adviceText = "_CinnabarGymBlainePostBattleAdviceText",
      gymType = "FIRE",
    },
    {
      id = "OPP_GIOVANNI",
      mapId = "VIRIDIAN_GYM",
      objectIndex = 1,
      partyIndex = 3,
      sprite = "SPRITE_GIOVANNI",
      preBattleText = "_ViridianGymGiovanniPreBattleText",
      adviceText = "_ViridianGymGiovanniPostBattleAdviceText",
      gymType = "GROUND",
    },
  }

  local GYM_BY_MAP = {}
  local GYM_BY_ID = {}
  for _, gym in ipairs(GYMS) do
    GYM_BY_MAP[gym.mapId] = gym
    GYM_BY_ID[gym.id] = gym
  end

  -- The city-map coordinates are one tile outside each gym entrance. They
  -- were checked against the Red, Blue, and Yellow extracted warp tables.
  local GYM_TELEPORTS = {
    OPP_BROCK = {
      badge = "BOULDERBADGE", mapId = "PEWTER_CITY", x = 16, y = 18,
    },
    OPP_MISTY = {
      badge = "CASCADEBADGE", mapId = "CERULEAN_CITY", x = 30, y = 20,
    },
    OPP_LT_SURGE = {
      badge = "THUNDERBADGE", mapId = "VERMILION_CITY", x = 12, y = 20,
    },
    OPP_ERIKA = {
      badge = "RAINBOWBADGE", mapId = "CELADON_CITY", x = 12, y = 28,
    },
    OPP_KOGA = {
      badge = "SOULBADGE", mapId = "FUCHSIA_CITY", x = 5, y = 28,
    },
    OPP_SABRINA = {
      badge = "MARSHBADGE", mapId = "SAFFRON_CITY", x = 34, y = 4,
    },
    OPP_BLAINE = {
      badge = "VOLCANOBADGE", mapId = "CINNABAR_ISLAND", x = 18, y = 4,
    },
    OPP_GIOVANNI = {
      badge = "EARTHBADGE", mapId = "VIRIDIAN_CITY", x = 32, y = 8,
    },
  }

  -- Captured in the entry chunk, while the imported base data is already
  -- available. The copies stay fixed so party scaling always targets the
  -- vanilla gym progression rather than a prior battle's temporary party.
  local VANILLA_PARTIES = {}
  local GYM_TRAINERS = {}
  local GYM_TRAINERS_BY_GYM = {}
  local GYM_TRAINER_BY_KEY = {}
  local PRE_EVOLUTION = nil
  local LIVE_GYM_NPCS = {}
  local LIVE_GYM_TRAINERS = {}

  local function copyRecord(value)
    if type(value) ~= "table" then return value end
    local out = {}
    for key, child in pairs(value) do out[key] = copyRecord(child) end
    return out
  end

  -- Crystal 251 enriches trainer rows with Gen II fields. Preserve every
  -- imported field in our baseline snapshot, then alter only species, level,
  -- and an explicitly requested moveset during physical-gym scaling.
  local function copyParty(party)
    local out = {}
    for i, mon in ipairs(party or {}) do out[i] = copyRecord(mon) end
    return out
  end

  for _, gym in ipairs(GYMS) do
    local trainer = mod.content.trainers:get(gym.id)
    local party = trainer and trainer.parties and trainer.parties[gym.partyIndex]
    if party then
      VANILLA_PARTIES[gym.id] = copyParty(party)
    else
      mod.log:error("Could not find %s party %d", gym.id, gym.partyIndex)
    end

    GYM_TRAINERS_BY_GYM[gym.id] = {}
    local map = mod.content.maps:get(gym.mapId)
    for arrayIndex, object in ipairs(map and map.objects or {}) do
      local objectIndex = object.index or arrayIndex
      if objectIndex ~= gym.objectIndex and object.trainerClass then
        local sourceTrainer = mod.content.trainers:get(object.trainerClass)
        local sourceParty = sourceTrainer and sourceTrainer.parties
          and sourceTrainer.parties[object.trainerParty]
        if sourceParty then
          local record = {
            key = gym.id .. ":" .. tostring(objectIndex),
            gymId = gym.id,
            mapId = gym.mapId,
            objectIndex = objectIndex,
            trainerClass = object.trainerClass,
            trainerParty = object.trainerParty,
            sprite = object.sprite,
            text = object.text,
            vanillaParty = copyParty(sourceParty),
          }
          GYM_TRAINERS[#GYM_TRAINERS + 1] = record
          GYM_TRAINERS_BY_GYM[gym.id][#GYM_TRAINERS_BY_GYM[gym.id] + 1] = record
          GYM_TRAINER_BY_KEY[record.key] = record
        else
          mod.log:warn("Could not find gym trainer party %s / %s", tostring(object.trainerClass), tostring(object.trainerParty))
        end
      end
    end
  end

  local function buildPreEvolutionIndex()
    if PRE_EVOLUTION then return end

    PRE_EVOLUTION = {}
    for speciesId, pokemon in mod.content.pokemon:each() do
      for _, evolution in ipairs(pokemon.evolutions or {}) do
        if evolution.method == "LEVEL" and evolution.species and evolution.level then
          PRE_EVOLUTION[evolution.species] = {
            species = speciesId,
            level = evolution.level,
          }
        end
      end
    end
  end

  local function devolveForLevel(species, level)
    buildPreEvolutionIndex()

    local current = species
    for _ = 1, 6 do
      local preEvolution = PRE_EVOLUTION[current]
      if not preEvolution or level >= preEvolution.level then break end
      current = preEvolution.species
    end
    return current
  end

  local function evolveForLevel(species, level)
    local current = species
    for _ = 1, 6 do
      local pokemon = mod.content.pokemon:get(current)
      local nextSpecies
      local nextLevel

      for _, evolution in ipairs(pokemon and pokemon.evolutions or {}) do
        if evolution.method == "LEVEL"
          and evolution.species
          and evolution.level
          and level >= evolution.level
          and (not nextLevel or evolution.level < nextLevel) then
          nextSpecies = evolution.species
          nextLevel = evolution.level
        end
      end

      if not nextSpecies then break end
      current = nextSpecies
    end
    return current
  end

  local function fitSpeciesToLevel(species, level)
    if not species or not level then return species end
    return evolveForLevel(devolveForLevel(species, level), level)
  end

  local function shuffle(list)
    for i = #list, 2, -1 do
      local j = love.math.random(i)
      list[i], list[j] = list[j], list[i]
    end
  end

  local function moveMatchesNativeType(move, pokemon)
    for _, pokemonType in ipairs(pokemon.types or {}) do
      if move.type == pokemonType then return true end
    end
    return false
  end

  local function candidateMoves(species, level, gymType)
    local pokemon = mod.content.pokemon:get(species)
    if not pokemon then return {} end

    local chosen = {}
    local seen = {}

    local function add(moveId)
      if not moveId or seen[moveId] then return end
      local move = mod.content.moves:get(moveId)
      if not move then return end

      local score = 0
      if mod.options:get("match_leader_type") and move.type == gymType then
        score = 2
      elseif mod.options:get("allow_native_stab") and moveMatchesNativeType(move, pokemon) then
        score = 1
      end

      seen[moveId] = true
      chosen[#chosen + 1] = {
        id = moveId,
        score = score,
        damaging = (move.power or 0) > 0,
      }
    end

    for _, moveId in ipairs(pokemon.level1Moves or {}) do
      add(moveId)
    end

    for _, learned in ipairs(pokemon.learnset or {}) do
      if not learned.level or learned.level <= level then
        add(learned.move)
      end
    end

    -- Every vanilla species has one of these. They are a conservative fallback
    -- for unusual records whose learnset contains no usable move at the target
    -- level.
    for _, moveId in ipairs({
      "TACKLE", "SCRATCH", "POUND", "QUICK_ATTACK", "BITE", "HEADBUTT",
    }) do
      add(moveId)
    end

    return chosen
  end

  local function randomizedMoves(species, level, gymType)
    if not mod.options:get("randomize_moves") then return nil end

    local candidates = candidateMoves(species, level, gymType)
    local preferred = {}
    local neutral = {}
    for _, candidate in ipairs(candidates) do
      if candidate.score > 0 then
        preferred[#preferred + 1] = candidate
      else
        neutral[#neutral + 1] = candidate
      end
    end
    shuffle(preferred)
    shuffle(neutral)

    local pool = {}
    for _, candidate in ipairs(preferred) do pool[#pool + 1] = candidate end
    for _, candidate in ipairs(neutral) do pool[#pool + 1] = candidate end

    local moves = {}
    local used = {}
    if mod.options:get("ensure_damaging_move") then
      for _, candidate in ipairs(pool) do
        if candidate.damaging then
          moves[#moves + 1] = candidate.id
          used[candidate.id] = true
          break
        end
      end
    end

    for _, candidate in ipairs(pool) do
      if #moves >= 4 then break end
      if not used[candidate.id] then
        moves[#moves + 1] = candidate.id
        used[candidate.id] = true
      end
    end

    return moves
  end

  local function scaledParty(sourceLeaderId, destinationGym)
    local source = VANILLA_PARTIES[sourceLeaderId] or {}
    local target = VANILLA_PARTIES[destinationGym.id] or {}
    local out = {}

    for i = 1, #target do
      local sourceMon = source[math.min(i, #source)] or source[1]
      local targetMon = target[i]
      if sourceMon and targetMon then
        local species = fitSpeciesToLevel(sourceMon.species, targetMon.level)
        local entry = copyRecord(sourceMon)
        entry.species, entry.level = species, targetMon.level
        local moves = randomizedMoves(species, targetMon.level, destinationGym.gymType)
        if moves and #moves > 0 then entry.moves = moves end
        out[#out + 1] = entry
      end
    end

    return out
  end

  local function scaledGymTrainerParty(sourceTrainer, destinationTrainer, destinationGym)
    local source = sourceTrainer and sourceTrainer.vanillaParty or {}
    local target = destinationTrainer and destinationTrainer.vanillaParty or {}
    local out = {}

    for i = 1, #target do
      local sourceMon = source[math.min(i, #source)] or source[1]
      local targetMon = target[i]
      if sourceMon and targetMon then
        local species = fitSpeciesToLevel(sourceMon.species, targetMon.level)
        local entry = copyRecord(sourceMon)
        entry.species, entry.level = species, targetMon.level
        local moves = randomizedMoves(species, targetMon.level, destinationGym.gymType)
        if moves and #moves > 0 then entry.moves = moves end
        out[#out + 1] = entry
      end
    end
    return out
  end

  local function createMapping()
    local leaders = {}
    for _, gym in ipairs(GYMS) do leaders[#leaders + 1] = gym.id end

    -- Use a derangement, not a generic permutation: every physical gym gets a
    -- different leader. This avoids a valid-but-confusing result where Brock
    -- happens to remain in Pewter on the first test.
    local hasFixedPoint
    repeat
      shuffle(leaders)
      hasFixedPoint = false
      for i, gym in ipairs(GYMS) do
        if leaders[i] == gym.id then
          hasFixedPoint = true
          break
        end
      end
    until not hasFixedPoint

    local mapping = {}
    for i, gym in ipairs(GYMS) do
      mapping[gym.id] = leaders[i]
    end
    mod.save:set("gym_mapping", mapping)
    mod.save:set("gym_trainer_mapping", nil)
    mod.log:info("Created a gym leader shuffle for this save")
    return mapping
  end

  -- A save made before this mod was installed has no modData bucket yet. Create
  -- its mapping the first time a gym is reached, rather than silently falling
  -- back to vanilla forever. A New Game also uses this helper deliberately.
  local function mappingForSave()
    if not mod.options:get("randomize_gyms") then return nil end
    return mod.save:get("gym_mapping") or createMapping()
  end

  -- For each physical gym, trainer slots draw from the visiting leader's
  -- original gym trainer roster. This changes non-leader teams, trainer
  -- classes, and sprites while preserving the physical gym's leader reward.
  local function createTrainerMapping(leaderMapping)
    local assignments = {}
    for _, destinationGym in ipairs(GYMS) do
      local sourceLeaderId = leaderMapping[destinationGym.id]
      local sourceGym = GYM_BY_ID[sourceLeaderId]
      local sourceTrainers = sourceGym and GYM_TRAINERS_BY_GYM[sourceGym.id] or {}
      local destinationTrainers = GYM_TRAINERS_BY_GYM[destinationGym.id] or {}
      if #sourceTrainers > 0 then
        local order = {}
        for i = 1, #sourceTrainers do order[i] = sourceTrainers[i] end
        shuffle(order)
        for i, destinationTrainer in ipairs(destinationTrainers) do
          assignments[destinationTrainer.key] = order[((i - 1) % #order) + 1].key
        end
      end
    end
    mod.save:set("gym_trainer_mapping", assignments)
    mod.log:info("Created a gym trainer shuffle for this save")
    return assignments
  end

  local function trainerMappingForSave(leaderMapping)
    if not mod.options:get("randomize_gym_trainers") or not leaderMapping then
      return nil
    end
    return mod.save:get("gym_trainer_mapping") or createTrainerMapping(leaderMapping)
  end

  local LEADER_NAMES = {
    OPP_BROCK = "BROCK", OPP_MISTY = "MISTY", OPP_LT_SURGE = "LT. SURGE",
    OPP_ERIKA = "ERIKA", OPP_KOGA = "KOGA", OPP_SABRINA = "SABRINA",
    OPP_BLAINE = "BLAINE", OPP_GIOVANNI = "GIOVANNI",
  }

  local projectGymStatues

  -- Gym statues are a shared engine interaction that reads the live
  -- data.scripts.gyms table for the physical map. Preserve each game's native
  -- spelling/punctuation, then project only the visiting leader name from the
  -- same saved mapping used by the leader sprite and battle.
  do
    local ok, statues = pcall(require, "data.scripts.gyms")
    if ok and type(statues) == "table" then
      local baseNames = {}
      for _, gym in ipairs(GYMS) do
        baseNames[gym.mapId] = statues[gym.mapId] and statues[gym.mapId].leader
      end
      projectGymStatues = function(leaderMapping)
        for _, physicalGym in ipairs(GYMS) do
          local statue = statues[physicalGym.mapId]
          local visitor = leaderMapping and GYM_BY_ID[leaderMapping[physicalGym.id]]
            or physicalGym
          if statue then
            statue.leader = baseNames[visitor.mapId] or LEADER_NAMES[visitor.id]
          end
        end
      end
    else
      mod.log:warn("Gym statue labels are unavailable on this engine build")
    end
  end

  local BADGE_NAMES = {
    OPP_BROCK = "BOULDER BADGE", OPP_MISTY = "CASCADE BADGE",
    OPP_LT_SURGE = "THUNDER BADGE", OPP_ERIKA = "RAINBOW BADGE",
    OPP_KOGA = "SOUL BADGE", OPP_SABRINA = "MARSH BADGE",
    OPP_BLAINE = "VOLCANO BADGE", OPP_GIOVANNI = "EARTH BADGE",
  }

  local function openSpoilerLog()
    local game = mod.game
    local mapping = mappingForSave()
    if not (game and mapping) then
      mod.log:warn("Spoiler log is unavailable until gym leader shuffling is enabled on a save")
      return false
    end

    -- TextBox displays exactly two rows at a time. Make each assignment its
    -- own explicit page instead of relying on scrolling, which keeps every
    -- leader and badge pair legible at the normal Game Boy text width.
    local pages = {}
    for i, gym in ipairs(GYMS) do
      local assignedId = mapping[gym.id] or gym.id
      pages[#pages + 1] = string.format("%d/8 %s", i,
        LEADER_NAMES[assignedId] or assignedId)
        .. "\n" .. (BADGE_NAMES[gym.id] or gym.id)
    end

    local TextBox = require("src.render.TextBox")
    game.stack:push(TextBox.new(game, table.concat(pages, "\f")))
    return true
  end

  local function hasBadge(game, leaderId)
    local destination = GYM_TELEPORTS[leaderId]
    local inventory = game and game.save and game.save.inventory or {}
    return destination and inventory[destination.badge] and true or false
  end

  local function nextGymCandidates(game)
    -- The first four badges are ordered by the normal Gen 1 progression. Once
    -- Celadon is complete, Fuchsia and Saffron are both valid next targets.
    -- Blaine becomes another valid choice after Koga, while Giovanni remains
    -- last. Whenever several valid gyms remain, choose one randomly.
    if not hasBadge(game, "OPP_BROCK") then return { "OPP_BROCK" } end
    if not hasBadge(game, "OPP_MISTY") then return { "OPP_MISTY" } end
    if not hasBadge(game, "OPP_LT_SURGE") then return { "OPP_LT_SURGE" } end
    if not hasBadge(game, "OPP_ERIKA") then return { "OPP_ERIKA" } end

    local candidates = {}
    if not hasBadge(game, "OPP_KOGA") then
      candidates[#candidates + 1] = "OPP_KOGA"
    end
    if not hasBadge(game, "OPP_SABRINA") then
      candidates[#candidates + 1] = "OPP_SABRINA"
    end
    if hasBadge(game, "OPP_KOGA") and not hasBadge(game, "OPP_BLAINE") then
      candidates[#candidates + 1] = "OPP_BLAINE"
    end
    if #candidates > 0 then return candidates end

    if not hasBadge(game, "OPP_GIOVANNI") then return { "OPP_GIOVANNI" } end
    return {}
  end

  local GYM_TELEPORT_ORIGIN_KEY = "gym_teleport_origin"

  local function captureGymTeleportOrigin()
    local existing = mod.save:get(GYM_TELEPORT_ORIGIN_KEY)
    if type(existing) == "table" and type(existing.mapId) == "string"
      and type(existing.x) == "number" and type(existing.y) == "number" then
      return existing
    end

    local current, err = mod.world:current()
    if not current or type(current.mapId) ~= "string"
      or type(current.x) ~= "number" or type(current.y) ~= "number" then
      mod.log:warn("Gym Teleport could not record a return point: %s", tostring(err))
      return nil
    end

    local origin = {
      mapId = current.mapId,
      x = current.x,
      y = current.y,
      facing = current.facing or "down",
    }
    mod.save:set(GYM_TELEPORT_ORIGIN_KEY, origin)
    mod.log:info("Gym Teleport recorded return point: %s (%d, %d)",
      origin.mapId, origin.x, origin.y)
    return origin
  end

  local function returnToGymTeleportOrigin()
    local origin = mod.save:get(GYM_TELEPORT_ORIGIN_KEY)
    if type(origin) ~= "table" or type(origin.mapId) ~= "string"
      or type(origin.x) ~= "number" or type(origin.y) ~= "number" then
      mod.log:warn("Return to Last Point: no Gym Teleport origin has been recorded")
      return false
    end

    local ok, err = mod.world:warpTo(origin.mapId, origin.x, origin.y,
      origin.facing or "down", { arrive = "teleport" })
    if not ok then
      mod.log:warn("Return to Last Point failed: %s", tostring(err))
      return false
    end

    -- A completed return closes the testing loop. The next Gym Teleport starts
    -- a new chain and records the player's then-current location.
    mod.save:set(GYM_TELEPORT_ORIGIN_KEY, nil)
    mod.log:info("Return to Last Point: returned to %s", origin.mapId)
    return true
  end

  local function teleportToNextGym()
    local game = mod.game
    local origin = captureGymTeleportOrigin()
    if not origin then return false end
    local candidates = nextGymCandidates(game)
    if #candidates == 0 then
      mod.log:info("Gym Teleport: every Kanto gym badge is already owned")
      return false
    end

    local leaderId = candidates[love.math.random(#candidates)]
    local target = GYM_TELEPORTS[leaderId]
    local ok, err = mod.world:warpTo(target.mapId, target.x, target.y, "up", {
      arrive = "teleport",
    })
    if not ok then
      mod.log:warn("Gym Teleport failed: %s", tostring(err))
      return false
    end

    mod.log:info("Gym Teleport: sent player to %s", leaderId)
    return true
  end

  -- The map registry already contains the imported game's exact object data.
  -- Reading the source leader object here supports Red, Blue, and Yellow: the
  -- latter uses different overworld sheets for Koga, Sabrina, and Blaine.
  local function leaderSpriteForGame(gym)
    local map = mod.content.maps:get(gym.mapId)
    for _, object in ipairs(map and map.objects or {}) do
      if object.index == gym.objectIndex and object.sprite then
        return object.sprite
      end
    end
    return gym.sprite
  end

  local function sourceLeaderText(leader)
    local map = mod.content.maps:get(leader.mapId)
    for _, object in ipairs(map and map.objects or {}) do
      if object.index == leader.objectIndex and object.text then
        return map.label, object.text
      end
    end
    return nil, nil
  end

  -- A defeated gym NPC remains the physical gym's NPC. Keep both its TM
  -- retry and its post-battle advice so every post-battle reference agrees
  -- with that gym's badge and TM.
  local function retryPhysicalGymTm(game, overworld, gym, done)
    local rewards = require("data.scripts.victories")
    local reward = rewards[gym.id .. "#" .. gym.partyIndex]
    if not (reward and reward.gotFlag) then return false end
    if game.save.flags[reward.gotFlag] then return false end

    local owned = game.save.inventory and game.save.inventory[reward.item] or 0
    if owned > 0 then
      game.save.flags[reward.gotFlag] = true
      return false
    end

    overworld:offerGymTm(reward, done)
    return true
  end

  -- The built-in gym scripts bind each room to its original leader's text
  -- constant. Replace that final talk dispatch, not the reward system: the
  -- visiting leader contributes only pre-battle dialogue, while the physical
  -- gym owns every post-battle line, its badge, TM, flags, and trainer
  -- deactivation.
  local function shuffledLeaderTalk(physicalGym)
    return function(game, overworld, npc, done)
      done = done or function() end
      local mapping = mappingForSave()
      local assignedId = mapping and mapping[physicalGym.id]
      local visitingLeader = GYM_BY_ID[assignedId] or physicalGym

      if game.save.defeatedTrainers and game.save.defeatedTrainers[npc.id] then
        if retryPhysicalGymTm(game, overworld, physicalGym, done) then return end

        local TextBox = require("src.render.TextBox")
        local advice = game.data.text[physicalGym.adviceText]
          or (physicalGym.id .. " has no repeat dialogue.")
        game.stack:push(TextBox.new(game, advice, done))
        return
      end

      local preBattle = game.data.text[visitingLeader.preBattleText]
      if not preBattle then
        mod.log:warn("Could not find challenge dialogue for %s", visitingLeader.id)
        overworld:engageTrainer(npc, done)
        return
      end

      local TextBox = require("src.render.TextBox")
      game.stack:push(TextBox.new(game, preBattle, function()
        -- The source pre-battle text was just displayed. Suppress the
        -- physical gym's duplicate pre-battle box, but retain its battle and
        -- reward machinery.
        overworld:engageTrainer(npc, done, nil, true)
      end))
    end
  end

  for _, gym in ipairs(GYMS) do
    local sourceLabel, sourceText = sourceLeaderText(gym)
    if sourceLabel and sourceText then
      mod.content.map_scripts:register(gym.mapId, {
        priority = 100,
        talk = {
          [sourceText] = shuffledLeaderTalk(gym),
        },
      })
    else
      mod.log:error("Could not register dialogue override for %s", gym.id)
    end
  end

  -- Ordinary gym trainers normally resolve their battle and victory lines from
  -- the physical map's trainer header. When their teams are shuffled, compose
  -- only their talk handler so the trainer uses the source gym's dialogue too.
  -- The battle still goes through the normal trainer flow, which keeps defeat
  -- tracking, physical-gym rewards, and all battle timing unchanged.
  local function shuffledGymTrainerTalk(destinationTrainer)
    return function(game, overworld, npc, done)
      done = done or function() end
      local leaderMapping = mappingForSave()
      local assignments = trainerMappingForSave(leaderMapping)
      local sourceKey = assignments and assignments[destinationTrainer.key]
      local sourceTrainer = sourceKey and GYM_TRAINER_BY_KEY[sourceKey]
        or destinationTrainer
      local header = game and game.data and game.data.trainerHeader
        and game.data:trainerHeader(sourceTrainer.mapId, sourceTrainer.objectIndex)
      local text = game and game.data and game.data.text or {}

      if npc and npc.facePlayer and overworld and overworld.player then
        npc:facePlayer(overworld.player)
      end
      if game.save.defeatedTrainers and game.save.defeatedTrainers[npc.id] then
        local after = header and header.after and text[header.after]
        if after then
          local TextBox = require("src.render.TextBox")
          game.stack:push(TextBox.new(game, after, done))
        else
          done()
        end
        return
      end

      local battleText = header and header.battle and text[header.battle]
      local wonText = header and header.won and text[header.won]
      local function engage()
        overworld:engageTrainer(npc, done, wonText, battleText ~= nil)
      end
      if battleText then
        local TextBox = require("src.render.TextBox")
        game.stack:push(TextBox.new(game, battleText, engage))
      else
        engage()
      end
    end
  end

  for _, trainer in ipairs(GYM_TRAINERS) do
    if trainer.text then
      mod.content.map_scripts:register(trainer.mapId, {
        priority = 110,
        talk = {
          [trainer.text] = shuffledGymTrainerTalk(trainer),
        },
      })
    end
  end

  local function setNpcSprite(npc, spriteId)
    local spriteDef = mod.content.sprites:get(spriteId)
    if not spriteDef then
      mod.log:error("Missing overworld sprite %s", tostring(spriteId))
      return false
    end

    npc.def.sprite = spriteId
    npc.sprite = SpriteRenderer.new(spriteDef, npc.id)
    return true
  end

  local function restorePhysicalGymTrainer(record)
    local npc = record.npc
    local trainer = record.destinationTrainer
    npc.def.trainerClass = trainer.trainerClass
    npc.def.trainerParty = trainer.trainerParty
    -- Keep the shuffled trainer's sprite visible in the gym. Only class and
    -- party identity return to the physical record after battle setup.
  end

  local function applyGymTrainersToActiveMap(gym, leaderMapping)
    local assignments = trainerMappingForSave(leaderMapping)
    for _, destinationTrainer in ipairs(GYM_TRAINERS_BY_GYM[gym.id] or {}) do
      local handle = mod.world:npc(gym.mapId, destinationTrainer.objectIndex)
      local npc = handle and handle.npc
      if npc then
        local sourceKey = assignments and assignments[destinationTrainer.key]
        local sourceTrainer = sourceKey and GYM_TRAINER_BY_KEY[sourceKey]
        if sourceTrainer then
          npc.def.trainerClass = sourceTrainer.trainerClass
          npc.def.trainerParty = sourceTrainer.trainerParty
          setNpcSprite(npc, sourceTrainer.sprite)
          LIVE_GYM_TRAINERS[npc.id] = {
            npc = npc,
            gym = gym,
            destinationTrainer = destinationTrainer,
            sourceTrainer = sourceTrainer,
          }
        else
          npc.def.trainerClass = destinationTrainer.trainerClass
          npc.def.trainerParty = destinationTrainer.trainerParty
          setNpcSprite(npc, destinationTrainer.sprite)
          LIVE_GYM_TRAINERS[npc.id] = nil
        end
      end
    end
  end

  local function restorePhysicalGymIdentity(record)
    local npc = record.npc
    local gym = record.gym
    npc.def.trainerClass = gym.id
    npc.def.trainerParty = gym.partyIndex
  end

  local function applyGymToActiveMap(mapId)
    local gym = GYM_BY_MAP[mapId]
    if not gym then return end
    local mapping = mappingForSave()
    if projectGymStatues then projectGymStatues(mapping) end

    local handle = mod.world:npc(mapId, gym.objectIndex)
    local npc = handle and handle.npc
    if not npc then
      mod.log:warn("Could not find gym object %s / %d", mapId, gym.objectIndex)
      return
    end

    local assignedLeaderId = mapping and mapping[gym.id]
    local assignedGym = assignedLeaderId and GYM_BY_ID[assignedLeaderId]

    if not assignedGym then
      npc.def.trainerClass = gym.id
      npc.def.trainerParty = gym.partyIndex
      setNpcSprite(npc, leaderSpriteForGame(gym))
      LIVE_GYM_NPCS[npc.id] = nil
      applyGymTrainersToActiveMap(gym, nil)
      return
    end

    npc.def.trainerClass = assignedGym.id
    npc.def.trainerParty = assignedGym.partyIndex
    setNpcSprite(npc, leaderSpriteForGame(assignedGym))
    LIVE_GYM_NPCS[npc.id] = {
      npc = npc,
      gym = gym,
      assignedLeaderId = assignedGym.id,
      assignedPartyIndex = assignedGym.partyIndex,
    }
    applyGymTrainersToActiveMap(gym, mapping)
  end

  -- The mapping is generated once for a New Game. For an existing save that
  -- predates the mod, mappingForSave creates it on the first gym map entry.
  mod.hooks:wrap("save.new_game", function(next, save)
    save = next(save)

    if not mod.options:get("randomize_gyms") then
      mod.save:set("gym_mapping", nil)
      return save
    end

    createMapping()
    return save
  end)

  -- `trainer.party` is called after the battle's trainer class and party index
  -- have been selected. The pending record, set by world.trainer_engaged,
  -- identifies the physical gym and makes Giovanni's other two appearances
  -- remain vanilla.
  local pendingGymBattle
  local pendingGymTrainerBattle
  mod.hooks:wrap("trainer.party", function(next, trainerClass, partyIndex, party)
    party = next(trainerClass, partyIndex, party)

    local pending = pendingGymBattle
    if pending
      and trainerClass == pending.assignedLeaderId
      and partyIndex == pending.assignedPartyIndex then
      local replacement = scaledParty(pending.assignedLeaderId, pending.gym)
      if #replacement == 0 then
        mod.log:warn("Could not scale party for %s", pending.gym.id)
        return party
      end
      return replacement
    end

    local trainerPending = pendingGymTrainerBattle
    if trainerPending
      and trainerClass == trainerPending.sourceTrainer.trainerClass
      and partyIndex == trainerPending.sourceTrainer.trainerParty then
      local replacement = scaledGymTrainerParty(
        trainerPending.sourceTrainer, trainerPending.destinationTrainer,
        trainerPending.gym)
      if #replacement > 0 then return replacement end
      mod.log:warn("Could not scale shuffled gym trainer %s", trainerPending.destinationTrainer.key)
    end
    return party
  end)

  mod.events:on("map.entered", function(event)
    applyGymToActiveMap(event.mapId)
  end)

  mod.events:on("game.ready", function(event)
    if crystal251Active() then
      mod.log:info("Gym Leader Shuffle: Crystal 251 detected; preserving imported trainer-party fields")
    end
    local game = event and event.game or mod.game
    if game and game.world and game.world.map then applyGymToActiveMap(game.world.map.id) end
  end)

  mod.events:on("world.trainer_engaged", function(event)
    local leaderRecord = event.npc and LIVE_GYM_NPCS[event.npc.id]
    if leaderRecord then
      -- A prior battle restores the physical gym identity so its reward remains
      -- correct. Reapply the visitor at the next engagement so a rematch after
      -- losing still starts against the shuffled leader.
      event.npc.def.trainerClass = leaderRecord.assignedLeaderId
      event.npc.def.trainerParty = leaderRecord.assignedPartyIndex
      pendingGymBattle = leaderRecord
      return
    end

    local trainerRecord = event.npc and LIVE_GYM_TRAINERS[event.npc.id]
    if trainerRecord then
      event.npc.def.trainerClass = trainerRecord.sourceTrainer.trainerClass
      event.npc.def.trainerParty = trainerRecord.sourceTrainer.trainerParty
      pendingGymTrainerBattle = trainerRecord
    end
  end)

  -- The engine calculates trainer art and the battle party before this event.
  -- Restoring only the physical gym's trainer class/party here ensures the
  -- normal gym badge and TM reward remain tied to the building the player beat.
  -- The visiting leader's sprite stays on the NPC when the battle screen closes.
  mod.events:on("battle.started", function(event)
    local origin = event.battle and event.battle.checkpointOrigin
    local leaderRecord = origin and LIVE_GYM_NPCS[origin.npcId]
    if leaderRecord and event.trainerId == leaderRecord.assignedLeaderId then
      restorePhysicalGymIdentity(leaderRecord)
    end

    local trainerRecord = origin and LIVE_GYM_TRAINERS[origin.npcId]
    if trainerRecord
      and event.trainerId == trainerRecord.sourceTrainer.trainerClass then
      restorePhysicalGymTrainer(trainerRecord)
    end
    pendingGymBattle = nil
    pendingGymTrainerBattle = nil
  end)

  local ACTION_OPTIONS = {
    gym_teleport = true,
    return_to_last_point = true,
    spoiler_log = true,
  }

  local function resetActionOptions()
    local game = mod.game
    local stored = game and game.save and game.save.options and game.save.options.modOptions
    local active = game and game.mods and game.mods.modOptions
    stored = stored and stored[mod.id]
    active = active and active[mod.id]
    for key in pairs(ACTION_OPTIONS) do
      if stored then stored[key] = false end
      if active then active[key] = false end
    end
  end

  mod.events:on("mod.options_changed", function(event)
    -- ManagerState emits `mod` as this mod's string ID, not as a mod object.
    -- Accept an object too for compatibility with any future event producer.
    local changedModId = type(event.mod) == "table" and event.mod.id or event.mod
    if changedModId ~= mod.id then return end

    -- These rows are one-shot actions. Clear their persisted and live values
    -- before running the action so the next click always produces a new event.
    if event.key == "gym_teleport" then
      if event.value then
        resetActionOptions()
        teleportToNextGym()
      end
      return
    end

    if event.key == "return_to_last_point" then
      if event.value then
        resetActionOptions()
        returnToGymTeleportOrigin()
      end
      return
    end

    if event.key == "spoiler_log" then
      if event.value then
        resetActionOptions()
        openSpoilerLog()
      end
      return
    end

    if event.key == "randomize_gyms" or event.key == "randomize_gym_trainers" then
      local current = mod.world:current()
      if current then applyGymToActiveMap(current.mapId) end
    end
  end)
end
