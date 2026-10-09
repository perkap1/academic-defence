extends Node
var completed_levels: Array[int] = []
var bookworm_seen := false
var save_path := "user://academic_defence_progress.cfg"
var persist_enabled := true

func _ready() -> void:
	# Script-driven tests must never modify the player's save.
	persist_enabled = not OS.get_cmdline_args().has("--script")
	if persist_enabled: load_progress()

func complete_level(level_id: int) -> void:
	if level_id not in completed_levels:
		completed_levels.append(level_id)
		save_progress()

func mark_bookworm_seen() -> void:
	bookworm_seen = true
	save_progress()

func save_progress() -> void:
	if not persist_enabled: return
	var config := ConfigFile.new()
	config.set_value("progress","completed_levels",completed_levels)
	config.set_value("progress","bookworm_seen",bookworm_seen)
	var error := config.save(save_path)
	if error != OK: push_warning("Could not save level progress: %s" % error)

func load_progress() -> void:
	var config := ConfigFile.new()
	if config.load(save_path) != OK: return
	completed_levels.clear()
	for level in config.get_value("progress","completed_levels",[]):
		if level is int and level >= 1 and level <= 4: completed_levels.append(level)
	bookworm_seen = bool(config.get_value("progress","bookworm_seen",false))
