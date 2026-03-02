extends CharacterBody2D

signal enemy_died(enemy, killed_by_player)

@export var max_health: int = 100
@export var armor: int = 0
@export var kill_reward: int = 10

var health: float
var armor_health: float

var time_since_last_damage: float = 0.0
@export var damage_delay: float = 3.0
@export var damage_increase: float = 50.0

func _ready():
  health = max_health
  armor_health = armor
  $EnemyHealthBar.max_value = max_health
  if has_node("ArmorBar"):
    $ArmorBar.max_value = armor
    
func _physics_process(delta: float) -> void:
  time_since_last_damage += delta
  
  if (time_since_last_damage>damage_delay):
    armor_health += damage_increase
    #make sure armor health never goes over max
    armor_health = min(armor_health, armor)
  
func set_enemy_health_bar() -> void:
  $EnemyHealthBar.value = health
  if has_node("ArmorBar"):
    $ArmorBar.value = armor_health

func take_damage(amount: int):
  time_since_last_damage = 0.0
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
