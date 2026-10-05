extends PanelContainer


class_name ResourcePicker

@export var resource_Type : FileDialog.FileMode = FileDialog.FileMode.FILE_MODE_OPEN_FILE
@export var resource_Tyoes : PackedStringArray
@export var locationText : LineEdit
@export var allowExternalLinks : bool

var selected : String = ""

signal Changed(t : String)

func SetFile(t : String) -> void:
	selected = t
	locationText.text = t

func _on_change_pressed() -> void:
	var fileDiag : FileDialog = FileDialog.new()
	fileDiag.file_mode = resource_Type
	fileDiag.filters = resource_Tyoes
	fileDiag.use_native_dialog = true
	fileDiag.access = FileDialog.ACCESS_FILESYSTEM
	fileDiag.current_path = selected
	add_child(fileDiag)
	fileDiag.popup_centered()
	var f : String
	if (resource_Type == FileDialog.FileMode.FILE_MODE_OPEN_FILE):
		f = await fileDiag.file_selected
		if (!FileAccess.file_exists(f)):
			return
	
	if (resource_Type == FileDialog.FileMode.FILE_MODE_SAVE_FILE):
		f = await fileDiag.file_selected
			
	else: if (resource_Type == FileDialog.FileMode.FILE_MODE_OPEN_DIR):
		f = await fileDiag.dir_selected
		if (!DirAccess.dir_exists_absolute(f)):
			return
	
	if (!allowExternalLinks and ProjectSettings.has_setting("application/config/mod_dir")):
		var modDir : String = ProjectSettings.get_setting("application/config/mod_dir")
		if (!modDir.is_empty()):
			#check if file is withing our mod
			if (f.contains(modDir)):
				#change the dir to res
				f = f.replace(modDir, "res:/")
			else:
				#we need to move the file inside the mod
				var importedLoc = modDir + "/ImportedAssets/" + f.get_file()
				_copy_file(f,importedLoc)
				f = importedLoc.replace(modDir, "res:/")
			
	SetFile(f)
	Changed.emit(f)

func _copy_file(source: String, destination: String) -> void:
	var parent := destination.get_base_dir()

	DirAccess.make_dir_recursive_absolute(parent)

	var data := FileAccess.get_file_as_bytes(source)

	var file := FileAccess.open(
		destination,
		FileAccess.WRITE
	)

	if file == null:
		print("Failed to create: " + destination)
		return

	var result = file.store_buffer(data)
	if (!result):
		print("File copying had errors")
		
	file.close()

func _on_line_edit_text_changed(new_text: String) -> void:
	locationText.text = selected
