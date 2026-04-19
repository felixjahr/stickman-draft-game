class_name GameEvent
extends RefCounted

enum Type {
	DRAFT_OPTIONS,
	DRAFT_FINISHED
}

var type: Type
var payload


func to_dict() -> Dictionary:
	return {
		"type": type,
		"payload": payload,
	}


static func from_dict(data: Dictionary) -> GameEvent:
	var game_event := GameEvent.new()
	game_event.type = data["type"]
	game_event.payload = data["payload"]
	return game_event
