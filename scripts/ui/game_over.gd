extends CanvasLayer

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS


func _on_main_menu_button_pressed() -> void:
    get_tree().paused = false
    get_tree().change_scene_to_file("res://scenes/levels/main_menu.tscn")
