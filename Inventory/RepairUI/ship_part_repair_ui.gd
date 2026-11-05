extends Control

class_name ShipPartRepairUI

@export var CurrentHullLabel : Label
@export var HullBar : ProgressBar
@export var PartBar : ProgressBar
@export var PartName : Label

signal RepairRequest(amm : float)

var part : ShipPart

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
		var rel = event.relative
		var AddedRepair = roundi(((rel.x / 6) * (HullBar.max_value / 60)))
		RepairRequest.emit(AddedRepair)
		Update()
		#UpdateRepairBar(AddedRepair)


func _on_reduce_pressed() -> void:
	RepairRequest.emit(-1)
	Update()


func _on_increase_pressed() -> void:
	RepairRequest.emit(1)
	Update()
