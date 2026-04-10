extends Node

signal room_created(pid: int)
signal room_joined(pid: int, code: String)


func create_server(port: int) -> void:
	var peer := ENetMultiplayerPeer.new()
	peer.create_server(port, 64)
	multiplayer.multiplayer_peer = peer
	print("server created")


func send_room_code(pid: int, code: String) -> void:
	print("send room code")
	rpc_id(pid, "receive_room_code", code)
	print("succ")


func send_room_start(pid: int, port: int, ip: String, game_id: String, map_id: String) -> void:
	print("send room start")
	rpc_id(pid, "receive_room_start", port, ip, game_id, map_id)
	print("succ")


func send_room_error(pid: int, error: String) -> void:
	print("send room error")
	rpc_id(pid, "receive_room_error", error)
	print("succ")


@rpc("any_peer", "reliable")
func receive_create_room() -> void:
	print("receive_create_room")
	var pid := multiplayer.get_remote_sender_id()
	emit_signal("room_created", pid)


@rpc("any_peer", "reliable")
func receive_join_room(code: String) -> void:
	var pid := multiplayer.get_remote_sender_id()
	emit_signal("room_joined", pid, code)


@rpc("authority", "reliable")
func receive_room_code(code: String) -> void:
	pass


@rpc("authority", "reliable")
func receive_room_start(port: int, ip: String, game_id: String, map_id: String) -> void:
	pass


@rpc("authority", "reliable")
func receive_room_error(error: String) -> void:
	pass
