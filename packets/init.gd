class_name Init
extends RefCounted

var map_id: String
var game_id: String


func to_dict() -> Dictionary:
	return {
		"map_id": map_id,
		"game_id": game_id,
	}


static func from_dict(data: Dictionary) -> Init:
	var init := Init.new()
	init.map_id = data["map_id"]
	init.game_id = data["game_id"]
	return init
