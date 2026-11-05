@tool
extends Resource

class_name ShipPartUpgrade

@export var UpgradeName : STAT_CONST.STATS
@export var UpgradeAmmount : float
@export var PenaltyAmmount : float = 0.0
@export var CurrentValue : float
##Normalised value from 0 to 1. Updated when ship part is damaged
@export var Condition : float = 1.0
