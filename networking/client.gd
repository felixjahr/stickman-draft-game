extends Node

enum ClientState {
	HOMESCREEN,
	CONNECTING,
	MATCH,
}

const Homescreen := preload("res://homescreen.tscn")

var state: ClientState

@onready var net := $Net
@onready var game := $Game

@onready var ui_container := $UIContainer


func _ready() -> void:
	_enter_state(ClientState.HOMESCREEN)


func _physics_process(delta: float) -> void:
	if state == ClientState.MATCH:
		game.game_tick(delta)


func _change_state(new_state: ClientState) -> void:
	if new_state == state:
		return
	_exit_state(new_state)
	_enter_state(new_state)
	state = new_state


func _enter_state(new_state: ClientState) -> void:
	if new_state == ClientState.HOMESCREEN:
		var new_homescreen = Homescreen.instantiate()
		ui_container.add_child(new_homescreen)
		new_homescreen.get_node("Play").connect("pressed", _on_homescreen_play_pressed)
	elif new_state == ClientState.CONNECTING:
		net.start_match()
	elif new_state == ClientState.MATCH:
		game.start_match()


func _exit_state(new_state: ClientState) -> void:
	if state == ClientState.HOMESCREEN:
		ui_container.get_child(0).queue_free()


func _on_homescreen_play_pressed() -> void:
	_change_state(ClientState.CONNECTING)


func _on_net_match_started() -> void:
	_change_state(ClientState.MATCH)
