extends PathFollow2D

@export var speed: float = 100.0

func _process(delta: float) -> void:
  progress += delta * speed
  if progress_ratio >= 1.0:
    var enemy = get_child(0)
    
    if enemy and enemy.has_method("die"):
      
      GameManager.take_damage(enemy.health)

      print("hit end of line, dying")
      enemy.die()
