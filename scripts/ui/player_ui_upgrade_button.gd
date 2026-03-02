extends Button
class_name UpgradeButton

var current_tower: Node = null
var upgrade_index: int = 1


func setup(tower: Node, index: int) -> void:
    current_tower = tower
    upgrade_index = index
    _update_state()


func player_interact(player_id: int, _cursor : PlayerCursor) -> void:
    if current_tower == null:
        return

    # Check if tower can upgrade
    if not _can_upgrade():
        return

    # Check money
    if not GameManager.spend_money(player_id, _get_cost()):
        return

    #apply the upgrade
    _apply_upgrade()
    _update_state()

func _can_upgrade() -> bool:
    match upgrade_index:
        1: return current_tower.can_upgrade_1()
        2: return current_tower.can_upgrade_2()
        3: return current_tower.can_upgrade_3()
    return false


func _apply_upgrade() -> void:
    match upgrade_index:
        1: current_tower.upgrade_1()
        2: current_tower.upgrade_2()
        3: current_tower.upgrade_3()


func _get_cost() -> int:
    match upgrade_index:
        1: return current_tower.get_upgrade_1_cost()
        2: return current_tower.get_upgrade_2_cost()
        3: if current_tower.has_method("get_upgrade_3_cost") : return current_tower.get_upgrade_3_cost()
    return 0


func _update_state() -> void:
    if current_tower == null:
        disabled = true
        return

    disabled = not _can_upgrade()

    var cost = _get_cost()
    var prize_text = "MAX" if cost == 0 else "$" + str(cost)
    text = current_tower.get_upgrade_name(upgrade_index) + " (" + prize_text + ")"

func clear() -> void:
    current_tower = null
    upgrade_index = 1
    disabled = true
    text = "Upgrade"
