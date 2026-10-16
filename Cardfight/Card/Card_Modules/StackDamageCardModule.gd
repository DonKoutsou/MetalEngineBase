extends CardModule
class_name StackDamageCardModule

@export var BuffAmmount : float

func GetDesc(Tier : int, _targetOverride : String = "") -> String:
	return "Card damage +{0}%".format([GetStackDamage(Tier) - 100]).replace(".0", "")

func GetStackDamage(Tier : int) -> float:
	if (TierUpgradeMethod == DamageInfo.CalcuationMethod.ADD):
		return roundi(BuffAmmount + (TierUpgrade * Tier) * 100)
	return roundi(BuffAmmount * max((TierUpgrade * Tier), 1) * 100)

func NeedsTargetSelect() -> bool:
	return false

static func CanBeInPassive() -> bool:
	return false

func Handle(_Performer : BattleShipStats, Action : CardStats, _Targets : Array[BattleShipStats] = []) -> AnimationData:
	if (Action.Burned):
		return DeffensiveAnimationData.new()
	
	for modIndex in Action.OnUseModules.size():
		var mod = Action.OnUseModules[modIndex]
		if (mod is OffensiveCardModule):
			var newMod = mod.duplicate()
			var NewAction = Action.duplicate()
			NewAction.OnUseModules[modIndex] = newMod
			Action = NewAction
			newMod.Damage += newMod.Damage * GetStackDamage(Action.Tier)
		
	var Data = DeffensiveAnimationData.new()
	Data.Mod = self
	#Data.Targets = Targets
	return Data
