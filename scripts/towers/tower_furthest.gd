extends TowerParent
class_name FurthestTower

const ATTACK_SFX: AudioStream = preload("res://assets/audio/olivia_parker-powerful-smack-demo-310472.mp3")

# max upgrade points
const MAX_DAMAGE_UPGRADE := 3
const MAX_COOLDOWN_UPGRADE := 3
const MAX_RANGE_UPGRADE := 3

var damage_upgrade_points := 0
var cooldown_upgrade_points := 0
var range_upgrade_points := 0
var attack_visual_tween: Tween
var visual_base_scale: Vector2 = Vector2.ONE
var attack_sfx_player: AudioStreamPlayer2D = null

func _ready() -> void:
    tower_display_name = "Furthest Tower"
    damage = 60.0
    attack_cooldown_s = 2.0
    attack_range = 200.0
    target_mode = TargettingMode.FURTHEST
    upgrade_cost1 = [235, 340, 460, 0]
    upgrade_cost2 = [255, 333, 431, 0]
    upgrade_cost3 = [100, 200, 300, 0]
    super._ready()
    if melee_visual != null and is_instance_valid(melee_visual):
        visual_base_scale = melee_visual.scale
    _setup_attack_sfx()

func _perform_attack(selected_targets: Array[Node2D]) -> void:
    if not selected_targets.is_empty():
        _play_attack_animation(selected_targets[0])
    _play_attack_sfx()
    super._perform_attack(selected_targets)

func upgrade_1() -> void:
    if damage_upgrade_points < MAX_DAMAGE_UPGRADE:
        damage_upgrade_points += 1
        damage += damage_upgrade_points * 20

func upgrade_2() -> void:
    if cooldown_upgrade_points < MAX_COOLDOWN_UPGRADE:
        cooldown_upgrade_points += 1
        attack_cooldown_s = maxf(attack_cooldown_s - cooldown_upgrade_points * 0.3, 0.1)

func upgrade_3() -> void:
    if range_upgrade_points < MAX_RANGE_UPGRADE:
        range_upgrade_points += 1
        attack_range += range_upgrade_points * 20

func can_upgrade_1() -> bool:
    return damage_upgrade_points < MAX_DAMAGE_UPGRADE

func can_upgrade_2() -> bool:
    return cooldown_upgrade_points < MAX_COOLDOWN_UPGRADE

func can_upgrade_3() -> bool:
    return range_upgrade_points < MAX_RANGE_UPGRADE

#get cost
func get_upgrade_1_cost() -> int:
    return upgrade_cost1[damage_upgrade_points]

func get_upgrade_2_cost() -> int:
    return upgrade_cost1[cooldown_upgrade_points]

func get_upgrade_3_cost() -> int:
    return upgrade_cost1[range_upgrade_points]

func _setup_attack_sfx() -> void:
    attack_sfx_player = AudioStreamPlayer2D.new()
    attack_sfx_player.stream = ATTACK_SFX
    attack_sfx_player.volume_db = -10.0
    add_child(attack_sfx_player)

func _play_attack_sfx() -> void:
    if attack_sfx_player == null:
        return
    attack_sfx_player.play()

func _play_attack_animation(target: Node2D) -> void:
    if melee_visual == null or not is_instance_valid(melee_visual):
        return

    var direction := Vector2.RIGHT
    if target != null and is_instance_valid(target):
        direction = (to_local(target.global_position) - melee_visual_rest_position).normalized()
        if direction.length_squared() <= 0.0001:
            direction = Vector2.RIGHT

    if attack_visual_tween != null and is_instance_valid(attack_visual_tween):
        attack_visual_tween.kill()

    melee_visual.position = melee_visual_rest_position
    melee_visual.scale = visual_base_scale

    var lunge_target := melee_visual_rest_position + direction * 8.0
    var hit_scale := visual_base_scale * 1.12

    attack_visual_tween = create_tween()
    attack_visual_tween.tween_property(melee_visual, "position", lunge_target, 0.06)
    attack_visual_tween.parallel().tween_property(melee_visual, "scale", hit_scale, 0.06)
    attack_visual_tween.tween_property(melee_visual, "position", melee_visual_rest_position, 0.12)
    attack_visual_tween.parallel().tween_property(melee_visual, "scale", visual_base_scale, 0.12)
