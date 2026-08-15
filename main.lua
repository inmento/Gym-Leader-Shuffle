-- Gym Leader Shuffle
-- Release: 0.0.2
-- Gen 1 Recomp mod API 2
--
-- This mod assigns one of the eight Kanto gym leaders to each gym when a new
-- save is created. The physical gym still awards its normal badge/TM; the
-- visiting leader supplies the battle portrait, overworld sprite, and party.

local SpriteRenderer = require("src.render.SpriteRenderer")

return function(mod)
  mod.options:define({
    {
      key = "randomize_gyms",
      type = "toggle",
      label = "SHUFFLE GYM LEADERS",
      default = true,
    },
    {
      key = "randomize_moves",
      type = "toggle",
      label = "RANDOMIZE MOVE SETS",
      default = false,
    },
    {
      key = "randomize_gym_trainers",
      type = "toggle",
      label = "SHUFFLE GYM TRAINERS",
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
      label = "GYM TELEPORT (TEST)",
      default = false,
    },
    {
      key = "return_to_last_point",
      type = "toggle",
      label = "RETURN TO LAST POINT (TEST)",
      default = false,
    },
    {
      key = "match_leader_type",
      type = "toggle",
      label = "PREFER GYM-TYPE MOVES",
      default = true,
    },
    {
      key = "allow_native_stab",
      type = "toggle",
      label = "ALLOW NATIVE STAB MOVES",
      default = true,
    },
    {
      key = "ensure_damaging_move",
      type = "toggle",
      label = "ENSURE A DAMAGING MOVE",
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

  local function copyParty(party)
    local out = {}
    for i, mon in ipairs(party or {}) do
      out[i] = {
        species = mon.species,
        level = mon.level,
      }
    end
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
        local entry = {
          species = species,
          level = targetMon.level,
        }
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
        local entry = { species = species, level = targetMon.level }
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

    local handle = mod.world:npc(mapId, gym.objectIndex)
    local npc = handle and handle.npc
    if not npc then
      mod.log:warn("Could not find gym object %s / %d", mapId, gym.objectIndex)
      return
    end

    local mapping = mappingForSave()
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

  mod.events:on("mod.options_changed", function(event)
    -- ManagerState emits `mod` as this mod's string ID, not as a mod object.
    -- Accept an object too for compatibility with any future event producer.
    local changedModId = type(event.mod) == "table" and event.mod.id or event.mod
    if changedModId ~= mod.id then return end

    -- This is deliberately one-shot: switch it on to warp, then switch it
    -- off and on again for the next test jump. The options facade is
    -- read-only, so the mod does not silently change the player's setting.
    if event.key == "gym_teleport" then
      if event.value then teleportToNextGym() end
      return
    end

    if event.key == "return_to_last_point" then
      if event.value then returnToGymTeleportOrigin() end
      return
    end

    -- Like the testing teleport, the spoiler log is an option-triggered
    -- action: turn it on to open, then off and on again to reopen it.
    if event.key == "spoiler_log" then
      if event.value then openSpoilerLog() end
      return
    end

    if event.key == "randomize_gyms" or event.key == "randomize_gym_trainers" then
      local current = mod.world:current()
      if current then applyGymToActiveMap(current.mapId) end
    end
  end)
end
