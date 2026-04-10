extends Node

enum ClientState {
	HOME,
	OPTIONS,
	CREATE,
	JOIN,
	GAME,
}

const LOBBY_IP_ADDRESS := "127.0.0.1"
#const LOBBY_IP_ADDRESS := "35.198.127.12"
const LOBBY_PORT := 8000

const GAMES: Dictionary[String, PackedScene] = {
	"draft": preload("res://games/draft/draft_client.tscn"),
}

const Home := preload("res://ui/home/home.tscn")
const Options := preload("res://ui/options/options.tscn")
const Create := preload("res://ui/create/create.tscn")
const Join := preload("res://ui/join/join.tscn")

var state: ClientState

var game: Node

@onready var net := $Net
@onready var ui := $UI


func _ready() -> void:
	net.connect("room_code_received", _on_net_room_code_received)
	net.connect("room_start_received", _on_net_room_start_received)
	net.connect("room_error_received", _on_net_room_error_received)
	_enter_state(ClientState.HOME)


func _change_state(new_state: ClientState, data = null) -> void:
	if new_state == state:
		return
	_exit_state(new_state, data)
	_enter_state(new_state, data)
	state = new_state


func _enter_state(new_state: ClientState, data = null) -> void:
	if new_state == ClientState.HOME:
		var new_home := Home.instantiate()
		ui.add_child(new_home)
		new_home.create_button.connect("pressed", _on_home_create_pressed)
		new_home.join_button.connect("pressed", _on_home_join_pressed)
		new_home.options_button.connect("pressed", _on_home_options_pressed)
	elif new_state == ClientState.OPTIONS:
		var new_options := Options.instantiate()
		ui.add_child(new_options)
		new_options.back_button.connect("pressed", _on_options_back_pressed)
	elif new_state == ClientState.CREATE:
		var new_create := Create.instantiate()
		ui.add_child(new_create)
		net.create_client(LOBBY_PORT, LOBBY_IP_ADDRESS)
		await multiplayer.connected_to_server
		net.send_create_room()
	elif new_state == ClientState.JOIN:
		var new_join := Join.instantiate()
		ui.add_child(new_join)
		new_join.submit_button.connect("pressed", _on_join_submit_pressed)
		net.create_client(LOBBY_PORT, LOBBY_IP_ADDRESS)
	elif new_state == ClientState.GAME:
		var new_game := GAMES[data["game_id"]].instantiate()
		new_game.port = data["port"]
		new_game.ip = data["ip"]
		new_game.game_id = data["game_id"]
		new_game.map_id = data["map_id"]
		add_child(new_game)
		game = new_game


func _exit_state(new_state: ClientState, data = null) -> void:
	for child in ui.get_children():
		child.queue_free()


func _on_home_create_pressed() -> void:
	_change_state(ClientState.CREATE)


func _on_home_join_pressed() -> void:
	_change_state(ClientState.JOIN)


func _on_home_options_pressed() -> void:
	_change_state(ClientState.OPTIONS)


func _on_options_back_pressed() -> void:
	_change_state(ClientState.HOME)


func _on_join_submit_pressed() -> void:
	var code: String = ui.get_child(0).code.text
	net.send_join_room(code)


func _on_net_room_code_received(code: String) -> void:
	if state == ClientState.CREATE:
		ui.get_child(0).code.text = code


func _on_net_room_start_received(port: int, ip: String, game_id: String, map_id: String) -> void:
	net.close_client()
	_change_state(ClientState.GAME, {
		"port" : port,
		"ip" : ip,
		"game_id" : game_id,
		"map_id" : map_id,
	})


func _on_net_room_error_received(error: String) -> void:
	print(error)
