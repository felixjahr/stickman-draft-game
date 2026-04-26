extends Node

const GAMES: Dictionary[String, PackedScene] = {
	"draft": preload("res://games/draft/draft_server.tscn"),
}

var game_id: String
var map_id: String
var code: String

var game: Node

@onready var backend_net := $Net/BackendNet
@onready var game_net := $Net/GameNet


func _ready() -> void:
	var args := _get_cmdline_params()
	var port := int(args["port"])
	game_id = args["game_id"]
	map_id = args["map_id"]
	code = args["code"]
	print(JSON.parse_string(args["allowed_players"]))
	game_net.allowed_players = JSON.parse_string(args["allowed_players"])
	
	game_net.create_server(port)
	game_net.connect("player_received", _on_net_player_received)
	
	var new_game := GAMES[game_id].instantiate()
	new_game.map_id = map_id
	add_child(new_game)
	new_game.connect("ended", _on_game_ended)
	game = new_game
	
	backend_net.start_room(code)


func _on_game_ended() -> void:
	backend_net.end_room(code)


func _on_net_player_received(player_id: String) -> void:
	game_net.send_init(player_id, game_id, map_id)


func _get_cmdline_params() -> Dictionary:
	var params := {}

	for arg in OS.get_cmdline_args():
		if "=" not in arg:
			continue
		var parts := arg.split("=")
		if parts.size() != 2:
			continue
		params[parts[0]] = parts[1]
	
	return params 
