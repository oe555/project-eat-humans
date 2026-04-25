extends Node

# =========================================================
# ShopManager — Autoload singleton
# Handles all shop transactions: upgrade purchases and fuel.
# Balance checks use GameState.gold.
# Events emitted through SignalBus.
# =========================================================

const FUEL_PRICE: int = 10

# Indexed by Enums.UpgradeCategory value
const UPGRADE_BASE_PRICES: Array[int] = [
    150, # SHIP_SPEED
    100, # FUEL_CAPACITY
    120, # CARGO_CAPACITY
     80, # RADAR_RANGE
    200  # RESOURCE_SCANNER
]

const UPGRADE_PRICE_MULTIPLIER: float = 2.0
const MAX_TIER: int = 3

# Current purchased tier per category (0 = NONE / unpurchased)
var upgrade_levels: Array[int] = [0, 0, 0, 0, 0]


func get_upgrade_level(category: int) -> int:
    return upgrade_levels[category]

func get_upgrade_price(category: int, tier: int) -> int:
    return int(UPGRADE_BASE_PRICES[category] * pow(UPGRADE_PRICE_MULTIPLIER, tier - 1))

func can_purchase_upgrade(category: int, tier: int) -> bool:
    if tier != upgrade_levels[category] + 1:
        return false
    if tier > MAX_TIER:
        return false
    return GameState.gold >= get_upgrade_price(category, tier)

func purchase_upgrade(category: int, tier: int) -> bool:
    if tier > MAX_TIER:
        SignalBus.purchase_failed.emit("already_max_tier")
        return false
    if tier != upgrade_levels[category] + 1:
        SignalBus.purchase_failed.emit("must_purchase_previous_tier")
        return false
    var price: int = get_upgrade_price(category, tier)
    if GameState.gold < price:
        SignalBus.purchase_failed.emit("insufficient_gold")
        return false
    GameState.gold -= price
    upgrade_levels[category] = tier
    SignalBus.gold_changed.emit(GameState.gold)
    SignalBus.upgrade_purchased.emit(category, tier)
    return true

func get_fuel_price() -> int:
    return FUEL_PRICE

func purchase_fuel(amount: int) -> bool:
    if amount <= 0:
        push_warning("ShopManager: purchase_fuel called with non-positive amount")
        return false
    var total_cost: int = FUEL_PRICE * amount
    if GameState.gold < total_cost:
        SignalBus.purchase_failed.emit("insufficient_gold")
        return false
    GameState.gold -= total_cost
    SignalBus.gold_changed.emit(GameState.gold)
    SignalBus.fuel_purchased.emit(amount)
    return true
