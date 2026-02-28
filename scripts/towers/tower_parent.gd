class_name TowerParent extends Node2D

enum TargettingMode {
  ALL_IN_RANGE,
  FURTHEST,
  CLOSEST
}

@export var damage: float = 10.0
@export var attack_cooldown_s: float = 1.0
@export var attack_range: float = 100.0:
  set(value):
    attack_range = maxf(value, 0.0)
    _update_attack_collision_size()
@export var cost: int = 50
@export var target_mode: TargettingMode = TargettingMode.FURTHEST

var can_attack: bool = true
var attack_timer: Timer
var targets: Array[Node2D] = []

@onready var attack_collision: CollisionShape2D = %AttackCollision
@onready var attack_area: Area2D = %AttackArea

func _ready() -> void:
  _setup_attack_timer()
  _update_attack_collision_size()

func _process(_delta: float) -> void:
  _prune_invalid_targets()
  if can_attack and not targets.is_empty():
    attack()

func attack() -> void:
  var selected_targets: Array[Node2D] = _select_targets()
  if selected_targets.is_empty():
    return

  can_attack = false
  attack_timer.start()
  _perform_attack(selected_targets)

func _perform_attack(selected_targets: Array[Node2D]) -> void:
  # Child towers can override this for projectiles, buffs, status effects, etc.
  for target in selected_targets:
    if is_instance_valid(target) and target.has_method("take_damage"):
      target.take_damage(damage)

func _select_targets() -> Array[Node2D]:
  match target_mode:
    TargettingMode.ALL_IN_RANGE:
      return targets
    TargettingMode.CLOSEST:
      var closest_target := _closest_target()
      if closest_target == null:
        return []
      return [closest_target]
    TargettingMode.FURTHEST:
      if targets.is_empty():
        return []
      return [targets[0]]

  return []

func _closest_target() -> Node2D:
  var closest: Node2D = null
  var closest_dist_sq := INF

  for target in targets:
    if not is_instance_valid(target):
      continue

    var dist_sq := global_position.distance_squared_to(target.global_position)
    if dist_sq < closest_dist_sq:
      closest_dist_sq = dist_sq
      closest = target
  
  return closest

func _setup_attack_timer() -> void:
  attack_timer = Timer.new()
  attack_timer.wait_time = attack_cooldown_s
  attack_timer.one_shot = true
  attack_timer.timeout.connect(_on_attack_timer_timeout)
  add_child(attack_timer)

func _on_attack_timer_timeout() -> void:
  can_attack = true

func _update_attack_collision_size() -> void:
  if not is_node_ready():
    return
  var circle := attack_collision.shape as CircleShape2D
  if circle:
    circle.radius = attack_range

func _prune_invalid_targets() -> void:
  targets = targets.filter(func(target: Node2D) -> bool:
    return is_instance_valid(target)
  )

func _on_attack_area_body_entered(body: Node2D) -> void:
  if body.is_in_group("enemy") and body not in targets:
    targets.append(body)

func _on_attack_area_body_exited(body: Node2D) -> void:
  targets.erase(body)
