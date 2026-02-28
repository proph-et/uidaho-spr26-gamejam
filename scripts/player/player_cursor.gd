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
var pending_tower_preview: Node = null

func _process(delta: float) -> void:
    var dir := Input.get_vector(
        "player_%d_left" % player_id, "player_%d_right" % player_id,
        "player_%d_up" % player_id, "player_%d_down" % player_id
    )
    global_position += dir * move_speed * delta
    _clamp_to_visible_screen()
    _update_hovered_ui()
    _update_hovered_tower()

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

func _update_hovered_tower() -> void:
    hovered_tower = null

    var world := get_world_2d()
    if world == null:
        return

    var query := PhysicsPointQueryParameters2D.new()
    query.position = global_position
    query.collide_with_areas = true
    query.collide_with_bodies = true

    var hits := world.direct_space_state.intersect_point(query, 16)
    for hit in hits:
        var collider: Node = hit.get("collider") as Node
        if collider == null or not collider.is_in_group("tower_select_area"):
            continue
        var tower := _resolve_tower_from_node(collider)
        if tower != null:
            hovered_tower = tower
            return

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
        return

    _clear_selected_towers()

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

func _resolve_tower_from_node(node: Node) -> Node:
    var current := node
    while current != null:
        if current.is_in_group("tower") and current.has_method("interact"):
            return current
        current = current.get_parent()
    return null

func _clear_selected_towers() -> void:
    for tower in get_tree().get_nodes_in_group("tower"):
        if tower.has_method("hide_selection_range_for_player"):
            tower.hide_selection_range_for_player(player_id)
        elif tower.has_method("hide_selection_range"):
            tower.hide_selection_range()

func queue_tower_purchase(tower_scene: PackedScene, tower_name: String, tower_cost: int) -> void:
    if tower_scene == null:
        push_warning("PlayerCursor: tower_scene is null, cannot queue purchase.")
        return

    _clear_pending_tower_preview()
    pending_tower_scene = tower_scene
    pending_tower_name = tower_name
    pending_tower_cost = tower_cost
    _create_pending_tower_preview()

func has_pending_tower() -> bool:
    return pending_tower_scene != null

func place_pending_tower() -> bool:
    if pending_tower_scene == null:
        return false
    if not _can_place_pending_tower_at_cursor():
        print("cannot place tower: overlaps another tower")
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
    _clear_pending_tower_preview()
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

func _can_place_pending_tower_at_cursor() -> bool:
    if pending_tower_preview == null:
        return true

    var pending_collision := _get_tower_collision_shape(pending_tower_preview)
    if pending_collision == null:
        return true

    var pending_center := pending_collision.global_position
    var pending_radius := _get_collision_radius_world(pending_collision)
    if pending_radius <= 0.0:
        return true

    for tower in get_tree().get_nodes_in_group("tower"):
        if tower == pending_tower_preview or not is_instance_valid(tower):
            continue

        var existing_collision := _get_tower_collision_shape(tower)
        if existing_collision == null:
            continue

        var existing_radius := _get_collision_radius_world(existing_collision)
        if existing_radius <= 0.0:
            continue

        var combined_radius := pending_radius + existing_radius
        if pending_center.distance_squared_to(existing_collision.global_position) < combined_radius * combined_radius:
            return false

    return true

func _create_pending_tower_preview() -> void:
    if pending_tower_scene == null:
        return

    pending_tower_preview = pending_tower_scene.instantiate()
    add_child(pending_tower_preview)

    if pending_tower_preview is Node2D:
        (pending_tower_preview as Node2D).position = Vector2.ZERO

    _prepare_preview_node(pending_tower_preview)
    _add_range_indicator(pending_tower_preview)

func _clear_pending_tower_preview() -> void:
    if pending_tower_preview != null and is_instance_valid(pending_tower_preview):
        pending_tower_preview.queue_free()
    pending_tower_preview = null

func _prepare_preview_node(node: Node) -> void:
    node.set_process(false)
    node.set_physics_process(false)
    node.set_process_input(false)
    node.set_process_unhandled_input(false)
    node.set_process_unhandled_key_input(false)

    if node is Area2D:
        (node as Area2D).monitoring = false
        (node as Area2D).monitorable = false
    elif node is CollisionObject2D:
        (node as CollisionObject2D).input_pickable = false

    if node is CollisionShape2D:
        (node as CollisionShape2D).disabled = true

    if node is CanvasItem:
        var preview_modulate := (node as CanvasItem).modulate
        preview_modulate.a *= 0.45
        (node as CanvasItem).modulate = preview_modulate

    for child in node.get_children():
        _prepare_preview_node(child)

func _add_range_indicator(preview_root: Node) -> void:
    var preview_2d := preview_root as Node2D
    if preview_2d == null:
        return

    var attack_range := _get_effective_attack_radius_local(preview_root)
    if attack_range <= 0.0:
        return

    var ring := Line2D.new()
    ring.name = "PlacementRange"
    ring.width = 2.0
    ring.default_color = Color(0.3, 1.0, 0.5, 0.9)
    ring.z_index = 1000
    ring.closed = true
    ring.antialiased = true

    var segments := 64
    for i in range(segments):
        var angle := TAU * float(i) / float(segments)
        ring.add_point(Vector2(cos(angle), sin(angle)) * attack_range)

    preview_2d.add_child(ring)

func _get_effective_attack_radius_local(node: Node) -> float:
    var attack_collision := node.find_child("AttackCollision", true, false) as CollisionShape2D
    if attack_collision != null and attack_collision.shape is CircleShape2D:
        var circle := attack_collision.shape as CircleShape2D
        var root_2d := node as Node2D
        if root_2d != null:
            var self_sx := maxf(absf(root_2d.global_scale.x), 0.0001)
            var self_sy := maxf(absf(root_2d.global_scale.y), 0.0001)
            var local_sx := absf(attack_collision.global_scale.x) / self_sx
            var local_sy := absf(attack_collision.global_scale.y) / self_sy
            var local_scale := maxf(local_sx, local_sy)
            return circle.radius * local_scale
        return circle.radius

    for property in node.get_property_list():
        if property is Dictionary and property.get("name", "") == "attack_range":
            return float(node.get("attack_range"))
    return 0.0

func _get_tower_collision_shape(tower_node: Node) -> CollisionShape2D:
    var tower_collision := tower_node.find_child("TowerCollision", true, false) as CollisionShape2D
    if tower_collision != null and tower_collision.shape is CircleShape2D:
        return tower_collision
    return null

func _get_collision_radius_world(collision: CollisionShape2D) -> float:
    var circle := collision.shape as CircleShape2D
    if circle == null:
        return 0.0
    var sx := absf(collision.global_scale.x)
    var sy := absf(collision.global_scale.y)
    var scale_factor := maxf(sx, sy)
    return circle.radius * scale_factor
