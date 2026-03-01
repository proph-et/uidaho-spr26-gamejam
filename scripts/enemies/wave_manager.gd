extends Node2D

@export var enemy_prefab: PackedScene
@export var time_between_spawns: float = 1.0
#@export var time_between_waves: float = 3.0
@onready var path = get_parent().get_node("Path2D")

var current_wave: int = 0
var enemies_alive: int = 0
var enemies_to_spawn: int = 1

func _ready():
    start_wave()

func start_wave():
    current_wave += 1
    print("current wave is: ", current_wave)
    
    enemies_to_spawn = enemies_to_spawn*2
    print("spawning enemies x", enemies_to_spawn)
    
    enemies_alive = enemies_to_spawn
    spawn_wave()
    
func spawn_wave():
    for i in enemies_to_spawn:
        spawn_enemy()
        await get_tree().create_timer(time_between_spawns).timeout

func spawn_enemy():
  var enemy = enemy_prefab.instantiate()
  path.add_child(enemy)
  enemy.progress = 0
  
  enemy.get_child(0).enemy_died.connect(_on_enemy_died)
  
func _on_enemy_died(enemy):
    enemies_alive -= 1
    
    if enemies_alive <= 0:
        start_wave()
