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

func upgrade_cooldown() -> void:
    if cooldown_upgrade_points < MAX_COOLDOWN_UPGRADE:
        cooldown_upgrade_points += 1
        attack_cooldown_s -= cooldown_upgrade_points * 0.2

func upgrade_damage() -> void:
    if value_upgrade_points < MAX_VALUE_UPGRADE:
        damage_upgrade_points += 1
        damage += damage_upgrade_points * 3

func upgrade_range() -> void:
    if value_upgrade_points < MAX_VALUE_UPGRADE:
        range_upgrade_points += 1
        attack_range += range_upgrade_points * 5