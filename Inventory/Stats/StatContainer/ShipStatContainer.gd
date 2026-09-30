@tool
extends VBoxContainer

class_name ShipStatContainer


@export_group("Nodes")
@export var StatNameLabel : Label
@export var StatValueLabel : Label
@export var ShipStatBar : ProgressBar
@export var ItemStatBar : ProgressBar
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
	ItemNegativeBar.max_value = MaxValue


func UpdateStatCustom(StatVal : float, ItemVar : float, ItemPenalty : float) -> void:
	var finalValue = snappedf(StatVal + ItemVar - ItemPenalty, 0.1)
	StatValueLabel.text = "{0} {1}".format([finalValue, Metric])
	
	ShipStatBar.value = 0
	ItemStatBar.value = 0
	ItemNegativeBar.value = 0
	
	var tw = create_tween()
	tw.set_ease(Tween.EASE_OUT)
	tw.set_trans(Tween.TRANS_BACK)
	tw.set_parallel(true)
	tw.tween_property(ShipStatBar, "value", StatVal, 0.25)
	tw.tween_property(ItemStatBar, "value", StatVal + ItemVar, 0.25)
	tw.tween_property(ItemNegativeBar, "value", StatVal + ItemVar - ItemPenalty, 0.25)

	ItemNegativeBar.visible = ItemPenalty > 0
	
func UpdateStatValue(StatVal : float, ItemVar : float, ItemPenalty : float) -> void:

	if (!STAT_CONST.ShouldStatStack(STName)):
		StatValueLabel.text = "{0} {1}".format([var_to_str(max(StatVal, ItemVar) - ItemPenalty).replace(".0", ""), Metric])
	else:
		StatValueLabel.text = "{0} {1}".format([var_to_str(StatVal + ItemVar - ItemPenalty).replace(".0", ""), Metric])
	
	ShipStatBar.value = 0
	ItemStatBar.value = 0
	ItemNegativeBar.value = 0
	
	var tw = create_tween()
	tw.set_ease(Tween.EASE_OUT)
	tw.set_trans(Tween.TRANS_BACK)
	tw.set_parallel(true)
	tw.tween_property(ShipStatBar, "value", StatVal, 0.25)
	tw.tween_property(ItemStatBar, "value", StatVal + ItemVar, 0.25)
	tw.tween_property(ItemNegativeBar, "value", StatVal + ItemVar - ItemPenalty, 0.25)

	ItemNegativeBar.visible = ItemPenalty > 0




func _on_h_slider_value_changed(_value: float) -> void:
	pass # Replace with function body.
