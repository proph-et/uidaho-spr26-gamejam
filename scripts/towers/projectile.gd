extends Node2D

@export var speed: float = 200.0

var damage: float = 0
var direction: Vector2 = Vector2.ZERO
var target: Node2D = null
var max_distance: float = 0.0

var start_position: Vector2
var distance_traveled: float = 0.0

func _ready() -> void:
  start_position = global_position
  if target != null and is_instance_valid(target):
    direction = (target.global_position - global_position).normalized()
  elif direction == Vector2.ZERO:
    direction = Vector2.RIGHT

func _process(delta: float) -> void:
  if target != null and is_instance_valid(target):
    direction = (target.global_position - global_position).normalized()

  var movement = direction * speed * delta
  global_position += movement
  distance_traveled += movement.length()

  if distance_traveled >= max_distance:
    queue_free()

func _on_body_entered(body: Node2D) -> void:
  if body != null and body.is_in_group("enemy") and body.has_method("take_damage"):
    body.take_damage(damage)
    queue_free()
