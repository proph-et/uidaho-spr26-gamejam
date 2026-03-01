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

func set_tower_options(tower_options: Array) -> void:
    var buttons: Array = find_children("*", "PlayerUIButton", true, false)
    for i in range(buttons.size()):
        var button := buttons[i] as PlayerUIButton
        if button == null:
            continue

        if i >= tower_options.size():
            button.visible = false
            continue

        var option: Dictionary = tower_options[i]
        button.visible = true
        button.tower_name = str(option.get("name", "Tower"))
        button.tower_cost = int(option.get("cost", 100))
        button.tower_scene = option.get("scene")
        button.text = "%s ($%d)" % [button.tower_name, button.tower_cost]
        button.allowed_player_id = shop_player_id

func _on_money_changed(player_id: int, new_amount: int) -> void:
    if player_id == shop_player_id:
        money_label.text = "$%d" % new_amount
