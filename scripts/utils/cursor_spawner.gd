# scripts/utils/cursor_spawner.gd
extends Node
class_name CursorSpawner

@export var cursor_scene: PackedScene
@export var cursor_parent_path: NodePath
@export var max_players := 2
@export var join_action_suffix := "join"
@export var leave_action_suffix := "leave"
@export var join_fallback_suffix := "interact"

var cursors: Dictionary = {} # player_id -> PlayerCursor

func _process(_delta: float) -> void:
    for player_id in range(1, max_players + 1):
        var join_action := _resolved_join_action(player_id)
        if join_action != "" and Input.is_action_just_pressed(join_action):
            spawn_cursor(player_id)
            continue

        var leave_action := _resolved_leave_action(player_id)
        if leave_action != "" and Input.is_action_just_pressed(leave_action):
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
    var parent := get_node_or_null(cursor_parent_path)
    if parent == null:
        push_warning("CursorSpawner: cursor_parent_path is invalid.")
        return

    var cursor := cursor_scene.instantiate()
    cursor.player_id = player_id
    parent.add_child(cursor)
    cursors[player_id] = cursor

func despawn_cursor(player_id: int) -> void:
    if not cursors.has(player_id):
        return
    cursors[player_id].queue_free()
    cursors.erase(player_id)

func _resolved_join_action(player_id: int) -> String:
    var join_action := "player_%d_%s" % [player_id, join_action_suffix]
    if InputMap.has_action(join_action):
        return join_action

    if join_fallback_suffix == "":
        return ""
    var fallback_action := "player_%d_%s" % [player_id, join_fallback_suffix]
    if InputMap.has_action(fallback_action):
        return fallback_action
    return ""

func _resolved_leave_action(player_id: int) -> String:
    var leave_action := "player_%d_%s" % [player_id, leave_action_suffix]
    if InputMap.has_action(leave_action):
        return leave_action
    return ""
