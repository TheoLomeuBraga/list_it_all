extends Control
class_name Main

@export var list_item_scene : PackedScene = preload("res://item_list/list_item.tscn")

func add_list_item() -> void:
	var li : ListItem = list_item_scene.instantiate()
	$PanelContainer/AspectRatioContainer/VBoxContainer/Panel/ScrollContainer/HBoxContainer/list_items.add_child(li)
	li.set_key($PanelContainer/AspectRatioContainer/VBoxContainer/add_column/key.text)
	li.set_value($PanelContainer/AspectRatioContainer/VBoxContainer/add_column/value.text)
	li.grab_focus()

func _ready() -> void:
	$PanelContainer/AspectRatioContainer/VBoxContainer/add_column/add.pressed.connect(add_list_item)
