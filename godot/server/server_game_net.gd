extends Node

signal input_received(player_id: String, input: PlayerInput)
signal player_received(player_id: String)
signal game_request_received(player_id: String, game_request: GameRequest)

var allowed_players: Dictionary
var player_id_by_pid: Dictionary[int, String]
var pid_by_player_id: Dictionary[String, int]


func create_server(port: int) -> void:
	var peer := ENetMultiplayerPeer.new()
	peer.create_server(port, 8)
	multiplayer.multiplayer_peer = peer


func send_snapshot(snapshot: Snapshot) -> void:
	rpc("receive_snapshot", snapshot.to_dict())


func send_init(player_id: String, game_id: String, map_id: String) -> void:
	var pid := pid_by_player_id[player_id]
	rpc_id(pid, "receive_init", game_id, map_id)


func send_game_event(player_id: String, game_event: GameEvent) -> void:
	var pid := pid_by_player_id[player_id]
	rpc_id(pid, "receive_game_event", game_event.to_dict())


@rpc("any_peer", "unreliable")
func receive_input(input: Dictionary) -> void:
	var player_id := player_id_by_pid[multiplayer.get_remote_sender_id()]
	emit_signal("input_received", player_id, PlayerInput.from_dict(input))


@rpc("any_peer", "reliable")
func receive_game_token(game_token: String) -> void:
	var pid := multiplayer.get_remote_sender_id()
	var token_hash := _hash_token(game_token)
	if not allowed_players.has(token_hash):
		multiplayer.multiplayer_peer.disconnect_peer(pid)
		return
	
	var player_id: String = allowed_players[token_hash]
	
	#if pid_by_player_id.has(player_id):
		#var old_pid := pid_by_player_id[player_id]
		#pid_by_player_id.erase(player_id)
		#player_id_by_pid.erase(old_pid)
		#pid_by_player_id[player_id] = pid
		#player_id_by_pid[pid] = player_id
		#return
	
	pid_by_player_id[player_id] = pid
	player_id_by_pid[pid] = player_id
	emit_signal("player_received", player_id)


@rpc("any_peer", "unreliable")
func receive_game_request(game_request: Dictionary) -> void:
	var player_id := player_id_by_pid[multiplayer.get_remote_sender_id()]
	emit_signal("game_request_received", player_id, GameRequest.from_dict(game_request))


@rpc("authority", "unreliable")
func receive_snapshot(snapshot: Dictionary) -> void:
	pass


@rpc("authority", "reliable")
func receive_init(game_id: String, map_id: String) -> void:
	pass


@rpc("authority", "reliable")
func receive_game_event(game_event: Dictionary) -> void:
	pass


func _hash_token(token: String) -> String:
	var ctx := HashingContext.new()
	ctx.start(HashingContext.HASH_SHA256)
	ctx.update(token.to_utf8_buffer())
	return ctx.finish().hex_encode()
