@tool
extends String_Happening_Option
class_name TownFuelHappeningOption

@export var FuelToGive : float = 500

func OptionResault(EventOrigin) -> String:
	EventOrigin.RewardFuel(FuelToGive)
	
	return StringReply
