extends CanvasLayer

signal start_requested
signal restart_requested
signal build_requested(slot, tower_type: String)
signal pause_requested
signal map_requested
signal sell_requested(slot)

const Artwork = preload("res://scripts/ui_skin.gd")
const RadialMenu = preload("res://scripts/radial_menu.gd")
var gold_label: Label
var life_label: Label
var wave_label: Label
var start_button: TextureButton
var start_caption: Label
var pause_button: Button
var message_label: Label
var activity_label: Label
var result_overlay: Control
var result_title: Label
var result_body: Label
var build_menu: Control
var book_button: TextureButton
var assistant_button: TextureButton
var blackboard_button: TextureButton
var pause_overlay: Control
var tower_panel: Control
var tower_title: Label
var tower_description: Label
var sell_button: Button
var tower_slot
var level_label: Label
var selected_slot
var message_time := 0.0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var root := Control.new()
	root.name = "HUD"
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	var header := Control.new()
	header.size = Vector2(1672,190)
	root.add_child(header)
	Artwork.panel(header, Vector2.ZERO, header.size)
	Artwork.label(header,"ACADEMIC DEFENCE",Vector2(46,54),Vector2(365,42),28)
	level_label = Artwork.label(header,"Skogsstien · v0.006",Vector2(47,96),Vector2(350,28),18,Color("bfd6b9"))
	Artwork.image(header,"icon_resources",Vector2(433,62),Vector2(65,65))
	gold_label = Artwork.label(header,"",Vector2(505,78),Vector2(155,35),26)
	Artwork.image(header,"icon_reputation",Vector2(670,56),Vector2(76,76))
	life_label = Artwork.label(header,"",Vector2(752,78),Vector2(140,35),26,Color("c0edda"))
	Artwork.image(header,"icon_wave",Vector2(903,63),Vector2(65,65))
	wave_label = Artwork.label(header,"",Vector2(975,78),Vector2(105,35),26)
	start_button = Artwork.action(header,"Start\nbølge 1",Vector2(1090,35))
	start_caption = start_button.get_child(0)
	start_button.pressed.connect(func(): start_requested.emit())
	pause_button = Artwork.icon_button(header,"pause",Vector2(1350,56),Vector2(80,80))
	pause_button.tooltip_text = "Pause / fortsett"
	pause_button.pressed.connect(func(): pause_requested.emit())
	var map_button := Artwork.icon_button(header,"wave",Vector2(1450,57),Vector2(80,80))
	map_button.tooltip_text = "Til verdenskart"
	map_button.pressed.connect(func(): map_requested.emit())
	Artwork.label(header,"Kart",Vector2(1450,134),Vector2(80,20),14).horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var reset_button := Artwork.plain_button(header,"Ny",Vector2(1555,67),Vector2(60,58))
	reset_button.tooltip_text = "Start banen på nytt"
	reset_button.pressed.connect(func(): restart_requested.emit())
	var instruction := Artwork.panel(root,Vector2(24,202),Vector2(790,116),true)
	message_label = Artwork.label(instruction,"Velg tårn · Book 70 · Blackboard 100 · Assistant 120 KP",Vector2(45,34),Vector2(708,27),19)
	activity_label = Artwork.label(instruction,"Bygg først, og start bølgen når du er klar.",Vector2(45,61),Vector2(708,23),16,Color("b7d5c2"))
	create_build_menu(root)
	create_tower_panel(root)
	create_pause_overlay(root)
	create_result(root)

func set_level_title(title: String) -> void:
	level_label.text = title + " · v0.006"

func create_tower_panel(root: Control) -> void:
	tower_panel = Control.new()
	tower_panel.name = "TowerPanel"
	tower_panel.size = Vector2(600,320)
	tower_panel.visible = false
	root.add_child(tower_panel)
	Artwork.panel(tower_panel,Vector2.ZERO,tower_panel.size)
	tower_title = Artwork.label(tower_panel,"",Vector2(72,55),Vector2(450,38),27)
	tower_description = Artwork.label(tower_panel,"",Vector2(72,103),Vector2(450,74),19)
	tower_description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	sell_button = Artwork.plain_button(tower_panel,"SELL",Vector2(145,197),Vector2(310,56))
	sell_button.pressed.connect(func():
		if is_instance_valid(tower_slot): sell_requested.emit(tower_slot))

func open_tower_panel(slot) -> void:
	tower_slot = slot
	tower_panel.position = Vector2(clampf(slot.global_position.x-300,24,1048),clampf(slot.global_position.y+45,320,785))
	var board: bool = slot.tower.tower_type == "blackboard"
	tower_title.text = "Blackboard Tower" if board else "Book Tower"
	tower_description.text = "Gruppeundervisning · +15 kunnskap\n30 % slow i 2 sek. · rekkevidde 225" if board else "Ett mål · +20 kunnskap per treff\nEtt skudd per sekund · rekkevidde 260"
	sell_button.text = "SELL · +%d KP" % (50 if board else 35)
	if slot.tower.tower_type=="assistant":
		tower_title.text="Teaching Assistant Post"
		tower_description.text="2 assistenter · stopp 3 sek. · +5 kunnskap/sek\nKlikk nær veien innenfor radius for å flytte rally."
		sell_button.text="SELL · +60 KP"
	tower_panel.visible = true

func close_tower_panel() -> void:
	if tower_panel != null: tower_panel.visible = false
	tower_slot = null

func create_build_menu(root: Control) -> void:
	build_menu = RadialMenu.new()
	build_menu.name = "RadialBuildMenu"
	build_menu.visible = false
	root.add_child(build_menu)
	assistant_button = radial_button("assistant",Vector2(145,-55),Vector2(150,156))
	var assistant_cost := Artwork.label(build_menu,"120 KP",Vector2(145,104),Vector2(150,27),20)
	assistant_cost.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	assistant_button.tooltip_text="Teaching Assistant Post · 120 KP · 2 assistenter, hold 3 sek., +5 kunnskap/sek"
	assistant_button.pressed.connect(func(): choose_tower("assistant"))
	book_button = radial_button("book",Vector2(25,89),Vector2(160,172))
	blackboard_button = radial_button("blackboard",Vector2(255,89),Vector2(160,172))
	var book_cost := Artwork.label(build_menu,"70 KP",Vector2(30,264),Vector2(150,27),20)
	book_cost.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var board_cost := Artwork.label(build_menu,"100 KP",Vector2(260,264),Vector2(150,27),20)
	board_cost.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var cancel := radial_button("cancel",Vector2(175,292),Vector2(90,98))
	cancel.tooltip_text = "Avbryt"
	cancel.pressed.connect(close_build_menu)
	book_button.tooltip_text = "Book Tower · 70 KP · ett mål, +20 kunnskap"
	blackboard_button.tooltip_text = "Blackboard Tower · 100 KP · gruppe, +15 kunnskap og 30 % slow"
	book_button.pressed.connect(func(): choose_tower("book"))
	blackboard_button.pressed.connect(func(): choose_tower("blackboard"))

func radial_button(kind: String, pos: Vector2, dimensions: Vector2) -> TextureButton:
	var item := TextureButton.new()
	item.texture_normal = load("res://assets/ui/radial_%s_normal.png" % kind)
	item.texture_hover = load("res://assets/ui/radial_%s_hover.png" % kind)
	item.texture_pressed = item.texture_hover
	item.texture_disabled = load("res://assets/ui/radial_%s_disabled.png" % kind)
	item.ignore_texture_size = true
	item.stretch_mode = TextureButton.STRETCH_SCALE
	item.position = pos
	item.size = dimensions
	item.focus_mode = Control.FOCUS_NONE
	build_menu.add_child(item)
	return item

func create_pause_overlay(root: Control) -> void:
	pause_overlay = Control.new()
	pause_overlay.position = Vector2(591,430)
	pause_overlay.size = Vector2(490,310)
	pause_overlay.visible = false
	root.add_child(pause_overlay)
	Artwork.panel(pause_overlay,Vector2.ZERO,pause_overlay.size)
	var title := Artwork.label(pause_overlay,"Undervisningen er pauset",Vector2(45,65),Vector2(400,44),27)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var resume := Artwork.action(pause_overlay,"Fortsett",Vector2(124,150))
	resume.pressed.connect(func(): pause_requested.emit())

func create_result(root: Control) -> void:
	result_overlay = Control.new()
	result_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	result_overlay.visible = false
	root.add_child(result_overlay)
	var veil := ColorRect.new()
	veil.color = Color(0.025,0.07,0.06,0.76)
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	result_overlay.add_child(veil)
	var result_panel := Control.new()
	result_panel.position = Vector2(466,300)
	result_panel.size = Vector2(740,470)
	result_overlay.add_child(result_panel)
	Artwork.panel(result_panel,Vector2.ZERO,result_panel.size)
	Artwork.image(result_panel,"icon_reputation",Vector2(317,28),Vector2(106,106))
	result_title = Artwork.label(result_panel,"",Vector2(50,137),Vector2(640,59),37)
	result_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	result_body = Artwork.label(result_panel,"",Vector2(70,214),Vector2(600,110),23,Color("d3ead7"))
	result_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var replay := Artwork.action(result_panel,"Spill\nigjen",Vector2(108,345))
	replay.pressed.connect(func(): restart_requested.emit())
	var world := Artwork.action(result_panel,"Verdens-\nkart",Vector2(389,345))
	world.pressed.connect(func(): map_requested.emit())

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		if build_menu.visible:
			close_build_menu()
		elif tower_panel.visible:
			# Main owns both range and panel; pause also clears selection.
			pause_requested.emit()
		else:
			pause_requested.emit()
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and build_menu.visible:
		if not build_menu.contains_point(event.position):
			close_build_menu()

func _process(delta: float) -> void:
	if message_time > 0:
		message_time -= delta
		if message_time <= 0:
			message_label.text = "Velg tårn · Book 70 · Blackboard 100 · Assistant 120 KP"
			message_label.add_theme_color_override("font_color",Color("fff0c7"))

func open_build_menu(slot, game) -> void:
	selected_slot = slot
	build_menu.position = slot.global_position - RadialMenu.CENTER
	build_menu.visible = true
	update_build_buttons(game)

func close_build_menu() -> void:
	if build_menu != null:
		build_menu.visible = false
	selected_slot = null

func choose_tower(kind: String) -> void:
	if is_instance_valid(selected_slot):
		build_requested.emit(selected_slot,kind)

func update_build_buttons(game) -> void:
	assistant_button.disabled = game.finished or game.gold < 120
	book_button.disabled = game.finished or game.gold < 70
	blackboard_button.disabled = game.finished or game.gold < 100

func update_state(game, waves) -> void:
	gold_label.text = "KP  %d" % game.gold
	life_label.text = "%d / 10" % game.lives
	var total: int = waves.counts.size()
	wave_label.text = "%d / %d" % [waves.wave,total]
	start_button.disabled = waves.active or game.finished
	start_caption.text = "Bølge\npågår" if waves.active else "Start\nbølge %d" % mini(waves.wave+1,total)
	if game.finished:
		start_caption.text = "Runden\ner ferdig"
	elif waves.active:
		activity_label.text = "%d på vei · %d venter · %d lært opp" % [waves.students.size(),waves.remaining,game.graduated]
	else:
		activity_label.text = "Bygg tårn, og start neste bølge når du er klar."
	if build_menu.visible:
		update_build_buttons(game)

func show_message(text: String, error: bool) -> void:
	message_label.text = text
	message_label.add_theme_color_override("font_color",Color("ffba93") if error else Color("fff0c7"))
	message_time = 4

func set_paused(value: bool) -> void:
	pause_overlay.visible = value
	var picture: TextureRect = pause_button.get_child(0)
	picture.texture = load("res://assets/ui/icon_play.png" if value else "res://assets/ui/icon_pause.png")

func show_result(won: bool, game, wave: int, total: int = 7) -> void:
	set_paused(false)
	result_overlay.visible = true
	result_title.text = "Akademisk seier!" if won else "Prøv et nytt opplegg"
	result_body.text = "Bølge %d av %d · Omdømme %d\n%d studenter lært opp\n%d studenter nådde broen" % [wave,total,game.lives,game.graduated,game.escaped]

