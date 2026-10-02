extends Control

const CENTER := Vector2(220,220)
const RADIUS := 195.0

func _ready() -> void:
	size = Vector2(440,440)
	mouse_filter = Control.MOUSE_FILTER_STOP

func contains_point(point: Vector2) -> bool:
	# Choice artwork can extend beyond the disc; its buttons still belong to the menu.
	for child in get_children():
		if child is TextureButton and child.get_global_rect().has_point(point):
			return true
	return (point - global_position - CENTER).length() <= RADIUS

func _draw() -> void:
	draw_circle(CENTER,RADIUS,Color(0.035,0.09,0.15,0.90))
	draw_arc(CENTER,RADIUS,0,TAU,96,Color("d0a345"),4)
	draw_arc(CENTER,67,0,TAU,48,Color("8caab6"),2)
	for offset in [Vector2(-53,0),Vector2(53,0),Vector2(0,54)]:
		draw_circle(CENTER+offset,5,Color("ffcc52"))
