@tool
extends Control

const ECHO_SLOT = preload("res://scenes/echo_slot.tscn")

@export_tool_button("Redraw") var action = func(): tab_indicator.queue_redraw()
@export var circle_radius: float = 4.0
@export var circle_spacing: float = 20.0
@export var tab_indicator_color: Color = Color("dee3ae")

var echoes := []
var tab_echoes := []
var tab_index: int = 0:
    set(value):
        tab_index = value
        if not is_node_ready():
            return
        populate_echoes(tab_index)
        tab_indicator.queue_redraw()
        if select_index >= tab_echoes[tab_index].size():
            select_index = tab_echoes[tab_index].size() - 1
        label.text = tab_echoes[tab_index][select_index].name

var select_index: int = 0:
    set(value):
        select_index = value
        if not is_node_ready():
            return
        if not Engine.is_editor_hint():
            SoundManager.play()
        selection_indicator.global_position = grid_container.get_child(select_index).global_position - Vector2(4, 4)
        label.text = tab_echoes[tab_index][select_index].name
var _select_interval_time: float = 0.1
var _holding: bool = false
var _hold_time: float = 0.0

@onready var selection_indicator: Panel = $SelectionIndicator
@onready var tab_indicator: Control = $TabIndicator
@onready var grid_container: GridContainer = $GridContainer
@onready var label: Label = $Label


func _ready():
    load_echoes()
    tab_indicator.draw.connect(_on_tab_indicator_draw)
    tab_index = 0
    select_index = 0


func _process(delta: float) -> void:
    if _holding:
        _hold_time += delta


func _on_tab_indicator_draw() -> void:
    var tab_amount = tab_echoes.size()
    var center_pos = Vector2(tab_indicator.size.x / 2, tab_indicator.size.y / 2)
    var total_size_x: float = tab_amount * circle_radius * 2.0 + (tab_amount - 1) * circle_spacing
    var start_pos := Vector2(center_pos.x - total_size_x / 2, center_pos.y)

    tab_indicator.draw_circle(start_pos + Vector2(circle_radius * 2.0 + circle_spacing * tab_index, 0), circle_radius, tab_indicator_color)

    for i in range(tab_amount):
        var pos := start_pos + Vector2(circle_radius * 2.0 + circle_spacing * i, 0)
        tab_indicator.draw_circle(pos, circle_radius, tab_indicator_color, false, 0.7, true)


func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey:
        if event.pressed:
            var tab_echoes_amount = tab_echoes[tab_index].size()
            if not event.is_echo():
                _holding = false
                if event.keycode == KEY_A:
                    select_index = (select_index - 1 + tab_echoes_amount) % tab_echoes_amount

                if event.keycode == KEY_D:
                    select_index = (select_index + 1 + tab_echoes_amount) % tab_echoes_amount

                if event.keycode == KEY_W:
                    select_index = (select_index - 6 + tab_echoes_amount) % tab_echoes_amount

                if event.keycode == KEY_S:
                    select_index = (select_index + 6 + tab_echoes_amount) % tab_echoes_amount

                if event.keycode == KEY_Q:
                    tab_index = (tab_index - 1 + tab_echoes.size()) % tab_echoes.size()

                if event.keycode == KEY_E:
                    tab_index = (tab_index + 1 + tab_echoes.size()) % tab_echoes.size()
            else:
                _holding = true
                if _hold_time > _select_interval_time:
                    _hold_time = 0.0
                    if event.keycode == KEY_A:
                        select_index = (select_index - 1 + tab_echoes_amount) % tab_echoes_amount

                    if event.keycode == KEY_D:
                        select_index = (select_index + 1 + tab_echoes_amount) % tab_echoes_amount

        if event.is_released():
            _holding = false


func load_echoes() -> void:
    var dir = DirAccess.open("res://echoes/")
    var files = dir.get_files()
    for file in files:
        if file.ends_with(".png"):
            echoes.append(Echo.new(dir.get_current_dir(false) + "/" + file))

    var i = 0
    var curr_tab := []
    for echo in echoes:
        curr_tab.append(echo)
        i += 1
        if i >= 18:
            tab_echoes.append(curr_tab)
            curr_tab = []
            i = 0
    tab_echoes.append(curr_tab)


func populate_echoes(ind: int) -> void:
    for child in grid_container.get_children():
        child.queue_free()

    for echo in tab_echoes[ind]:
        var echo_instance = ECHO_SLOT.instantiate()
        echo_instance.custom_minimum_size.y = 120
        echo_instance.size.y = 120
        echo_instance.get_node("Anchor/Sprite").texture = echo.image
        grid_container.add_child(echo_instance)
