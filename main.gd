extends Control
class_name Main

const software_dir : String = "user://list_it_all"
var current_list_name : String = ""
func create_software_directory() -> void:
	DirAccess.make_dir_absolute(software_dir)

func save_list(name:String,data:Array) -> void:
	var file : FileAccess = FileAccess.open(software_dir + "/" + name + ".json",FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()


func load_list(name:String) -> Array:
	
	
	if name == "":
		return []
	
	var file_text : String = FileAccess.get_file_as_string(software_dir + "/" + name + ".json")
	var file_data = JSON.parse_string(file_text)
	
	if file_data == null:
		return []
	
	var data : Array = JSON.parse_string(file_text)
	if data != null:
		return data
	
	return []

func delete_list(name:String) -> void:
	DirAccess.remove_absolute(software_dir + "/" + name + ".json")
	


@export var list_item_scene : PackedScene = preload("res://item_list/list_item.tscn")

func add_list_item() -> void:
	var li : ListItem = list_item_scene.instantiate()
	$PanelContainer/AspectRatioContainer/VBoxContainer/Panel/ScrollContainer/HBoxContainer/list_items.add_child(li)
	li.set_key($PanelContainer/AspectRatioContainer/VBoxContainer/add_column/key.text)
	li.set_value($PanelContainer/AspectRatioContainer/VBoxContainer/add_column/value.text)
	li.grab_focus()

func on_new_list_button() -> void:
	$new_list.visible = true

func on_create_new_list_button() -> void:
	
	if $new_list/PanelContainer/VBoxContainer/LineEdit.text != "":
		save_list($new_list/PanelContainer/VBoxContainer/LineEdit.text,[
			[$new_list/PanelContainer/VBoxContainer/HBoxContainer/Column1.text,$new_list/PanelContainer/VBoxContainer/HBoxContainer/Column2.text]
		])
		
		#$new_list/PanelContainer/VBoxContainer/LineEdit.text = current_list_name
		$PanelContainer/AspectRatioContainer/VBoxContainer/column_info/key.text = $new_list/PanelContainer/VBoxContainer/HBoxContainer/Column1.text
		$PanelContainer/AspectRatioContainer/VBoxContainer/column_info/value.text = $new_list/PanelContainer/VBoxContainer/HBoxContainer/Column2.text
		
		$new_list.visible = false
		
		var ob : OptionButton = $PanelContainer/AspectRatioContainer/VBoxContainer/list_manager/OptionButton
		print($new_list/PanelContainer/VBoxContainer/LineEdit.text)
		ob.add_item($new_list/PanelContainer/VBoxContainer/LineEdit.text)
		ob.select(ob.item_count-1)



func on_create_new_list_clossed() -> void:
	$new_list.visible = false

func save_list_data() -> void:
	var data : Array
	data.push_back([$PanelContainer/AspectRatioContainer/VBoxContainer/column_info/key.text,$PanelContainer/AspectRatioContainer/VBoxContainer/column_info/value.text])
	
	for c in $PanelContainer/AspectRatioContainer/VBoxContainer/Panel/ScrollContainer/HBoxContainer/list_items.get_children():
		if c is ListItem:
			var li : ListItem = c
			data.push_back([c.get_id(),c.get_key(),c.get_value()])
	
	
	save_list(current_list_name,data)

func load_list_data(name : String) -> void:
	var data : Array = load_list(name)
	
	if data.size() == 0:
		return
	
	$PanelContainer/AspectRatioContainer/VBoxContainer/column_info/key.text = data[0][0]
	$PanelContainer/AspectRatioContainer/VBoxContainer/column_info/value.text = data[0][1]
	
	for c in $PanelContainer/AspectRatioContainer/VBoxContainer/Panel/ScrollContainer/HBoxContainer/list_items.get_children():
		c.queue_free()
	
	for i in range(1,data.size()):
		var li : ListItem = list_item_scene.instantiate()
		$PanelContainer/AspectRatioContainer/VBoxContainer/Panel/ScrollContainer/HBoxContainer/list_items.add_child(li)
		li.set_id(data[i][0])
		li.set_key(data[i][1])
		li.set_value(data[i][2])
		li.grab_focus()
	
	current_list_name = name
	

func reload_list_data() -> void:
	load_list_data(current_list_name)

func on_file_selected(idx : int) -> void:
	
	save_list_data()
	
	load_list_data($PanelContainer/AspectRatioContainer/VBoxContainer/list_manager/OptionButton.get_item_text(idx))
	call_deferred("reload_list_data")
	

func on_rename_clicked() -> void:
	$rename_list_to.visible = true

func on_rename_clicked_confirmed() -> void:
	
	var ob : OptionButton = $PanelContainer/AspectRatioContainer/VBoxContainer/list_manager/OptionButton
	var new_name : String = $rename_list_to/PanelContainer/VBoxContainer/LineEdit.text
	
	save_list(new_name,load_list(current_list_name))
	ob.get_selected_id()
	ob.set_item_text(ob.get_selected_id(),new_name)
	
	delete_list(current_list_name)
	
	current_list_name = new_name
	$rename_list_to.visible = false

func on_delete_list_pressed() -> void:
	$delete_list.visible = true

func on_dont_delete_list() -> void:
	$delete_list.visible = false

func on_delete_list_confirmed() -> void:
	var ob : OptionButton = $PanelContainer/AspectRatioContainer/VBoxContainer/list_manager/OptionButton
	
	delete_list(current_list_name)
	
	var selected_id : int = ob.get_selected_id()
	
	ob.select(0)
	
	load_list_data($PanelContainer/AspectRatioContainer/VBoxContainer/list_manager/OptionButton.get_item_text(0))
	call_deferred("reload_list_data")
	
	ob.remove_item(selected_id)
	
	$delete_list.visible = false

func _ready() -> void:
	
	#connections
	
	$PanelContainer/AspectRatioContainer/VBoxContainer/add_column/add.pressed.connect(add_list_item)
	
	$PanelContainer/AspectRatioContainer/VBoxContainer/list_manager/add.pressed.connect(on_new_list_button)
	$new_list/PanelContainer/VBoxContainer/create.pressed.connect(on_create_new_list_button)
	$new_list.close_requested.connect(on_create_new_list_clossed)
	
	$PanelContainer/AspectRatioContainer/VBoxContainer/HBoxContainer/save.pressed.connect(save_list_data)
	
	$PanelContainer/AspectRatioContainer/VBoxContainer/HBoxContainer/reload.pressed.connect(reload_list_data)
	
	$PanelContainer/AspectRatioContainer/VBoxContainer/list_manager/OptionButton.item_selected.connect(on_file_selected)
	
	$PanelContainer/AspectRatioContainer/VBoxContainer/list_manager/rename.pressed.connect(on_rename_clicked)
	
	$rename_list_to/PanelContainer/VBoxContainer/rename.pressed.connect(on_rename_clicked_confirmed)
	
	$PanelContainer/AspectRatioContainer/VBoxContainer/list_manager/remove.pressed.connect(on_delete_list_pressed)
	
	$delete_list/PanelContainer/VBoxContainer/HBoxContainer/yes.pressed.connect(on_delete_list_confirmed)
	
	$delete_list/PanelContainer/VBoxContainer/HBoxContainer/no.pressed.connect(on_dont_delete_list)
	$delete_list.close_requested.connect(on_dont_delete_list)
	
	#directory manager
	
	create_software_directory()
	var dir : DirAccess = DirAccess.open(software_dir)
	for f in dir.get_files():
		var file_name : PackedStringArray = f.split(".")
		
		if file_name[1] == "json":
			$PanelContainer/AspectRatioContainer/VBoxContainer/list_manager/OptionButton.add_item(file_name[0])
	
	on_file_selected(0)
