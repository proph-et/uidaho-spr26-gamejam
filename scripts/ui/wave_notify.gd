extends CanvasLayer
@onready var label = $Label


func _ready() -> void:
  label.visible = false

func show_wave_notify(wave_number: int):
  label.text = "Wave %d Incoming" % wave_number
  
  label.visible = true  
  await get_tree().create_timer(2.0).timeout
  label.visible = false
