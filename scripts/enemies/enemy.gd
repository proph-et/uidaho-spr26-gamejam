extends PathFollow2D

@export var speed:float = 100.0 

func _process(delta:float) -> void:
  #forever move forward
  progress += delta * speed
  
  #if you hit the end of the map
  if progress_ratio >= 1.0:
    var enemy = get_child(0)
    
    if enemy and enemy.has_method("die"):
      print("hit end of line, dying")
      enemy.die()
