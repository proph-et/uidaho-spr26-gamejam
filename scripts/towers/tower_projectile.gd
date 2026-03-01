extends TowerParent

#base values 
@export var damage: float = 5
@export var attack_cooldown_s: float = 0.25
@export var attack_range: float = 100.0:
  set(value):
    attack_range = maxf(value, 0.0)
    _update_attack_collision_size()
@export var target_mode: TargettingMode = TargettingMode.CLOSEST

#projectile image
@export var projectile_scene: PackedScene

# max upgrade points 
const MAX_DAMAGE_UPGRADE := 3
const MAX_COOLDOWN_UPGRADE := 3
const MAX_RANGE_UPGRADE := 3

var damage_upgrade_points := 0
var cooldown_upgrade_points := 0
var range_upgrade_points := 0

func upgrade_cooldown() -> void:
    if cooldown_upgrade_points < MAX_COOLDOWN_UPGRADE:
        cooldown_upgrade_points += 1
        attack_cooldown_s -= cooldown_upgrade_points * 0.05

func upgrade_damage() -> void:
    if value_upgrade_points < MAX_VALUE_UPGRADE:
        damage_upgrade_points += 1
        damage += damage_upgrade_points * 5

func upgrade_range() -> void:
    if value_upgrade_points < MAX_VALUE_UPGRADE:
        range_upgrade_points += 1
        attack_range += range_upgrade_points * 5

func _perform_attack(selected_targets: Array[Node2D]) -> void:
  # projectiles
  for target in selected_targets:
    if is_instance_valid(target) and target.has_method("take_damage"):
        spawn_projectile(target)

func spawn_projectile(target: Node2D) -> void:
    if projectile_scene == null:
        return
    var proj = projectile_scene.instantiate()
    proj.global_position = global_position
    proj.damage = damage
    proj.target = target
    proj.max_distance = attack_range 
    get_tree().current_scene.add_child(proj)