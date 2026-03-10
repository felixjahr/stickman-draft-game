extends Node

enum MessageTyp {
	DRAFT_FINISHED,
}

signal snapshot_received(snapshot: Snapshot)
signal match_init_received(match_init: MatchInit)
signal game_message_received(type: MessageTyp, payload: Dictionary)

const IP_ADDRESS := "127.0.0.1"
#const IP_ADDRESS := "34.185.168.1"
const PORT := 9000


func connect_to_server() -> void:
	var peer := ENetMultiplayerPeer.new()
	peer.create_client(IP_ADDRESS, PORT)
	multiplayer.multiplayer_peer = peer


func send_input(input: PlayerInput) -> void:
	rpc_id(1, "receive_input", input.to_dict())


func send_match_message(type: int, payload: Dictionary) -> void:
	rpc_id(1, "receive_match_message", type, payload)


@rpc("authority", "unreliable")
func receive_snapshot(snapshot: Dictionary) -> void:
	emit_signal("snapshot_received", Snapshot.from_dict(snapshot))


@rpc("authority", "reliable")
func receive_match_init(match_init: Dictionary) -> void:
	emit_signal("match_init_received", MatchInit.from_dict(match_init))


@rpc("authority", "reliable")
func receive_game_message(type: int, payload: Dictionary) -> void:
	emit_signal("game_message_received", type, payload)


@rpc("any_peer", "unreliable")
func receive_input(input: Dictionary) -> void:
	pass


@rpc("any_peer", "unreliable")
func receive_match_message(type: int, payload: Dictionary) -> void:
	pass
