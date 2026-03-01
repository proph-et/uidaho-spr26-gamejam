extends Node

signal money_changed(player_id, new_amount)
signal player_registered(player_id)
signal money_transferred(from_id, to_id, amount)

const STARTING_MONEY := 650

var player_money := {}
var active_players := []
var health := 1000

func _ready():
    register_player(1)
    # Remove this line when you want P2 to join dynamically instead
    register_player(2)


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
        print("Game Over")

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


# --- Internal Helpers ---

func _is_valid_player(player_id: int) -> bool:
    if not player_money.has(player_id):
        push_warning("GameManager: Invalid player_id %d" % player_id)
        return false
    return true
