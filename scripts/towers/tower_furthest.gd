extends TowerParent

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
    super._ready()

func upgrade_cooldown() -> void:
    if cooldown_upgrade_points < MAX_COOLDOWN_UPGRADE:
        cooldown_upgrade_points += 1
        attack_cooldown_s -= cooldown_upgrade_points * 0.3

func upgrade_damage() -> void:
    if damage_upgrade_points < MAX_DAMAGE_UPGRADE:
        damage_upgrade_points += 1
        damage += damage_upgrade_points * 10

func upgrade_range() -> void:
    if range_upgrade_points < MAX_RANGE_UPGRADE:
        range_upgrade_points += 1
        attack_range += range_upgrade_points * 20
