extends DeffenceCardModule

class_name FireExtinguishModule

func GetDesc(_Tier : int, targetOverride : String = "") -> String:
	if (!targetOverride.is_empty()):
		return "Extinguishes [color=#ff3c22]fires[/color] on {0}".format([targetOverride])
	return "Extinguishes [color=#ff3c22]fires[/color] on ship"

func NeedsTargetSelect() -> bool:
	return true

func CanBeInPassive() -> bool:
	return true

func Handle(Performer : BattleShipStats, Action : CardStats, Targets : Array[BattleShipStats] = []) -> AnimationData:
	if (Action.Burned):
		return DeffensiveAnimationData.new()
	var Callables : Array[Callable] = [Performer.CombustFire]
	
	var Data = DeffensiveAnimationData.new()
	Data.Mod = self
	Data.Targets.append(Performer.ShipViz.ShipIcon)
	Data.Callables = Callables
	return Data
