extends Node2D

var bullet_speed: int
var bullet_damage: int
var bullet_direction: Vector2
var self_hit: bool
var player_id: String

@onready var hitbox := $Hitbox
@onready var arena := $Arena


func _ready() -> void:
	if !OS.has_feature("match"):
		hitbox.queue_free()
		arena.queue_free()
	rotation = bullet_direction.angle()


func _physics_process(delta: float) -> void:
	global_position += bullet_direction * bullet_speed * delta


func _on_hitbox_area_entered(area: Area2D) -> void:
	if not self_hit and area.get_parent().name == player_id:
		return
	area.get_parent().simulate_hit(bullet_damage)
	get_parent().send_despawn_bullet_event(int(name))
	queue_free()


func _on_hitbox_body_entered(body: Node2D) -> void:
	get_parent().send_despawn_bullet_event(int(name))
	queue_free()


func _on_arena_area_exited(area: Area2D) -> void:
	get_parent().send_despawn_bullet_event(int(name))
	queue_free()
