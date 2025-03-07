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

        spiral_container.current_index = index
        var target_child = spiral_container.get_child(index)
        # 一定要先将旋转还原回零
        selection_indicator.rotation = 0
        selection_indicator.scale = Vector2.ONE
        selection_indicator.global_position = spiral_container.get_child_position(index) - Vector2(4, 4)
        # selection_indicator.global_position = target_child.global_position - Vector2(4, 4)
        selection_indicator.rotation = target_child.rotation
        selection_indicator.scale = target_child.scale
        label.text = echoes[index].name

        accumulated_angle = index * TAU / spiral_container.base_amount
        direction_indicator.rotation = accumulated_angle
        joystick_direction = Vector2.from_angle(accumulated_angle)

var joystick_direction := Vector2.ZERO
var new_direction = Vector2.ZERO
var accumulated_angle := 0.0

var _select_interval_time: float = 0.1
var _holding: bool = false
var _hold_time: float = 0.0

@onready var selection_indicator: Panel = $SelectionIndicator
@onready var direction_indicator: Control = $DirectionIndicator
@onready var spiral_container: Container = $SpiralContainer
@onready var label: Label = $Label


func _ready():
    load_echoes()
    populate_echoes()
    # await spiral_container.sort_children
    # index = 0
    var c = func(): index = 0
    var d = func(): c.call_deferred()
    d.call_deferred()


func _process(delta: float) -> void:
    if _holding:
        _hold_time += delta


func _unhandled_input(event: InputEvent) -> void:
    # if event is InputEventJoypadButton and event.is_pressed():
    #     Logger.info("ButtonEvent: %s" % event)
    if event is InputEventJoypadMotion:
        # Logger.info("MotionEvent: %s" % event)
        if event.axis == 0:
            new_direction.x = event.axis_value
        if event.axis == 1:
            # Down:1, Up: -1
            new_direction.y = event.axis_value

        if new_direction.length() > 0.8:
            var angle_delta = - new_direction.angle_to(joystick_direction)
            accumulated_angle += angle_delta
            joystick_direction = new_direction

            index = (floori((accumulated_angle + TAU / spiral_container.base_amount / 4.0) / (TAU / spiral_container.base_amount)) + echoes.size()) % echoes.size()

            direction_indicator.rotation = accumulated_angle


    if event is InputEventKey:
        if event.pressed:
            if not event.is_echo():
                _holding = false
                if event.keycode == KEY_A:
                    index = (index - 1 + echoes.size()) % echoes.size()

                if event.keycode == KEY_D:
                    index = (index + 1 + echoes.size()) % echoes.size()
            else:
                _holding = true
                if _hold_time > _select_interval_time:
                    _hold_time = 0.0
                    if event.keycode == KEY_A:
                        index = (index - 1 + echoes.size()) % echoes.size()

                    if event.keycode == KEY_D:
                        index = (index + 1 + echoes.size()) % echoes.size()

        if event.is_released():
            _holding = false


func load_echoes() -> void:
    var dir = DirAccess.open("res://echoes/")
    var files = dir.get_files()
    for file in files:
        if file.ends_with(".png"):
            echoes.append(Echo.new(dir.get_current_dir(false) + "/" + file))


func populate_echoes() -> void:
    for child in spiral_container.get_children():
        child.queue_free()

    for echo in echoes:
        var echo_instance = ECHO_SLOT.instantiate()
        echo_instance.get_node("Anchor/Sprite").texture = echo.image
        spiral_container.add_child(echo_instance)
