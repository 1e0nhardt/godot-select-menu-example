extends Control

const ECHO_SLOT = preload("res://scenes/echo_slot.tscn")

var echoes := []
var index: int = 0:
    set(value):
        if index != value:
            SoundManager.play()

        index = value
        if not is_node_ready():
            return
        index = (index + echoes.size()) % echoes.size()
        selection_indicator.global_position = radial_container.get_child(index).global_position - Vector2(4, 4)
        label.text = echoes[index].name

var _select_interval_time: float = 0.1
var _holding: bool = false
var _hold_time: float = 0.0

@onready var selection_indicator: Panel = $SelectionIndicator
@onready var radial_container: Container = $RadialContainer
@onready var label: Label = $Label


func _ready():
    load_echoes()
    populate_echoes()
    await radial_container.sort_children
    index = 0


func _process(delta: float) -> void:
    if _holding:
        _hold_time += delta


func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey:
        if event.pressed:
            if not event.is_echo():
                _holding = false
                if event.keycode == KEY_A:
                    index -= 1

                if event.keycode == KEY_D:
                    index += 1
            else:
                _holding = true
                if _hold_time > _select_interval_time:
                    _hold_time = 0.0
                    if event.keycode == KEY_A:
                        index -= 1

                    if event.keycode == KEY_D:
                        index += 1

        if event.is_released():
            _holding = false


func load_echoes() -> void:
    var dir = DirAccess.open("res://echoes/")
    var files = dir.get_files()
    for file in files:
        if file.ends_with(".png"):
            echoes.append(Echo.new(dir.get_current_dir(false) + "/" + file))

    var random_index = randi_range(0, echoes.size() - 9)
    echoes = echoes.slice(random_index, random_index + 8)


func populate_echoes() -> void:
    for echo in echoes:
        var echo_instance = ECHO_SLOT.instantiate()
        echo_instance.get_node("Anchor/Sprite").texture = echo.image
        radial_container.add_child(echo_instance)
