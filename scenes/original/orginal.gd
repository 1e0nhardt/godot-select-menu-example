extends Control

const START_POS: int = -62
const ECHO_SLOT = preload("res://scenes/echo_slot.tscn")

var echoes := []
var index: int = 0:
    set(value):
        index = value
        if is_node_ready():
            # hbox_container.position.x = START_POS - (index - 4) * 144
            _target_pos_x = START_POS - (index - 4) * 144
            label.text = echoes[index].name
var _target_pos_x: float = 0.0

var _tween: Tween
var _left_time: float
var _select_interval_time: float = 0.2
var _holding: bool = false
var _hold_time: float = 0.0

@onready var hbox_container: HBoxContainer = $HBoxContainer
@onready var label: Label = $Label


func _ready():
    load_echoes()
    populate_echoes()
    index = 0
    hbox_container.position.x = _target_pos_x


func _process(delta: float) -> void:
    if _holding:
        _hold_time += delta


func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey:
        if event.pressed:
            if not event.is_echo():
                _holding = false
                if event.keycode == KEY_A:
                    animate_select(-1)

                if event.keycode == KEY_D:
                    animate_select(1)
            else:
                _holding = true
                if _hold_time > _select_interval_time:
                    _hold_time = 0.0
                    if event.keycode == KEY_A:
                        animate_select(-1)

                    if event.keycode == KEY_D:
                        animate_select(1)

        if event.is_released():
            _holding = false


func load_echoes() -> void:
    var dir = DirAccess.open("res://echoes/")
    var files = dir.get_files()
    for file in files:
        if file.ends_with(".png"):
            echoes.append(Echo.new(dir.get_current_dir(false) + "/" + file))


func populate_echoes() -> void:
    for echo in echoes:
        var echo_instance = ECHO_SLOT.instantiate()
        echo_instance.get_node("Anchor/Sprite").texture = echo.image
        hbox_container.add_child(echo_instance)


func animate_select(dircection: int) -> void:
    _left_time = 0.0
    if _tween:
        _left_time = _select_interval_time - _tween.get_total_elapsed_time()
        _tween.kill()

    _tween = get_tree().create_tween()
    index = (index + dircection + echoes.size()) % echoes.size()
    SoundManager.play()
    _tween.tween_property(hbox_container, "position:x", _target_pos_x, _select_interval_time + _left_time)
