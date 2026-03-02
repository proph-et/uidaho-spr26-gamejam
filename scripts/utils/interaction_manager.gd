extends Node
class_name InteractionManager

func request_interact(player_id: int, ui_target: Control, tower_target: Node, cursor: PlayerCursor = null) -> void:
    if ui_target != null:
        if ui_target.has_method("player_interact"):
            ui_target.player_interact(player_id, cursor)
            return
        var ui_button := ui_target as BaseButton
        if ui_button != null:
            if ui_button.toggle_mode:
                ui_button.button_pressed = not ui_button.button_pressed
                ui_button.toggled.emit(ui_button.button_pressed)
            ui_button.pressed.emit()
            return

    if get_tree().paused:
        return

    if cursor != null and cursor.has_pending_tower():
        cursor.place_pending_tower()
        return

    if tower_target and tower_target.has_method("interact"):
        tower_target.interact(player_id)
