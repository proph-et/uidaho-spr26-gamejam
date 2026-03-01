extends CanvasLayer

@onready var player_1_shop: ShopPanel = %Player_1_Shop
@onready var player_2_shop: ShopPanel = %Player_2_Shop
@onready var p2_join_prompt: Label = %P2JoinPrompt

var cursor_spawner: CursorSpawner = null
var player2_joined: bool = false
var coop_enabled: bool = true

func _ready() -> void:
    _apply_player_loadouts()
    coop_enabled = GameManager.is_player_active(2) or GameManager.get_active_player_count() >= 2
    if p2_join_prompt != null:
        p2_join_prompt.queue_free()
    _bind_cursor_spawner()
    player2_joined = _is_player_joined(2)
    if player_2_shop != null:
        player_2_shop.visible = coop_enabled
    _refresh_p2_join_prompt()

func _process(_delta: float) -> void:
    _refresh_p2_join_prompt()

func _apply_player_loadouts() -> void:
    if player_1_shop != null:
        var p1_loadout: Array = GameManager.get_player_tower_loadout(1)
        if not p1_loadout.is_empty():
            player_1_shop.set_tower_options(p1_loadout)

    if player_2_shop != null:
        var p2_loadout: Array = GameManager.get_player_tower_loadout(2)
        if not p2_loadout.is_empty():
            player_2_shop.set_tower_options(p2_loadout)

func _refresh_p2_join_prompt() -> void:
    if p2_join_prompt == null:
        return
    p2_join_prompt.visible = false

func _is_player_joined(player_id: int) -> bool:
    for node in get_tree().get_nodes_in_group("player_cursor"):
        var cursor: PlayerCursor = node as PlayerCursor
        if cursor != null and cursor.player_id == player_id:
            return true
    return false

func _bind_cursor_spawner() -> void:
    var current_scene := get_tree().current_scene
    if current_scene == null:
        return
    cursor_spawner = current_scene.find_child("CursorSpawner", true, false) as CursorSpawner
    if cursor_spawner == null:
        return
    cursor_spawner.player_joined.connect(_on_player_joined)
    cursor_spawner.player_left.connect(_on_player_left)

func _on_player_joined(player_id: int) -> void:
    if player_id == 2:
        coop_enabled = true
        player2_joined = true
        if player_2_shop != null:
            player_2_shop.visible = true
        _refresh_p2_join_prompt()

func _on_player_left(player_id: int) -> void:
    if player_id == 2:
        player2_joined = false
        coop_enabled = GameManager.is_player_active(2)
        if player_2_shop != null:
            player_2_shop.visible = coop_enabled
