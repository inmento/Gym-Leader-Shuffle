# Changelog

## 1.0.9 — Silver support

Gym Leader Shuffle now recognizes **Pokémon Silver** as Generation 2 and runs the same established sixteen-gym Johto/Kanto shuffle path as Gold. Silver receives the Gen 2 leader definitions, gym NPC handling, intro and defeat text projection, held-item behavior, scaling, and gym warp tools instead of incorrectly entering the Gen 1 eight-gym branch.

This is a direct root-cause correction using Gen1Recomp’s shared `GameVersion.generation()` contract rather than a separate Silver gym table. The Gen 1 harness and the full shared sixteen-gym Gold/Silver harness pass.

## 1.0.8 — Compact option labels

All Gen 1 and Gold option labels now fit the fixed 17-column mod-settings viewport. The setting names were shortened for readability only; gym assignments, trainer scaling, dialogue, teleports, conflict rules, and gameplay behavior are unchanged.

## 1.0.7 — Clear Gym Challenge mutual exclusion

Gym Leader Shuffle now declares **Randomized Gym Challenge** as a reciprocal manifest conflict. The reverse conflict already existed in Randomized Gym Challenge; this update makes the launcher’s choice behavior clear regardless of which mod a player selects or updates first.

This is a necessary mutual exclusion, not a broader compatibility restriction. Gym Leader Shuffle remains usable alongside Starter Picker, Item Randomizer, Sound Effect Replacer, Gen 1 Shedinja, and compatible expanded-dex providers such as Crystal 251. It continues to preserve imported trainer-party fields when Crystal 251 is active.

No Gym assignment, trainer scaling, dialogue, reward, teleport, or Crystal 251 gameplay behavior changed.
