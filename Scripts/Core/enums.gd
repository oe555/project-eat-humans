extends Node

# =========================================================
# All globally available enums are defined in this file.
# Use in other files with Enums.{name}.
# =========================================================

# Example enum
enum Example {
    OPTION_A,
    OPTION_B,
    OPTION_C
}

enum UpgradeCategory {
    SHIP_SPEED,
    FUEL_CAPACITY,
    CARGO_CAPACITY,
    RADAR_RANGE,
    RESOURCE_SCANNER
}

enum UpgradeTier {
    NONE,   # 0 — starting state
    TIER_1, # 1
    TIER_2, # 2
    TIER_3  # 3
}