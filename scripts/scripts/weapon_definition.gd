extends Resource
class_name WeaponDefinition

@export var display_name := "Service Rifle"
@export var magazine_size := 30
@export var reserve_ammo := 120
@export var damage := 24
@export var rounds_per_minute := 500.0
@export var reload_seconds := 2.1
@export var range_meters := 120.0
@export var hip_spread_degrees := 1.4
@export var moving_spread_degrees := 2.2
@export var recoil_degrees := 0.7

func fire_interval_ms() -> int:
	return int(60000.0 / maxf(rounds_per_minute, 1.0))
