extends Button
class_name DraftOptionButton

@export var tower_id: String = ""
@export var tower_name: String = "Tower"
@export var tower_cost: int = 100

func _ready() -> void:
    add_to_group("player_ui_interactable")

func player_interact(player_id: int, _cursor: PlayerCursor = null) -> void:
    if disabled:
        return

    var current: Node = self
    while current != null:
        if current.has_method("on_draft_option_interact"):
            current.on_draft_option_interact(player_id, tower_id)
            return
        current = current.get_parent()
