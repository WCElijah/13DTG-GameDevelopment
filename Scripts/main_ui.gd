extends Control


func create_keybind_label(message):
	var new_keybind = Label.new()
	$Keybinds.add_child(new_keybind)
	new_keybind.text = message


func show_keybind_label(message):
	if not $Keybinds.get_children():
		create_keybind_label(message)
	for label in $Keybinds.get_children():
		if label.text == message:
			label.visible = true


func hide_keybind_label(message):
	for label in $Keybinds.get_children():
		if label.text == message:
			label.visible = false
