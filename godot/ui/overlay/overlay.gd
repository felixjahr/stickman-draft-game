extends Control

var jumping := false
var attacking := false
var ability := false

var attack_direction := Vector2.ZERO
var attack_weapon := 0

@onready var melee_joystick := $MeleeJoystick
@onready var ranged_joystick := $RangedJoystick
@onready var dpad := $Dpad
@onready var logic: Node = get_parent().get_parent().game.logic


func poll() -> PlayerInput:
	var input := PlayerInput.new()
	if not attacking:
		if melee_joystick.is_active:
			input.aim_direction = melee_joystick.output
			input.current_weapon = 0
		elif ranged_joystick.is_active:
			input.aim_direction = ranged_joystick.output
			input.current_weapon = 1
		elif Input.is_action_pressed("aim_melee"):
			input.aim_direction = _get_mouse_aim_direction()
			input.current_weapon = 0
		elif Input.is_action_pressed("aim_ranged"):
			input.aim_direction = _get_mouse_aim_direction()
			input.current_weapon = 1
	else:
		input.aim_direction = attack_direction
		input.current_weapon = attack_weapon
	
	input.jumping = jumping
	input.ability = ability
	input.attacking = attacking
	input.direction = clampi(signf(Input.get_axis("move_left", "move_right") + dpad.output), -1, 1)
	
	jumping = false
	ability = false
	attacking = false
	
	return input


func apply_snapshot(snapshot: PlayerSnapshot) -> void:
	pass
	#if current_ability_id != snapshot.ability_id:
		#current_ability_id = snapshot.ability_id
		#ability_button.setup_ability(current_ability_id)
#
	#var total_recharge_time = Data.ABILITY[snapshot.ability_id].recharge_time
	#var recharge_progress := clampf(snapshot.ability_recharge_time / total_recharge_time, 0.0, 1.0)
	#var percent = (1.0 - recharge_progress) * 100.0
	#
	#ability_button.update_cooldown_visuals(percent)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		jumping = true
	elif event.is_action_pressed("ability"):
		ability = true
	elif event.is_action_released("aim_melee"):
		attacking = true
		attack_direction = _get_mouse_aim_direction()
		attack_weapon = 0
	elif event.is_action_released("aim_ranged"):
		attacking = true
		attack_direction = _get_mouse_aim_direction()
		attack_weapon = 1


func _on_melee_joystick_released(direction: Vector2) -> void:
	attacking = true
	attack_direction = direction
	attack_weapon = 0


func _on_ranged_joystick_released(direction: Vector2) -> void:
	attacking = true
	attack_direction = direction
	attack_weapon = 1


func _on_jump_button_pressed() -> void:
	jumping = true


func _get_mouse_aim_direction() -> Vector2:
	var local_player: Node2D = logic.players.get(logic.local_player_id)
	var pivot: Vector2 = local_player.right_shoulder.global_position
	return pivot.direction_to(local_player.get_global_mouse_position())
