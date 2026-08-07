# Milestone 8.42 — Complete Axis visual assets

This build adds the split Survival Character texture payload and preserves the relative `Textures/Textures/...` hierarchy referenced by `survival_character.fbx`. It also adds the supplied `German_Handgrenade.fbx` as `assets/external/weapons/model24_grenade.fbx`, which is already the highest-priority Axis grenade candidate in the external asset registry. The v8.41 procedural textured stick grenade remains as a safe fallback.

Network protocol remains 341 because this milestone changes imported visuals/assets rather than replicated gameplay state.
