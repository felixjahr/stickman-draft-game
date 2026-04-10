extends Node2D


@onready var camera := $Camera2D
@onready var arena := $Arena
@onready var collision_shapes := [
	$CollisionShape2D,
	$CollisionShape2D2,
	$CollisionShape2D3,
	$CollisionShape2D4,
	$CollisionShape2D5,
]


func _ready() -> void:
	if not OS.has_feature("server"):
		for collision_shape in collision_shapes:
			arena.queue_free()
			collision_shape.queue_free()
