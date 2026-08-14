# Gym Leader Shuffle

Gym Leader Shuffle creates a persistent per-save derangement of the eight Kanto Gym Leaders. The visiting leader supplies the overworld sprite, trainer portrait, intro dialogue, and scaled battle team. The physical gym continues to own every badge, TM, reward line, progression flag, and post-battle dialogue.

| Example | Result |
|---|---|
| Lt. Surge occupies Pewter Gym | Surge appears and gives Surge’s pre-battle challenge and a team scaled to Pewter. |
| Winning that battle | The player receives Brock’s Boulder Badge and TM Bide, with Brock’s reward wording. |

## Install

Import `gym_leader_shuffle-0.0.1.zip` through Gen 1 Recomp’s **Import mod .zip** action. Alternatively, extract its files so the layout is exactly:

```text
mods/
└── gym_leader_shuffle/
    ├── manifest.json
    ├── main.lua
    └── README.md
```

There must be no additional parent folder between `gym_leader_shuffle/` and `manifest.json`.

## Included action-control repair

This first published build correctly receives the game’s string-based option events, so **OPEN SPOILER LOG**, **GYM TELEPORT (TEST)**, and **RETURN TO LAST POINT (TEST)** work as one-shot controls.

## Spoiler Log

Turn **OPEN SPOILER LOG** on from the mod options to display all eight saved assignments. Each of the eight explicit two-line pages shows `POSITION/8 VISITING LEADER` followed by the physical badge, such as `1/8 LT. SURGE` and `BOULDER BADGE`. This avoids scrolling and keeps every pair within the Game Boy text box width. Turn the option off and on again whenever you want to reopen it.

## Shuffle Gym Trainers

Enable **SHUFFLE GYM TRAINERS** to apply the visiting leader’s original gym-trainer roster to the non-leader NPCs in that physical gym. Each trainer slot receives a source trainer’s class, party style, and overworld sprite. Their Pokémon are evolved or de-evolved and level-scaled to the physical trainer’s original level curve and party size, so a late gym does not acquire early-game levels or vice versa.

The gym leader remains the only NPC whose battle triggers a badge or TM. Non-leader trainer rewards and trainer-defeat behavior remain ordinary. The trainer assignments are saved separately but are tied to the same leader shuffle. A new leader shuffle clears and recreates the trainer assignments.

## Other options

**RANDOMIZE MOVE SETS** can randomize leader and shuffled gym-trainer movesets. **PREFER GYM-TYPE MOVES**, **ALLOW NATIVE STAB MOVES**, and **ENSURE A DAMAGING MOVE** control that shared moveset generator.

**GYM TELEPORT (TEST)** is a one-shot testing convenience. On its first successful use it records your exact map, tile, and facing direction, then warps directly outside the next badge-eligible gym. Further Gym Teleports keep the same recorded origin. Use **RETURN TO LAST POINT (TEST)** to warp back to that original location—such as the Pewter Pokémon Center—and clear it for the next testing chain. Turn either toggle off and on again to reuse it.

## Persistence and compatibility

The leader mapping is created for a New Game or, for a save that predates the mod, on first entering a Kanto gym. Continuing the save keeps the same order. Giovanni’s Rocket Hideout and Silph Co. appearances are excluded; only his Viridian Gym party participates. The leader sprite reader supports Yellow’s distinct Koga, Sabrina, and Blaine sheets.

## Verification status

The manifest has been checked as valid JSON, `main.lua` has passed offline Lua syntax validation, and an isolated harness verifies spoiler-log rendering plus non-leader trainer class, sprite, and party projection. The mod has not been run against a player-imported game in this environment.
