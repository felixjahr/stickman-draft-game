extends BackendNet

const HTTP_BASE := "http://host.docker.internal:8000"


func start_room(code: String) -> void:
	var data = await _request(
		HTTP_BASE + "/rooms/start/" + code,
		HTTPClient.METHOD_POST,
	)
