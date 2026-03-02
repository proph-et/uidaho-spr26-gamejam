extends Panel
class_name UpgradePanel

var current_tower: Node = null

@export var panel_player_id: int = 0

@onready var button_upgrade_1: UpgradeButton = $Margin/VBoxContainer/Buttons/Button_Upgrade1
@onready var button_upgrade_2: UpgradeButton = $Margin/VBoxContainer/Buttons/Button_Upgrade2
@onready var button_upgrade_3: UpgradeButton = $Margin/VBoxContainer/Buttons/Button_Upgrade3
@onready var label_title: Label = $Margin/VBoxContainer/Label_Title
@onready var money_label: Label = $Margin/VBoxContainer/MoneyLabel


func _ready() -> void:
    GameManager.tower_selected.connect(on_tower_selected)
    GameManager.tower_cleared.connect(on_tower_cleared)
    GameManager.money_changed.connect(_on_money_changed)
    _refresh_money_label()
    hide_panel()


func setup(tower) -> void:
    current_tower = tower
    show()

    if tower != null and tower.has_method("get_display_name"):
        label_title.text = str(tower.get_display_name())
    else:
        label_title.text = tower.name

    button_upgrade_1.setup(tower, 1)
    button_upgrade_2.setup(tower, 2)
    button_upgrade_3.setup(tower, 3)


func hide_panel() -> void:
    hide()
    current_tower = null
    label_title.text = "No Tower"
    button_upgrade_1.clear()
    button_upgrade_2.clear()
    button_upgrade_3.clear()

func on_tower_selected(tower: Node, player_id: int) -> void:
    if panel_player_id > 0 and panel_player_id != player_id:
        return
    print("signal to open upgrade hud %d" % player_id)
    setup(tower)
    GameManager.emit_shop_to_upgrade(player_id)

func on_tower_cleared(player_id: int) -> void:
    if panel_player_id > 0 and panel_player_id != player_id:
        return
    hide_panel()
    GameManager.emit_upgrade_to_shop(player_id)

func _on_money_changed(player_id: int, _new_amount: int) -> void:
    if panel_player_id > 0 and panel_player_id != player_id:
        return
    _refresh_money_label()

func _refresh_money_label() -> void:
    if money_label == null:
        return
    if panel_player_id > 0:
        money_label.text = "$%d" % GameManager.get_money(panel_player_id)
    else:
        money_label.text = "$---"
