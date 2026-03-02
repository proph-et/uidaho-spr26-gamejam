extends CharacterBody2D

signal enemy_died(enemy, killed_by_player)
const HIT_SFX: AudioStream = preload("res://assets/audio/olivia_parker-powerful-smack-demo-310472.mp3")

@export var max_health: int = 100
@export var armor: int = 0
@export var kill_reward: int = 10

@onready var animated_sprite = $AnimatedSprite2D

var health: float
var armor_health: float

func _ready():
  health = max_health
  armor_health = armor
  $EnemyHealthBar.max_value = max_health
  if has_node("ArmorBar"):
    $ArmorBar.max_value = armor
func _process(delta: float) -> void:
  animated_sprite.play("walk")
  
func set_enemy_health_bar() -> void:
  $EnemyHealthBar.value = health
  if has_node("ArmorBar"):
    $ArmorBar.value = armor_health

func take_damage(amount: int):
  _play_hit_sfx()
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

func _play_hit_sfx() -> void:
  var hit_player := AudioStreamPlayer2D.new()
  hit_player.stream = HIT_SFX
  hit_player.volume_db = -6.0
  add_child(hit_player)
  hit_player.finished.connect(hit_player.queue_free)
  hit_player.play()
