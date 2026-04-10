extends Node

signal snapshot_received(snapshot: Snapshot)
signal init_received(init: Init)
signal game_event_received(game_event: GameEvent)


func create_client(port: int, ip: String) -> void:
	var peer := ENetMultiplayerPeer.new()
	peer.create_client(ip, port)
	multiplayer.multiplayer_peer = peer


func send_input(input: PlayerInput) -> void:
	rpc_id(1, "receive_input", input.to_dict())


func send_game_request(game_request: GameRequest) -> void:
	rpc_id(1, "receive_game_request", game_request.to_dict())


@rpc("authority", "unreliable")
func receive_snapshot(snapshot: Dictionary) -> void:
	emit_signal("snapshot_received", Snapshot.from_dict(snapshot))


@rpc("authority", "reliable")
func receive_init(init: Dictionary) -> void:
	emit_signal("init_received", Init.from_dict(init))


@rpc("authority", "reliable")
func receive_game_event(game_event: Dictionary) -> void:
	emit_signal("game_event_received", GameEvent.from_dict(game_event))


@rpc("any_peer", "unreliable")
func receive_input(input: Dictionary) -> void:
	pass


@rpc("any_peer", "unreliable")
func receive_game_request(game_request: Dictionary) -> void:
	pass
