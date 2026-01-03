extends Panel

const SAVE_SLOT = preload("uid://bevkundhur8ab")

@export var save_slots_v_box: VBoxContainer
@export var create_save_profile_modal: PanelContainer
@export var profile_name_input: LineEdit
@export var profile_form_error_label: Label
@export var create_new_save_button: Button

func _ready() -> void:
	setup_save_slots()
	create_save_profile_modal.hide()
	profile_form_error_label.text = ""

func setup_save_slots() -> void:
	var saves: Array[Dictionary] = SaveDataManager.load_all_saves()
	for save in saves:
		var save_slot: SaveSlot = SAVE_SLOT.instantiate()
		save_slot.loaded_data = SaveData.new(save, save.get("file_index"))
		save_slots_v_box.add_child(save_slot)
		save_slots_v_box.move_child(create_new_save_button, -1)

func _on_cancel_button_pressed() -> void:
	create_save_profile_modal.hide()
	profile_form_error_label.text = ""

func _on_create_new_save_button_pressed() -> void:
	create_save_profile_modal.show()
	profile_name_input.grab_focus()

func _on_back_button_pressed() -> void:
	hide()

func _on_confirm_button_pressed() -> void:
	create_new_save()

func _on_profile_name_input_text_submitted(_new_text: String) -> void:
	create_new_save()

func create_new_save() -> void:
	var profile_name := profile_name_input.text
	
	if !profile_name or profile_name.length() == 0 or profile_name.strip_edges().length( ) == 0:
		profile_form_error_label.text = "Please enter a profile name"
		return
	
	profile_name_input.text = ""
	profile_form_error_label.text = ""
	
	SaveDataManager.create_new_save(profile_name.strip_edges())

	var save_slot: SaveSlot = SAVE_SLOT.instantiate()
	save_slot.loaded_data = SaveDataManager.loaded_data
	
	save_slots_v_box.add_child(save_slot)
	
	create_save_profile_modal.hide()
	save_slots_v_box.move_child(create_new_save_button, -1)
