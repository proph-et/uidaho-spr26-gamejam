extends Button
class_name PlayerUIButton

@export var tower_name := "Tower"
@export var tower_cost := 100
@export var tower_scene: PackedScene
@export var allowed_player_id := 0 # 0 means any player

func _ready() -> void:
  add_to_group("player_ui_interactable")

func player_interact(player_id: int, cursor: PlayerCursor = null) -> void:
  if allowed_player_id > 0 and player_id != allowed_player_id:
    return

  if GameManager.player_money[player_id] >= tower_cost:
    GameManager.spend_money(player_id, tower_cost)
    print("purchased tower %s for %d money" % [tower_name, tower_cost])
  else:
    return
  if cursor != null:
    cursor.queue_tower_purchase(tower_scene, tower_name, tower_cost)
