# scripts/utils/cursor_spawner.gd
extends Node
class_name CursorSpawner

signal player_joined(player_id: int)
signal player_left(player_id: int)

@export var cursor_scene: PackedScene
@export var cursor_parent_path: NodePath
@export var max_players: int = 2
@export var join_action_suffix: String = "join"
@export var leave_action_suffix: String = "leave"
@export var join_fallback_suffix: String = "interact"
@export var auto_spawn_player_ids: Array[int] = [1]
@export var center_spawn_offset: float = 48.0
@export var hold_required_player_ids: Array[int] = [2]
@export var hold_duration_seconds: float = 0.55

var cursors: Dictionary = {} # player_id -> PlayerCursor
var join_hold_time: Dictionary = {}
var leave_hold_time: Dictionary = {}
var join_hold_fired: Dictionary = {}
var leave_hold_fired: Dictionary = {}

func _ready() -> void:
    GameManager.set_player_active(1, true)

    var has_any_active: bool = false
    for player_id in range(1, max_players + 1):
        if GameManager.is_player_active(player_id):
            spawn_cursor(player_id)
            has_any_active = true

    if has_any_active:
        return

    for id_value in auto_spawn_player_ids:
        var player_id: int = int(id_value)
        if player_id >= 1 and player_id <= max_players:
            spawn_cursor(player_id)

func _process(_delta: float) -> void:
    if not cursors.has(1):
        spawn_cursor(1)

    for player_id in range(1, max_players + 1):
        if not _can_player_join_in_current_context(player_id):
            continue

        var join_actions: Array[String] = _resolved_join_actions(player_id)
        var leave_action: String = _resolved_leave_action(player_id)
        var require_hold: bool = _requires_hold(player_id)
        var allow_leave: bool = _can_player_leave_in_current_context(player_id)

        if require_hold:
            _update_join_hold(player_id, join_actions, _delta)
            if allow_leave:
                _update_leave_hold(player_id, leave_action, _delta)
            else:
                leave_hold_time[player_id] = 0.0
                leave_hold_fired[player_id] = false
        else:
            if _is_any_action_just_pressed(join_actions):
                spawn_cursor(player_id)
                continue
            if allow_leave and leave_action != "" and Input.is_action_just_pressed(leave_action):
                despawn_cursor(player_id)

func spawn_cursors(player_ids: Array[int]) -> void:
    for player_id in player_ids:
        spawn_cursor(player_id)

func spawn_cursor(player_id: int) -> void:
    if cursors.has(player_id):
        return
    if cursor_scene == null:
        push_warning("CursorSpawner: cursor_scene is not set.")
        return
    var parent: Node = get_node_or_null(cursor_parent_path)
    if parent == null:
        push_warning("CursorSpawner: cursor_parent_path is invalid.")
        return

    var cursor: Node = cursor_scene.instantiate()
    cursor.player_id = player_id
    parent.add_child(cursor)
    _set_cursor_spawn_position(cursor, player_id)
    cursors[player_id] = cursor
    GameManager.set_player_active(player_id, true)
    player_joined.emit(player_id)

func despawn_cursor(player_id: int) -> void:
    if player_id == 1:
        return
    if not cursors.has(player_id):
        return
    cursors[player_id].queue_free()
    cursors.erase(player_id)
    GameManager.set_player_active(player_id, false)
    player_left.emit(player_id)

func _resolved_join_actions(player_id: int) -> Array[String]:
    var actions: Array[String] = []
    var join_action: String = "player_%d_%s" % [player_id, join_action_suffix]
    if InputMap.has_action(join_action):
        actions.append(join_action)

    if join_fallback_suffix != "":
        var fallback_action: String = "player_%d_%s" % [player_id, join_fallback_suffix]
        if InputMap.has_action(fallback_action) and fallback_action != join_action:
            actions.append(fallback_action)
    return actions

func _resolved_leave_action(player_id: int) -> String:
    var leave_action: String = "player_%d_%s" % [player_id, leave_action_suffix]
    if InputMap.has_action(leave_action):
        return leave_action
    return ""

func _set_cursor_spawn_position(cursor: Node, player_id: int) -> void:
    var cursor_2d: Node2D = cursor as Node2D
    if cursor_2d == null:
        return

    var viewport: Viewport = get_viewport()
    if viewport == null:
        return

    var screen_rect: Rect2 = viewport.get_visible_rect()
    var screen_center: Vector2 = screen_rect.position + (screen_rect.size * 0.5)
    var to_world: Transform2D = viewport.get_canvas_transform().affine_inverse()
    var world_center: Vector2 = to_world * screen_center

    var offset_x: float = 0.0
    if player_id == 1:
        offset_x = -center_spawn_offset
    elif player_id == 2:
        offset_x = center_spawn_offset
    else:
        offset_x = (float(player_id) - 1.5) * (center_spawn_offset * 0.75)

    cursor_2d.global_position = world_center + Vector2(offset_x, 0.0)

func _requires_hold(player_id: int) -> bool:
    for id_value in hold_required_player_ids:
        if int(id_value) == player_id:
            return true
    return false

func _update_join_hold(player_id: int, actions: Array[String], delta: float) -> void:
    if cursors.has(player_id):
        join_hold_time[player_id] = 0.0
        join_hold_fired[player_id] = false
        return
    if not _can_player_join_in_current_context(player_id):
        join_hold_time[player_id] = 0.0
        join_hold_fired[player_id] = false
        return
    if actions.is_empty():
        return

    if _is_any_action_pressed(actions):
        var held: float = float(join_hold_time.get(player_id, 0.0)) + delta
        join_hold_time[player_id] = held
        var fired: bool = bool(join_hold_fired.get(player_id, false))
        if held >= hold_duration_seconds and not fired:
            spawn_cursor(player_id)
            join_hold_fired[player_id] = true
    else:
        join_hold_time[player_id] = 0.0
        join_hold_fired[player_id] = false

func _update_leave_hold(player_id: int, action: String, delta: float) -> void:
    if not cursors.has(player_id):
        leave_hold_time[player_id] = 0.0
        leave_hold_fired[player_id] = false
        return
    if action == "":
        return

    if Input.is_action_pressed(action):
        var held: float = float(leave_hold_time.get(player_id, 0.0)) + delta
        leave_hold_time[player_id] = held
        var fired: bool = bool(leave_hold_fired.get(player_id, false))
        if held >= hold_duration_seconds and not fired:
            despawn_cursor(player_id)
            leave_hold_fired[player_id] = true
    else:
        leave_hold_time[player_id] = 0.0
        leave_hold_fired[player_id] = false

func _can_player_join_in_current_context(player_id: int) -> bool:
    if player_id == 1:
        return true

    var current_scene := get_tree().current_scene
    if current_scene == null:
        return true

    var has_in_game_hud: bool = current_scene.find_child("InGameHud", true, false) != null
    if not has_in_game_hud:
        return true

    var match_started_with_coplayer: bool = GameManager.get_active_player_count() >= 2
    return match_started_with_coplayer

func _can_player_leave_in_current_context(player_id: int) -> bool:
    if player_id == 1:
        return false

    var current_scene := get_tree().current_scene
    if current_scene == null:
        return true

    var has_in_game_hud: bool = current_scene.find_child("InGameHud", true, false) != null
    if not has_in_game_hud:
        return true

    if player_id == 2:
        return false
    return true

func _is_any_action_pressed(actions: Array[String]) -> bool:
    for action_name in actions:
        if Input.is_action_pressed(action_name):
            return true
    return false

func _is_any_action_just_pressed(actions: Array[String]) -> bool:
    for action_name in actions:
        if Input.is_action_just_pressed(action_name):
            return true
    return false
