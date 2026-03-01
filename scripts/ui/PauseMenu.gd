extends CanvasLayer

func _ready() -> void:
    hide()
    # This makes sure pause menu input still works while game is paused
    process_mode = Node.PROCESS_MODE_ALWAYS


func _input(_event: InputEvent) -> void:
    if Input.is_action_just_pressed("ui_cancel"):  # Escape key
        toggle_pause()


func toggle_pause() -> void:
    if visible:
        resume()
    else:
        pause()


func pause() -> void:
    show()
    get_tree().paused = true


func resume() -> void:
    hide()
    get_tree().paused = false


func _on_resume_button_pressed() -> void:
    resume()


func _on_main_menu_button_pressed() -> void:
    get_tree().paused = false
    get_tree().change_scene_to_file("res://scenes/levels/main_menu.tscn")
