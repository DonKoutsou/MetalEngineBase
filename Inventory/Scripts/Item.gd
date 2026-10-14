@tool
extends Resource
class_name Item

@export var ItemIcon : Texture
@export var ItemName = "ItemName"
@export_multiline var ItemDesc = "ItemDesc"

@export var PartType : ShipPart.ShipPartType = ShipPart.ShipPartType.INVENTORY

@export var CardProviding : Array[CardStats] = []

@export var Cost : int = 0
@export var Tier : int = 0
@export var MaxStackCount = 1
@export var CanTransfer : bool = true

func GetItemName() -> String:
	return ItemName

func GetItemDesc() -> String:
	return ItemDesc

func IsSame(It : Item) -> bool:
	return ItemName == It.ItemName

func GetRequirementDesc() -> String:
	return""

func GetWorkshopItemDesc() -> String:
	return ""
