extends Node2D

const Artwork = preload("res://scripts/ui_skin.gd")
const LEVEL_POSITIONS := [Vector2(223,655),Vector2(490,568),Vector2(829,459),Vector2(1163,364),Vector2(1447,274)]
var level_buttons := []

func _ready() -> void:
	get_tree().paused = false
	var canvas := CanvasLayer.new()
	add_child(canvas)
	var root := Control.new()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	canvas.add_child(root)
	var header := Artwork.panel(root,Vector2.ZERO,Vector2(1672,190))
	Artwork.label(header,"ACADEMIC DEFENCE",Vector2(47,54),Vector2(760,49),34)
	Artwork.label(header,"Verdenskart · velg en bane",Vector2(49,101),Vector2(900,32),23,Color("c4debf"))
	Artwork.image(header,"icon_reputation",Vector2(1420,54),Vector2(87,87))
	Artwork.label(header,"v0.005",Vector2(1520,78),Vector2(108,30),22)
	var note := Artwork.panel(root,Vector2(24,202),Vector2(778,116),true)
	Artwork.label(note,"Velg bane 1 eller 2 · klikk på en grønn spilleknapp",Vector2(46,34),Vector2(690,28),20)
	Artwork.label(note,"Skogsstien: 7 bølger · Elvesvingene: 12 bølger",Vector2(46,62),Vector2(690,23),17,Color("bbd8bf"))
	for i in range(5):
		var pos: Vector2 = LEVEL_POSITIONS[i] + Vector2(0,190)
		var choice := Button.new()
		choice.name = "Level%d" % (i+1)
		choice.position = pos-Vector2(47,47)
		choice.size = Vector2(94,94)
		choice.focus_mode = Control.FOCUS_NONE
		choice.disabled = i > 1
		choice.tooltip_text = ["Bane 1 · Skogsstien","Bane 2 · Elvesvingene"][i] if i < 2 else "Bane %d er låst" % (i+1)
		for state in ["normal","hover","pressed","disabled","focus"]:
			choice.add_theme_stylebox_override(state,StyleBoxEmpty.new())
		root.add_child(choice)
		level_buttons.append(choice)
		if i < 2:
			var picture := Artwork.image(choice,"icon_play",Vector2(5,5),Vector2(84,84))
			choice.mouse_entered.connect(func(): picture.modulate = Color(1.2,1.2,1.1))
			choice.mouse_exited.connect(func(): picture.modulate = Color.WHITE)
			choice.pressed.connect(choose_level.bind(i))
			var plate := Artwork.panel(root,pos+Vector2(-154,64),Vector2(308,112),true)
			var title := Artwork.label(plate,["1 · Skogsstien","2 · Elvesvingene"][i],Vector2(43,38),Vector2(227,34),23)
			title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		else:
			var title := Artwork.label(root,"%d · LÅST" % (i+1),pos+Vector2(-79,54),Vector2(158,30),20,Color("e0dac6"))
			title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	queue_redraw()

func _draw() -> void:
	for i in range(5):
		var pos: Vector2 = LEVEL_POSITIONS[i] + Vector2(0,190)
		if i < 2:
			draw_arc(pos,55,0,TAU,64,Color("bfff8d"),4)
		else:
			draw_circle(pos,43,Color(0.04,0.10,0.12,0.92))
			draw_arc(pos,43,0,TAU,48,Color("64706b"),3)
			draw_arc(pos+Vector2(0,-2),13,PI,TAU,20,Color("b7af8d"),6)
			draw_rect(Rect2(pos+Vector2(-17,-3),Vector2(34,27)),Color("b7af8d"))
			draw_circle(pos+Vector2(0,7),4,Color("253936"))
			draw_rect(Rect2(pos+Vector2(-2,7),Vector2(4,9)),Color("253936"))

func choose_level(index: int) -> bool:
	if index < 0 or index > 1:
		return false
	get_tree().change_scene_to_file("res://scenes/main.tscn" if index == 0 else "res://scenes/main_map2.tscn")
	return true

