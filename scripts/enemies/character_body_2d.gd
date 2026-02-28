extends CharacterBody2D

signal enemy_died(enemy)

@export var max_health: int = 100
var health: int

func _ready():
  health = max_health

func take_damage(amount: int):
  health -= amount
    
  if health <= 0:
      die()

func die():
  print("enemy died")
  enemy_died.emit(self)
  get_parent().queue_free()
