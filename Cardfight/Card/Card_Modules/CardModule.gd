@abstract 
extends Resource

class_name CardModule

@export var AOE : bool = false
@export var TierUpgrade : float = 1
@export var TierUpgradeMethod : DamageInfo.CalcuationMethod

func GetDesc(_Tier : int, _targetOverride : String = "") -> String:
	return ""

static func CanBeInPassive() -> bool:
	return true

@abstract
func NeedsTargetSelect() -> bool

@abstract
func Handle(Performer : BattleShipStats, Action : CardStats, Targets : Array[BattleShipStats] = []) -> AnimationData

func GetBattleDesc(_User : BattleShipStats, Tier : int, targetOverride : String = "") -> String:
	return GetDesc(Tier, targetOverride)

func GetStatShortName(St : Stat) -> String:
	var StatName : String
	if (St == Stat.FIREPOWER):
		return TranslationServer.translate("FRPW")
	if (St == Stat.SPEED):
		return TranslationServer.translate("SPD")
	if (St == Stat.DEFENCE):
		return TranslationServer.translate("DEF")
	
	return StatName

static func GetColorForStat(stat : Stat) -> Color:
	if (stat == Stat.FIREPOWER):
		return Color("f35033")
	else : if (stat == Stat.SPEED):
		return Color("308a4d")
	else : if (stat == Stat.DEFENCE):
		return Color("7bb0b4")
	else : if (stat == Stat.WEIGHT):
		return Color("828dff")
	return Color(1,1,1)

enum Stat{
	FIREPOWER,
	SPEED,
	DEFENCE,
	WEIGHT,
	ENERGY
}
