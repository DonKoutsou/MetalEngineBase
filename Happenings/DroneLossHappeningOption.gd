@tool
extends String_Happening_Option
class_name DroneLossHappening_Option

@export var Cpt : Captain

#func _init() -> void:
	#Dron = DroneScene.instantiate()

func OptionResault(_EventOrigin) -> String:
	return StringReply
	
func OptionOutCome(Instigator) -> bool:
	super(Instigator)
	if (!CheckResault):
		Instigator.GetDock().RemoveCaptain(Cpt)
	return CheckResault
