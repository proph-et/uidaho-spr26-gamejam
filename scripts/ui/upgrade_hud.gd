extends CanvasLayer
class_name UpgradeHud

@onready var upgrade_panel_player_1: UpgradePanel = $UpgradePanel_player1
@onready var upgrade_panel_player_2: UpgradePanel = $UpgradePanel_player2

var in_game_hud: CanvasLayer = null

func _ready() -> void:
  in_game_hud = get_tree().current_scene.find_child("InGameHud", true, false) as CanvasLayer
  if not GameManager.shop_to_upgrade.is_connected(_on_shop_to_upgrade):
    GameManager.shop_to_upgrade.connect(_on_shop_to_upgrade)
  if not GameManager.upgrade_to_shop.is_connected(_on_upgrade_to_shop):
    GameManager.upgrade_to_shop.connect(_on_upgrade_to_shop)

  # Panels own their own show/hide logic, but start hidden for safety.
  if upgrade_panel_player_1 != null:
    upgrade_panel_player_1.hide_panel()
  if upgrade_panel_player_2 != null:
    upgrade_panel_player_2.hide_panel()

func _on_shop_to_upgrade(player_id: int) -> void:
  _sync_upgrade_panel_to_shop_slot(player_id)
  _set_shop_visible(player_id, false)

func _on_upgrade_to_shop(player_id: int) -> void:
  _set_shop_visible(player_id, true)

func _set_shop_visible(player_id: int, visible: bool) -> void:
  if in_game_hud == null:
    return
  var shop_name := "Player_1_Shop" if player_id == 1 else "Player_2_Shop"
  var shop := in_game_hud.find_child(shop_name, true, false) as CanvasItem
  if shop != null:
    shop.visible = visible

func _sync_upgrade_panel_to_shop_slot(player_id: int) -> void:
  if in_game_hud == null:
    return
  var shop_name := "Player_1_Shop" if player_id == 1 else "Player_2_Shop"
  var shop := in_game_hud.find_child(shop_name, true, false) as Control
  var panel := _get_upgrade_panel_for_player(player_id)
  if shop == null or panel == null:
    return

  panel.anchor_left = shop.anchor_left
  panel.anchor_top = shop.anchor_top
  panel.anchor_right = shop.anchor_right
  panel.anchor_bottom = shop.anchor_bottom
  panel.offset_left = shop.offset_left
  panel.offset_top = shop.offset_top
  panel.offset_right = shop.offset_right
  var panel_height := panel.custom_minimum_size.y
  panel.offset_bottom = panel.offset_top + panel_height

func _get_upgrade_panel_for_player(player_id: int) -> UpgradePanel:
  if player_id == 1:
    return upgrade_panel_player_1
  if player_id == 2:
    return upgrade_panel_player_2
  return null
