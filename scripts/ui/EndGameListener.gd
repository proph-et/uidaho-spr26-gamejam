
extends Node

func _ready() -> void:
    GameManager.game_over.connect(_on_game_over)

func _on_game_over() -> void:
    get_tree().paused = true
    get_tree().change_scene_to_file("res://scenes/ui/GameOver.tscn")
