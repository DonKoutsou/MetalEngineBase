@tool
extends Item
class_name ShipPart

@export_group("Upgrade")
@export var Upgrades : Array[ShipPartUpgrade]
@export var UpgradeVersion : ShipPart
@export var UpgradeTime : float
@export_group("Dispsition")
@export var disp : DispositionManager.Dispositions = DispositionManager.Dispositions.KINETIC
@export var DispositionAmm : float = 0.1
@export var Repair_Parts : float = 0.0

func _setup_local_to_scene() -> void:
	for Up in Upgrades:
		Up.CurrentValue = Up.UpgradeAmmount

func GetPartMaxCondition() -> float:
	for g in Upgrades:
		if (g.UpgradeName == STAT_CONST.STATS.HULL):
			return g.UpgradeAmmount
	return -1

func GetPartCondition() -> float:
	for g in Upgrades:
		if (g.UpgradeName == STAT_CONST.STATS.HULL):
			return g.CurrentValue
	return -1

func GetPartConditionNormalised() -> float:
	for g in Upgrades:
		if (g.UpgradeName == STAT_CONST.STATS.HULL):
			return g.CurrentValue / g.UpgradeAmmount
	return -1

func Damage(amm : float) -> void:
	for g in Upgrades:
		if (g.UpgradeName == STAT_CONST.STATS.HULL):
			g.CurrentValue = max(0, g.CurrentValue - amm)
			break
	
	var newCondition = GetPartConditionNormalised()
	for g in Upgrades:
		g.Condition = newCondition
		g.CurrentValue = min(g.CurrentValue, g.UpgradeAmmount * newCondition)

func Repair(amm : float) -> void:
	for g in Upgrades:
		if (g.UpgradeName == STAT_CONST.STATS.HULL):
			g.CurrentValue = min(g.UpgradeAmmount, g.CurrentValue + amm)
	
	var newCondition = GetPartConditionNormalised()
	for g in Upgrades:
		g.Condition = newCondition
		if (STAT_CONST.ShouldRefillOnRepair(g.UpgradeName)):
			g.CurrentValue = g.UpgradeAmmount * newCondition

func GetItemDesc() -> String:
	var condition = GetPartConditionNormalised()
	var UpNames = "\n[color=#ffc315]-------------[/color]\nPROVIDING STATS"
	for g in Upgrades.size():
		#var Multiplier = 1
		#if (Upgrades[g].UpgradeName == STAT_CONST.STATS.THRUST):
			#Multiplier = 360
		var UpName = STAT_CONST.STATS.keys()[Upgrades[g].UpgradeName].replace("_", " ")
		var UpAmm
		var UpSymbol
		var Col
		if (Upgrades[g].UpgradeAmmount > 0):
			UpAmm = Upgrades[g].UpgradeAmmount
			UpSymbol = "+"
			Col = "ffc315"
		else : if (Upgrades[g].PenaltyAmmount > 0):
			UpAmm = Upgrades[g].PenaltyAmmount
			UpSymbol = "-"
			Col = "db2c36"
		UpNames += "\n[color=#{3}]{0}[/color] : {2} {1}".format([UpName, UpAmm, UpSymbol, Col])
		if (STAT_CONST.IsStatConditionAffected(Upgrades[g].UpgradeName)):
			if (condition < 1.0):
				var reducedAmm = snappedf(UpAmm - (UpAmm * condition), 0.1)
				UpNames += " [color=#f35033]- {0}[/color]".format([reducedAmm])
		
		UpNames += " " + STAT_CONST.GetStatMetric(Upgrades[g].UpgradeName)

	UpNames += "\n[color=#{3}]{0}[/color] : {2} {1}".format(["VALUE", Cost, "+", "ffc315"])
	if (STAT_CONST.IsStatConditionAffected(STAT_CONST.STATS.VALUE)):
		if (condition < 1.0):
			var reducedAmm = snappedf(Cost - (Cost * condition), 0.1)
			UpNames += " [color=#f35033]- {0}[/color]".format([reducedAmm])
	UpNames += " " + STAT_CONST.GetStatMetric(STAT_CONST.STATS.VALUE)
	
	
	var PartTypeString : String = ShipPartType.keys()[PartType]
	PartTypeString = PartTypeString.replace("_", " ")
	return "[color=#ffc315]Ship Part Type[/color] : {2}\n[color=#ffc315]DISPOSITION[/color] : {3}\n[color=#ffc315]-------------[/color]\n{0} {1}".format([ItemDesc, UpNames, PartTypeString, DispositionManager.Dispositions.keys()[disp]])


func GetWorkshopItemDesc() -> String:
	var PartTypeString : String = ShipPartType.keys()[PartType]
	PartTypeString = "[color=#ffc315]Ship Part Type[/color] : {0}\n[color=#ffc315]-------------[/color]".format([PartTypeString.replace("_", " ")]) 
	
	var DispText = "\n[color=#ffc315]DISPOSITION[/color] : {0}\n[color=#ffc315]-------------[/color]".format([DispositionManager.Dispositions.keys()[disp]])
	var UpNames = "\nPROVIDING STATS"
	for g in Upgrades.size():
		#var Multiplier = 1
		#if (Upgrades[g].UpgradeName == STAT_CONST.STATS.THRUST):
			#Multiplier = 360
		var UpName = STAT_CONST.STATS.keys()[Upgrades[g].UpgradeName].replace("_", " ")
		var UpAmm
		var UpSymbol
		var Col
		if (Upgrades[g].UpgradeAmmount > 0):
			UpAmm = Upgrades[g].UpgradeAmmount
			UpSymbol = "+"
			Col = "ffc315"
		else : if (Upgrades[g].PenaltyAmmount > 0):
			UpAmm = Upgrades[g].PenaltyAmmount
			UpSymbol = "-"
			Col = "db2c36"
		UpNames += "\n[color=#{4}]{0}[/color] : {3} {1} {2}".format([UpName, UpAmm, STAT_CONST.GetStatMetric(Upgrades[g].UpgradeName), UpSymbol, Col])
	return PartTypeString + DispText + UpNames



enum ShipPartType{
	INVENTORY,
	ENGINE,
	SENSOR,
	FUEL_TANK,
	WEAPON,
	SHIELD
}
