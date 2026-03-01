extends Node2D

@export var enemy_prefab: PackedScene
@export var armored_enemy_prefab: PackedScene

@export var time_between_spawns: float = 2.0
@export var time_between_waves: float = 10.0

@onready var path = get_parent().get_node("Path2D")

var current_wave: int = 0
var enemies_alive: int = 0
var enemies_to_spawn: int = 0
var spawn_bonus: int = 5
var enemy_health_bonus: float = 2.5
var enemy_speed_bonus: float = 0

func _ready():
    start_wave()

func start_wave():
    current_wave += 1
    print("current wave is: ", current_wave)
    
    enemies_to_spawn = log(current_wave) * spawn_bonus + 5
    
    if (current_wave+1)%20 == 0:
      enemies_to_spawn = enemies_to_spawn*0.5
      spawn_bonus -= 1
      enemy_health_bonus += 1
      enemy_speed_bonus += 25
      
    print("spawning enemies x", enemies_to_spawn)
    
    enemies_alive = enemies_to_spawn
    spawn_wave()
    
func spawn_wave():
    for i in enemies_to_spawn:
        spawn_enemy(enemy_prefab)
        if (i+1)%5 == 0:
          spawn_enemy(armored_enemy_prefab)
        await get_tree().create_timer(time_between_spawns).timeout

func spawn_enemy(enemy: PackedScene):
  var e = enemy.instantiate()
  path.add_child(e)
  e.progress = 0
  e.get_child(0).max_health += current_wave * enemy_health_bonus
  e.speed -= enemy_speed_bonus
  
  e.get_child(0).enemy_died.connect(_on_enemy_died)
  
  
func _on_enemy_died(enemy):
    enemies_alive -= 1
    
    if enemies_alive <= 0:
        await get_tree().create_timer(time_between_waves).timeout
        start_wave()
