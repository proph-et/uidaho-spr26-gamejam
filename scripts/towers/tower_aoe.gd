extends TowerParent

#base values 
@export var damage: float = 10
@export var attack_cooldown_s: float = 1.5
@export var attack_range: float = 40.0:
	set(value):
		attack_range = maxf(value, 0.0)
		_update_attack_collision_size()
@export var target_mode: TargettingMode = TargettingMode.CLOSEST


# max upgrade points 
const MAX_DAMAGE_UPGRADE := 3
const MAX_COOLDOWN_UPGRADE := 3
const MAX_RANGE_UPGRADE := 3

var damage_upgrade_points := 0
var cooldown_upgrade_points := 0
var range_upgrade_points := 0

func upgrade_1() -> void:
	if damage_upgrade_points < MAX_DAMAGE_UPGRADE:
		damage_upgrade_points += 1
		attack_cooldown_s -= damage_upgrade_points * 3

func upgrade_2() -> void:
	if cooldown_upgrade_points < MAX_COOLDOWN_UPGRADE:
		cooldown_upgrade_points += 1
		damage += cooldown_upgrade_points * 0.2

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
