extends TowerParent

#projectile image
@export var projectile_scene: PackedScene

# max upgrade points 
const MAX_DAMAGE_UPGRADE := 3
const MAX_COOLDOWN_UPGRADE := 3
const MAX_RANGE_UPGRADE := 3

var damage_upgrade_points := 0
var cooldown_upgrade_points := 0
var range_upgrade_points := 0

func _ready() -> void:
    damage = 5.0
    attack_cooldown_s = 0.25
    attack_range = 100.0
    target_mode = TargettingMode.CLOSEST
    super._ready()

func upgrade_cooldown() -> void:
    if cooldown_upgrade_points < MAX_COOLDOWN_UPGRADE:
        cooldown_upgrade_points += 1
        attack_cooldown_s -= cooldown_upgrade_points * 0.05

func upgrade_damage() -> void:
    if damage_upgrade_points < MAX_DAMAGE_UPGRADE:
        damage_upgrade_points += 1
        damage += damage_upgrade_points * 5

func upgrade_range() -> void:
    if range_upgrade_points < MAX_RANGE_UPGRADE:
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
    proj.direction = (target.global_position - global_position).normalized()
    proj.max_distance = attack_range 
    get_tree().current_scene.add_child(proj)
