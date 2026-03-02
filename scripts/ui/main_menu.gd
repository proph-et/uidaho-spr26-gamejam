extends Control

func _on_start_pressed() -> void:
  GameManager.set_selected_map_scene_path("res://scenes/levels/map1_rework.tscn")
  get_tree().change_scene_to_file("res://scenes/levels/tower_draft_menu.tscn")

func _on_start_map_2_pressed() -> void:
  GameManager.set_selected_map_scene_path("res://scenes/levels/map2_sandland.tscn")
  get_tree().change_scene_to_file("res://scenes/levels/tower_draft_menu.tscn")

func _on_quit_pressed() -> void:
  get_tree().quit()
