extends HBoxContainer
class_name ListItem

func get_id() -> int:
	return get_index()
	
func set_id(id : int) -> void:
	
	if id < 0:
		$id.text = str(0)
		get_parent().move_child(self,0)
	
	if id >= 0:
		$id.text = str(id)
		get_parent().move_child(self,id)
	else:
		return
	
	var last_brother_id : int = get_parent().get_child_count()-1
	if id > last_brother_id:
		$id.text = str(id)
		get_parent().move_child(self,last_brother_id)
	
	

func reset_id_display() -> void:
	set_id(get_id())

func reset_id_display_all_brothers() -> void:
	for b in get_parent().get_children():
		if b is ListItem:
			b.reset_id_display()

func get_key() -> String:
	return $key.text

func set_key(key : String) -> void:
	$key.text = key

func get_value() -> String:
	return $value.text

func set_value(value : String) -> void:
	$value.text = value

func move_up() -> void:
	set_id(get_id()-1)
	

func move_down() -> void:
	set_id(get_id()+1)
	

func _ready() -> void:
	
	
	var on_id_submitted = func (text : String) -> void:
		set_id(text.to_int())
	$id.text_submitted.connect(on_id_submitted)
	
	$VBoxContainer/up.pressed.connect(move_up)
	$VBoxContainer/down.pressed.connect(move_down)
	
	$remove.pressed.connect(queue_free)
	
	reset_id_display()
