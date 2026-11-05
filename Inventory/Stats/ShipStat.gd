@tool
extends Resource
class_name ShipStat

@export var StatName : STAT_CONST.STATS
#@export var StatName : String
@export var StatBase : float
@export var StatShipPartBuff : Array[ShipPartUpgrade]
@export var StatShipPartPenalty : float
@export var CurrentValue : float

func GetStatName() -> STAT_CONST.STATS:
	return StatName

func GetBaseValue()-> float:
	return StatBase
	
func GetShipPartBuff()-> float:
	return STAT_CONST.GetStatItemBuff(StatName, StatShipPartBuff)
	
func GetShipPartPenalty() -> float:
	var penalty : float = 0
	for g in StatShipPartBuff:
		var partPenalty = g.PenaltyAmmount
		if (STAT_CONST.IsStatConditionAffected(g.UpgradeName)):
			partPenalty *= g.Condition
		penalty += partPenalty
	return penalty

func GetShipPartDamage() -> float:
	var damage : float = 0
	
	for g in StatShipPartBuff:
		var partDamage = 0
		if (STAT_CONST.IsStatConditionAffected(g.UpgradeName)):
			partDamage = g.UpgradeAmmount - (g.UpgradeAmmount * g.Condition)
		damage += partDamage
	
	return damage

func AddShipPartBuff(buff : ShipPartUpgrade) -> void:
	StatShipPartBuff.append(buff)

func RemoveShipPartBuff(buff : ShipPartUpgrade) -> void:
	StatShipPartBuff.erase(buff)

#func AddShipPartPenalty(Amm : float) -> void:
	#StatShipPartPenalty += Amm
	
func GetFinalValue()-> float:
	if (!STAT_CONST.ShouldStatStack(StatName)):
		return max(StatBase, STAT_CONST.GetStatItemBuff(StatName, StatShipPartBuff)) - GetShipPartPenalty()
	return StatBase + STAT_CONST.GetStatItemBuff(StatName, StatShipPartBuff) - GetShipPartPenalty()
	
func GetCurrentValue()-> float:
	var current = CurrentValue
	for g in StatShipPartBuff:
		current += g.CurrentValue
	return current
	
func RefilCurrentValue(RefAmmount : float) -> void:
	var remainingRefill : float = RefAmmount
	var addToBase = min(StatBase - CurrentValue, remainingRefill)
	CurrentValue += addToBase
	remainingRefill -= addToBase
	if (remainingRefill == 0):
		return
	for g in StatShipPartBuff:
		var ammToAdd = min(g.UpgradeAmmount - g.CurrentValue, remainingRefill)
		g.CurrentValue += ammToAdd
		remainingRefill -= ammToAdd
	
func ConsumeResource(Consumtion : float) -> void:
	var remainingToConsume : float = Consumtion
	
	var baseToConsume = min(CurrentValue, remainingToConsume)
	CurrentValue -= baseToConsume
	remainingToConsume -= baseToConsume
	
	for g in StatShipPartBuff:
		var ammToConsume = min(g.CurrentValue, remainingToConsume)
		g.CurrentValue -= ammToConsume
		remainingToConsume -= ammToConsume
	
func ForceMaxValue() -> void:
	CurrentValue = GetBaseValue()
	for g in StatShipPartBuff:
		g.CurrentValue = g.CurrentValue
	
