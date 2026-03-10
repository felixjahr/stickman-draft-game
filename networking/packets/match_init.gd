class_name MatchInit
extends RefCounted

var map_id: String
var gamemode_id: String
var gamemode_payload: Dictionary


func to_dict() -> Dictionary:
	return {
		"map_id" : map_id,
		"gamemode_id" : gamemode_id,
		"gamemode_payload" : gamemode_payload,
	}


static func from_dict(data: Dictionary) -> MatchInit:
	var init := MatchInit.new()
	init.map_id = data["map_id"]
	init.gamemode_id = data["gamemode_id"]
	init.gamemode_payload = data["gamemode_payload"]
	return init
