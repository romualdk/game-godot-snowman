extends Control

func _ready():
	pass

func _on_Exit_gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		get_tree().quit()


func _on_Music_toggled(button_pressed):
	var bg_music = get_node("/root/BackgroundMusic")
	
	if button_pressed == true:
		bg_music.turnOff()
	elif button_pressed == false:
		bg_music.turnOn()
