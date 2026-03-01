extends TowerParent
class_name FarmTower

#base values
@export var base_value := 10
@export var base_spawn_cooldown := 10.0

#max upgrades
const MAX_VALUE_UPGRADE := 3
const MAX_COOLDOWN_UPGRADE := 3

var value_upgrade_points := 0
var cooldown_upgrade_points := 0
var stored_value := 0
var timer: Timer

func _ready() -> void:
    can_attack = false
    super._ready()
    add_to_group("farms")
    _setup_spawn_timer()

func _setup_spawn_timer() -> void:
    timer = Timer.new()
    timer.wait_time = get_current_cooldown()
    timer.one_shot = false
    timer.timeout.connect(_on_timer_timeout)
    add_child(timer)

# how do the tower get the information that the round has started with get_tree in the round/wave manager
func on_round_start():
    timer.wait_time = get_current_cooldown()
    timer.start()

func on_round_end():
    timer.stop()
    collect()

func _on_timer_timeout():
    stored_value += get_current_value()

func get_current_value() -> int:
    return base_value + value_upgrade_points * 5

func get_current_cooldown() -> float:
    return base_spawn_cooldown - cooldown_upgrade_points * 1.8

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

func get_upgrade_1_name() -> String:
    return "Value"

func get_upgrade_2_name() -> String:
    return "Cooldown"

func get_upgrade_3_name() -> String:
    return ""
