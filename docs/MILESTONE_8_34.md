# Milestone 8.34 — Third-Person Reload Mechanics and Editor-State Recovery

## Goal

Make remote reloads mechanically readable through the fallback weapon model while separating Godot's editor-only gutter warning from game runtime behavior.

## Delivered

- A normalized presentation timeline follows the current weapon's existing reload duration.
- Reload start resets the world animation phase cleanly.
- The Support LMG drum, SMG magazine, carbine magazine, service-rifle magazine, and scoped-rifle magazine retain their authored base transforms.
- Magazines leave the weapon, travel through the support-hand phase, and reseat before reload completion.
- The bolt handle cycles during the final reload phase.
- The support arm follows the staged magazine movement rather than an unrelated looping sine wave.
- Reload completion, interruption, weapon switching, and respawn restore neutral hardware state.
- Editor-state recovery tools back up stale `.godot` data and allow Godot to rebuild it.

## TextEdit Gutter Warning

The project source contains no `TextEdit`, `CodeEdit`, gutter index, or gutter-management calls. The warning originates from Godot's editor UI state. Extracting a new ZIP over an existing project does not remove that folder's old `.godot` directory.

Close Godot and either extract v8.34 into a new empty folder or run the appropriate reset tool in `tools`. The previous local state is retained as `.godot_editor_state_backup`.

## Compatibility

- Network protocol remains 341.
- No snapshot fields or RPC arguments were added.
- Authoritative reload duration, ammo transfer, fire timing, weapon balance, collision, and hitboxes are unchanged.
- Imported character and weapon animation controllers remain preferred.

## Verification

- Observe each class reload from a remote or spectator view.
- Confirm the correct magazine type leaves and returns to the weapon.
- Confirm the bolt handle cycles near reload completion.
- Interrupt a reload through elimination or respawn and confirm the hardware returns to its authored pose.
- Extract into a clean directory and confirm no stale editor state is included.
- If the gutter warning persists in an old working folder, close Godot, run the recovery tool, and reopen the project.
