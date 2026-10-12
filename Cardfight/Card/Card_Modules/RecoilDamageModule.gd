extends CardModule
class_name RecoilDamageModule

@export_range(0, 200) var RecoilPercent : int

func GetDesc(_Tier : int, _targetOverride : String = "") -> String:
	return "[color=#ffc315]{0}%[/color] recoil damage.".format([RecoilPercent])


func GetRecoilAmmount(DamageDone : float) -> float:
	return DamageDone * (RecoilPercent as float / 100)

func NeedsTargetSelect() -> bool:
	return false

static func CanBeInPassive() -> bool:
	return false

func Handle(Performer : BattleShipStats, Action : CardStats, _Targets : Array[BattleShipStats] = []) -> AnimationData:
	if (Action.Burned):
		return DeffensiveAnimationData.new()
	
	var finalDmg : float = 0
	for mod in Action.OnUseModules:
		if (mod is OffensiveCardModule):
			finalDmg += mod.GetFinalDamage(Performer, Action.Tier)
	
	var Callables : Array[Callable]
	var Recoil = GetRecoilAmmount(finalDmg)
	Callables.append(Performer.DamageShip.bind(Recoil, true, false, false, Performer))
	
	var AnimData = OffensiveAnimationData.new()
	AnimData.Mod = self
	
	var Data : Dictionary
	Data["Def"] = null
	Data["DefMod"] = null
	Data["Viz"] = Performer.ShipViz.ShipIcon
	var DefList : Dictionary[BattleShipStats, Dictionary]
	DefList[Performer] = Data
	AnimData.DeffenceList = DefList
	AnimData.Callables = Callables
	
	return AnimData
