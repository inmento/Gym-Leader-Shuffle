# Changelog

## 1.0.5 — Optional Crystal 251 Compatibility

Gym Leader Shuffle now detects **Crystal 251** only as an optional compatibility signal; it remains a fully standalone mod with no new dependencies.

When Crystal 251 is active in Red, Blue, or Yellow, gym leader and gym-trainer scaling now clones the full imported party record before adjusting only the species, level, and any explicitly randomized moves. This preserves compatible imported fields such as held items, gender, form data, and other Generation II party metadata instead of reducing a scaled team to species and level alone.

Gen 1 and Gold regression coverage, package validation, linting, and Gen 2 safety checks passed. This update does not alter badges, rewards, story progression, or the existing Gym Leader Shuffle conflict policy.
