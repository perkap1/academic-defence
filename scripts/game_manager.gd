extends Node

signal changed
signal ended(won: bool)

const TOWER_COST := 70
const TOWER_COSTS := {"book": 70, "blackboard": 100, "assistant": 120, "economy": 100}
var gold := 200
var lives := 10
var starting_reputation := 10
const TWO_STAR_RATIO := 0.70

func _ready() -> void:
	starting_reputation = lives

func get_star_rating() -> int:
	if not won or starting_reputation <= 0: return 0
	if lives >= starting_reputation: return 3
	return 2 if float(lives)/starting_reputation >= TWO_STAR_RATIO else 1
var graduated := 0
var escaped := 0
var finished := false
var won := false

func try_build(slot, tower_type: String = "book") -> bool:
	if not TOWER_COSTS.has(tower_type):
		return false
	var cost: int = TOWER_COSTS[tower_type]
	if finished or slot.occupied or slot.is_blocked() or gold < cost:
		return false
	gold -= cost
	slot.occupied = true
	changed.emit()
	return true

func try_clear_site(slot) -> bool:
	if finished or get_tree().paused or not is_instance_valid(slot) or slot.occupied or not slot.is_blocked(): return false
	var cost: int = slot.get_clear_cost()
	if cost <= 0 or gold < cost: return false
	# Mutation before notification prevents repeated clicks from charging twice.
	gold -= cost
	slot.set_blocker("")
	changed.emit()
	return true

func try_upgrade(slot) -> bool:
	if finished or get_tree().paused or not is_instance_valid(slot) or not slot.occupied or not is_instance_valid(slot.tower): return false
	var tower = slot.tower
	if tower.game != self or tower.is_queued_for_deletion() or tower.tower_type not in ["book","blackboard","economy"]: return false
	var cost: int = tower.get_upgrade_cost()
	if cost <= 0 or gold < cost: return false
	if not tower.upgrade_level(): return false
	gold -= cost
	changed.emit()
	return true

func try_specialize(slot, branch: String) -> bool:
	if finished or get_tree().paused or not is_instance_valid(slot) or not slot.occupied or not is_instance_valid(slot.tower): return false
	var building = slot.tower
	if building.game != self or building.is_queued_for_deletion() or building.tower_type != "economy": return false
	var cost: int = building.get_specialization_cost(branch)
	if cost <= 0 or gold < cost or not building.specialize(branch): return false
	gold -= cost
	changed.emit()
	return true

func try_sell(slot) -> bool:
	if finished or not is_instance_valid(slot) or not slot.occupied or not is_instance_valid(slot.tower):
		return false
	var tower = slot.tower
	if tower.game != self or not TOWER_COSTS.has(tower.tower_type) or tower.is_queued_for_deletion():
		return false
	var refund: int = int(TOWER_COSTS[tower.tower_type] / 2)
	if tower.tower_type in ["book","blackboard","economy"]:
		refund = tower.get_sell_refund()
	# Clear ownership before emitting changed; repeated input cannot refund twice.
	slot.tower = null
	slot.occupied = false
	tower.set_process(false)
	tower.set_range_visible(false)
	tower.get_parent().remove_child(tower)
	tower.queue_free()
	slot.refresh_visuals()
	gold += refund
	changed.emit()
	return true

func resolve_student(was_graduated: bool) -> void:
	if finished:
		return
	if was_graduated:
		gold += 10
		graduated += 1
	else:
		lives = maxi(0, lives - 1)
		escaped += 1
	changed.emit()
	if lives == 0:
		finish(false)

func reward_wave() -> void:
	if not finished:
		gold += 45
		changed.emit()

func finish(victory: bool) -> void:
	if finished:
		return
	finished = true
	won = victory
	ended.emit(won)
	changed.emit()
