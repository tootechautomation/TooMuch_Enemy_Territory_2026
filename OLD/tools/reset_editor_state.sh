#!/usr/bin/env sh
set -eu

project_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
state_dir="$project_dir/.godot"
backup_dir="$project_dir/.godot_editor_state_backup"

if [ ! -d "$state_dir" ]; then
	printf '%s\n' "No local .godot editor state exists. Nothing to reset."
	exit 0
fi

if [ -e "$backup_dir" ]; then
	printf '%s\n' "Backup .godot_editor_state_backup already exists."
	printf '%s\n' "Rename or remove that backup before running this tool again."
	exit 1
fi

printf '%s\n' "Close the Godot editor before continuing."
printf '%s' "Back up and reset this project's local editor state? [y/N] "
read answer
case "$answer" in
	y|Y|yes|YES)
		mv "$state_dir" "$backup_dir"
		printf '%s\n' "Editor state backed up to .godot_editor_state_backup."
		printf '%s\n' "Reopen project.godot so Godot can rebuild clean state."
		;;
	*)
		printf '%s\n' "Cancelled."
		;;
esac
