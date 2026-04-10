extends Node

signal input_received(pid: int, input: PlayerInput)
signal game_request_received(pid: int, game_request: GameRequest)
signal peer_connected(pid: int)
signal peer_disconnected(pid: int)


func create_server(port: int) -> void:
	var peer := ENetMultiplayerPeer.new()
	peer.create_server(port, 8)
	multiplayer.multiplayer_peer = peer
	multiplayer.connect("peer_connected", _on_net_peer_connected)
	multiplayer.connect("peer_disconnected", _on_net_peer_disconnected)


func send_snapshot(snapshot: Snapshot) -> void:
	rpc("receive_snapshot", snapshot.to_dict())


func send_init(pid: int, init: Init) -> void:
	rpc_id(pid, "receive_init", init.to_dict())


func send_game_event(pid: int, game_event: GameEvent) -> void:
	rpc_id(pid, "receive_game_event", game_event.to_dict())


@rpc("any_peer", "unreliable")
func receive_input(input: Dictionary) -> void:
	var pid := multiplayer.get_remote_sender_id()
	emit_signal("input_received", pid, PlayerInput.from_dict(input))


@rpc("any_peer", "unreliable")
func receive_game_request(game_request: Dictionary) -> void:
	var pid := multiplayer.get_remote_sender_id()
	emit_signal("game_request_received", pid, GameRequest.from_dict(game_request))


func _on_net_peer_connected(pid: int) -> void:
	emit_signal("peer_connected", pid)


func _on_net_peer_disconnected(pid: int) -> void:
	emit_signal("peer_disconnected", pid)


@rpc("authority", "unreliable")
func receive_snapshot(snapshot: Dictionary) -> void:
	pass


@rpc("authority", "reliable")
func receive_init(init: Dictionary) -> void:
	pass


@rpc("authority", "reliable")
func receive_game_event(game_event: Dictionary) -> void:
	pass
