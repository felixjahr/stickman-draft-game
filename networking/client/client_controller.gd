extends Node

enum ClientState {
	HOME,
	OPTIONS,
	CONNECTING,
	MATCH,
}

const Home := preload("res://menus/home/home.tscn")
const Options := preload("res://menus/options/options.tscn")
const Match := preload("res://draft/client_draft.tscn")

var state: ClientState

var current_match: Node
var match_init: MatchInit

@onready var net := $Net
@onready var ui := $UI


func _ready() -> void:
	_enter_state(ClientState.HOME)


func change_state(new_state: ClientState) -> void:
	if new_state == state:
		return
	_exit_state(new_state)
	_enter_state(new_state)
	state = new_state


func _enter_state(new_state: ClientState) -> void:
	if new_state == ClientState.HOME:
		var new_home = Home.instantiate()
		ui.add_child(new_home)
		new_home.play_button.connect("pressed", _on_home_play_pressed)
		new_home.options_button.connect("pressed", _on_home_options_pressed)
	elif new_state == ClientState.OPTIONS:
		var new_options = Options.instantiate()
		ui.add_child(new_options)
		new_options.back_button.connect("pressed", _on_options_back_pressed)
	elif new_state == ClientState.CONNECTING:
		net.connect_to_server()
	elif new_state == ClientState.MATCH:
		var new_match = Match.instantiate()
		net.connect("game_message_received", new_match._on_net_game_message_received)
		#net.connect("match_init_received", new_match.)
		add_child(new_match)
		current_match = new_match
		new_match.init_match(match_init)


func _exit_state(new_state: ClientState) -> void:
	for child in ui.get_children():
		child.queue_free()


func _on_home_play_pressed() -> void:
	change_state(ClientState.CONNECTING)


func _on_home_options_pressed() -> void:
	change_state(ClientState.OPTIONS)


func _on_options_back_pressed() -> void:
	change_state(ClientState.HOME)


func _on_net_match_init_received(match_init: MatchInit) -> void:
	self.match_init = match_init
	change_state(ClientState.MATCH)
