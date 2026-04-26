extends Control

signal draft_finished(draft_result: Array[int])

@onready var card_a := $MarginContainer/HBoxContainer/HBoxContainer/CardA
@onready var card_b := $MarginContainer/HBoxContainer/HBoxContainer/CardB

@onready var left_slots_container := $MarginContainer/HBoxContainer/LeftSlotsContainer
@onready var right_slots_container := $MarginContainer/HBoxContainer/RightSlotsContainer

var current_option: Dictionary
var current_slot_index := 0

var draft_options: Array[Dictionary]
var draft_result: Array[int] = []


func _ready() -> void:
	card_a.pressed.connect(_on_card_selected.bind(0))
	card_b.pressed.connect(_on_card_selected.bind(1))
	_show_next_category()


func _show_next_category() -> void:
	if draft_options.is_empty():
		emit_signal("draft_finished", draft_result)
		card_a.hide()
		card_b.hide()
		return
	
	current_option = draft_options.pop_front()
	var current_category_id = current_option["category_id"]
	var current_options_ids = current_option["option_ids"]
	
	var texture_a: Texture2D = Data.CATEGORIES[current_category_id][current_options_ids[0]].card_texture
	var texture_b: Texture2D = Data.CATEGORIES[current_category_id][current_options_ids[1]].card_texture
	
	card_a.get_node("ItemTexture").texture = texture_a
	card_b.get_node("ItemTexture").texture = texture_b
	
	card_a.disabled = false
	card_b.disabled = false
	
	card_a.show()
	card_b.show()


func _on_card_selected(index: int) -> void:
	draft_result.append(index)
	
	var selected_btn = card_a if index == 0 else card_b
	var unselected_btn = card_b if index == 0 else card_a
	
	_play_selection_animation(selected_btn, unselected_btn)


func _play_selection_animation(selected_btn: Button, unselected_btn: Button) -> void:
	var target_left_slot: TextureRect = left_slots_container.get_child(current_slot_index)
	var target_right_slot: TextureRect = right_slots_container.get_child(current_slot_index)
	
	var flying_selected: Button = _create_flying_card(selected_btn)
	var flying_unselected: Button = _create_flying_card(unselected_btn)
	add_child(flying_selected)
	add_child(flying_unselected)
	
	flying_selected.global_position = selected_btn.global_position
	flying_selected.size = selected_btn.size
	flying_unselected.global_position = unselected_btn.global_position
	flying_unselected.size = unselected_btn.size
	
	var tween = get_tree().create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(flying_selected, "global_position", target_left_slot.global_position, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(flying_selected, "size", target_left_slot.size, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	tween.tween_property(flying_unselected, "global_position", target_right_slot.global_position, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(flying_unselected, "size", target_right_slot.size, 0.4).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	tween.chain().tween_callback(
		func():
			_embed_in_slot(flying_selected, target_left_slot)
			_embed_in_slot(flying_unselected, target_right_slot)
			
			current_slot_index += 1
			_show_next_category()
	)
	
	card_a.hide()
	card_b.hide()


func _create_flying_card(btn: Button) -> Button:
	var card_copy = btn.duplicate()
	card_copy.disabled = true
	
	var glow = card_copy.get_node("GlowTexture")
	glow.queue_free()
	
	card_copy.custom_minimum_size = Vector2.ZERO
	card_copy.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT, Control.PRESET_MODE_MINSIZE)
	
	return card_copy


func _embed_in_slot(flying_card: Button, target_slot: TextureRect) -> void:
	flying_card.reparent(target_slot)
	flying_card.position = Vector2.ZERO
	flying_card.size = target_slot.size
	target_slot.self_modulate = Color.TRANSPARENT
