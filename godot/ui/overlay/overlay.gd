extends Control

var output_0 := Vector2.ZERO
var output_1 := Vector2.ZERO

var current_weapon := 0
var weapon_aim_directions: Array[Vector2] = [Vector2.ZERO, Vector2.ZERO]
var direction := 0.0
var jumping := false
var ability := false

var current_ability_id = ""

@onready var aim_joystick_0 := $AimJoystick0
@onready var aim_joystick_1 := $AimJoystick1
@onready var dpad := $Dpad
@onready var ability_button := $AbilityButton


func poll() -> void:
	if aim_joystick_0.output != weapon_aim_directions[0]:
		current_weapon = 0
	elif aim_joystick_1.output != weapon_aim_directions[1]:
		current_weapon = 1
	weapon_aim_directions = [aim_joystick_0.output, aim_joystick_1.output]
	
	direction = dpad.output.x
	jumping = dpad.output.y < 0.0
	ability = Input.is_action_just_pressed("ability") or ability_button.is_pressed()


func apply_snapshot(snapshot: PlayerSnapshot) -> void:
	if current_ability_id != snapshot.ability_id:
		current_ability_id = snapshot.ability_id
		ability_button.setup_ability(current_ability_id)

	var total_recharge_time = Data.ABILITY[snapshot.ability_id].recharge_time
	var recharge_progress := clampf(snapshot.ability_recharge_time / total_recharge_time, 0.0, 1.0)
	var percent = (1.0 - recharge_progress) * 100.0
	
	ability_button.update_cooldown_visuals(percent)
