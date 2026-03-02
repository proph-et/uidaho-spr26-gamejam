extends TowerParent
class_name FurthestTower

# max upgrade points
const MAX_DAMAGE_UPGRADE := 3
const MAX_COOLDOWN_UPGRADE := 3
const MAX_RANGE_UPGRADE := 3

var damage_upgrade_points := 0
var cooldown_upgrade_points := 0
var range_upgrade_points := 0

func _ready() -> void:
    damage = 60.0
    attack_cooldown_s = 2.0
    attack_range = 200.0
    target_mode = TargettingMode.FURTHEST
    upgrade_cost1 = [235, 340, 460, 0]
    upgrade_cost2 = [255, 333, 431, 0]
    upgrade_cost3 = [100, 200, 300, 0]
    super._ready()

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