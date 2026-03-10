extends Node

enum MessageTyp {
	DRAFT_FINISHED,
}

signal input_received(pid: int, input: PlayerInput)
signal match_message_received(pid: int, type: int,  payload: Dictionary)
signal peer_connected(pid: int)
signal peer_disconnected(pid: int)

const PORT := 9000


func create_server() -> void:
	var peer := ENetMultiplayerPeer.new()
	peer.create_server(PORT, 8)
	multiplayer.multiplayer_peer = peer
	multiplayer.connect("peer_connected", _on_net_peer_connected)
	multiplayer.connect("peer_disconnected", _on_net_peer_disconnected)


func send_snapshot(snapshot: Snapshot) -> void:
	rpc("receive_snapshot", snapshot.to_dict())


func send_match_init(pid: int, match_init: MatchInit) -> void:
	rpc_id(pid, "receive_match_init", match_init.to_dict())


func send_game_message(pid: int, type: int, payload: Dictionary) -> void:
	rpc_id(pid, "receive_game_message", type, payload)


@rpc("any_peer", "unreliable")
func receive_input(input: Dictionary) -> void:
	var pid := multiplayer.get_remote_sender_id()
	emit_signal("input_received", pid, PlayerInput.from_dict(input))


@rpc("any_peer", "unreliable")
func receive_match_message(type: int, payload: Dictionary) -> void:
	var pid := multiplayer.get_remote_sender_id()
	emit_signal("match_message_received", pid, type, payload)


func _on_net_peer_connected(pid: int) -> void:
	emit_signal("peer_connected", pid)


func _on_net_peer_disconnected(pid: int) -> void:
	emit_signal("peer_disconnected", pid)


@rpc("authority", "unreliable")
func receive_snapshot(snapshot: Dictionary) -> void:
	pass


@rpc("authority", "reliable")
func receive_match_init(match_init: Dictionary) -> void:
	pass


@rpc("authority", "reliable")
func receive_game_message(type: int, payload: Dictionary) -> void:
	pass
