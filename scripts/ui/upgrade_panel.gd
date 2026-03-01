extends Panel
class_name UpgradePanel

var current_tower: Node = null

@onready var button_upgrade_1 = $Panel/Button_Upgrade1
@onready var button_upgrade_2 = $Panel/Button_Upgrade2
@onready var button_upgrade_3 = $Panel/Button_Upgrade3
@onready var label_title: Label = $Panel/Label_Title
@onready var player1_ui: UpgradePanel = $Player1UI
@onready var player2_ui: UpgradePanel = $Player2UI


func _ready() -> void:
	player1_ui.hide_panel()
	player2_ui.hide_panel()


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
	if player_id == 1:
		player1_ui.setup(tower)
	else:
		player2_ui.setup(tower)
		
func on_tower_cleared(player_id: int) -> void:
	if player_id == 1:
		player1_ui.hide_panel()
	elif player_id == 2:
		player2_ui.hide_panel()
