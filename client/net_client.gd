extends Node

signal room_code_received(code: String)
signal room_start_received(port: int, ip: String, game_id: String, map_id: String)
signal room_error_received(error: String)


func create_client(port: int, ip: String) -> void:
	var peer := ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer


func close_client() -> void:
	if multiplayer.multiplayer_peer:
		multiplayer.multiplayer_peer.close()
		multiplayer.multiplayer_peer = null


func send_create_room() -> void:
	print("send create room")
	rpc_id(1, "receive_create_room")


func send_join_room(code: String) -> void:
	rpc_id(1, "receive_join_room", code)


@rpc("authority", "reliable")
func receive_room_code(code: String) -> void:
	emit_signal("room_code_received", code)


@rpc("authority", "reliable")
func receive_room_start(port: int, ip: String, game_id: String, map_id: String) -> void:
	emit_signal("room_start_received", port, ip, game_id, map_id)


@rpc("authority", "reliable")
func receive_room_error(error: String) -> void:
	emit_signal("room_error_received", error)


@rpc("any_peer", "reliable")
func receive_create_room() -> void:
	pass


@rpc("any_peer", "reliable")
func receive_join_room(code: String) -> void:
	pass
