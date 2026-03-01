extends Control

const PICKS_PER_PLAYER: int = 3
const SOLO_PICKS_FOR_P1: int = 6
const PROJECTILE_TOWER_SCENE: PackedScene = preload("res://scenes/towers/tower_projectile.tscn")
const AOE_TOWER_SCENE: PackedScene = preload("res://scenes/towers/tower_aoe.tscn")
const CLOSE_RANGE_TOWER_SCENE: PackedScene = preload("res://scenes/towers/tower_close_range.tscn")
const FURTHEST_TOWER_SCENE: PackedScene = preload("res://scenes/towers/tower_furthest.tscn")
const BUFF_TOWER_SCENE: PackedScene = preload("res://scenes/towers/tower_buff.tscn")
const FARM_TOWER_SCENE: PackedScene = preload("res://scenes/towers/tower_farm.tscn")

const TOWER_OPTIONS: Array = [
    {"id": "tower_projectile", "name": "Projectile Tower", "cost": 100, "scene": PROJECTILE_TOWER_SCENE},
    {"id": "tower_aoe", "name": "AOE Tower", "cost": 120, "scene": AOE_TOWER_SCENE},
    {"id": "tower_close_range", "name": "Close Range Tower", "cost": 140, "scene": CLOSE_RANGE_TOWER_SCENE},
    {"id": "tower_furthest", "name": "Furthest Tower", "cost": 160, "scene": FURTHEST_TOWER_SCENE},
    {"id": "tower_buff", "name": "Buff Tower", "cost": 180, "scene": BUFF_TOWER_SCENE},
    {"id": "tower_farm", "name": "Farm Tower", "cost": 200, "scene": FARM_TOWER_SCENE}
]

const P1_COLOR: Color = Color(0.3, 1.0, 0.5, 1.0)
const P2_COLOR: Color = Color(0.3, 0.7, 1.0, 1.0)
const UNCLAIMED_COLOR: Color = Color(1.0, 1.0, 1.0, 1.0)

@onready var p1_status: Label = %P1Status
@onready var p2_title: Label = $P2Info/P2Title
@onready var p2_status: Label = %P2Status
@onready var join_prompt: Label = %JoinPrompt
@onready var options_container: GridContainer = %SharedOptions
@onready var start_match_button: Button = %StartMatchButton
@onready var cursor_spawner: CursorSpawner = %CursorSpawner
@onready var p2_info: VBoxContainer = $P2Info

var selected_ids_by_player: Dictionary = {
    1: [],
    2: []
}
var selected_owner_by_tower_id: Dictionary = {} # tower_id -> player_id
var option_buttons_by_tower_id: Dictionary = {} # tower_id -> DraftOptionButton
var player2_joined: bool = false

func _ready() -> void:
    GameManager.clear_tower_loadouts()
    GameManager.set_player_active(1, true)
    _build_shared_option_buttons()
    _connect_spawner_signals()
    player2_joined = GameManager.is_player_active(2) or _is_player_joined(2)
    GameManager.set_active_player_count(2 if player2_joined else 1)
    _refresh_join_prompt()
    _refresh_status_and_buttons()

func _process(_delta: float) -> void:
    if not player2_joined and _is_player_joined(2):
        _handle_player2_joined_transition()
    elif player2_joined and not _is_player_joined(2):
        _handle_player2_left_transition()
    _refresh_join_prompt()

func _connect_spawner_signals() -> void:
    if cursor_spawner == null:
        return
    cursor_spawner.player_joined.connect(_on_player_joined)
    cursor_spawner.player_left.connect(_on_player_left)

func _build_shared_option_buttons() -> void:
    option_buttons_by_tower_id.clear()
    for option_value in TOWER_OPTIONS:
        var option: Dictionary = option_value
        var button: DraftOptionButton = DraftOptionButton.new()
        button.tower_id = str(option["id"])
        button.tower_name = str(option["name"])
        button.tower_cost = int(option["cost"])
        button.custom_minimum_size = Vector2(220, 72)
        button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
        button.size_flags_vertical = Control.SIZE_EXPAND_FILL
        button.clip_text = true
        button.focus_mode = Control.FOCUS_NONE
        options_container.add_child(button)
        option_buttons_by_tower_id[button.tower_id] = button

func on_draft_option_interact(player_id: int, tower_id: String) -> void:
    if player_id < 1 or player_id > 2:
        return
    if player_id == 2 and not player2_joined:
        return

    var owner: int = int(selected_owner_by_tower_id.get(tower_id, 0))
    var selected_ids: Array = selected_ids_by_player.get(player_id, [])

    if owner == player_id:
        selected_owner_by_tower_id.erase(tower_id)
        selected_ids.erase(tower_id)
        selected_ids_by_player[player_id] = selected_ids
        _refresh_status_and_buttons()
        return

    if owner != 0:
        return
    if selected_ids.size() >= _max_picks_for_player(player_id):
        return

    selected_owner_by_tower_id[tower_id] = player_id
    selected_ids.append(tower_id)
    selected_ids_by_player[player_id] = selected_ids
    _refresh_status_and_buttons()

func _refresh_status_and_buttons() -> void:
    var p1_selected: Array = selected_ids_by_player.get(1, [])
    var p2_selected: Array = selected_ids_by_player.get(2, [])

    p1_status.text = "Player 1 Picks: %d/%d" % [p1_selected.size(), _max_picks_for_player(1)]
    p2_status.text = "Player 2 Picks: %d/%d" % [p2_selected.size(), _max_picks_for_player(2)]
    start_match_button.disabled = not _both_players_ready()

    for tower_id_value in option_buttons_by_tower_id.keys():
        var tower_id: String = str(tower_id_value)
        var button: DraftOptionButton = option_buttons_by_tower_id[tower_id]
        if button == null:
            continue

        var owner: int = int(selected_owner_by_tower_id.get(tower_id, 0))
        button.disabled = false
        button.button_pressed = owner != 0
        if owner == 1:
            button.modulate = P1_COLOR
            button.text = "%s ($%d) [P1]" % [button.tower_name, button.tower_cost]
        elif owner == 2:
            button.modulate = P2_COLOR
            button.text = "%s ($%d) [P2]" % [button.tower_name, button.tower_cost]
        else:
            button.modulate = UNCLAIMED_COLOR
            button.text = "%s ($%d)" % [button.tower_name, button.tower_cost]

func _both_players_ready() -> bool:
    var p1_ready: bool = selected_ids_by_player.get(1, []).size() == _max_picks_for_player(1)
    var p2_required: bool = player2_joined
    var p2_ready: bool = selected_ids_by_player.get(2, []).size() == _max_picks_for_player(2)
    return p1_ready and (not p2_required or p2_ready)

func _on_start_match_button_pressed() -> void:
    if not _both_players_ready():
        return
    GameManager.set_active_player_count(2 if player2_joined else 1)
    GameManager.set_player_tower_loadout(1, _build_player_loadout(1))
    GameManager.set_player_tower_loadout(2, _build_player_loadout(2))
    get_tree().change_scene_to_file("res://scenes/levels/map1_rework.tscn")

func _build_player_loadout(player_id: int) -> Array:
    var selected_ids: Array = selected_ids_by_player.get(player_id, [])
    var option_by_id: Dictionary = {}
    for option_value in TOWER_OPTIONS:
        var option: Dictionary = option_value
        option_by_id[option["id"]] = option

    var loadout: Array = []
    for tower_id_value in selected_ids:
        var tower_id: String = str(tower_id_value)
        var option: Dictionary = option_by_id.get(tower_id, {})
        if option.is_empty():
            continue
        loadout.append({
            "id": option["id"],
            "name": option["name"],
            "cost": option["cost"],
            "scene": option["scene"]
        })
    return loadout

func _on_back_button_pressed() -> void:
    get_tree().change_scene_to_file("res://scenes/levels/main_menu.tscn")

func _on_player_joined(_player_id: int) -> void:
    if _player_id == 2:
        _handle_player2_joined_transition()
    _refresh_join_prompt()

func _on_player_left(player_id: int) -> void:
    if player_id == 2:
        _handle_player2_left_transition()
    else:
        _clear_player_selections(player_id)
    _refresh_join_prompt()
    _refresh_status_and_buttons()

func _clear_player_selections(player_id: int) -> void:
    var selected_ids: Array = selected_ids_by_player.get(player_id, [])
    for tower_id_value in selected_ids:
        var tower_id: String = str(tower_id_value)
        if int(selected_owner_by_tower_id.get(tower_id, 0)) == player_id:
            selected_owner_by_tower_id.erase(tower_id)
    selected_ids_by_player[player_id] = []

func _refresh_join_prompt() -> void:
    if join_prompt == null:
        return
    if p2_info != null:
        p2_info.visible = true

    if player2_joined or _is_player_joined(2):
        if p2_title != null:
            p2_title.visible = true
        if p2_status != null:
            p2_status.visible = true
        join_prompt.visible = false
    else:
        if p2_title != null:
            p2_title.visible = false
        if p2_status != null:
            p2_status.visible = false
        join_prompt.visible = true
        join_prompt.text = "Player 2 Hold Interact to Join"

func _is_player_joined(player_id: int) -> bool:
    for node in get_tree().get_nodes_in_group("player_cursor"):
        var cursor: PlayerCursor = node as PlayerCursor
        if cursor != null and cursor.player_id == player_id:
            return true
    return false

func _max_picks_for_player(player_id: int) -> int:
    if player_id == 1:
        return PICKS_PER_PLAYER if player2_joined else SOLO_PICKS_FOR_P1
    if player_id == 2:
        return PICKS_PER_PLAYER if player2_joined else 0
    return PICKS_PER_PLAYER

func _reset_draft_selections() -> void:
    selected_ids_by_player[1] = []
    selected_ids_by_player[2] = []
    selected_owner_by_tower_id.clear()

func _handle_player2_joined_transition() -> void:
    if player2_joined:
        return
    player2_joined = true
    _reset_draft_selections()
    _refresh_status_and_buttons()

func _handle_player2_left_transition() -> void:
    if not player2_joined:
        return
    player2_joined = false
    _clear_player_selections(2)
    _refresh_status_and_buttons()
