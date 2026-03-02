extends TowerParent
class_name FarmTower

#base values
@export var base_value := 10
@export var base_spawn_cooldown := 5.0

#max upgrades
const MAX_VALUE_UPGRADE := 3
const MAX_COOLDOWN_UPGRADE := 3

var value_upgrade_points := 0
var cooldown_upgrade_points := 0
var stored_value := 0
var elapsed_time := 0.0
var round_active := false

func _ready() -> void:
    can_attack = false
    attack_range = 1
    upgrade_cost1 = [200, 350, 567, 0]
    upgrade_cost2 = [300, 420, 670, 0]
    super._ready()
    add_to_group("farms")


func _process(delta: float) -> void:
    if round_active:
        elapsed_time += delta

func on_round_start() -> void:
    elapsed_time = 0
    round_active = true
    print("Farm round started")

func on_round_end() -> void:
    round_active = false
    stored_value = get_current_value()
    collect()
    elapsed_time = 0

func get_current_value() -> int:
    return int((elapsed_time / get_current_cooldown()) * (base_value + value_upgrade_points * 5))

func get_current_cooldown() -> float:
    return base_spawn_cooldown - cooldown_upgrade_points * 0.6

func collect():
    if stored_value <= 0:
        return

    var active_player_ids: Array[int] = GameManager.get_active_players()
    if active_player_ids.is_empty():
        active_player_ids = [1]

    for player_id in active_player_ids:
        GameManager.add_money(player_id, stored_value)
    stored_value = 0

func upgrade_1() -> void:
    if value_upgrade_points < MAX_VALUE_UPGRADE:
        value_upgrade_points += 1

func upgrade_2() -> void:
    if cooldown_upgrade_points < MAX_COOLDOWN_UPGRADE:
        cooldown_upgrade_points += 1

func can_upgrade_1() -> bool:
    return value_upgrade_points < MAX_VALUE_UPGRADE

func can_upgrade_2() -> bool:
    return cooldown_upgrade_points < MAX_COOLDOWN_UPGRADE

func get_upgrade_name(index: int) -> String:
  match index:
    1: return "Value"
    2: return "Cooldown"
  return ""

#get cost
func get_upgrade_1_cost() -> int:
    return upgrade_cost1[value_upgrade_points]

func get_upgrade_2_cost() -> int:
    return upgrade_cost1[cooldown_upgrade_points]
