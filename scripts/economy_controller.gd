extends RefCounted
# Resolve current live buildings on each event; sold nodes retain no callbacks.
var map
var game
var waves
var paid_waves := {}
var rewarded_students := {}
var current_wave := 0
func configure(level, manager, wave_manager) -> void:
	map = level
	game = manager
	waves = wave_manager
func buildings() -> Array:
	var result := []
	for tower in map.towers.get_children():
		if is_instance_valid(tower) and not tower.is_queued_for_deletion() and tower.tower_type == "economy":
			result.append(tower)
	return result
func begin_wave(wave_id: int) -> void:
	if wave_id == current_wave: return
	current_wave = wave_id
	for building in buildings(): building.wave_bonus = 0
func complete_wave(wave_id: int) -> int:
	if game.finished or wave_id <= 0 or paid_waves.has(wave_id): return 0
	paid_waves[wave_id] = true
	var total := 0
	for building in buildings():
		var income: int = building.get_income()
		total += income
		if income > 0:
			building.stats.add("kp",income)
			building.stats.add("waves")
			building.show_income(income)
	game.gold += total
	if total > 0: game.changed.emit()
	return total
func student_graduated(student) -> void:
	if game.finished or not waves.active or not is_instance_valid(student): return
	var id: int = student.get_instance_id()
	if rewarded_students.has(id): return
	rewarded_students[id] = true
	var chosen
	var distance := INF
	for building in buildings():
		if building.branch != "scholarship" or building.wave_bonus >= building.get_wave_cap(): continue
		var candidate_distance: float = building.global_position.distance_to(student.global_position)
		if candidate_distance <= building.SCHOLARSHIP_RADIUS and candidate_distance < distance:
			chosen = building
			distance = candidate_distance
	if not is_instance_valid(chosen): return
	chosen.wave_bonus += 5
	game.gold += 5
	chosen.stats.add("kp",5)
	chosen.stats.add("rewarded")
	chosen.stats.record_income_wave(current_wave)
	chosen.show_income(5)
	game.changed.emit()
