class_name Weapon
extends Node2D

@export var self_hit: bool = false
@export var aim_animation: String
@export var attack_animation: String

var player: CharacterBody2D
var weapon_number: int


func animate_aim(aim_direction: Vector2) -> void:
	pass


func animate_attack_event(attack: Dictionary) -> void:
	pass


func simulate_attack(aim_direction: Vector2) -> void:
	pass
