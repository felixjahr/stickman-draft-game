extends Control

@onready var centerpoint = $CenterPoint
@onready var horizontal = $CenterPoint/CanvasGroup/Horizontal
@onready var vertical = $CenterPoint/CanvasGroup/Vertical
@onready var handle = $CenterPoint/Handle

@export var output = Vector2(0.0, 0.0)

const MAX_RANGE_X = 146
const MAX_RANGE_Y = -140
const HORIZONTAL_CLAMPING = 0.15
const VERTICAL_CLAMPING = 0.0
const HORIZONTAL_THRESHOLD = 0.2
const VERTICAL_THRESHOLD = 0.4

var is_active : bool = false
var initial_center_pos : Vector2

func _ready() -> void:
	centerpoint.position = Vector2(size.x * 0.4, size.y * 0.6)
	initial_center_pos = centerpoint.global_position

func _input(event) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			if get_global_rect().has_point(event.position):
				is_active = true
				centerpoint.global_position = event.position
				_update_dpad(event.position)
		else:
			if is_active:
				is_active = false
				centerpoint.global_position = initial_center_pos
				_reset_dpad()
				
	if event is InputEventScreenDrag and is_active:
		_update_dpad(event.position)

func _update_dpad(finger_position : Vector2) -> void:
	var offset = centerpoint.to_local(finger_position)
	
	if abs(offset.x) < MAX_RANGE_X * HORIZONTAL_CLAMPING: offset.x = 0
	if abs(offset.y) < abs(MAX_RANGE_Y) * VERTICAL_CLAMPING: offset.y = 0
	
	offset.x = clamp(offset.x, -MAX_RANGE_X, MAX_RANGE_X)
	offset.y = clamp(offset.y, MAX_RANGE_Y, 0)
	
	handle.position = offset
	vertical.position.x = offset.x
	
	output.x = sign(offset.x) if abs(offset.x) > (MAX_RANGE_X * HORIZONTAL_THRESHOLD) else 0.0
	output.y = sign(offset.y) if abs(offset.y) > (abs(MAX_RANGE_Y) * VERTICAL_THRESHOLD) else 0.0

func _reset_dpad() -> void:
	handle.position = Vector2.ZERO
	vertical.position.x = 0
	output = Vector2.ZERO
