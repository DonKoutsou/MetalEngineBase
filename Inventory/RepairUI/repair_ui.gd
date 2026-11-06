extends Control

class_name RepairUI

@export var RepairPriceLabel : Label
@export var CurrentHullLabel : Label

@export var ConditionBar : ProgressBar
@export var ConditionPartBar : ProgressBar
@export var ConditionLabel : Label

@export var HullBar : ProgressBar
@export var PartBar : ProgressBar
@export var ReprairTimeLabel : Label

@export var PlayerWallet : Wallet

@export var partUIScene : PackedScene
var RepairPricePerUnit : float
var hasRepair : bool = false
var PlMaxCondition : float = 0
var PlCondition : float = 0
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
	
	var repairParts = CurrentShip.Repair_Parts
	var overallParts = CurrentShip.GetRepairParts()
	SetHullData(Ship)
	CurrentHullLabel.text = "{0}/{1}".format([roundi(PlHull + repairParts), roundi(PlMaxHull)])
	ConditionLabel.text = "{0}/{1}".format([roundi(PlCondition + overallParts), roundi(PlMaxCondition)])
	
	ConditionBar.max_value = PlMaxCondition
	ConditionPartBar.max_value = PlMaxCondition
	ConditionBar.set_value_no_signal(PlCondition)
	ConditionPartBar.set_value_no_signal(PlCondition + overallParts)
	
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
		$MarginContainer/VBoxContainer/PanelContainer/ScrollContainer/VBoxContainer2.add_child(sc)

func SetHullData(Ship : Captain):
	PlMaxCondition = Ship.GetStatFinalValue(STAT_CONST.STATS.HULL)
	PlMaxHull = Ship.GetStatBaseValue(STAT_CONST.STATS.HULL)
	PlHull = Ship._GetStat(STAT_CONST.STATS.HULL).CurrentValue
	PlCondition = Ship.GetStatCurrentValue(STAT_CONST.STATS.HULL)

func UpdatePartUI() -> void:
	for g in partUIS:
		g.Update()

func UpdatePartRepairBar(AddedRepair : int, Part : ShipPart):
	var partDamage = Part.GetPartMaxCondition() - Part.GetPartCondition()
	
	var added : float = 0
	
	if (AddedRepair > 0):
		added = min(partDamage - Part.Repair_Parts, min(AddedRepair, PlayerWallet.Funds / RepairPricePerUnit))
		Part.Repair_Parts += added
	else:
		added = -min(Part.Repair_Parts, abs(AddedRepair))
		Part.Repair_Parts += added
	
	if (added == 0):
		return
	
	var MoneySpent = added * RepairPricePerUnit
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
	var currentParts = CurrentShip.Repair_Parts
	var overallParts = CurrentShip.GetRepairParts()
	
	PartBar.value = PlHull + currentParts
	ConditionPartBar.value = PlCondition + overallParts
	#FundAmm.text = var_to_str(roundi(PlFunds)) + " ₯"
	CurrentHullLabel.text = "{0}/{1}".format([roundi(PlHull + currentParts), roundi(PlMaxHull)])
	ConditionLabel.text = "{0}/{1}".format([roundi(PlCondition + overallParts), roundi(PlMaxCondition)])
	
	var TimeMulti = 0.025
		
	if (hasRepair):
		TimeMulti = 0.10
		
	var t = currentParts / TimeMulti / 6
	
	ReprairTimeLabel.text = Clock.MinutesToHours(t, true)

func UpdateRepairBar(AddedRepair : int):
	#$AudioStreamPlayer.play()
	var currentParts = CurrentShip.Repair_Parts

	var added : float = 0
	var damage = PlMaxHull - PlHull
	
	
	if (AddedRepair > 0):
		added = min(damage - currentParts, min(AddedRepair, PlayerWallet.Funds / RepairPricePerUnit))
		CurrentShip.Repair_Parts += added
	else:
		added = -min(currentParts, abs(AddedRepair))
		CurrentShip.Repair_Parts += added
	
	if (added == 0):
		return

	var MoneySpent = added * RepairPricePerUnit
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
	currentParts = CurrentShip.Repair_Parts
	
	PartBar.value = PlHull + currentParts
	ConditionPartBar.value = PlCondition + CurrentShip.GetRepairParts()
	#FundAmm.text = var_to_str(roundi(PlFunds)) + " ₯"
	CurrentHullLabel.text = "{0}/{1}".format([roundi(PlHull + currentParts), roundi(PlMaxHull)])
	
	var TimeMulti = 0.025
		
	if (hasRepair):
		TimeMulti = 0.10
		
	var t = currentParts / TimeMulti / 6
	
	ReprairTimeLabel.text = Clock.MinutesToHours(t, true)
	UpdatePartUI()

var accumulated : float = 0
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
		
		UpdateRepairBar(AddedRepair)


func _on_increase_pressed() -> void:
	UpdateRepairBar(1)


func _on_reduce_pressed() -> void:
	UpdateRepairBar(-1)


func _on_reset_pressed() -> void:
	UpdateRepairBar(-9999999999)


func _on_max_pressed() -> void:
	UpdateRepairBar(9999999999)

func AddToAll(i : bool) -> void:
	for g in CurrentShip.GetCharacterInventory().GetDagamedShipParts():
		if (i):
			var damage = g.GetPartMaxCondition() - g.GetPartCondition()
			var neededParts = damage - g.Repair_Parts
			var addedParts = min(neededParts, PlayerWallet.Funds / RepairPricePerUnit)
			g.Repair_Parts += addedParts
			PlayerWallet.AddFunds(-addedParts * RepairPricePerUnit)
		else:
			var removedParts = g.Repair_Parts
			g.Repair_Parts -= removedParts
			PlayerWallet.AddFunds(removedParts * RepairPricePerUnit)
	
	if (i):
		var damage = PlMaxHull - PlHull
		var neededParts = damage - CurrentShip.Repair_Parts
		var addedParts = min(neededParts, PlayerWallet.Funds / RepairPricePerUnit)
		CurrentShip.Repair_Parts += addedParts
		PlayerWallet.AddFunds(-addedParts * RepairPricePerUnit)
	else:
		var removedParts = CurrentShip.Repair_Parts
		CurrentShip.Repair_Parts -= removedParts
		PlayerWallet.AddFunds(removedParts * RepairPricePerUnit)
	
	var currentParts = CurrentShip.Repair_Parts
	
	PartBar.value = PlHull + currentParts
	ConditionPartBar.value = PlCondition + CurrentShip.GetRepairParts()
	#FundAmm.text = var_to_str(roundi(PlFunds)) + " ₯"
	CurrentHullLabel.text = "{0}/{1}".format([roundi(PlHull + currentParts), roundi(PlMaxHull)])
	
	var TimeMulti = 0.025
		
	if (hasRepair):
		TimeMulti = 0.10
		
	var t = currentParts / TimeMulti / 6
	
	ReprairTimeLabel.text = Clock.MinutesToHours(t, true)
	UpdatePartUI()
			

func _on_max_all_pressed() -> void:
	AddToAll(true)

func _on_reset_all_pressed() -> void:
	AddToAll(false)
