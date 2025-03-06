extends Control

const START_POS: int = -62
const ECHO_SLOT = preload("res://scenes/echo_slot.tscn")

var echoes: Array = []
var categorized_echoes: Array[Array] = []

var index: int = 0:
    set(value):
        index = value
        if is_node_ready():
            _target_pos_x = START_POS - (index - 4) * 144
            _focused_shifter = hbox_container.get_child(index)
            label.text = categorized_echoes[index][shifter_indices[index]].name
var _target_pos_x: float = 0.0
var shifter_indices := []
var _focused_shifter: VBoxContainer

var _tween: Tween
var _left_time: float
var _select_interval_time: float = 0.2
var _holding: bool = false
var _hold_time: float = 0.0

@onready var hbox_container: HBoxContainer = $HBoxContainer
@onready var label: Label = $Label


func _ready():
    load_categorized_echoes()
    shifter_indices.resize(categorized_echoes.size())
    shifter_indices.fill(0)
    populate_echoes()
    index = 0
    hbox_container.position.x = _target_pos_x
    hbox_container.position.y += hbox_container.size.y / 2.0 - 80


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

                if event.keycode == KEY_W:
                    shifter_animate_select(-1)

                if event.keycode == KEY_S:
                    shifter_animate_select(1)
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


func load_categorized_echoes() -> void:
    var dir = DirAccess.open("res://echoes/")
    var files = dir.get_files()
    for file in files:
        if file.ends_with(".png"):
            echoes.append(Echo.new(dir.get_current_dir(false) + "/" + file))

    # 自动分类
    var categories := {}
    for echo in echoes:
        var last_word = echo.name.split(" ")[-1]
        if categories.has(last_word):
            categories[last_word].append(echo)
        else:
            categories[last_word] = [echo]

    var echoes_left = []
    var need_to_erase = []
    for key in categories:
        if key.is_valid_int() or categories[key].size() == 1 or key in ["Moblin", "Boarblin", "Baba"]:
            echoes_left += categories[key]
            need_to_erase.append(key)

    for key in need_to_erase:
        categories.erase(key)

    for echo in echoes_left:
        var first_word = echo.name.split(" ")[0]
        if categories.has(first_word):
            categories[first_word].append(echo)
        else:
            categories[first_word] = [echo]

    var keys = categories.keys()
    keys.sort()
    for key in keys:
        var l_echoes = categories[key]
        var new_echoes = []
        new_echoes.resize(l_echoes.size())
        for echo in l_echoes:
            if echo.name[-1].is_valid_int():
                new_echoes[echo.name[-1].to_int() - 1] = echo
            else:
                var i = 0
                while i < new_echoes.size():
                    if new_echoes[i] == null:
                        new_echoes[i] = echo
                        break
                    i += 1
        categorized_echoes.append(new_echoes)


func populate_echoes() -> void:
    for echo_category in categorized_echoes:
        var shifter = VBoxContainer.new()
        shifter.add_theme_constant_override("separation", 20)
        for echo in echo_category:
            var echo_instance = ECHO_SLOT.instantiate()
            echo_instance.get_node("Anchor/Sprite").texture = echo.image
            shifter.add_child(echo_instance)
        hbox_container.add_child(shifter)


func animate_select(dircection: int) -> void:
    _left_time = 0.0
    if _tween:
        _left_time = _select_interval_time - _tween.get_total_elapsed_time()
        _tween.kill()

    _tween = get_tree().create_tween()
    index = (index + dircection + categorized_echoes.size()) % categorized_echoes.size()
    SoundManager.play()
    _tween.tween_property(hbox_container, "position:x", _target_pos_x, _select_interval_time + _left_time)


func shifter_animate_select(dircection: int) -> void:
    if _tween.is_running():
        await _tween.finished
        _tween.kill()

    _tween = get_tree().create_tween()
    var curr_category_size = categorized_echoes[index].size()
    shifter_indices[index] = (shifter_indices[index] + dircection + curr_category_size) % curr_category_size
    var target_shifter_position = - shifter_indices[index] * (160 + _focused_shifter.get_theme_constant("separation"))
    label.text = categorized_echoes[index][shifter_indices[index]].name
    SoundManager.play()
    _tween.tween_property(_focused_shifter, "position:y", target_shifter_position, _select_interval_time)
