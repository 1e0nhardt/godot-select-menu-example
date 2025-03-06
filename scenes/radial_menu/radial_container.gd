@tool
extends Container

@export var radius: float = 250


func _ready() -> void:
    sort_children.connect(_on_sort_children)


func _on_sort_children() -> void:
    var children = get_children()
    var angle_delta = TAU / children.size()

    for i in range(children.size()):
        var child = children[i]
        # 调整Slot大小
        child.custom_minimum_size.y = 124
        child.size.y = 124

        child.position = Vector2(radius * cos(i * angle_delta), radius * sin(i * angle_delta)) - child.size / 2