extends Area2D

@export var speed: float = 200.0

var damage: float = 0
var direction: Vector2
var max_distance: float = 0.0

var start_position: Vector2
var distance_traveled: float = 0.0

func _ready() -> void:
    start_position = global_position

func _process(delta: float) -> void:
    var movement = direction * speed * delta
    global_position += movement
    distance_traveled += movement.length()

    if distance_traveled >= max_distance:
        queue_free()

func _on_body_entered(body: Node2D) -> void:
    if body.has_method("take_damage"):
        body.take_damage(damage)
        queue_free()