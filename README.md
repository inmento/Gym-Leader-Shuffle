# Gym Leader Shuffle

Gym Leader Shuffle creates a persistent per-save derangement of the eight Kanto Gym Leaders in Gen 1, or all sixteen Johto and Kanto leaders in Gold. The visiting leader supplies the overworld sprite and scaled battle team. The physical gym continues to own every badge, TM, reward line, and progression flag. **Gold support was built from the current Gold data/API path but has not yet been tested in a player game.**

| Example | Result |
|---|---|
| Lt. Surge occupies Pewter Gym | Surge appears and gives Surge’s pre-battle challenge and a team scaled to Pewter. |
| Winning that battle | The player receives Brock’s Boulder Badge and TM Bide, with Brock’s reward wording. |

## Install

Import `gym_leader_shuffle-0.0.3.zip` through Gen 1 Recomp’s **Import mod .zip** action. Alternatively, extract its files so the layout is exactly:

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

Turn **OPEN SPOILER LOG** on from the mod options to display every saved assignment. It uses eight pages in Gen 1 and sixteen pages in Gold. Each two-line page shows `POSITION/TOTAL VISITING LEADER` followed by the physical badge, such as `1/8 LT. SURGE` and `BOULDER BADGE`. Turn the option off and on again whenever you want to reopen it.

## Shuffle Gym Trainers

Enable **SHUFFLE GYM TRAINERS** to apply the visiting leader’s original gym-trainer roster to the non-leader NPCs in that physical gym. Each trainer slot receives a source trainer’s class, party style, and overworld sprite. Their Pokémon are evolved or de-evolved and level-scaled to the physical trainer’s original level curve and party size, so a late gym does not acquire early-game levels or vice versa.

The gym leader remains the only NPC whose battle triggers a badge or TM. Non-leader trainer rewards and trainer-defeat behavior remain ordinary. The trainer assignments are saved separately but are tied to the same leader shuffle. A new leader shuffle clears and recreates the trainer assignments.

## Gold support — untested

In Gold, the shuffle uses the correct sixteen gym locations and leader sprites, including **Blaine at Seafoam Gym**. Gold leader battles are redirected from their native leader scripts while the physical script keeps its native rewards, badge flags, and text. **SHUFFLE GYM TRAINERS** also supports Gold map-trainer NPCs, preserving their party fields and scaling their visiting roster to the destination’s levels.

**RANDOMIZE GYM HELD ITEMS (GOLD)** changes only an existing Gold gym Pokémon held item, selecting from legal tossable items with a real held effect. It never creates an item on a Pokémon that did not already hold one, and it excludes key items.

## Other options

**RANDOMIZE MOVE SETS** can randomize leader and shuffled gym-trainer movesets. **PREFER GYM-TYPE MOVES**, **ALLOW NATIVE STAB MOVES**, and **ENSURE A DAMAGING MOVE** control that shared moveset generator.

**GYM TELEPORT (TEST)** is a one-shot testing convenience. On its first successful use it records your exact map, tile, and facing direction, then warps directly outside the next badge-eligible gym. Further Gym Teleports keep the same recorded origin. Use **RETURN TO LAST POINT (TEST)** to warp back to that original location—such as the Pewter Pokémon Center—and clear it for the next testing chain. Turn either toggle off and on again to reuse it.

## Persistence and compatibility

The leader mapping is created for a New Game or, for a save that predates the mod, on first entering an eligible gym. Continuing the save keeps the same order. In Gen 1, Giovanni’s Rocket Hideout and Silph Co. appearances are excluded; only his Viridian Gym party participates. The leader sprite reader supports Yellow’s distinct Koga, Sabrina, and Blaine sheets.

## Verification status

The manifest has been checked as valid JSON and `main.lua` has passed offline Lua syntax validation. Isolated harnesses cover Gen 1 behavior and the Gold leader-script, sprite, scaled-party, trainer, and held-item paths. **Gold remains untested in a player-imported game**, so please back up a save before testing it.
