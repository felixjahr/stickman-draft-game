extends Node

enum GameState {
	DRAFT,
	MATCH,
}

var state: GameState

var current_draft_pool := {}
var category_owners := {}
var received_drafts := {}

@onready var net := $"../Net"
@onready var simulation := $Simulation



func _ready() -> void:
	net.connect("input_received", simulation._on_net_input_received)
	_enter_state(GameState.DRAFT)


func _change_state(new_state: GameState) -> void:
	if new_state == state:
		return
	_exit_state(new_state)
	_enter_state(new_state)
	state = new_state


func _enter_state(new_state: GameState) -> void:
	if new_state == GameState.DRAFT:
		simulation.spawn_map("forest")


func _exit_state(new_state: GameState) -> void:
	pass



func _on_net_peer_connected(pid: int) -> void:
	# Generate draft options and
	if current_draft_pool.is_empty():
		current_draft_pool = _generate_draft_pool()
	
	var draft_categories = _assign_draft_categories(pid)
	var draft_options = {}
	
	for category in draft_categories:
		draft_options[category] = current_draft_pool[category]
	
	# Send options to player
	var new_match_init = MatchInit.new()
	new_match_init.map_id = "mountains"
	new_match_init.gamemode_id = "draft"
	new_match_init.gamemode_payload = {
		"draft_options" : draft_options
	}
	net.send_match_init(pid, new_match_init)


func _generate_draft_pool() -> Dictionary:
	# Hardcoded options
	# Add random generation later
	var pool = {
		"weapon_1": ["sword", "spear"],
		"weapon_2": ["gun", "rifle"],
		"armour": ["light_armour", "heavy_armour"],
		"ability": ["dash", "double_jump"]
	}
	return pool


func _assign_draft_categories(pid: int) -> Array:
	# Hardcoded assignment
	# Add random assignment later
	var assigned_categories = []
	
	if category_owners.is_empty():
		assigned_categories = ["weapon_1", "armour"]
	else:
		assigned_categories = ["weapon_2", "ability"]
		
	for category in assigned_categories:
		category_owners[category] = pid
		
	return assigned_categories


func _on_net_match_message_received(pid: int, type: int, payload: Dictionary) -> void:
	# Store drafts
	received_drafts[pid] = payload
	
	# Check if all drafts have been received
	if received_drafts.size() == 2:
		_resolve_drafts_and_start_match(received_drafts)


func _resolve_drafts_and_start_match(received_drafts: Dictionary):
	var pids = received_drafts.keys()
	
	# Assign final items to players
	var final_player_items := {}
	for pid in pids:
		final_player_items[pid] = {}
		
	# Distribute items
	for category in current_draft_pool:
		var owner_pid = category_owners[category]
		var other_pid = pids[0] if pids[1] == owner_pid else pids[1]
		
		var chosen_item = received_drafts[owner_pid][category]
		var options = current_draft_pool[category]
		
		var remaining_item = options[0] if options[1] == chosen_item else options[1]
		
		final_player_items[owner_pid][category] = chosen_item
		final_player_items[other_pid][category] = remaining_item
	
	# Start match for both clients
	for pid in pids:
		var weapon_ids: Array[String] = [final_player_items[pid]["weapon_1"], final_player_items[pid]["weapon_2"]]
		var armour_id = final_player_items[pid]["armour"]
		simulation.spawn_player(pid, weapon_ids, armour_id)
		net.send_game_message(pid, net.MessageTyp.DRAFT_FINISHED, {})
