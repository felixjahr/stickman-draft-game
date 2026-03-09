extends Node2D


@onready var camera := $Camera2D
@onready var arena := $Arena
@onready var collision_shapes := [
	$CollisionPolygon2D,
	$CollisionPolygon2D2,
]


func _ready() -> void:
	if not OS.has_feature("match"):
		arena.queue_free()
		for collision_shape in collision_shapes:
			collision_shape.queue_free()
