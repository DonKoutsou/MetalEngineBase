@tool
extends String_Happening_Option
class_name Drone_Happening_Option

var DroneScene : String = "res://Scenes/drone.tscn"
@export var Cpt : Captain

#func _init() -> void:
	#Dron = DroneScene.instantiate()

func OptionResault(_EventOrigin) -> String:
	return StringReply
	
func OptionOutCome(Instigator) -> bool:
	super(Instigator)
	if (CheckResault):
		Instigator.GetDock().AddCaptain(Cpt)
	return CheckResault
