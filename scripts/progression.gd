extends Node
var completed_levels: Array[int] = []
var best_stars: Dictionary = {}
var bookworm_seen := false
var save_path := "user://academic_defence_progress.cfg"
var persist_enabled := true

func _ready() -> void:
	# Script-driven tests must never modify the player's save.
	persist_enabled = not OS.get_cmdline_args().has("--script")
	if persist_enabled: load_progress()

func get_stars(level_id: int) -> int:
	return clampi(int(best_stars.get(level_id,1 if level_id in completed_levels else 0)),0,3)

func complete_level(level_id: int, stars: int = 1) -> void:
	if level_id < 1 or level_id > 4 or stars <= 0: return
	var previous := get_stars(level_id)
	if level_id not in completed_levels: completed_levels.append(level_id)
	best_stars[level_id] = maxi(previous,clampi(stars,1,3))
	save_progress()

func mark_bookworm_seen() -> void:
	bookworm_seen = true
	save_progress()

func save_progress() -> void:
	if not persist_enabled: return
	var config := ConfigFile.new()
	config.set_value("progress","completed_levels",completed_levels)
	config.set_value("progress","bookworm_seen",bookworm_seen)
	for level in completed_levels: config.set_value("stars",str(level),get_stars(level))
	var error := config.save(save_path)
	if error != OK: push_warning("Could not save level progress: %s" % error)

func load_progress() -> void:
	var config := ConfigFile.new()
	if config.load(save_path) != OK: return
	completed_levels.clear()
	best_stars.clear()
	for level in config.get_value("progress","completed_levels",[]):
		if level is int and level >= 1 and level <= 4: completed_levels.append(level)
	for level in completed_levels:
		best_stars[level] = clampi(int(config.get_value("stars",str(level),1)),1,3)
	bookworm_seen = bool(config.get_value("progress","bookworm_seen",false))
