# Changelog

## 1.0.7 — Clear Gym Challenge mutual exclusion

Gym Leader Shuffle now declares **Randomized Gym Challenge** as a reciprocal manifest conflict. The reverse conflict already existed in Randomized Gym Challenge; this update makes the launcher’s choice behavior clear regardless of which mod a player selects or updates first.

This is a necessary mutual exclusion, not a broader compatibility restriction. Gym Leader Shuffle remains usable alongside Starter Picker, Item Randomizer, Sound Effect Replacer, Gen 1 Shedinja, and compatible expanded-dex providers such as Crystal 251. It continues to preserve imported trainer-party fields when Crystal 251 is active.

No Gym assignment, trainer scaling, dialogue, reward, teleport, or Crystal 251 gameplay behavior changed.
