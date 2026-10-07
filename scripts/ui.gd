extends CanvasLayer

signal start_requested
signal restart_requested
signal build_requested(slot, tower_type: String)
signal pause_requested
signal map_requested
signal sell_requested(slot)
signal upgrade_requested(slot)
signal specialize_requested(slot, branch: String)

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
var study_button: TextureButton
var specialization_panel: Control
var specialization_buttons := []
var pause_overlay: Control
var tower_panel: Control
var tower_title: Label
var tower_description: Label
var sell_button: Button
var upgrade_button: Button
var upgrade_caption: Label
var tower_banner: Control
var banner_title: Label
var banner_description: Label
var banner_extra: Label
var banner_sprite: TextureRect
var banner_sell: Button
var invested_label: Label
var tower_slot
var level_label: Label
var selected_slot
var message_time := 0.0
var instruction_panel: Control
var bookworm_tutorial: Control

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
	level_label = Artwork.label(header,"Skogsstien · v" + ProjectSettings.get_setting("application/config/version"),Vector2(47,96),Vector2(350,28),18,Color("bfd6b9"))
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
	instruction_panel = Artwork.panel(root,Vector2(24,202),Vector2(790,116),true)
	var instruction := instruction_panel
	message_label = Artwork.label(instruction,"Book 70 · Science 100 · Assistant 120 · Study Hall 100 KP",Vector2(45,34),Vector2(708,27),19)
	activity_label = Artwork.label(instruction,"Bygg først, og start bølgen når du er klar.",Vector2(45,61),Vector2(708,23),16,Color("b7d5c2"))
	create_build_menu(root)
	create_tower_panel(root)
	create_pause_overlay(root)
	create_result(root)
	bookworm_tutorial = Artwork.panel(root,Vector2(866,322),Vector2(770,136),true)
	bookworm_tutorial.name = "BookwormIntroduction"
	Artwork.label(bookworm_tutorial,"THE BOOKWORM",Vector2(42,25),Vector2(686,30),23)
	var explanation := Artwork.label(bookworm_tutorial,"Books act as shields. Each hit removes one book before Knowledge can affect him.",Vector2(42,57),Vector2(686,60),19)
	explanation.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	bookworm_tutorial.hide()

func configure_map(level_id: int) -> void:
	if level_id == 3: instruction_panel.position = Vector2(860,202)

func show_bookworm_tutorial() -> void:
	bookworm_tutorial.show()
	get_tree().create_timer(6.0).timeout.connect(func():
		if is_instance_valid(bookworm_tutorial): bookworm_tutorial.hide())

func set_level_title(title: String) -> void:
	level_label.text = title + " · v" + ProjectSettings.get_setting("application/config/version")

func create_tower_panel(root: Control) -> void:
	tower_banner = Control.new()
	tower_banner.name = "TowerInformationBanner"
	tower_banner.position = Vector2(24,947)
	tower_banner.size = Vector2(1624,168)
	tower_banner.visible = false
	root.add_child(tower_banner)
	Artwork.panel(tower_banner,Vector2.ZERO,tower_banner.size,true)
	banner_sprite = TextureRect.new()
	banner_sprite.position = Vector2(35,5)
	banner_sprite.size = Vector2(120,153)
	banner_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	banner_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	banner_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	banner_sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tower_banner.add_child(banner_sprite)
	banner_title = Artwork.label(tower_banner,"",Vector2(175,18),Vector2(880,32),26)
	banner_description = Artwork.label(tower_banner,"",Vector2(175,61),Vector2(500,68),20)
	banner_extra = Artwork.label(tower_banner,"",Vector2(690,55),Vector2(405,84),20,Color("c0edca"))
	banner_extra.add_theme_constant_override("line_spacing",-6)
	banner_sell = Artwork.plain_button(tower_banner,"SELL",Vector2(1110,52),Vector2(210,52))
	banner_sell.pressed.connect(request_sell)
	invested_label = Artwork.label(tower_banner,"",Vector2(1110,104),Vector2(250,26),18)
	upgrade_button = preload("res://scripts/upgrade_button.gd").new()
	upgrade_button.position = Vector2(1400,25)
	upgrade_button.size = Vector2(100,83)
	upgrade_button.focus_mode = Control.FOCUS_NONE
	tower_banner.add_child(upgrade_button)
	upgrade_button.pressed.connect(func():
		if is_instance_valid(tower_slot): upgrade_requested.emit(tower_slot))
	upgrade_caption = Artwork.label(tower_banner,"",Vector2(1345,104),Vector2(235,26),20)
	upgrade_caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	specialization_panel = Control.new()
	specialization_panel.position = Vector2(625,55)
	specialization_panel.size = Vector2(460,90)
	tower_banner.add_child(specialization_panel)
	var choices := ["library","scholarship","research"]
	var names := ["Library","Scholarship\nOffice","Research\nInstitute"]
	for i in range(3):
		var choice: String = choices[i]
		var button := Artwork.plain_button(specialization_panel,names[i]+"\n120 KP",Vector2(i*155,0),Vector2(148,84))
		button.add_theme_font_size_override("font_size",17)
		button.tooltip_text = ["+45 KP etter hver bølge","+10 KP/bølge · +5 per fullført student innen radius, maks +50","+15 KP første bølge, deretter +10 til maks +65"][i]
		button.pressed.connect(func():
			if is_instance_valid(tower_slot): specialize_requested.emit(tower_slot,choice))
		specialization_buttons.append(button)
	specialization_panel.visible = false
	tower_panel = tower_banner
	tower_title = banner_title
	tower_description = banner_description
	sell_button = banner_sell

func request_sell() -> void:
	if is_instance_valid(tower_slot): sell_requested.emit(tower_slot)

func open_tower_panel(slot) -> void:
	close_tower_panel()
	tower_slot = slot
	tower_panel = tower_banner
	tower_title = banner_title
	tower_description = banner_description
	sell_button = banner_sell
	refresh_tower_banner(slot.tower.game)
	tower_panel.visible = true

func refresh_tower_banner(game) -> void:
	if not is_instance_valid(tower_slot) or not is_instance_valid(tower_slot.tower): return
	var tower = tower_slot.tower
	specialization_panel.visible = false
	upgrade_button.visible = true
	banner_extra.visible = true
	banner_description.size.x = 500
	if tower.tower_type == "economy":
		banner_title.text = tower.get_display_name()
		banner_sprite.texture = tower.frames[0]
		banner_sell.text = "SELL · +%d KP" % tower.get_sell_refund()
		invested_label.text = "Invested: %d KP" % tower.total_invested
		upgrade_button.visible = false
		upgrade_caption.text = "Velg én retning" if tower.branch == "study" else "Spesialisert"
		upgrade_caption.modulate = Color("c0edca")
		banner_description.text = "Passive income: +%d KP / wave\nIngen angrep" % tower.get_income()
		banner_extra.text = ""
		match tower.branch:
			"study":
				banner_description.size.x = 440
				banner_extra.visible = false
				specialization_panel.visible = true
				for button in specialization_buttons: button.disabled = game.finished or game.gold < 120
			"scholarship":
				banner_description.text = "Base income: +10 KP / wave\nBonus: +5 per student i radius"
				banner_extra.text = "Wave bonus: %d / 50 KP\nRadius: %d" % [tower.wave_bonus,tower.SCHOLARSHIP_RADIUS]
			"research":
				banner_description.text = "Current income: +%d KP / wave\nNext income: +%d KP" % [tower.get_income(),tower.get_next_income()]
				banner_extra.text = "Max income: +65 KP / wave\nØker etter fullført bølge"
		return
	if tower.tower_type == "assistant":
		banner_title.text = "Teaching Assistant Post"
		banner_sprite.texture = tower.get_node("Sprite").texture
		banner_description.text = "2 assistenter · Hold: 3 sec\nKnowledge: 5/sec · 15 totalt"
		banner_extra.text = "Range: %d · Rally: %d\nKlikk nær veien: flytt rally" % [tower.teaching_range,tower.work_radius]
		banner_sell.text = "SELL · +60 KP"
		invested_label.text = "Invested: 120 KP"
		upgrade_button.disabled = true
		upgrade_caption.text = "Ingen upgrades"
		upgrade_caption.modulate = Color("aaa59c")
		upgrade_button.tooltip_text = "Dette tårnet har ingen oppgraderinger ennå."
		upgrade_button.queue_redraw()
		return
	banner_title.text = tower.get_display_name()
	banner_sprite.texture = tower.frames[0]
	banner_description.text = "Level %d · Knowledge per attack: %d\nAttack speed: %.2f/s (%.2f sec)" % [tower.level,tower.knowledge_per_hit,1.0/tower.fire_interval,tower.fire_interval]
	if tower.tower_type == "blackboard":
		banner_extra.text = "Range: %d\nSlow: %d %% · %.1f sec\nAoE radius: %d" % [tower.teaching_range,roundi(tower.slow_strength*100),tower.slow_duration,tower.area_radius]
	else:
		banner_extra.text = "Range: %d\n" % tower.teaching_range + ("Single target" if tower.level < 3 else "Every 5th book: Golden\n2× Knowledge · 60 per hit")
	banner_sell.text = "SELL · +%d KP" % tower.get_sell_refund()
	invested_label.text = "Invested: %d KP" % tower.total_invested
	var cost: int = tower.get_upgrade_cost()
	upgrade_button.disabled = cost == 0 or game.gold < cost or game.finished
	upgrade_caption.text = "MAX LEVEL" if cost == 0 else "Upgrade – %d KP" % cost
	upgrade_caption.modulate = Color("aaa59c") if upgrade_button.disabled else Color("bbf59d")
	upgrade_button.tooltip_text = "MAX LEVEL" if cost == 0 else "Upgrade – %d KP%s" % [cost," · ikke nok KP" if game.gold < cost else ""]
	upgrade_button.queue_redraw()

func close_tower_panel() -> void:
	if tower_banner != null: tower_banner.visible = false
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
	var comic_frames:Array=preload("res://scripts/tower_presentation.gd").comic_book_frames()
	book_button.texture_normal=comic_frames[0]
	book_button.texture_hover=comic_frames[2]
	book_button.texture_pressed=comic_frames[2]
	book_button.texture_disabled=comic_frames[0]
	book_button.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	var book_name=Artwork.label(book_button,"Book Tower",Vector2(0,146),Vector2(160,25),18)
	book_name.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	blackboard_button = radial_button("blackboard",Vector2(255,89),Vector2(160,172))
	var science_frames:Array=preload("res://scripts/tower_presentation.gd").science_teacher_frames()
	blackboard_button.texture_normal=science_frames[0]
	blackboard_button.texture_hover=science_frames[1]
	blackboard_button.texture_pressed=science_frames[1]
	blackboard_button.texture_disabled=science_frames[0]
	blackboard_button.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
	var science_name=Artwork.label(blackboard_button,"Science Tower",Vector2(0,146),Vector2(160,25),18)
	science_name.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	var book_cost := Artwork.label(build_menu,"70 KP",Vector2(30,264),Vector2(150,27),20)
	book_cost.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var board_cost := Artwork.label(build_menu,"100 KP",Vector2(260,264),Vector2(150,27),20)
	board_cost.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	study_button = TextureButton.new()
	var study_frames: Array = preload("res://scripts/economy_artwork.gd").frames("study")
	study_button.texture_normal = study_frames[0]
	study_button.texture_hover = study_frames[4]
	study_button.texture_pressed = study_frames[4]
	study_button.texture_disabled = study_frames[0]
	study_button.ignore_texture_size = true
	study_button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	study_button.position = Vector2(145,282)
	study_button.size = Vector2(150,134)
	study_button.focus_mode = Control.FOCUS_NONE
	study_button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	study_button.tooltip_text = "Study Hall · 100 KP · +15 KP etter hver bølge"
	build_menu.add_child(study_button)
	study_button.pressed.connect(func(): choose_tower("economy"))
	var study_name := Artwork.label(build_menu,"Study Hall · 100 KP",Vector2(120,413),Vector2(200,27),17)
	study_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var cancel := radial_button("cancel",Vector2(188,182),Vector2(64,70))
	cancel.tooltip_text = "Avbryt"
	cancel.pressed.connect(close_build_menu)
	book_button.tooltip_text = "Book Tower · 70 KP · ett mål, +20 kunnskap"
	blackboard_button.tooltip_text = "Science Tower · 100 KP · gruppe, +15 kunnskap og 30 % slow"
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
			message_label.text = "Book 70 · Science 100 · Assistant 120 · Study Hall 100 KP"
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
	book_button.modulate=Color(0.45,0.45,0.45) if book_button.disabled else Color.WHITE
	blackboard_button.disabled = game.finished or game.gold < 100
	blackboard_button.modulate=Color(0.45,0.45,0.45) if blackboard_button.disabled else Color.WHITE
	study_button.disabled = game.finished or game.gold < 100
	study_button.self_modulate = Color("777777") if study_button.disabled else Color.WHITE

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
	if tower_banner.visible:
		refresh_tower_banner(game)
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




