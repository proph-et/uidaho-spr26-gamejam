extends CharacterBody2D

signal enemy_died(enemy, killed_by_player)

@export var max_health: int = 100
@export var armor: int = 0
@export var kill_reward: int = 10

var health: float
var armor_health: float

func _ready():
  health = max_health
  armor_health = armor
  $EnemyHealthBar.max_value = max_health
  if has_node("ArmorBar"):
    $ArmorBar.max_value = armor
  
func set_enemy_health_bar() -> void:
  $EnemyHealthBar.value = health
  if has_node("ArmorBar"):
    $ArmorBar.value = armor_health

func take_damage(amount: int):
  if armor_health > 0:
    armor_health -= amount
  else:
    health -= amount
    
  set_enemy_health_bar()
    
  if health <= 0:
      die(true)

func die(killed_by_player: bool = false):
  print("enemy died")
  enemy_died.emit(self, killed_by_player)
  get_parent().queue_free()
