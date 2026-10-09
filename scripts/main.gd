extends Node2D

const TowerScene = preload("res://scenes/book_tower.tscn")
const AssistantScene = preload("res://scenes/assistant_post.tscn")
const BlackboardScene = preload("res://scenes/blackboard_tower.tscn")
const EconomyScene = preload("res://scenes/economy_building.tscn")
var economy = preload("res://scripts/economy_controller.gd").new()
@onready var map = $Map1
@onready var game = $GameManager
@onready var waves = $WaveManager
@onready var ui = $UI
var selected_tower_slot

func _ready() -> void:
	waves.configure(map, game, student_resolved)
	economy.configure(map,game,waves)
	waves.wave_started.connect(economy.begin_wave)
	if map.level_id==4:waves.wave_started.connect(func(_id):ui.show_route_notice(waves.get_route_notice()))
	for slot in map.slots.get_children():
		slot.build_requested.connect(select_slot)
	game.changed.connect(update_ui)
	game.ended.connect(on_ended)
	waves.state_changed.connect(update_ui)
	waves.wave_completed.connect(on_wave_completed)
	waves.bookworm_introduced.connect(show_bookworm_tutorial)
	ui.start_requested.connect(func(): waves.start_wave())
	ui.restart_requested.connect(restart)
	ui.build_requested.connect(build)
	ui.pause_requested.connect(toggle_pause)
	ui.map_requested.connect(return_to_map)
	ui.sell_requested.connect(sell)
	ui.upgrade_requested.connect(upgrade)
	ui.specialize_requested.connect(specialize)
	ui.set_level_title(map.level_title)
	ui.configure_map(map.level_id)
	update_ui()

func show_bookworm_tutorial() -> void:
	var progress = get_node("/root/Progression")
	if progress.bookworm_seen: return
	progress.mark_bookworm_seen()
	ui.show_bookworm_tutorial()

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
			if is_instance_valid(selected_tower_slot) and selected_tower_slot.tower.tower_type=="assistant" and not game.finished and not get_tree().paused:
				var clicked_slot := false
				for slot in map.slots.get_children():
					if slot.global_position.distance_to(event.position)<70: clicked_slot=true
				if not clicked_slot and selected_tower_slot.tower.try_move_rally(event.position):
					ui.show_message("Rally point flyttet · assistentene samles her.",false)
					get_viewport().set_input_as_handled()
					return
			clear_selection()

func upgrade(slot) -> bool:
	if get_tree().paused or not is_instance_valid(slot) or slot != selected_tower_slot or slot.get_parent() != map.slots: return false
	if not game.try_upgrade(slot): return false
	ui.show_message("%s · Level %d" % [slot.tower.get_display_name(),slot.tower.level],false)
	return true

func specialize(slot, branch: String) -> bool:
	if get_tree().paused or not is_instance_valid(slot) or slot != selected_tower_slot or slot.get_parent() != map.slots: return false
	if not game.try_specialize(slot,branch): return false
	slot.tower.set_range_visible(true)
	ui.show_message("%s klar · passiv inntekt etter bølgen." % slot.tower.get_display_name(),false)
	return true

func sell(slot) -> bool:
	if get_tree().paused or not is_instance_valid(slot) or slot.get_parent() != map.slots:
		return false
	if not game.try_sell(slot):
		return false
	clear_selection()
	ui.show_message("Tårnet er solgt · 50 % av investeringen tilbake.",false)
	return true

func build(slot, tower_type: String = "book") -> void:
	if get_tree().paused or slot.occupied:
		return
	if not game.try_build(slot, tower_type):
		if not game.finished:
			ui.show_message("Du har ikke nok kunnskapspoeng til dette tårnet.", true)
		return
	var scene = EconomyScene if tower_type=="economy" else (AssistantScene if tower_type=="assistant" else (BlackboardScene if tower_type=="blackboard" else TowerScene))
	var tower = scene.instantiate()
	map.towers.add_child(tower)
	tower.position = slot.position
	tower.configure(map, game)
	slot.tower = tower
	slot.refresh_visuals()
	tower.set_range_visible(false)
	ui.close_build_menu()
	ui.show_message("Study Hall bygget · +15 KP etter hver bølge." if tower_type=="economy" else "%s bygget. Klar for undervisning!" % ("Teaching Assistant Post" if tower_type=="assistant" else ("Science Tower" if tower_type == "blackboard" else "Book Tower")), false)

func student_resolved(student, graduated: bool) -> void:
	if graduated: economy.student_graduated(student)
	map.show_completion(student, graduated)
	game.resolve_student(graduated)
	waves.resolve_student(student)

func on_wave_completed(last_wave: bool) -> void:
	var passive_income: int = economy.complete_wave(waves.wave)
	game.reward_wave()
	if last_wave:
		game.finish(true)
	else:
		ui.show_message("Bølge fullført! +%d KP. Gjør klar neste bølge." % (45+passive_income), false)

func on_ended(won: bool) -> void:
	if won: get_node("/root/Progression").complete_level(map.level_id)
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
