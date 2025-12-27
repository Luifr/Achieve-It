extends Control

@export var resolution_option_button: OptionButton
@export var screen_mode_option_button: OptionButton
@export var volume_h_slider: HSlider
@export var mute_check_box: CheckBox

func _ready() -> void:
	set_default_resolution()
	set_default_window_mode()
	set_default_volume()

# Get the current resolution and set the selected item to match it
func set_default_resolution() -> void:
	var current_size := DisplayServer.window_get_size()
	var current_size_text: String = "%dx%d" % [current_size.x, current_size.y]
	print(current_size_text)

	for i: int in range(resolution_option_button.get_item_count()):
		var item_text := resolution_option_button.get_item_text(i)
		
		if item_text == current_size_text:
			resolution_option_button.select(i)

func set_default_window_mode() -> void:
	var window_mode := DisplayServer.window_get_mode()
	
	match window_mode:
		DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			screen_mode_option_button.select(0)
		DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN:
			screen_mode_option_button.select(1)
		DisplayServer.WindowMode.WINDOW_MODE_MAXIMIZED:
			screen_mode_option_button.select(2)
		DisplayServer.WindowMode.WINDOW_MODE_WINDOWED:
			screen_mode_option_button.select(3)

func set_default_volume() -> void:
	volume_h_slider.value = AudioServer.get_bus_volume_linear(0)
	mute_check_box.button_pressed = volume_h_slider.value == 0

func _on_resolution_option_button_item_selected(index: int) -> void:
	var resolution_text := resolution_option_button.get_item_text(index)
	var resolution := resolution_text.split("x")
	var resolution_vector_2 := Vector2i(int(resolution[0]), int(resolution[1]))
	GameConfigManager.save_config("Video", "resolution", resolution_vector_2)
	DisplayServer.window_set_size(resolution_vector_2)

func _on_screen_mode_option_button_item_selected(index: int) -> void:
	var window_mode: DisplayServer.WindowMode
	match index:
		0:
			window_mode = DisplayServer.WindowMode.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
		1:
			window_mode = DisplayServer.WindowMode.WINDOW_MODE_FULLSCREEN
		2:
			window_mode = DisplayServer.WindowMode.WINDOW_MODE_MAXIMIZED
		3:
			window_mode = DisplayServer.WindowMode.WINDOW_MODE_WINDOWED
	
	GameConfigManager.save_config("Video", "window_mode", window_mode)
	DisplayServer.window_set_mode(window_mode)

func _on_back_button_pressed() -> void:
	var MAIN_MENU := load("uid://co5e4q0jguxgk")
	get_tree().change_scene_to_packed(MAIN_MENU)

func _on_volume_h_slider_value_changed(value: float) -> void:
	if value == 0:
		mute_check_box.button_pressed = true
	elif value > 0:
		mute_check_box.button_pressed = false
	AudioServer.set_bus_volume_linear(0, value)

func _on_mute_check_box_toggled(toggled_on: bool) -> void:
	if toggled_on:
		volume_h_slider.value = 0
	AudioServer.set_bus_mute(0, toggled_on)


func _on_volume_h_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		GameConfigManager.save_config("Audio", "volume", volume_h_slider.value)
