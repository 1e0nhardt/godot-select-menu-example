@tool
extends Panel


func _ready() -> void:
    resized.connect(_on_resized)
    _on_resized()


func _on_resized() -> void:
    material.set_shader_parameter("iResolution", Vector2(size))