extends Panel
class_name ShopPanel

@export var shop_player_id := 0 # 0 means any player

func _ready() -> void:
    _apply_player_ownership_to_buttons()

func _apply_player_ownership_to_buttons() -> void:
    for child in find_children("*", "PlayerUIButton", true, false):
        child.allowed_player_id = shop_player_id
