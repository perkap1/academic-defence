extends Node

signal state_changed
signal wave_completed(last_wave: bool)
signal wave_started(wave_id: int)

const StudentScene = preload("res://scenes/student.tscn")
var counts := [4, 6, 8, 11, 14, 17, 20]
var pe_counts := [0, 0, 2, 3, 4, 5, 6]
var intervals := [1.8, 1.6, 1.4, 1.2, 1.1, 1.0, 0.9]
var wave := 0
var active := false
var remaining := 0
var students := []
var countdown := 0.0
var spawn_index := 0
var game
var map
var on_student_resolved: Callable

func configure(level, manager, resolved_callback: Callable) -> void:
	map = level
	game = manager
	on_student_resolved = resolved_callback
	if level.level_id == 2:
		counts = [6,8,10,13,15,17,19,21,23,26,28,32]
		pe_counts = [0,0,2,3,5,5,7,7,9,10,10,12]
		intervals = [1.8,1.6,1.45,1.3,1.2,1.1,1.0,0.95,0.9,0.85,0.8,0.75]

func start_wave() -> bool:
	if active or game.finished or wave >= counts.size():
		return false
	wave += 1
	remaining = counts[wave - 1]
	countdown = 0.0
	spawn_index = 0
	active = true
	wave_started.emit(wave)
	state_changed.emit()
	return true

func _process(delta: float) -> void:
	if not active or game == null or game.finished:
		return
	countdown -= delta
	while remaining > 0 and countdown <= 0:
		var student = StudentScene.instantiate()
		# Distribute PE students evenly; their visual variant is independent of the wave mix.
		var pe_total: int = pe_counts[wave - 1]
		var total: int = counts[wave - 1]
		var is_pe := int((spawn_index + 1) * pe_total / float(total)) > int(spawn_index * pe_total / float(total))
		student.configure("pe" if is_pe else "normal", "boy" if randi() % 2 == 0 else "girl")
		spawn_index += 1
		student.resolved.connect(on_student_resolved)
		map.route.add_child(student)
		students.append(student)
		remaining -= 1
		countdown += intervals[wave - 1]
		state_changed.emit()

func resolve_student(student) -> void:
	students.erase(student)
	if game.finished:
		active = false
	elif remaining == 0 and students.is_empty() and active:
		active = false
		wave_completed.emit(wave == counts.size())
	state_changed.emit()

func stop() -> void:
	active = false
	remaining = 0
	state_changed.emit()
