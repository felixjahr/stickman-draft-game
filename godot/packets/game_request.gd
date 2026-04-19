class_name GameRequest
extends RefCounted

enum Type {
	DRAFT_RESULT
}

var type: Type
var payload


func to_dict() -> Dictionary:
	return {
		"type": type,
		"payload": payload,
	}


static func from_dict(data: Dictionary) -> GameRequest:
	var game_event := GameRequest.new()
	game_event.type = data["type"]
	game_event.payload = data["payload"]
	return game_event
