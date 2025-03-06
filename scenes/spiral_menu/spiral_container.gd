@tool
extends Container

@export var radius: float = 300
@export var base_amount: int = 16
@export var visible_amount: int = 24

var children_positions := []
var current_index: int:
    set(value):
        current_index = value
        @warning_ignore("INTEGER_DIVISION")
        var visible_index_start = clamp(current_index - visible_amount / 2, 0, get_child_count() - 1)
        var visible_index_end = clamp(visible_index_start + visible_amount - 1, 0, get_child_count() - 1)
        if visible_index_end - visible_index_start < visible_amount - 1:
            visible_index_start = clamp(visible_index_end - visible_amount + 1, 0, get_child_count() - 1)
        # Logger.info("%s: %s -> %s" % [value, visible_index_start, visible_index_end])

        @warning_ignore("INTEGER_DIVISION")
        var center_index = visible_index_start + visible_amount / 2

        children_positions.resize(get_child_count())
        var angle_delta = TAU / base_amount
        for i in range(get_child_count()):
            var child = get_child(i)
            if i >= visible_index_start and i <= visible_index_end:
                child.show()
                var scale_factor = float(i - center_index) / base_amount * 0.5 + 1.0
                var new_pos = Vector2(radius * scale_factor * cos(i * angle_delta), radius * scale_factor * sin(i * angle_delta)) - child.size / 2.0
                child.position = new_pos
                children_positions[i] = new_pos
                child.scale = Vector2.ONE * scale_factor
                child.modulate.a = 1.0 - abs(float(i - current_index) / base_amount * 0.8)
            else:
                child.hide()


func _init() -> void:
    sort_children.connect(_on_sort_children)


func get_child_position(ind: int) -> Vector2:
    if children_positions.size() <= ind:
        return Vector2.ZERO
    return children_positions[ind] + global_position


func _on_sort_children() -> void:
    var children = get_children()
    var angle_delta = TAU / base_amount

    for i in range(children.size()):
        var child = children[i]
        # 调整Slot大小
        child.custom_minimum_size.y = 124
        child.size.y = 124

        child.pivot_offset = child.size / 2.0
        child.rotation = i * angle_delta # + PI / 2.0

        var sprite = child.get_node("Anchor/Sprite")
        sprite.pivot_offset = sprite.size / 2.0
        sprite.rotation = - child.rotation
