extends Panel
class_name UpgradePanel

var current_tower: Node = null

@export var panel_player_id: int = 0

@onready var button_upgrade_1: UpgradeButton = $Margin/VBoxContainer/Buttons/Button_Upgrade1
@onready var button_upgrade_2: UpgradeButton = $Margin/VBoxContainer/Buttons/Button_Upgrade2
@onready var button_upgrade_3: UpgradeButton = $Margin/VBoxContainer/Buttons/Button_Upgrade3
@onready var label_title: Label = $Margin/VBoxContainer/Label_Title


func _ready() -> void:
    GameManager.tower_selected.connect(on_tower_selected)
    GameManager.tower_cleared.connect(on_tower_cleared)
    button_upgrade_1.allowed_player_id = panel_player_id
    button_upgrade_2.allowed_player_id = panel_player_id
    button_upgrade_3.allowed_player_id = panel_player_id
    hide_panel()


func setup(tower) -> void:
    current_tower = tower
    show()

    label_title.text = tower.name

    button_upgrade_1.setup(tower, 1)
    button_upgrade_2.setup(tower, 2)
    button_upgrade_3.setup(tower, 3)


func hide_panel() -> void:
    hide()
    current_tower = null
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
