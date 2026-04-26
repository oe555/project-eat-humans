extends CanvasLayer

# =========================================================
# ShopMenu — opened on home planet arrival, closed with button
# Displays upgrade categories with tier buttons.
# Unpurchasable items are greyed out.
# =========================================================

const CATEGORY_COUNT := 5
const TIER_COUNT := 3

@onready var _gold_label: Label = %GoldLabel

var _tier_buttons: Array = []  # [cat_idx][0..2] -> Button


func _ready() -> void:
	SignalBus.gold_changed.connect(_on_gold_changed)
	SignalBus.upgrade_purchased.connect(_on_upgrade_purchased)
	SignalBus.home_planet_reached.connect(_on_home_planet_reached)

	var close_btn = get_node("CenterContainer/Panel/VBox/CloseButton")
	close_btn.pressed.connect(func() -> void: visible = false)

	var rows: Array = [%SpeedRow, %FuelRow, %CargoRow, %RadarRow, %ScannerRow]
	for cat_idx in range(CATEGORY_COUNT):
		var buttons: Array = []
		for tier in range(1, TIER_COUNT + 1):
			var btn: Button = rows[cat_idx].get_child(tier)
			var cap_cat := cat_idx
			var cap_tier := tier
			btn.pressed.connect(func() -> void: _on_buy(cap_cat, cap_tier))
			buttons.append(btn)
		_tier_buttons.append(buttons)



# --------------- State refresh ---------------

func _refresh() -> void:
	_gold_label.text = "GOLD: %d" % GameState.gold
	for cat_idx in range(CATEGORY_COUNT):
		var level := ShopManager.get_upgrade_level(cat_idx)
		for tier in range(1, TIER_COUNT + 1):
			var btn: Button = _tier_buttons[cat_idx][tier - 1]
			var price := ShopManager.get_upgrade_price(cat_idx, tier)
			if tier <= level:
				btn.text = "T%d\nOWNED" % tier
				btn.modulate = Color(0.4, 0.85, 0.45, 0.85)
				btn.disabled = true
			elif tier == level + 1:
				btn.text = "T%d\n%dg" % [tier, price]
				if GameState.gold >= price:
					btn.modulate = Color(1.0, 1.0, 1.0, 1.0)
					btn.disabled = false
				else:
					btn.modulate = Color(0.55, 0.55, 0.55, 0.75)
					btn.disabled = true
			else:
				btn.text = "T%d\n%dg" % [tier, price]
				btn.modulate = Color(0.3, 0.3, 0.3, 0.6)
				btn.disabled = true


# --------------- Signal handlers ---------------

func _on_buy(cat_idx: int, tier: int) -> void:
	ShopManager.purchase_upgrade(cat_idx, tier)


func _on_gold_changed(_value: int) -> void:
	if visible:
		_refresh()


func _on_upgrade_purchased(_category: int, _tier: int) -> void:
	if visible:
		_refresh()


func _on_home_planet_reached() -> void:
	visible = true
	_refresh()
