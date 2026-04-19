extends Node

const GAMES: Dictionary[String, PackedScene] = {
	"draft": preload("res://games/draft/draft_server.tscn"),
}

var game: Node

@onready var backend_net := $Net/BackendNet
@onready var game_net := $Net/GameNet


func _ready() -> void:
	var args := _get_cmdline_params()
	var port := int(args["port"])
	var code: String = args["code"]
	var game_id: String = args["game_id"]
	var map_id: String = args["map_id"]
	
	game_net.create_server(port)
	
	var new_game := GAMES[game_id].instantiate()
	new_game.game_id = game_id
	new_game.map_id = map_id
	new_game.game_net = game_net
	add_child(new_game)
	game = new_game
	
	backend_net.start_room(code)


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
