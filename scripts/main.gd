extends Node2D

const TowerScene = preload("res://scenes/book_tower.tscn")
const BlackboardScene = preload("res://scenes/blackboard_tower.tscn")
@onready var map = $Map1
@onready var game = $GameManager
@onready var waves = $WaveManager
@onready var ui = $UI
var selected_tower_slot

func _ready() -> void:
	waves.configure(map, game, student_resolved)
	for slot in map.slots.get_children():
		slot.build_requested.connect(select_slot)
	game.changed.connect(update_ui)
	game.ended.connect(on_ended)
	waves.state_changed.connect(update_ui)
	waves.wave_completed.connect(on_wave_completed)
	ui.start_requested.connect(func(): waves.start_wave())
	ui.restart_requested.connect(restart)
	ui.build_requested.connect(build)
	ui.pause_requested.connect(toggle_pause)
	ui.map_requested.connect(return_to_map)
	ui.sell_requested.connect(sell)
	ui.set_level_title(map.level_title)
	update_ui()

func select_slot(slot) -> void:
	if game.finished or get_tree().paused:
		return
	clear_selection()
	ui.close_build_menu()
	if slot.occupied:
		selected_tower_slot = slot
		slot.tower.set_range_visible(true)
		ui.open_tower_panel(slot)
		return
	ui.open_build_menu(slot, game)

func clear_selection() -> void:
	if is_instance_valid(selected_tower_slot) and is_instance_valid(selected_tower_slot.tower):
		selected_tower_slot.tower.set_range_visible(false)
	selected_tower_slot = null
	ui.close_tower_panel()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if not ui.tower_panel.visible or not ui.tower_panel.get_global_rect().has_point(event.position):
			clear_selection()

func sell(slot) -> bool:
	if get_tree().paused or not is_instance_valid(slot) or slot.get_parent() != map.slots:
		return false
	if not game.try_sell(slot):
		return false
	clear_selection()
	ui.show_message("Tårnet er solgt · 50 % av byggeprisen tilbake.",false)
	return true

func build(slot, tower_type: String = "book") -> void:
	if get_tree().paused or slot.occupied:
		return
	if not game.try_build(slot, tower_type):
		if not game.finished:
			ui.show_message("Du har ikke nok kunnskapspoeng til dette tårnet.", true)
		return
	var tower = BlackboardScene.instantiate() if tower_type == "blackboard" else TowerScene.instantiate()
	map.towers.add_child(tower)
	tower.position = slot.position
	tower.configure(map, game)
	slot.tower = tower
	slot.refresh_visuals()
	tower.set_range_visible(false)
	ui.close_build_menu()
	ui.show_message("%s bygget. Klar for undervisning!" % ("Blackboard Tower" if tower_type == "blackboard" else "Book Tower"), false)

func student_resolved(student, graduated: bool) -> void:
	map.show_completion(student, graduated)
	game.resolve_student(graduated)
	waves.resolve_student(student)

func on_wave_completed(last_wave: bool) -> void:
	game.reward_wave()
	if last_wave:
		game.finish(true)
	else:
		ui.show_message("Bølge fullført! +45 KP. Gjør klar neste bølge.", false)

func on_ended(won: bool) -> void:
	get_tree().paused = false
	clear_selection()
	ui.close_build_menu()
	waves.stop()
	for student in waves.students:
		if is_instance_valid(student):
			student.set_process(false)
	for projectile in map.projectiles.get_children():
		projectile.set_process(false)
	ui.show_result(won, game, waves.wave, waves.counts.size())

func update_ui() -> void:
	ui.update_state(game, waves)
	for slot in map.slots.get_children():
		slot.affordable = game.gold >= game.TOWER_COST and not game.finished
		slot.queue_redraw()

func restart() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func toggle_pause() -> void:
	if game.finished:
		return
	get_tree().paused = not get_tree().paused
	clear_selection()
	ui.close_build_menu()
	ui.set_paused(get_tree().paused)

func return_to_map() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/world_map.tscn")
