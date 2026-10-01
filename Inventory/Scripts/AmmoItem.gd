@tool
extends Item

class_name AmmoItem

@export var WType : CardStats.WeaponType

func GetItemDesc() -> String:
	var Desc = "[color=#ffc315]REQUIRES {0}[/color]\n{1}".format([CardStats.WeaponType.keys()[WType],ItemDesc])
	return Desc

func GetRequirementDesc() -> String:
	return "[color=#ffc315]REQUIRES {0}[/color]".format([CardStats.WeaponType.keys()[WType]])
