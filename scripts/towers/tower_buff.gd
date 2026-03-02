extends TowerParent
class_name BuffTower

@export var buff_amount: float = 0.1
@export var buff_range: float = 80.0:
    set(value):
        buff_range = maxf(value, 0.0)
        $BuffArea/CollisionShape2D.shape.radius = buff_range

#max upgrades
const MAX_BUFF_AMOUNT_UPGRADE := 3
const MAX_RANGE_UPGRADE := 3

var buff_amount_upgrade_points := 0
var range_upgrade_points := 0

var towers_in_range: Array = []

func _ready() -> void:
    can_attack = false
    upgrade_cost1 = [300, 480, 669, 0]
    upgrade_cost2 = [350, 555, 750, 0]
    super._ready()

func _on_BuffArea_body_entered(body: Node2D) -> void:
    if body is TowerParent and body != self:
        towers_in_range.append(body)
        apply_buff(body)

func _on_BuffArea_body_exited(body: Node2D) -> void:
    if body in towers_in_range:
        remove_buff(body)
        towers_in_range.erase(body)

func apply_buff(tower: TowerParent) -> void:
    if tower.damage > 0:
        tower.damage_multiplier += buff_amount

func remove_buff(tower: TowerParent) -> void:
    if tower.damage > 0:
        tower.damage_multiplier -= buff_amount

func upgrade_1() -> void:
    if buff_amount_upgrade_points < MAX_BUFF_AMOUNT_UPGRADE:
        for tower in towers_in_range:
            remove_buff(tower)

        buff_amount_upgrade_points += 1
        buff_amount += 0.1 * buff_amount_upgrade_points

        for tower in towers_in_range:
            apply_buff(tower)

func upgrade_2() -> void:
    if range_upgrade_points < MAX_RANGE_UPGRADE:
        range_upgrade_points += 1
        buff_range += 20

func can_upgrade_1() -> bool:
    return buff_amount_upgrade_points < MAX_BUFF_AMOUNT_UPGRADE

func can_upgrade_2() -> bool:
    return range_upgrade_points < MAX_RANGE_UPGRADE

func get_upgrade_name(index: int) -> String:
  match index:
    1: return "Buff strength"
    2: return "Range"
  return ""

#get cost
func get_upgrade_1_cost() -> int:
    return upgrade_cost1[buff_amount_upgrade_points]

func get_upgrade_2_cost() -> int:
    return upgrade_cost1[range_upgrade_points]
