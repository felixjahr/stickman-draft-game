extends TextureButton

@onready var cooldown_bar = $TextureProgressBar
@onready var timer = $Timer

@export var cooldown_time : float = 3.0
@export var ability_name : String = "double_jump"

signal ability_activated(name)

var abilities = {
	"dash" : ["res://ui/ability_button/dash_grey.png", "res://ui/ability_button/dash_color.png"],
	"double_jump" : ["res://ui/ability_button/double_jump_grey.png", "res://ui/ability_button/double_jump_color.png"],
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cooldown_bar.max_value = 100
	cooldown_bar.value = 100
	cooldown_bar.step = 0.1
	texture_normal = load(abilities[ability_name][0])
	cooldown_bar.texture_progress = load(abilities[ability_name][1])
	
func _on_pressed() -> void:
	if timer.is_stopped():
		print("Ability triggered") #TODO Connect with ability!
		_start_cooldown()
		ability_activated.emit(ability_name)
		
func _start_cooldown() -> void:
	disabled = true
	cooldown_bar.value = 0
	timer.wait_time = cooldown_time
	timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not timer.is_stopped():
		var progress_percent = 1.0 - (timer.time_left / cooldown_time)
		cooldown_bar.value = progress_percent * 100
	
func _on_timer_timeout() -> void:
	disabled = false
	cooldown_bar.value = 100
