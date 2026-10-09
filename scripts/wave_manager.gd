extends Node

signal state_changed
signal wave_completed(last_wave: bool)
signal wave_started(wave_id: int)
signal bookworm_introduced

const SnackScene=preload("res://scenes/snack_monster.tscn")
var snack_counts:=[0,0,0,0,0,0,0]
const StudentScene = preload("res://scenes/student.tscn")
const BookwormScene = preload("res://scenes/bookworm.tscn")
var bookworm_counts := [0,0,0,1,1,2,2]
var bookworm_announced := false
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
		snack_counts=[0,0,0,0,1,1,1,1,2,2,3,3]
		counts = [6,8,10,13,15,17,19,21,23,26,28,32]
		pe_counts = [0,0,2,3,5,5,7,7,9,10,10,12]
		bookworm_counts = [0,0,0,1,2,2,3,3,4,4,5,6]
		intervals = [1.8,1.6,1.45,1.3,1.2,1.1,1.0,0.95,0.9,0.85,0.8,0.75]
	elif level.level_id == 3:
		snack_counts=[0,0,0,1,1,1,2,2,2,2,3,3,3,4,4]
		counts = [8,12,14,14,17,20,21,24,25,28,30,32,34,36,40]
		pe_counts = [0,2,4,4,4,5,6,7,8,8,10,10,12,10,12]
		bookworm_counts = [0,0,0,2,3,3,5,5,7,6,8,8,10,10,12]
		intervals = [1.8,1.65,1.55,1.5,1.45,1.4,1.35,1.3,1.25,1.2,1.15,1.1,1.05,1.0,0.95]

	elif level.level_id == 4:
		counts=[6,8,10,12,20,23,26,29,32,34,37,40,43,46,49,53,64]
		pe_counts=[0,1,2,2,4,5,6,7,8,8,9,10,11,12,13,14,18]
		bookworm_counts=[1,2,3,3,6,7,8,9,10,11,12,13,15,17,18,20,24]
		snack_counts=[0,1,1,1,2,3,3,4,4,5,5,6,6,7,7,8,10]
		# Counts below include snacks already; the common addition retains earlier maps.
		for i in range(counts.size()):counts[i]-=snack_counts[i]
		intervals=[1.8,1.65,1.6,1.55,1.45,1.4,1.35,1.3,1.25,1.2,1.15,1.1,1.05,1.0,0.95,0.9,0.8]

	for i in range(counts.size()): counts[i]+=snack_counts[i]

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
		var kind: String = get_spawn_kind(spawn_index)
		var student = SnackScene.instantiate() if kind=="snack" else (BookwormScene.instantiate() if kind == "bookworm" else StudentScene.instantiate())
		# Visual variants are independent of the evenly distributed wave mix.
		student.configure(kind, "boy" if randi() % 2 == 0 else "girl")
		var paths: Array = map.get_routes()
		var path: Path2D = paths[get_spawn_route(spawn_index)]
		spawn_index += 1
		student.resolved.connect(on_student_resolved)
		path.add_child(student)
		if kind == "bookworm" and not bookworm_announced:
			bookworm_announced = true
			bookworm_introduced.emit()
		students.append(student)
		remaining -= 1
		countdown += intervals[wave - 1]
		if map.level_id==4 and wave==17 and spawn_index in [14,35]:countdown+=3.0
		state_changed.emit()

func get_spawn_kind(index:int)->String:
	if map.level_id==4 and wave==17:
		var finale:Array=[]
		for mix in [[2,6,4,2],[3,8,6,4],[5,10,8,6]]:
			for kind in range(4):
				for i in range(mix[kind]):finale.append(["snack","bookworm","pe","normal"][kind])
		return finale[index]
	var total:int=counts[wave-1]
	var snacks:int=snack_counts[wave-1]
	if int((index+1)*snacks/float(total))>int(index*snacks/float(total)):return "snack"
	var original_index:int=index-int(index*snacks/float(total))
	var original_total:int=total-snacks
	var special:int=pe_counts[wave-1]+bookworm_counts[wave-1]
	var before:int=int(original_index*special/float(original_total))
	var after:int=int((original_index+1)*special/float(original_total))
	if after==before:return "normal"
	var books:int=bookworm_counts[wave-1]
	return "bookworm" if int(after*books/float(special))>int(before*books/float(special)) else "pe"

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

func get_spawn_route(index:int)->int:
	if map.level_id==4:
		if wave in [3,9,15]:return 0
		if wave in [6,12]:return 1
	return index%map.get_routes().size()
func get_route_notice()->String:
	if wave in [3,9,15]:return "UPPER PATH ONLY!"
	if wave in [6,12]:return "LOWER PATH ONLY!"
	return "BOTH PATHS!"
