extends TextureButton

@onready var cooldown_bar = $TextureProgressBar

var abilities = {
	"dash" : ["res://ui/ability_button/dash_grey.png", "res://ui/ability_button/dash_color.png"],
	"double_jump" : ["res://ui/ability_button/double_jump_grey.png", "res://ui/ability_button/double_jump_color.png"],
}

func setup_ability(new_ability_id: String) -> void:
	if abilities.has(new_ability_id):
		texture_normal = load(abilities[new_ability_id][0])
		cooldown_bar.texture_progress = load(abilities[new_ability_id][1])
	
func update_cooldown_visuals(percent: float) -> void:
	cooldown_bar.value = percent
	disabled = percent < 100.0
