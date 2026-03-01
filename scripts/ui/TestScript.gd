extends Node

func _input(_event: InputEvent) -> void:
    if Input.is_action_just_pressed("ui_accept"):
        GameManager.award_kill_money(100)
