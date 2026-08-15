# Gym Leader Shuffle

> **AI assisted; not AI created.**

Gym Leader Shuffle creates a persistent per-save leader shuffle for the eight Kanto gyms in Gen 1 and all sixteen Johto and Kanto gyms in Gold. A visiting leader brings their own presentation and battle identity, while the physical gym continues to own its badge, TM, rewards, progression flags, and post-battle flow.

| Example | Result |
|---|---|
| Lt. Surge visits Pewter Gym | Surge appears with a team scaled to Pewter’s intended challenge. |
| The player wins | The player receives Brock’s Boulder Badge and TM Bide through Pewter’s normal reward sequence. |

## Install

Import the `gym_leader_shuffle-1.0.0.zip` release archive through Gen 1 Recomp’s **Import mod .zip** action. The archive extracts directly to a `gym_leader_shuffle/` folder containing `manifest.json` and `main.lua`.

## Features

The leader assignment is created once per save and remains stable across map changes and reloads. The visiting leader supplies their sprite, challenge dialogue, and source team, while the destination gym supplies the battle’s level curve, badge, TM, and progression rules.

Optional trainer shuffle extends the assignment to eligible gym NPCs. Their source trainer identity, dialogue, sprite, and party style follow the shuffled gym, but their level curve and party size remain appropriate for the physical gym. Optional move and held-item settings add further variety while respecting each generation’s safe data paths.

## Gold

Gold includes all sixteen gyms, including Blaine’s Seafoam Gym and the Kanto leaders. Gold leader dialogue is mapped to the visiting leader, while physical-gym rewards remain intact. Gold gym NPC shuffle, level scaling, held items, and leader presentation are available through compact Gold-specific options.

The Gold spoiler log presents one entry per page as `POSITION/16 VISITING LEADER` followed by `BADGE PHYSICAL`. Its action resets after use. Gold Gym Warp records a return point and warps outside the next unowned physical gym; Gold Return Point returns to that recorded map location. Both actions reset after use and return the player directly to the overworld after a successful warp.

## Compatibility

Gym Leader Shuffle targets Mod API 2 and supports Gen 1 and Gold. Giovanni’s non-gym Gen 1 appearances are excluded; only his Viridian Gym party participates. See [CHANGELOG.md](CHANGELOG.md) for the complete 1.0.0 feature list.
