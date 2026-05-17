extends Control

signal pressed

const ABILITIES = {
	"dash" : ["res://ui/overlay/ability_button/dash_grey.png", "res://ui/overlay/ability_button/dash_color.png"],
	"double_jump" : ["res://ui/overlay/ability_button/double_jump_grey.png", "res://ui/overlay/ability_button/double_jump_color.png"],
	"invisibility" : ["res://ui/overlay/ability_button/invisibility_grey.png", "res://ui/overlay/ability_button/invisibility_color.png"],
	"slam_down" : ["res://ui/overlay/ability_button/slam_down_grey.png", "res://ui/overlay/ability_button/slam_down_color.png"],
}

var is_active := false

var active_touch_index := -1
var _just_pressed := false
var disabled := false

@onready var icon := $Icon
@onready var cooldown_bar := $Icon/CooldownBar


func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			_activate_touch(event.index, event.position)
		else:
			_release_touch(event.index)


func consume_just_pressed() -> bool:
	var pressed := _just_pressed
	_just_pressed = false
	return pressed


func setup_ability(new_ability_id: String) -> void:
	if ABILITIES.has(new_ability_id):
		icon.texture = load(ABILITIES[new_ability_id][0])
		cooldown_bar.texture_progress = load(ABILITIES[new_ability_id][1])


func update_cooldown_visuals(percent: float) -> void:
	cooldown_bar.value = percent
	disabled = percent < 100.0
	if disabled and active_touch_index == -1:
		_reset_touch()


func is_hovered() -> bool:
	return get_global_rect().has_point(get_global_mouse_position())


func _activate_touch(touch_index: int, touch_position: Vector2) -> void:
	if disabled or active_touch_index != -1 or not get_global_rect().has_point(touch_position):
		return
	active_touch_index = touch_index
	is_active = true
	_just_pressed = true
	pressed.emit()
	get_viewport().set_input_as_handled()


func _release_touch(touch_index: int) -> void:
	if touch_index != active_touch_index:
		return
	_reset_touch()
	get_viewport().set_input_as_handled()


func _reset_touch() -> void:
	active_touch_index = -1
	is_active = false
