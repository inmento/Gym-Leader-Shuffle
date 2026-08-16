# Changelog

## 1.0.2 — Testing Action Quality-of-Life

**Gym Teleport**, **Return to Last Point**, and **Open Spoiler Log** now clear their own toggle state immediately after use in the Gen 1 branch. Gym Teleport therefore returns to Off after every attempt, making each next click a fresh teleport request instead of requiring a manual Off/On cycle.

This patch changes only the test-action controls. Leader assignments, scaling, dialogue, rewards, trainer shuffle, and Gold behavior remain unchanged.

## 1.0.1 — Gen 2 Detection Stability

Gym Leader Shuffle now determines the active game through the engine’s `GameVersion.get()` API before registering generation-specific behavior. This replaces data-shape inference, so the Kanto and Gold branches consistently select the correct option schema, map handling, battle hooks, and testing tools when Red, Blue, Yellow, or Gold is loaded.

No shuffle, scaling, dialogue, reward, NPC, teleport, or spoiler-log rules were changed in this update.

## 1.0.0 — Full Release

Gym Leader Shuffle 1.0.0 expands the original Kanto leader shuffle into a complete Gen 1 and Gold gym-randomization experience. Every shuffle is saved per playthrough, allowing a run to remain internally consistent across saves, resets, and revisits.

### Gym Leader Shuffle

| Feature | What it does |
|---|---|
| Persistent leader shuffle | Creates and stores a per-save leader assignment instead of reshuffling on every map load. |
| Physical-gym rewards | The gym’s original badge, TM, progression flags, defeat text, and reward flow remain attached to the physical gym. |
| Visiting-leader presentation | The visiting leader supplies the encounter identity, sprite, challenge dialogue, and battle source team. |
| Physical-gym scaling | Visiting teams are adapted to the destination gym’s intended level curve, with evolution and de-evolution handling where appropriate. |
| Optional moves | The optional move setting rebuilds eligible visiting teams from level-up moves. |
| Optional held items | Eligible existing held items can be safely randomized without giving items to Pokémon that were originally itemless. |

### Gen 1 Features

The original Kanto shuffle remains fully supported. The release includes the eight Kanto leaders, the established physical-gym reward rules, leader sprite and dialogue handling, optional gym-trainer shuffle, spoiler log, Gym Teleport, and Return to Last Point test tools.

### Gold Features

Gold support includes all sixteen Johto and Kanto gyms. Visiting leaders are keyed to their Gold map scripts, while the physical gym retains its own badge and progression. Gold gym NPCs can be shuffled independently, including their trainer identity, trainer dialogue, sprite, and physical-gym level curve.

| Gold option | Effect |
|---|---|
| **GOLD SHUFFLE** | Enables the saved sixteen-gym leader shuffle. |
| **GOLD GYM NPCS** | Shuffles eligible gym trainers alongside the leader assignment. |
| **GOLD RANDOM MOVES** | Rebuilds visiting teams with eligible level-up moves. |
| **GOLD HELD ITEMS** | Randomizes eligible existing held items only. |
| **GOLD SPOILER LOG** | Opens a sixteen-page visiting-leader and physical-badge reference. |
| **GOLD GYM WARP** | Warps outside the next unowned physical gym and records a return point. |
| **GOLD RETURN POINT** | Returns to the location recorded by Gold Gym Warp. |

Gold spoiler and teleport controls are one-shot actions. They reset to **Off** after use. A successful Gold warp closes the mod manager and pause menu, returning directly to the overworld.

### Compatibility and quality

This release targets Mod API 2 and supports both Gen 1 and Gold. Option labels are sized for the mobile menu, and the release archive contains only mod source, metadata, documentation, and license material.
