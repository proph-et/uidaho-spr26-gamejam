extends Node

signal money_changed(player_id, new_amount)

var player_money := {
    1: 650,
    2: 650
}

var health = 1000
var player_tower_loadouts: Dictionary = {
    1: [],
    2: []
}
var active_player_count: int = 1
var player_active_states: Dictionary = {
    1: true,
    2: false
}

func _ready():
    # Starting money
    pass

func add_money(player_id: int, amount: int):
    player_money[player_id] += amount
    money_changed.emit(player_id, player_money[player_id])

func can_afford(player_id: int, cost: int) -> bool:
    return player_money[player_id] >= cost

func spend_money(player_id: int, cost: int) -> bool:
    if not can_afford(player_id, cost):
        return false

    player_money[player_id] -= cost
    money_changed.emit(player_id, player_money[player_id])
    return true

func get_money(player_id: int) -> int:
    return player_money[player_id]

func take_damage(amount: int):
    health -= amount
    print("Base health: ", health)
    if health <= 0:
        print("Game Over")

func set_player_tower_loadout(player_id: int, towers: Array) -> void:
    player_tower_loadouts[player_id] = towers.duplicate(true)

func get_player_tower_loadout(player_id: int) -> Array:
    return player_tower_loadouts.get(player_id, []).duplicate(true)

func clear_tower_loadouts() -> void:
    player_tower_loadouts[1] = []
    player_tower_loadouts[2] = []

func set_active_player_count(count: int) -> void:
    active_player_count = clampi(count, 1, 2)

func get_active_player_count() -> int:
    return active_player_count

func set_player_active(player_id: int, is_active: bool) -> void:
    player_active_states[player_id] = is_active
    _sync_active_player_count_from_states()

func is_player_active(player_id: int) -> bool:
    return bool(player_active_states.get(player_id, false))

func get_active_players() -> Array[int]:
    var active_players: Array[int] = []
    for id_value in player_active_states.keys():
        var player_id: int = int(id_value)
        if bool(player_active_states[player_id]):
            active_players.append(player_id)
    active_players.sort()
    return active_players

func _sync_active_player_count_from_states() -> void:
    var count: int = 0
    for id_value in player_active_states.keys():
        var player_id: int = int(id_value)
        if bool(player_active_states[player_id]):
            count += 1
    active_player_count = clampi(count, 1, 2)
