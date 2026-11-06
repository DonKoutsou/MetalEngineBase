extends Control

class_name ShipPartRepairUI

@export var CurrentHullLabel : Label
@export var HullBar : ProgressBar
@export var PartBar : ProgressBar
@export var PartName : Label

signal RepairRequest(amm : int)

var part : ShipPart

var accumulated : float = 0

func SetStats(p : ShipPart) -> void:
	PartName.text = p.GetItemName()
	part = p
	HullBar.max_value = p.GetPartMaxCondition()
	PartBar.max_value = p.GetPartMaxCondition()
	HullBar.value = p.GetPartCondition()
	PartBar.value = p.GetPartCondition() + p.Repair_Parts
	CurrentHullLabel.text = "{0}/{1}".format([roundi(p.GetPartCondition() + part.Repair_Parts), roundi(p.GetPartMaxCondition())])

func Update() -> void:
	HullBar.value = part.GetPartCondition()
	PartBar.value = part.GetPartCondition() + part.Repair_Parts
	CurrentHullLabel.text = "{0}/{1}".format([roundi(part.GetPartCondition() + part.Repair_Parts), roundi(part.GetPartMaxCondition())])

func RepairBar_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseMotion and Input.is_action_pressed("Click") or event is InputEventScreenDrag):
		var bar_width = HullBar.size.x
		var max_value = HullBar.max_value

		var progress_per_pixel = max_value / bar_width
		
		accumulated += event.relative.x * progress_per_pixel
		
		if (accumulated < 1 and accumulated  > -1):
			return
		
		var AddedRepair = roundi(accumulated)
		accumulated -= AddedRepair

		RepairRequest.emit(AddedRepair)
		Update()
		#UpdateRepairBar(AddedRepair)


func _on_reduce_pressed() -> void:
	RepairRequest.emit(-1)
	Update()


func _on_increase_pressed() -> void:
	RepairRequest.emit(1)
	Update()


func _on_max_pressed() -> void:
	RepairRequest.emit(99999999)
	Update()


func _on_reset_pressed() -> void:
	RepairRequest.emit(-99999999)
	Update()
