extends Node

var env_data: Dictionary = {}
var api_key
var device_sku = "H61A8"  # Replace with your device SKU
var device_id = "0F:C9:35:34:35:40:3A:FF"  # Replace with your device ID

func _ready():
	print("Api init")
	load_env()
	
	$HTTPRequest.request_completed.connect(_on_request_completed)
	
	api_key = get_env("API_KEY") 
	var api_header = "Govee-API-Key: " + api_key
	
	#$HTTPRequest.request("https://openapi.api.govee.com/router/api/v1/user/devices", [api_header])
	
	switch_color_to_red()

func _on_request_completed(result, response_code, headers, body):
	print(result)
	print(response_code)
	print(headers)
	print(body)
	var json = JSON.parse_string(body.get_string_from_utf8())
	print(json)

# Load the .env file
func load_env(file_path: String = "res://API/env.txt"):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:    
		while not file.eof_reached():
			var line = file.get_line().strip_edges()
			
			if line.is_empty() or line.begins_with("#"):  # Skip comments or empty lines
				continue
			var parts = line.split("=", false, 2)
			if parts.size() == 2:
				env_data[parts[0]] = parts[1]
	else:
		push_error("Environment file not found: ", file_path)

# Retrieve an environment variable
func get_env(key: String, default_value: String = "") -> String:
	if not env_data.has(key):
		push_warning("Requested environment variable not found: " + key)
	return env_data.get(key, default_value)

# Function to switch the color to red
func switch_color_to_red():
	var red_rgb = ((255 & 0xFF) << 16) | ((0 & 0xFF) << 8) | (0 & 0xFF)  # RGB for red: (255, 0, 0)
	var api_header = "Govee-API-Key: " + api_key
	var request_data = {
		"requestId": str(OS.get_unique_id()),  # Unique request ID
		"payload": {
			"sku": device_sku,
			"device": device_id,
			"capability": {
				"type": "devices.capabilities.color_setting",
				"instance": "colorRgb",
				"value": red_rgb
			}
		}
	}
	$HTTPRequest.request(
		"https://openapi.api.govee.com/router/api/v1/device/control",
		[api_header],
		HTTPClient.METHOD_POST,
		JSON.stringify(request_data)
	)
