extends Node2D
class_name PlayerCursor

@export var player_id: int = 1
@export var move_speed: float = 700.0
@export var screen_margin: float = 0.0

var hovered_tower: Node = null
var hovered_ui: Control = null
var pending_tower_scene: PackedScene = null
var pending_tower_name := ""
var pending_tower_cost := 0

func _process(delta: float) -> void:
    var dir := Input.get_vector(
        "player_%d_left" % player_id, "player_%d_right" % player_id,
        "player_%d_up" % player_id, "player_%d_down" % player_id
    )
    global_position += dir * move_speed * delta
    _clamp_to_visible_screen()
    _update_hovered_ui()

    if Input.is_action_just_pressed("player_%d_interact" % player_id):
        attempt_interact()

func _clamp_to_visible_screen() -> void:
    var viewport := get_viewport()
    var screen_rect := viewport.get_visible_rect()
    var to_world := viewport.get_canvas_transform().affine_inverse()

    var top_left := to_world * screen_rect.position
    var bottom_right := to_world * (screen_rect.position + screen_rect.size)

    global_position.x = clampf(global_position.x, top_left.x + screen_margin, bottom_right.x - screen_margin)
    global_position.y = clampf(global_position.y, top_left.y + screen_margin, bottom_right.y - screen_margin)

func _update_hovered_ui() -> void:
    var viewport := get_viewport()
    var screen_pos := viewport.get_canvas_transform() * global_position
    hovered_ui = _pick_ui_at_screen_pos(screen_pos)

func attempt_interact() -> void:
    var manager := _find_interaction_manager()
    if manager != null and manager.has_method("request_interact"):
        manager.request_interact(player_id, hovered_ui, hovered_tower, self)
        return

    if hovered_ui != null and hovered_ui.has_method("player_interact"):
        hovered_ui.player_interact(player_id, self)
        return

    if has_pending_tower():
        place_pending_tower()
        return

    if hovered_tower != null and hovered_tower.has_method("interact"):
        hovered_tower.interact(player_id)

func _find_interaction_manager() -> Node:
    var current_scene := get_tree().current_scene
    if current_scene == null:
        return null
    return current_scene.find_child("InteractionManager", true, false)

func _pick_ui_at_screen_pos(screen_pos: Vector2) -> Control:
    var picked: Control = null
    for node in get_tree().get_nodes_in_group("player_ui_interactable"):
        var control := node as Control
        if control == null:
            continue
        if not control.visible:
            continue
        if control.mouse_filter == Control.MOUSE_FILTER_IGNORE:
            continue
        if not control.get_global_rect().has_point(screen_pos):
            continue

        # Prefer the deepest child when controls overlap.
        if picked == null or picked.is_ancestor_of(control):
            picked = control

    return picked

func queue_tower_purchase(tower_scene: PackedScene, tower_name: String, tower_cost: int) -> void:
    if tower_scene == null:
        push_warning("PlayerCursor: tower_scene is null, cannot queue purchase.")
        return
    pending_tower_scene = tower_scene
    pending_tower_name = tower_name
    pending_tower_cost = tower_cost

func has_pending_tower() -> bool:
    return pending_tower_scene != null

func place_pending_tower() -> bool:
    if pending_tower_scene == null:
        return false

    var tower_instance := pending_tower_scene.instantiate()
    var parent := _resolve_tower_parent()
    if parent == null:
        push_warning("PlayerCursor: no valid parent to place tower.")
        return false

    parent.add_child(tower_instance)
    if tower_instance is Node2D:
        (tower_instance as Node2D).global_position = global_position

    print("placed tower %s for player %d" % [pending_tower_name, player_id])
    pending_tower_scene = null
    pending_tower_name = ""
    pending_tower_cost = 0
    return true

func _resolve_tower_parent() -> Node:
    var current_scene := get_tree().current_scene
    if current_scene == null:
        return null

    var placed_towers := current_scene.find_child("PlacedTowers", true, false)
    if placed_towers != null:
        return placed_towers
    return current_scene
