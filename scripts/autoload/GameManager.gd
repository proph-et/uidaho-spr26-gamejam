extends Node

signal money_changed(player_id, new_amount)
signal player_registered(player_id)
signal money_transferred(from_id, to_id, amount)
signal game_over
signal base_health_changed(current_health, max_health)

#signal for the upgrades of towers
signal tower_selected(tower: TowerParent, player_id: int)
signal tower_cleared(player_id: int)
signal shop_to_upgrade(player_id: int)
signal upgrade_to_shop(player_id: int)

const STARTING_MONEY := 650
const MAX_BASE_HEALTH := 1000
const BGM_STREAM: AudioStream = preload("res://assets/audio/BattleLoop2.ogg")
const DEFAULT_MAP_SCENE_PATH := "res://scenes/levels/map1_rework.tscn"

var player_tower_loadouts: Dictionary = {
    1: [],
    2: []
}
var active_player_count: int = 1
var player_active_states: Dictionary = {
    1: true,
    2: false
}
var player_money := {}
var active_players := []
var health := MAX_BASE_HEALTH
var bgm_player: AudioStreamPlayer = null
var selected_map_scene_path: String = DEFAULT_MAP_SCENE_PATH

func _ready():
    _ensure_bgm()
    register_player(1)
    # Remove this line when you want P2 to join dynamically instead
    register_player(2)
    base_health_changed.emit(health, MAX_BASE_HEALTH)

func _ensure_bgm() -> void:
    if bgm_player != null and is_instance_valid(bgm_player):
        if not bgm_player.playing:
            bgm_player.play()
        return

    bgm_player = AudioStreamPlayer.new()
    bgm_player.name = "BGMPlayer"
    bgm_player.stream = BGM_STREAM
    bgm_player.bus = "Master"
    bgm_player.autoplay = false
    bgm_player.process_mode = Node.PROCESS_MODE_ALWAYS
    add_child(bgm_player)
    bgm_player.play()


# --- Player Registration ---

func register_player(player_id: int):
    if player_money.has(player_id):
        return
    player_money[player_id] = STARTING_MONEY
    active_players.append(player_id)
    money_changed.emit(player_id, player_money[player_id])
    player_registered.emit(player_id)


func unregister_player(player_id: int):
    if not _is_valid_player(player_id):
        return
    player_money.erase(player_id)
    active_players.erase(player_id)


# --- Core Money Functions ---

func add_money(player_id: int, amount: int):
    if not _is_valid_player(player_id):
        return
    player_money[player_id] += amount
    money_changed.emit(player_id, player_money[player_id])

func can_afford(player_id: int, cost: int) -> bool:
    if not _is_valid_player(player_id):
        return false
    return player_money[player_id] >= cost

func spend_money(player_id: int, cost: int) -> bool:
    if not _is_valid_player(player_id):
        return false
    if not can_afford(player_id, cost):
        return false
    player_money[player_id] -= cost
    money_changed.emit(player_id, player_money[player_id])
    return true

func get_money(player_id: int) -> int:
    if not _is_valid_player(player_id):
        return 0
    return player_money[player_id]

func take_damage(amount: int):
    health -= amount
    print("Base health: ", health)
    if health <= 0:
        health = 0 
    base_health_changed.emit(health, MAX_BASE_HEALTH)
    if health <= 0:
        game_over.emit()
  
func set_player_tower_loadout(player_id: int, towers: Array) -> void:
    player_tower_loadouts[player_id] = towers.duplicate(true)

func get_player_tower_loadout(player_id: int) -> Array:
    return player_tower_loadouts.get(player_id, []).duplicate(true)

func clear_tower_loadouts() -> void:
    player_tower_loadouts[1] = []
    player_tower_loadouts[2] = []

func set_selected_map_scene_path(scene_path: String) -> void:
    if scene_path.is_empty():
        selected_map_scene_path = DEFAULT_MAP_SCENE_PATH
        return
    selected_map_scene_path = scene_path

func get_selected_map_scene_path() -> String:
    if selected_map_scene_path.is_empty():
        return DEFAULT_MAP_SCENE_PATH
    return selected_map_scene_path

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
    var players_active_now: Array[int] = []
    for id_value in player_active_states.keys():
        var player_id: int = int(id_value)
        if bool(player_active_states[player_id]):
            players_active_now.append(player_id)
    players_active_now.sort()
    return players_active_now

func _sync_active_player_count_from_states() -> void:
    var count: int = 0
    for id_value in player_active_states.keys():
        var player_id: int = int(id_value)
        if bool(player_active_states[player_id]):
            count += 1
    active_player_count = clampi(count, 1, 2)
# --- Kill Reward ---

func award_kill_money(base_reward: int):
    var count := active_players.size()
    if count == 0:
        return

    var share : int = base_reward / count
    var remainder := base_reward % count

    for player_id in active_players:
        add_money(player_id, share)

    if remainder > 0:
        add_money(active_players[0], remainder)


# --- Transfer ---

func transfer_money(from_id: int, to_id: int, amount: int) -> bool:
    if not _is_valid_player(from_id) or not _is_valid_player(to_id):
        return false
    if not can_afford(from_id, amount):
        return false
    player_money[from_id] -= amount
    player_money[to_id] += amount
    money_changed.emit(from_id, player_money[from_id])
    money_changed.emit(to_id, player_money[to_id])
    money_transferred.emit(from_id, to_id, amount)
    return true


# --- Reset ---

func reset():
    for player_id in active_players:
        player_money[player_id] = STARTING_MONEY
        money_changed.emit(player_id, player_money[player_id])
    health = MAX_BASE_HEALTH
    base_health_changed.emit(health, MAX_BASE_HEALTH)


# --- Internal Helpers ---

func _is_valid_player(player_id: int) -> bool:
    if not player_money.has(player_id):
        push_warning("GameManager: Invalid player_id %d" % player_id)
        return false
    return true

func end_wave():
    for tower in get_tree().get_nodes_in_group("farms"):
        tower.on_round_end()

func start_wave():
    for tower in get_tree().get_nodes_in_group("farms"):
        tower.on_round_start()

# --- Tower/UI Signal Helpers ---

func emit_tower_selected(tower: TowerParent, player_id: int) -> void:
    tower_selected.emit(tower, player_id)

func emit_tower_cleared(player_id: int) -> void:
    tower_cleared.emit(player_id)

func emit_shop_to_upgrade(player_id: int) -> void:
    shop_to_upgrade.emit(player_id)

func emit_upgrade_to_shop(player_id: int) -> void:
    upgrade_to_shop.emit(player_id)
