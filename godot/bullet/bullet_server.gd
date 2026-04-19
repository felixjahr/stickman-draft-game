extends Node2D

var speed: int
var damage: int
var self_hit: bool

var direction: Vector2
var pid: int
var bullet_id: int

@onready var hitbox := $Hitbox
@onready var arena := $Arena


func _ready() -> void:
	rotation = direction.angle()


func tick(delta: float) -> void:
	global_position += direction * speed * delta


func _on_hitbox_area_entered(area: Area2D) -> void:
	if not self_hit and area.get_parent().pid == pid:
		return
	area.get_parent().apply_hit(damage)
	get_parent().get_parent().despawn_bullet(bullet_id)


func _on_hitbox_body_entered(body: Node2D) -> void:
	get_parent().get_parent().despawn_bullet(bullet_id)


func _on_arena_area_exited(area: Area2D) -> void:
	get_parent().get_parent().despawn_bullet(bullet_id)
