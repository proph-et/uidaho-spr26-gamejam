extends Control

@onready var music_player: AudioStreamPlayer2D = $MusicPlayer

func _on_start_pressed() -> void:
  fade_out_music()
  
func fade_out_music() -> void:
  var tween = create_tween()
  tween.tween_property(music_player, "volume_db", -80.0, 1.0)
  tween.tween_callback(music_player.stop)
  await tween.finished
  get_tree().change_scene_to_file("res://scenes/levels/tower_draft_menu.tscn")
   
  

func _on_options_pressed() -> void:
  pass # Replace with function body.
  

func _on_quit_pressed() -> void:
  get_tree().quit()
