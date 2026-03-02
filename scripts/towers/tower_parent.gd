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
@export var selection_ring_color_p1: Color = Color(0.3, 1.0, 0.5, 0.9)
@export var selection_ring_color_p2: Color = Color(0.3, 0.7, 1.0, 0.9)
@export var selection_ring_width: float = 2.0
@export var upgrade_cost1 = [0,0,0,0]
@export var upgrade_cost2 = [0,0,0,0]
@export var upgrade_cost3 = [0,0,0,0]

var can_attack: bool = true
var damage_multiplier: float = 1.0
var attack_timer: Timer
var targets: Array[Node2D] = []
var selection_rings_by_player: Dictionary = {}

static var selected_tower_by_player: Dictionary = {}

@onready var attack_collision: CollisionShape2D = %AttackCollision
@onready var attack_area: Area2D = %AttackArea
@onready var tower_area: Area2D = $TowerArea

func _ready() -> void:
    add_to_group("tower")
    if tower_area != null:
        tower_area.add_to_group("tower_select_area")
    _setup_attack_timer()
    _update_attack_collision_size()

func _exit_tree() -> void:
  var to_clear: Array[int] = []
  for key in selected_tower_by_player.keys():
    var player_id: int = int(key)
    if selected_tower_by_player[player_id] == self:
        to_clear.append(player_id)
  for player_id in to_clear:
    selected_tower_by_player.erase(player_id)

func _process(_delta: float) -> void:
  _prune_invalid_targets()
  if can_attack and not targets.is_empty():
    attack()

func attack() -> void:
  var selected_targets: Array[Node2D] = _select_targets()
  if selected_targets.is_empty():
    return

  print("Attacking ", selected_targets.size(), " targets.")
  can_attack = false
  attack_timer.start()
  _perform_attack(selected_targets)

func _perform_attack(selected_targets: Array[Node2D]) -> void:
  # Child towers can override this for projectiles, buffs, status effects, etc.
  for target in selected_targets:
    if is_instance_valid(target) and target.has_method("take_damage"):
        target.take_damage(get_damage())

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
  _update_all_selection_rings()

func _prune_invalid_targets() -> void:
  targets = targets.filter(func(target: Node2D) -> bool:
    return is_instance_valid(target)
  )

func _on_attack_area_body_entered(body: Node2D) -> void:
  print("Body entered attack area: ", body.name)
  if body.is_in_group("enemy") and body not in targets:
    targets.append(body)

func _on_attack_area_body_exited(body: Node2D) -> void:
  targets.erase(body)

func can_interact(player_id: int) -> bool:
  for key in selected_tower_by_player.keys():
    var other_player_id: int = int(key)
    if other_player_id == player_id:
        continue
    if selected_tower_by_player[other_player_id] == self:
        return false
  return true

func interact(player_id: int) -> void:
    if not can_interact(player_id):
        return
    _select_for_player(player_id)

func hide_selection_range() -> void:
  for key in selection_rings_by_player.keys():
    var player_id: int = int(key)
    hide_selection_range_for_player(player_id)

func hide_selection_range_for_player(player_id: int) -> void:
  var ring: Line2D = selection_rings_by_player.get(player_id) as Line2D
  if ring != null and is_instance_valid(ring):
    ring.visible = false
  if selected_tower_by_player.get(player_id) == self:
    selected_tower_by_player.erase(player_id)

func _select_for_player(player_id: int) -> void:
  var previous: Variant = selected_tower_by_player.get(player_id)
  if previous != null and previous != self and is_instance_valid(previous):
    if previous.has_method("hide_selection_range_for_player"):
        previous.hide_selection_range_for_player(player_id)

  var ring := _ensure_selection_ring_for_player(player_id)
  if ring != null and is_instance_valid(ring):
    ring.visible = true
  selected_tower_by_player[player_id] = self
  GameManager.emit_tower_selected(self, player_id)

func _ensure_selection_ring_for_player(player_id: int) -> Line2D:
  var existing: Line2D = selection_rings_by_player.get(player_id) as Line2D
  if existing != null and is_instance_valid(existing):
    return existing

  var ring := Line2D.new()
  ring.name = "SelectionRangeP%d" % player_id
  ring.width = selection_ring_width
  ring.default_color = _selection_color_for_player(player_id)
  ring.closed = true
  ring.antialiased = true
  ring.z_index = 1000 + player_id
  ring.visible = false
  add_child(ring)
  selection_rings_by_player[player_id] = ring
  _update_selection_ring_for_player(player_id)
  return ring

func _update_all_selection_rings() -> void:
  for key in selection_rings_by_player.keys():
    var player_id: int = int(key)
    _update_selection_ring_for_player(player_id)

func _update_selection_ring_for_player(player_id: int) -> void:
  var ring: Line2D = selection_rings_by_player.get(player_id) as Line2D
  if ring == null or not is_instance_valid(ring):
    return

  ring.clear_points()

  var radius := _get_effective_attack_radius_local()
  if radius <= 0.0:
    return

  var segments := 64
  for i in range(segments):
    var angle := TAU * float(i) / float(segments)
    ring.add_point(Vector2(cos(angle), sin(angle)) * radius)

func _selection_color_for_player(player_id: int) -> Color:
  if player_id == 1:
    return selection_ring_color_p1
  if player_id == 2:
    return selection_ring_color_p2
  return Color(1.0, 1.0, 1.0, 0.9)

func _get_effective_attack_radius_local() -> float:
  if attack_collision == null:
    return attack_range
  var circle := attack_collision.shape as CircleShape2D
  if circle == null:
    return attack_range

  var self_sx := maxf(absf(global_scale.x), 0.0001)
  var self_sy := maxf(absf(global_scale.y), 0.0001)
  var local_sx := absf(attack_collision.global_scale.x) / self_sx
  var local_sy := absf(attack_collision.global_scale.y) / self_sy
  var local_scale := maxf(local_sx, local_sy)
  return circle.radius * local_scale


#upgrade functions
func upgrade_1() -> void:
    pass

func upgrade_2() -> void:
    pass

func upgrade_3() -> void:
    pass

func can_upgrade_1() -> bool:
    return false

func can_upgrade_2() -> bool:
    return false

func can_upgrade_3() -> bool:
    return false

func get_upgrade_name(index: int) -> String:
  match index:
    1: return "Damage"
    2: return "Cooldown"
    3: return "Range"
  return "MAX"

#function to get current damage with mulipliers
func get_damage() -> float:
    return damage * damage_multiplier

