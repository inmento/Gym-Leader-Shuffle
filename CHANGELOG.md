# Changelog

## 1.0.6 — Release metadata and clean package maintenance

Gym Leader Shuffle now declares its tested **Gen1Recomp API 2** compatibility floor (`>=0.1.99`) in the manifest, allowing the launcher and mod indexes to make a clear compatibility decision before installation. The source banner now correctly identifies the current 1.0.6 release.

The distributed ZIP has been rebuilt as a clean player package. It retains the mod, manifest, license, and player documentation while excluding the local regression harnesses and packaging metadata. No gym assignment, trainer scaling, dialogue, reward, teleport, or Crystal 251 behavior has changed.

The 1.0.6 source and final install archive pass current Gen1Recomp 0.2.3 validation, linting, Gen 2 compatibility checks, and the saved Gen 1 and Gold regression harnesses.
