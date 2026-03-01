extends TowerParent

# max upgrade points
const MAX_DAMAGE_UPGRADE := 3
const MAX_COOLDOWN_UPGRADE := 3
const MAX_RANGE_UPGRADE := 3

var damage_upgrade_points := 0
var cooldown_upgrade_points := 0
var range_upgrade_points := 0

func _ready() -> void:
	damage = 30.0
	attack_cooldown_s = 0.5
	attack_range = 80.0
	target_mode = TargettingMode.CLOSEST
	super._ready()

func upgrade_1() -> void:
	if damage_upgrade_points < MAX_DAMAGE_UPGRADE:
		damage_upgrade_points += 1
		damage += damage_upgrade_points * 5

func upgrade_2() -> void:
	if cooldown_upgrade_points < MAX_COOLDOWN_UPGRADE:
		cooldown_upgrade_points += 1
		attack_cooldown_s = maxf(attack_cooldown_s - cooldown_upgrade_points * 0.1, 0.1)

func upgrade_3() -> void:
	if range_upgrade_points < MAX_RANGE_UPGRADE:
		range_upgrade_points += 1
		attack_range += range_upgrade_points * 10

func can_upgrade_1() -> bool:
	return damage_upgrade_points < MAX_DAMAGE_UPGRADE

func can_upgrade_2() -> bool:
	return cooldown_upgrade_points < MAX_COOLDOWN_UPGRADE

func can_upgrade_3() -> bool:
	return range_upgrade_points < MAX_RANGE_UPGRADE
