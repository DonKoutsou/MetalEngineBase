extends Control

class_name RepairUI

@export var RepairPriceLabel : Label
@export var CurrentHullLabel : Label
@export var HullBar : ProgressBar
@export var PartBar : ProgressBar
@export var ReprairTimeLabel : Label

@export var PlayerWallet : Wallet

@export var partUIScene : PackedScene
var RepairPricePerUnit : float
var hasRepair : bool = false
var PlHull : float = 0
var PlMaxHull : float = 0
var CurrentShip : Captain

var SpentFunds : float

var partUIS : Array[ShipPartRepairUI]

func SetStats(Ship : Captain) -> void:
	for g in partUIS:
		g.queue_free()
	partUIS.clear()
	
	CurrentShip = Ship
	RepairPricePerUnit = Ship.GetStatFinalValue(STAT_CONST.STATS.REPAIR_PRICE)
	if (hasRepair):
		RepairPricePerUnit /= 2
	
	var repairParts = CurrentShip.GetRepairParts()
	SetHullData(Ship)
	CurrentHullLabel.text = "{0}/{1}".format([roundi(PlHull + repairParts), roundi(PlMaxHull)])
	HullBar.max_value = PlMaxHull
	PartBar.max_value = PlMaxHull
	HullBar.set_value_no_signal(PlHull)
	PartBar.set_value_no_signal(PlHull + repairParts)
	RepairPriceLabel.text = var_to_str(RepairPricePerUnit).replace(".0", "")
	
	var TimeMulti = 0.025
		
	if (hasRepair):
		TimeMulti = 0.10
		
	var t = repairParts/ TimeMulti / 6
	
	ReprairTimeLabel.text = Clock.MinutesToHours(t, true)
	
	var parts = Ship.GetCharacterInventory().GetDagamedShipParts()
	for g in parts:
		var sc : ShipPartRepairUI = partUIScene.instantiate()
		sc.SetStats(g)
		sc.RepairRequest.connect(UpdatePartRepairBar.bind(g))
		partUIS.append(sc)
		$MarginContainer/ScrollContainer/VBoxContainer2.add_child(sc)

func SetHullData(Ship : Captain):
	PlMaxHull = Ship.GetStatFinalValue(STAT_CONST.STATS.HULL)
	PlHull = Ship.GetStatCurrentValue(STAT_CONST.STATS.HULL)

func UpdatePartUI() -> void:
	for g in partUIS:
		g.Update()

func UpdatePartRepairBar(AddedRepair : float, Part : ShipPart):
	#$AudioStreamPlayer.play()
	var currentParts = Part.Repair_Parts
	
	var partDamage = Part.GetPartMaxCondition() - Part.GetPartCondition()
	
	if (AddedRepair * RepairPricePerUnit > PlayerWallet.Funds):
		AddedRepair = PlayerWallet.Funds / RepairPricePerUnit
	
	if (AddedRepair > 0):
		AddedRepair = min(partDamage - Part.Repair_Parts, AddedRepair)
		Part.Repair_Parts += AddedRepair
	else:
		AddedRepair = -min(Part.Repair_Parts, abs(AddedRepair))
		Part.Repair_Parts += AddedRepair
	
	if (AddedRepair == 0):
		return
	
	var MoneySpent = AddedRepair * RepairPricePerUnit
	if (MoneySpent > 0):
		SpentFunds += MoneySpent
		if (roundi(SpentFunds/1000) > 1):
			Map.GetInstance().GetScreenUi().TownUi.DropCoins(roundi(SpentFunds / 1000))
			SpentFunds = 0
	else:
		SpentFunds += MoneySpent
		var z = roundi(SpentFunds/1000)
		if (z < -1):
			Map.GetInstance().GetScreenUi().TownUi.CoinsReceived(abs(z))
			SpentFunds = 0
			
	if (MoneySpent > 0):
		AchievementManager.GetInstance().IncrementStatFloat("REPAM", MoneySpent)
	
	PlayerWallet.AddFunds(-MoneySpent)
	#PlayerWallet.AddFunds(-(AddedRepair * RepairpricePerRepairValue))
	currentParts = CurrentShip.GetRepairParts()
	
	PartBar.value = PlHull + currentParts
	#FundAmm.text = var_to_str(roundi(PlFunds)) + " ₯"
	CurrentHullLabel.text = "{0}/{1}".format([roundi(PlHull + currentParts), roundi(PlMaxHull)])
	
	var TimeMulti = 0.025
		
	if (hasRepair):
		TimeMulti = 0.10
		
	var t = currentParts / TimeMulti / 6
	
	ReprairTimeLabel.text = Clock.MinutesToHours(t, true)

func UpdateRepairBar(AddedRepair : float):
	#$AudioStreamPlayer.play()
	var currentParts = CurrentShip.GetRepairParts()
	if (AddedRepair * RepairPricePerUnit > PlayerWallet.Funds):
		AddedRepair = PlayerWallet.Funds / RepairPricePerUnit
	var NewPlRepair = PlHull + currentParts + AddedRepair
	
	if (NewPlRepair < PlHull):
		AddedRepair = 0
		NewPlRepair = PlHull + currentParts

	if (NewPlRepair > PlMaxHull):
		AddedRepair = PlMaxHull - (PlHull + currentParts)
		NewPlRepair = PlMaxHull
	
	if (AddedRepair > 0):
		CurrentShip.AddRepairParts(AddedRepair)
	else:
		CurrentShip.RemoveRepairParts(-AddedRepair)
	
	var MoneySpent = AddedRepair * RepairPricePerUnit
	if (MoneySpent > 0):
		SpentFunds += MoneySpent
		if (roundi(SpentFunds/1000) > 1):
			Map.GetInstance().GetScreenUi().TownUi.DropCoins(roundi(SpentFunds / 1000))
			SpentFunds = 0
	else:
		SpentFunds += MoneySpent
		var z = roundi(SpentFunds/1000)
		if (z < -1):
			Map.GetInstance().GetScreenUi().TownUi.CoinsReceived(abs(z))
			SpentFunds = 0
			
	if (MoneySpent > 0):
		AchievementManager.GetInstance().IncrementStatFloat("REPAM", MoneySpent)
	
	PlayerWallet.AddFunds(-MoneySpent)
	#PlayerWallet.AddFunds(-(AddedRepair * RepairpricePerRepairValue))
	currentParts = CurrentShip.GetRepairParts()
	
	PartBar.value = PlHull + currentParts
	#FundAmm.text = var_to_str(roundi(PlFunds)) + " ₯"
	CurrentHullLabel.text = "{0}/{1}".format([roundi(PlHull + currentParts), roundi(PlMaxHull)])
	
	var TimeMulti = 0.025
		
	if (hasRepair):
		TimeMulti = 0.10
		
	var t = currentParts / TimeMulti / 6
	
	ReprairTimeLabel.text = Clock.MinutesToHours(t, true)
	UpdatePartUI()

func RepairBar_gui_input(event: InputEvent) -> void:
	if (event is InputEventMouseMotion and Input.is_action_pressed("Click") or event is InputEventScreenDrag):
		var rel = event.relative
		var AddedRepair = roundi(((rel.x / 6) * (HullBar.max_value / 100)))
		UpdateRepairBar(AddedRepair)


func _on_increase_pressed() -> void:
	UpdateRepairBar(1)


func _on_reduce_pressed() -> void:
	UpdateRepairBar(-1)
