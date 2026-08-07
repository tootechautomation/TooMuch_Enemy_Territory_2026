@echo off
setlocal
cd /d "%~dp0\.."

if not exist ".godot" (
  echo No local .godot editor state exists. Nothing to reset.
  exit /b 0
)

if exist ".godot_editor_state_backup" (
  echo Backup .godot_editor_state_backup already exists.
  echo Rename or remove that backup before running this tool again.
  exit /b 1
)

echo Close the Godot editor before continuing.
choice /M "Back up and reset this project's local editor state"
if errorlevel 2 exit /b 0

ren ".godot" ".godot_editor_state_backup"
if errorlevel 1 (
  echo Editor-state reset failed. Confirm Godot is closed and try again.
  exit /b 1
)

echo Editor state backed up to .godot_editor_state_backup.
echo Reopen project.godot. Godot will rebuild a clean .godot directory.
exit /b 0
