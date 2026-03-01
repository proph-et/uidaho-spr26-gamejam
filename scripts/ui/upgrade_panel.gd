extends Panel
class_name UpgradePanel

var current_tower: Node = null

@export var panel_player_id: int = 0

@onready var button_upgrade_1: UpgradeButton = $Margin/VBoxContainer/Buttons/Button_Upgrade1
@onready var button_upgrade_2: UpgradeButton = $Margin/VBoxContainer/Buttons/Button_Upgrade2
@onready var button_upgrade_3: UpgradeButton = $Margin/VBoxContainer/Buttons/Button_Upgrade3
@onready var label_title: Label = $Margin/VBoxContainer/Label_Title


func _ready() -> void:
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

func on_tower_selected(tower: Node, player_id: int) -> void:
	if panel_player_id > 0 and panel_player_id != player_id:
		return
	setup(tower)

func on_tower_cleared(player_id: int) -> void:
	if panel_player_id > 0 and panel_player_id != player_id:
		return
	hide_panel()
