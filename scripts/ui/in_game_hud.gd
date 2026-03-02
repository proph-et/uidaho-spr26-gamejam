extends CanvasLayer

@onready var player_1_shop: ShopPanel = %Player_1_Shop
@onready var player_2_shop: ShopPanel = %Player_2_Shop
@onready var p2_join_prompt: Label = get_node_or_null("%P2JoinPrompt") as Label

var cursor_spawner: CursorSpawner = null
var player2_joined: bool = false
var coop_enabled: bool = true
const TRANSFER_AMOUNT := 25

func _ready() -> void:
    _apply_player_loadouts()
    coop_enabled = GameManager.is_player_active(2) or GameManager.get_active_player_count() >= 2
    if p2_join_prompt != null:
        p2_join_prompt.queue_free()
    _bind_cursor_spawner()
    player2_joined = _is_player_joined(2)
    if player_2_shop != null:
        player_2_shop.visible = coop_enabled
    _layout_shop_panels()
    _refresh_p2_join_prompt()
    
    print("HUD ready, transfer amount: ", TRANSFER_AMOUNT)

func _process(_delta: float) -> void:
    _refresh_p2_join_prompt()
    
func _input(event: InputEvent) -> void:
    print("input received")
    if event.is_action_pressed("player_1_send_money"):
        GameManager.transfer_money(1, 2, TRANSFER_AMOUNT)
    
    if event.is_action_pressed("player_2_send_money"):
        GameManager.transfer_money(2, 1, TRANSFER_AMOUNT)

func _apply_player_loadouts() -> void:
    if player_1_shop != null:
        var p1_loadout: Array = GameManager.get_player_tower_loadout(1)
        if not p1_loadout.is_empty():
            player_1_shop.set_tower_options(p1_loadout)

    if player_2_shop != null:
        var p2_loadout: Array = GameManager.get_player_tower_loadout(2)
        if not p2_loadout.is_empty():
            player_2_shop.set_tower_options(p2_loadout)
    _layout_shop_panels()

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
        _layout_shop_panels()
        _refresh_p2_join_prompt()

func _on_player_left(player_id: int) -> void:
    if player_id == 2:
        player2_joined = false
        coop_enabled = GameManager.is_player_active(2)
        if player_2_shop != null:
            player_2_shop.visible = coop_enabled
        _layout_shop_panels()

func _layout_shop_panels() -> void:
    if player_1_shop != null:
        _layout_single_shop(player_1_shop, true)
    if player_2_shop != null:
        _layout_single_shop(player_2_shop, false)

func _layout_single_shop(shop: ShopPanel, is_left_side: bool) -> void:
    var panel_width: float = shop.custom_minimum_size.x
    var panel_height: float = shop.get_preferred_height()
    var margin_x := 12.0
    var half_height := panel_height * 0.5

    shop.anchor_top = 0.5
    shop.anchor_bottom = 0.5
    shop.offset_top = -half_height
    shop.offset_bottom = half_height

    if is_left_side:
        shop.anchor_left = 0.0
        shop.anchor_right = 0.0
        shop.offset_left = margin_x
        shop.offset_right = margin_x + panel_width
    else:
        shop.anchor_left = 1.0
        shop.anchor_right = 1.0
        shop.offset_left = -margin_x - panel_width
        shop.offset_right = -margin_x
