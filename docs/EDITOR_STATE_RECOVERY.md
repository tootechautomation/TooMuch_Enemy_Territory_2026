# Godot Editor-State Recovery

## TextEdit gutter warning

Repeated messages such as the following originate in Godot's script-editor `TextEdit` implementation:

`scene/gui/text_edit.cpp - Index p_gutter = -1 is out of bounds`

Frontline: Objective does not create `TextEdit` or `CodeEdit` nodes and does not call any gutter API. The replacement archives also exclude the local `.godot` directory. If a new archive is extracted over an older working folder, however, the previous editor's `.godot` state remains on that computer and can retain an invalid script-editor gutter selection.

## Recovery

1. Close every Godot editor window using this project.
2. Prefer extracting the complete replacement ZIP into a new empty folder.
3. For an existing folder, run `tools/RESET_EDITOR_STATE_WINDOWS.bat` on Windows or `tools/reset_editor_state.sh` on Linux/macOS.
4. Reopen `project.godot`. Godot will import the project and rebuild `.godot`.

The recovery tools preserve the old state as `.godot_editor_state_backup`; they do not delete project source or imported assets. After confirming the clean editor works, that backup is no longer required.

This warning is editor UI state and is not produced by multiplayer, HUD, game-world, weapon, or character code.
