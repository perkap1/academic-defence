extends SceneTree

var failures := 0
var checks := 0

func check(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		print("FAIL: " + message)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	if not FileAccess.file_exists("res://scripts/game_manager.gd"):
		check(false, "GameManager is not implemented yet")
		quit(1)
		return
	var game = load("res://scripts/game_manager.gd").new()
	root.add_child(game)
	check(game.gold == 200 and game.lives == 10, "Initial economy")
	var slot = load("res://scripts/build_slot.gd").new()
	root.add_child(slot)
	check(game.try_build(slot), "First tower can be built")
	check(game.gold == 130 and slot.occupied, "Build spends exactly 70")
	check(not game.try_build(slot) and game.gold == 130, "No duplicate spending")
	var poor_slot = load("res://scripts/build_slot.gd").new()
	root.add_child(poor_slot)
	game.gold = 69
	check(not game.try_build(poor_slot) and not poor_slot.occupied, "Insufficient funds")
	var student = load("res://scenes/student.tscn").instantiate()
	root.add_child(student)
	var results := []
	student.resolved.connect(func(_s, graduated): results.append(graduated))
	student.teach(80)
	check(student.knowledge == 80 and results.is_empty(), "Partial knowledge remains active")
	student.teach(40)
	student.teach(20)
	check(student.knowledge == 100 and results == [true], "Clamped knowledge, one graduation")
	check(student.get_node("KnowledgeBar").value == 100, "Progress bar follows knowledge")
	game.resolve_student(true)
	check(game.gold == 79, "Graduation reward")
	game.resolve_student(false)
	check(game.lives == 9, "Escaped student costs one life")
	game.lives = 1
	game.resolve_student(false)
	check(game.finished and not game.won, "Zero lives ends round")
	var previous_gold = game.gold
	game.resolve_student(true)
	check(game.gold == previous_gold, "No rewards after game over")
	check(not game.try_build(poor_slot), "No building after game over")
	var target = load("res://scenes/student.tscn").instantiate()
	root.add_child(target)
	var projectile = load("res://scenes/projectile.tscn").instantiate()
	root.add_child(projectile)
	projectile.configure(target, 20)
	target.free()
	projectile._process(0.1)
	check(projectile.is_queued_for_deletion(), "Projectile safely retires with deleted target")
	print("RULES: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
