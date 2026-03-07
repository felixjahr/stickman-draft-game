extends StaticBody2D

@onready var collision_shape := $CollisionShape2D


func _ready() -> void:
	if not OS.has_feature("match"):
		collision_shape.queue_free()
