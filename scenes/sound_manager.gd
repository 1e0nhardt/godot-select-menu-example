extends Node

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


func play() -> void:
	audio_stream_player.play()