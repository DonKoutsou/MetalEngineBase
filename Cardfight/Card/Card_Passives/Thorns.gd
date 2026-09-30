
extends Card_Passive

class_name OnDamagedPassive

@export var AllowSelfDamage : bool = false
@export var AllowShieldDamage : bool = false

func GetTrigger() -> ActionType:
	return ActionType.DAMAGED

func OnActionPerformed(data : Dictionary, _C : CardStats, PassiveOwner : BattleShipStats) -> PassiveAnimationData:
	if (!data["Direct"]):
		return
	
	if (data["Damage"] == 0):
		if (data["ShieldDamage"] > 0 and !AllowShieldDamage):
			return
		else: if (data["ShieldDamage"] == 0):
			return
	
	var actionReceiver : BattleShipStats = data["Receiver"]
	var Instigator : BattleShipStats = data["Performer"]
	
	if (!AllowSelfDamage and actionReceiver == Instigator):
		return null
		
	var possibleReceivers : Array[BattleShipStats] = GetPossibleReceivers(data, PassiveOwner)
	if (!possibleReceivers.has(actionReceiver)):
		return null
	
	var targets : Array[BattleShipStats] = GetPossibleTargets(data, PassiveOwner)
	
	var dat : PassiveAnimationData = PassiveAnimationData.new()
	dat.Performer = PassiveOwner
	dat.Targets = targets

	return dat

func GetTrigerString() -> String:
	var triggerString : String = ActionType.keys()[GetTrigger()].replace("_", " ")
	var receiverString : String = ReceiverType.keys()[Receiver].replace("_", " ")
	
	return "[color=#ffc315]ON {1} {0}[/color]".format([triggerString, receiverString])
