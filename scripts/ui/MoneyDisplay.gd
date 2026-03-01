extends CanvasLayer

@onready var p1_panel: PanelContainer = $MoneyDisplay/P1MoneyPanel
@onready var p2_panel: PanelContainer = $MoneyDisplay/P2MoneyPanel
@onready var p1_label: Label = $MoneyDisplay/P1MoneyPanel/P1MoneyLabel
@onready var p2_label: Label = $MoneyDisplay/P2MoneyPanel/P2MoneyLabel


func _ready() -> void:
    GameManager.money_changed.connect(_on_money_changed)
    GameManager.player_registered.connect(_on_player_registered)

    # P1 always shown by default
    p1_label.text = "$%d" % GameManager.get_money(1)
    p1_panel.show()

    # P2 hidden until they join
    p2_panel.hide()


func _on_money_changed(player_id: int, new_amount: int) -> void:
    match player_id:
        1: p1_label.text = "$%d" % new_amount
        2: p2_label.text = "$%d" % new_amount


func _on_player_registered(player_id: int) -> void:
    if player_id == 2:
        p2_label.text = "$%d" % GameManager.get_money(2)
        p2_panel.show()
