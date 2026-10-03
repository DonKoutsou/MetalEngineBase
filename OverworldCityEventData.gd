extends OverworldEventData

class_name OverworCityldEventData

@export var CityToFocus : String

func GetFocusPos() -> Vector2:
	return Vector2.ZERO
	#return MapHelper.GetSpotByName(CityToFocus).global_position
