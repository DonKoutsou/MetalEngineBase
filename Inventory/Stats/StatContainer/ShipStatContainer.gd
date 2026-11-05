@tool
extends VBoxContainer

class_name ShipStatContainer


@export_group("Nodes")
@export var StatNameLabel : Label
@export var StatValueLabel : Label
@export var ShipStatBar : ProgressBar
@export var ItemStatBar : ProgressBar
@export var DamageStatBar : ProgressBar
@export var ItemNegativeBar : ProgressBar

var STName = -1

var Metric = ""

func _ready() -> void:
	set_process(false)

func SetData(Stat : STAT_CONST.STATS) -> void:
	#store stat type and the metric
	STName = Stat
	Metric =  STAT_CONST.GetStatMetric(STName)
	
	#Set the stat name to the label
	StatNameLabel.text = STAT_CONST.STATS.keys()[Stat].replace("_", " ")
	
	#assign the max possible value of the stat to the progress bars
	var MaxVal = STAT_CONST.GetStatMaxValue(Stat)

	ShipStatBar.max_value = MaxVal
	ItemStatBar.max_value = MaxVal
	DamageStatBar.max_value = MaxVal
	ItemNegativeBar.max_value = MaxVal

#used for "custom" stats that are pseudo stat, created from the combination of others, like speed and range
func SetDataCustom(MaxValue : float, StatMetric : String, StatName : String, Stat : STAT_CONST.STATS) -> void:
	#store stat type and the metric
	STName = Stat
	Metric = StatMetric
	
	#Set the stat name on the label
	StatNameLabel.text = StatName
	
	#assign the max possible value of the stat to the progress bars
	ShipStatBar.max_value = MaxValue
	ItemStatBar.max_value = MaxValue
	DamageStatBar.max_value = MaxValue
	ItemNegativeBar.max_value = MaxValue


func UpdateStatCustom(StatVal : float, ItemVar : float, DamageVar : float, ItemPenalty : float, tween : bool = true) -> void:
	var finalValue = snappedf(StatVal + ItemVar - ItemPenalty, 0.1)
	if (DamageVar > 0):
		StatValueLabel.text = "{0} - {2} {1}".format([finalValue, Metric,snappedf(DamageVar, 0.1)]).replace(".0", "")
	else:
		StatValueLabel.text = "{0} {1}".format([finalValue, Metric]).replace(".0", "")
	
	if (tween):
		ShipStatBar.value = 0
		ItemStatBar.value = 0
		DamageStatBar.value = 0
		ItemNegativeBar.value = 0
		
		var tw = create_tween()
		tw.set_ease(Tween.EASE_OUT)
		tw.set_trans(Tween.TRANS_BACK)
		tw.set_parallel(true)
		tw.tween_property(ShipStatBar, "value", StatVal, 0.25)
		tw.tween_property(ItemStatBar, "value", StatVal + ItemVar - DamageVar, 0.25)
		tw.tween_property(DamageStatBar, "value", StatVal + ItemVar, 0.25)
		tw.tween_property(ItemNegativeBar, "value", StatVal + ItemVar - ItemPenalty, 0.25)
	else:
		ShipStatBar.value = StatVal
		ItemStatBar.value = StatVal + ItemVar - DamageVar
		DamageStatBar.value = StatVal + ItemVar
		ItemNegativeBar.value = StatVal + ItemVar - ItemPenalty

	ItemNegativeBar.visible = ItemPenalty > 0
	
func UpdateStatValue(StatVal : float, ItemVar : float, DamageVar : float, ItemPenalty : float, tween : bool = true) -> void:
	var finalValue
	if (!STAT_CONST.ShouldStatStack(STName)):
		finalValue = snappedf(max(StatVal, ItemVar) - ItemPenalty, 0.1)
	else:
		finalValue = snappedf(StatVal + ItemVar - ItemPenalty, 0.1)

	if (DamageVar > 0):
		StatValueLabel.text = "{0} - {2} {1}".format([finalValue, Metric, snappedf(DamageVar, 0.1)]).replace(".0", "")
	else:
		StatValueLabel.text = "{0} {1}".format([finalValue, Metric]).replace(".0", "")
	
	if (tween):
		ShipStatBar.value = 0
		ItemStatBar.value = 0
		DamageStatBar.value = 0
		ItemNegativeBar.value = 0
		
		var tw = create_tween()
		tw.set_ease(Tween.EASE_OUT)
		tw.set_trans(Tween.TRANS_BACK)
		tw.set_parallel(true)
		tw.tween_property(ShipStatBar, "value", StatVal, 0.25)
		if (!STAT_CONST.ShouldStatStack(STName)):
			tw.tween_property(ItemStatBar, "value", ItemVar - DamageVar, 0.25)
			tw.tween_property(DamageStatBar, "value", ItemVar, 0.25)
		else:
			tw.tween_property(ItemStatBar, "value", StatVal + ItemVar - DamageVar, 0.25)
			tw.tween_property(DamageStatBar, "value", StatVal + ItemVar, 0.25)
		tw.tween_property(ItemNegativeBar, "value", StatVal + ItemVar - ItemPenalty, 0.25)
	else:
		ShipStatBar.value = StatVal
		if (!STAT_CONST.ShouldStatStack(STName)):
			ItemStatBar.value = ItemVar - DamageVar
			DamageStatBar.value = ItemVar
		else:
			ItemStatBar.value = StatVal + ItemVar - DamageVar
			DamageStatBar.value = StatVal + ItemVar
		ItemNegativeBar.value = StatVal + ItemVar - ItemPenalty
		
	ItemNegativeBar.visible = ItemPenalty > 0




func _on_h_slider_value_changed(_value: float) -> void:
	pass # Replace with function body.
