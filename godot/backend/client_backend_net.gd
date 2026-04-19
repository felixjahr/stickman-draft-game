extends BackendNet

signal room_code_received(code: String)
signal room_start_received(port: int, ip: String)

const HTTP_BASE := "http://127.0.0.1:8000"
const WS_URL := "ws://127.0.0.1:8000/ws"

var socket := WebSocketPeer.new()
var session_id := ""


func _ready() -> void:
	socket.connect_to_url(WS_URL)


func _process(_delta: float) -> void:
	socket.poll()
	
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count() > 0:
			var text := socket.get_packet().get_string_from_utf8()
			var msg = JSON.parse_string(text)
			
			if typeof(msg) != TYPE_DICTIONARY:
				continue
			
			var event := str(msg.get("event", ""))
			var data: Dictionary = msg.get("data", {})
			
			match event:
				"session":
					session_id = str(data.get("sessionId", ""))
				"receiveRoomStart":
					var ip := str(data.get("ip", ""))
					var port := int(data.get("port", 0))
					emit_signal("room_start_received", port, ip)


func create_room() -> void:
	if session_id.is_empty():
		return
	
	var data = await _request(
		HTTP_BASE + "/rooms/create",
		HTTPClient.METHOD_POST,
		null,
		["x-session-id: " + session_id]
	)
	
	emit_signal("room_code_received", data.code)


func join_room(code: String) -> void:
	if session_id.is_empty():
		return

	await _request(
		HTTP_BASE + "/rooms/join/" + code,
		HTTPClient.METHOD_POST,
		null,
		["x-session-id: " + session_id]
	)
