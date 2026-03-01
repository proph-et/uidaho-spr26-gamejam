extends CharacterBody2D

signal enemy_died(enemy, killed_by_player)

@export var max_health: int = 100
@export var armor: int = 0
@export var kill_reward: int = 10

var health: int

func _ready():
  health = max_health + armor

func take_damage(amount: int):
  health -= amount
    
  if health <= 0:
      die(true)

func die(killed_by_player: bool = false):
  print("enemy died")
  enemy_died.emit(self, killed_by_player)
  get_parent().queue_free()
