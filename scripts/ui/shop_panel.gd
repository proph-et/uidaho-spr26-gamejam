extends Panel
class_name ShopPanel

@export var shop_player_id := 0

@onready var money_label: Label = $VBoxContainer/MoneyLabel

func _ready() -> void:
    _apply_player_ownership_to_buttons()
    GameManager.money_changed.connect(_on_money_changed)

    if shop_player_id > 0:
        money_label.text = "$%d" % GameManager.get_money(shop_player_id)
    else:
        money_label.text = "$---"


func _apply_player_ownership_to_buttons() -> void:
    for child in find_children("*", "PlayerUIButton", true, false):
        child.allowed_player_id = shop_player_id


func _on_money_changed(player_id: int, new_amount: int) -> void:
    if player_id == shop_player_id:
        money_label.text = "$%d" % new_amount
