extends TowerParent
class_name AoeTower

# max upgrade points
const MAX_DAMAGE_UPGRADE := 3
const MAX_COOLDOWN_UPGRADE := 3
const MAX_RANGE_UPGRADE := 3

var damage_upgrade_points := 0
var cooldown_upgrade_points := 0
var range_upgrade_points := 0

func _ready() -> void:
    damage = 10.0
    attack_cooldown_s = 1.5
    attack_range = 40.0
    target_mode = TargettingMode.ALL_IN_RANGE
    upgrade_cost1 = [150, 200, 400, 0]
    upgrade_cost2 = [150, 200, 400, 0]
    upgrade_cost3 = [150, 200, 400, 0]
    super._ready()

func upgrade_1() -> void:
    if damage_upgrade_points < MAX_DAMAGE_UPGRADE:
        damage_upgrade_points += 1
        damage += damage_upgrade_points * 3

func upgrade_2() -> void:
    if cooldown_upgrade_points < MAX_COOLDOWN_UPGRADE:
        cooldown_upgrade_points += 1
        attack_cooldown_s = maxf(attack_cooldown_s - cooldown_upgrade_points * 0.2, 0.1)

func upgrade_3() -> void:
    if range_upgrade_points < MAX_RANGE_UPGRADE:
        range_upgrade_points += 1
        attack_range += range_upgrade_points * 5

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