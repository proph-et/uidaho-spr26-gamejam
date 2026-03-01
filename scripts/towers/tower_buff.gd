extends TowerParent

@export var buff_amount: float = 0.2
@export var buff_range: float = 80.0:
    set(value):
        buff_range = maxf(value, 0.0)
        $BuffArea/CollisionShape2D.shape.radius = buff_range

#max upgrades
const MAX_BUFF_AMOUNT_UPGRADE := 3
const MAX_RANGE_UPGRADE := 3

var buff_amount_upgrade_points := 0
var range_upgrade_points := 0

var can_attack: bool = false
var towers_in_range: Array = []

func _on_BuffArea_body_entered(body: Node2D) -> void:
    if body is TowerParent and body != self:
        towers_in_range.append(body)
        apply_buff(body)

func _on_BuffArea_body_exited(body: Node2D) -> void:
    if body in towers_in_range:
        remove_buff(body)
        towers_in_range.erase(body)

func apply_buff(tower: TowerParent) -> void:
    tower.damage *= (1.0 + buff_amount)

func remove_buff(tower: TowerParent) -> void:
    tower.damage /= (1.0 + buff_amount)

func upgrade_buff_amount() -> void:
    if buff_amount_upgrade_points < MAX_BUFF_AMOUNT_UPGRADE:
        buff_amount_upgrade_points += 1

func upgrade_range() -> void:
    if range_upgrade_points < MAX_RANGE_UPGRADE:
        range_upgrade_points += 1