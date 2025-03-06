class_name Echo
extends RefCounted

var name: String
var image: Texture2D


func _init(path: String):
    name = path.get_file().get_slice(".", 0).left(-5).uri_decode().capitalize()
    image = load(path)


func _to_string() -> String:
    return name