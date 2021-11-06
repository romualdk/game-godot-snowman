extends Control

onready var bg_music = get_node("/root/BgMusic")
onready var btn_music = get_node("HBoxContainer/Music")

func setMusic(on):
	btn_music.pressed = !on
	bg_music.turn(on)

func _on_Exit_gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		get_tree().quit()

func _on_Music_toggled(button_pressed):
	bg_music.turn(!button_pressed)
