extends CharacterBody2D

signal enemy_died(enemy)

@export var max_health: int = 100
@export var armor: int = 0

@export var armor_heal_rate: float = 300
@export var armor_heal_delay: float = 3.0
@export var time_since_last_damage: float = 0.0

var health: float
var armor_health: float

func _ready():
  health = max_health
  armor_health = armor
  $EnemyHealthBar.max_value = max_health
  if has_node("ArmorBar"):
    $ArmorBar.max_value = armor
    
func _physics_process(delta: float) -> void:
  time_since_last_damage += delta
  if armor_health < armor && time_since_last_damage > armor_heal_delay:
    armor_health += armor_heal_rate
    armor_health = min(armor_health, armor)
  
func set_enemy_health_bar() -> void:
  $EnemyHealthBar.value = health
  if has_node("ArmorBar"):
    $ArmorBar.value = armor_health

func take_damage(amount: int):
  time_since_last_damage = 0.0
  
  if armor_health > 0:
    armor_health -= amount
    if armor_health < 0:
      health + armor_health
  else:
    health -= amount
    
  set_enemy_health_bar()
    
  if health <= 0:
      die()

func die():
  print("enemy died")
  enemy_died.emit(self)
  get_parent().queue_free()
