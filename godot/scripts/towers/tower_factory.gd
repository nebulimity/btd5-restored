# class_name TowerFactory
extends Node

var base_towers: Array[TowerDef] = []

var small: float = 23.999 / 2
var medium: float = 29.996 / 2
var large: float = 38.002 / 2

func tower_factory():
	var path_behavior = FollowPath.new().Path([CubicBezierDef.new().A(Vector2.ZERO).B(Vector2.ZERO).C(Vector2(112, 55)).D(Vector2(131, -27)), CubicBezierDef.new().A(Vector2(131, -27)).B(Vector2(151, -109)).C(Vector2(45, -159)).D(Vector2(-13, -11))])
	
	var medium_explosion = ProjectileDef.new().Display("MediumExplosion").Pierce(40).Radius(60).DamageEffect(DamageEffectDef.new().Damage(1).CanBreakIce(true).CantBreak([Bloon.BloonType.BLACK, Bloon.BloonType.ZEBRA]).ShowPop(false))
	
	var dart_projectile = ProjectileDef.new().Display("Dart").Pierce(1).DamageEffect(DamageEffectDef.new().Damage(1).CantBreak([Bloon.BloonType.LEAD]).CanBreakIce(false))
	var dart = Single.new().SetRange(161).SetPower(805).SetReloadTime(0.9).SetProjectile(dart_projectile)
	var tack_projectile = ProjectileDef.new().Display("Tack").Pierce(1).DamageEffect(DamageEffectDef.new().Damage(1).CantBreak([Bloon.BloonType.LEAD]).CanBreakIce(false))
	var tack = Circular.new().SetRange(70).SetPower(350).SetReloadTime(1.66).SetProjectile(tack_projectile).SetCount(8)
	var sniper_projectile = ProjectileDef.new().Display("Dart").DamageEffect(DamageEffectDef.new().Damage(2).CantBreak([Bloon.BloonType.LEAD]).CanBreakIce(false))
	var sniper = Instant.new().SetReloadTime(2.2).SetProjectile(sniper_projectile)
	var boomerang_projectile = ProjectileDef.new().Display("Boomerang").Pierce(3).Radius(10).DamageEffect(DamageEffectDef.new().Damage(1).CantBreak([Bloon.BloonType.LEAD]).CanBreakIce(false)).Behavior(ProjectileBehaviorDef.new().Process(path_behavior))
	var boomerang = Spread.new().SetRange(520).SetPower(700).SetReloadTime(1.33).SetProjectile(boomerang_projectile).SetCount(1).SetAngle(0.5)
	var shuriken_projectile = ProjectileDef.new().Pierce(2).Radius(4).DamageEffect(DamageEffectDef.new().Damage(1).CantBreak([Bloon.BloonType.LEAD]).CanBreakIce(false))
	var shuriken = Single.new().SetRange(360).SetPower(630).SetReloadTime(0.6).SetProjectile(shuriken_projectile)
	var bomb_projectile = ProjectileDef.new().Display("Bomb").Pierce(1).Radius(5).Behavior(ProjectileBehaviorDef.new().Collision(CollisionSpawnProjectile.new().SetProjectile(medium_explosion)))
	var bomb = Single.new().SetRange(234).SetPower(455).SetReloadTime(1.54).SetProjectile(bomb_projectile)
	var super_dart = Single.new().SetRange(500).SetPower(700).SetReloadTime(0.058).SetProjectile(dart_projectile)
	
	var dart_monkey = TowerDef.new("DartMonkey").Label("Dart Monkey").Description("Shoots a single dart that pops a single bloon. A good, cheap tower suitable for the early rounds.").Display("DartMonkey").OccupiedSpace(small).RangeOfVisibility(100).Behavior(TowerBehaviorDef.new().Process(RotateToTarget.new())).Weapons([dart]).WeaponOffsets([Vector2(6, 9)]).PositionOffset(Vector2(-2.335, 3.335)).FireFrame(8).Cost(200)
	var tack_shooter = TowerDef.new("TackShooter").Label("Tack Shooter").Description("Shoots 8 tacks spread in all directions, each tack can pop 1 bloon. Has short range and medium-slow fire rate.").Display("TackShooter").OccupiedSpace(small).RangeOfVisibility(70).Rotates(false).Weapons([tack]).FireFrame(5).Cost(360)
	var sniper_monkey = TowerDef.new("SniperMonkey").Label("Sniper Monkey").Description("Armed with a high-tech long range rifle, pops 2 layers off of bloons with unlimited range.").Display("SniperMonkey").OccupiedSpace(small).RangeOfVisibility(1200).Weapons([sniper]).PositionOffset(Vector2(22.5, -3.5)).FireFrame(2).Cost(350)
	var boomerang_thrower = TowerDef.new("BoomerangThrower").Label("Boomerang Thrower").Description("Throws a single boomerang in an arc back round to the monkey. Each boomerang can pop 3 bloons.").Display("BoomerangThrower").OccupiedSpace(medium).RangeOfVisibility(130).Behavior(TowerBehaviorDef.new().Process(RotateToTarget.new())).Weapons([boomerang]).WeaponOffsets([Vector2(26, 8)]).PositionOffset(Vector2(-3.0, 8.5)).FireFrame(10).Cost(380)
	var ninja_monkey = TowerDef.new("NinjaMonkey").Label("Ninja Monkey").Description("Stealthy tower that can see Camo Bloons and throws sharp shurikens rapidly.").Display("NinjaMonkey").OccupiedSpace(small).RangeOfVisibility(120).Weapons([shuriken]).Behavior(TowerBehaviorDef.new().Process(RotateToTarget.new())).FireFrame(3).Cost(500)
	var bomb_tower = TowerDef.new("BombTower").Label("Bomb Tower").Description("Shoots a single bomb that explodes in a radius burst on impact. Good range, medium-slow fire rate. Can pop lead bloons but not black bloons.").Display("BombTower").OccupiedSpace(medium).RangeOfVisibility(120).Weapons([bomb]).Behavior(TowerBehaviorDef.new().Process(RotateToTarget.new())).PositionOffset(Vector2(13, -0.5)).FireFrame(2).Cost(650)
	var super_monkey = TowerDef.new("SuperMonkey").Label("Super Monkey").Description("Throws darts incredibly fast. Has long range and lots of insanely powerful upgrades.").Display("SuperMonkey").OccupiedSpace(large).RangeOfVisibility(140).Weapons([super_dart]).WeaponOffsets([Vector2(9, 14)]).PositionOffset(Vector2(-1.0, 1.5)).IdleFrame(1).FireFrame(2).Cost(3500)

	base_towers.append(dart_monkey)
	base_towers.append(tack_shooter)
	base_towers.append(sniper_monkey)
	base_towers.append(boomerang_thrower)
	base_towers.append(ninja_monkey)
	base_towers.append(bomb_tower)
	base_towers.append(super_monkey)

func get_base_tower(tower_name: String) -> TowerDef:
	for tower: TowerDef in base_towers:
		if tower.id == tower_name:
			return tower
	
	return null

#static func get_tower_def(tower_type: String) -> Dictionary:
	#var small: float = 23.999 / 2
	#var medium: float = 29.996 / 2
	#var large: float = 38.002 / 2
#
	#var defs = {
		#"DartMonkey": {
			#"cost": 200,
			#"can_place_on_water": false,
			#"can_place_on_track": false
		#},
		#"TackShooter": {
			#"cost": 360,
			#"can_place_on_water": false,
			#"can_place_on_track": false
		#},
		#"SniperMonkey": {
			#"cost": 350,
			#"can_place_on_water": false,
			#"can_place_on_track": false
		#},
		#"BoomerangThrower": {
			#"cost": 380,
			#"can_place_on_water": false,
			#"can_place_on_track": false
		#},
		#"NinjaMonkey": {
			#"cost": 500,
			#"can_place_on_water": false,
			#"can_place_on_track": false
		#},
		#"BombTower": {
			#"cost": 650,
			#"can_place_on_water": false,
			#"can_place_on_track": false
		#},
		#"IceTower": {
			#"label": "Ice Tower",
			#"description": "Freezes bloons in its burst radius for a short time. Frozen bloons are immune to sharp objects.",
			#"cost": 300,
			#"range": 60,
			#"rotation_offset": 0.0,
			#"rotates": false,
			#"occupied_space_radius": small,
			#"can_place_on_water": false,
			#"can_place_on_track": false
		#},
		#"GlueTower": {
			#"label": "Glue Gunner",
			#"description": "Shoots a glob of monkey glue at a single bloon. Glued bloons move more slowly than normal.",
			#"cost": 270,
			#"range": 140,
			#"occupied_space_radius": small,
			#"can_place_on_water": false,
			#"can_place_on_track": false
		#},
		#"BuccaneerTower": {
			#"label": "Monkey Buccaneer",
			#"description": "Monkey Buccaneers can only be placed on water. Shoots a single, heavy dart that can pop up to 5 bloons each.",
			#"cost": 500,
			#"range": 180,
			#"occupied_space_radius": medium,
			#"can_place_on_water": true,
			#"can_place_on_track": false,
			#"requires_water": true
		#},
		#"MonkeyAce": {
			#"label": "Monkey Ace",
			#"description": "Patrols the skies above the action, regularly strafing the area with powerful darts in 8 directions.",
			#"cost": 900,
			#"range": 50, 
			#"occupied_space_radius": "ace_space",
			#"can_place_on_water": false,
			#"can_place_on_track": true,  # Runway
			#"requires_track": true
		#},
		#"SuperMonkey": {
			#"cost": 3500,
			#"can_place_on_water": false,
			#"can_place_on_track": false
		#},
		#"MonkeyApprentice": {
			#"label": "Monkey Apprentice",
			#"description": "Trained in the arts of monkey magic, the Monkey Apprentice weaves magical bolts of power that pop bloons. Each shot can pop 2 bloons. Can upgrade to cast additional spells.",
			#"cost": 550,
			#"range": 120,
			#"occupied_space_radius": small,
			#"can_place_on_water": false,
			#"can_place_on_track": false
		#},
		#"MonkeyVillage": {
			#"label": "Monkey Village",
			#"description": "Monkey Village does not attack bloons but instead lowers cost of all towers and upgrades in radius by 10%. Has many useful upgrades that help nearby towers.",
			#"cost": 1600,
			#"range": 120,
			#"occupied_space_radius": "village_space",
			#"can_place_on_water": false,
			#"can_place_on_track": false
		#},
		#"BananaTower": {
			#"label": "Banana Farm",
			#"description": "Banana Farms grow bananas that you can collect to turn into cash. When your farm produces some bananas, collect them by moving your mouse over them. Don't leave them too long however, or they will spoil!",
			#"cost": 1000,
			#"range": 120,
			#"occupied_space_radius": "banana_farm_space",
			#"can_place_on_water": false,
			#"can_place_on_track": false
		#},
		#"MortarTower": {
			#"label": "Mortar Tower",
			#"description": "Targets a specific bit of ground anywhere on the screen. Launches explosive mortar shells to that spot. Useful for placing far away from the track to make room for other towers.",
			#"cost": 750,
			#"range": 1250,  # Manual targeting
			#"occupied_space_radius": "mortar_monkey_space",
			#"can_place_on_water": false,
			#"can_place_on_track": false
		#},
		#"DartlingGun": {
			#"label": "Dartling Gun",
			#"description": "Shoots darts like a machine gun, super fast but not very accurate. The Dartling Gun will shoot towards wherever your mouse is, so you control how effective it is!",
			#"cost": 950,
			#"range": 1250,  # Manual aiming
			#"occupied_space_radius": large,
			#"can_place_on_water": false,
			#"can_place_on_track": false
		#},
		#"SpikeFactory": {
			#"label": "Spike Factory",
			#"description": "Generates piles of road spikes on bits of nearby track. Each pile can pop 5 bloons, and unused spikes disappear at the end of each round.",
			#"cost": 750,
			#"range": 105,
			#"occupied_space_radius": large,
			#"can_place_on_water": false,
			#"can_place_on_track": false
		#},
		#"RoadSpikes": {
			#"label": "Road Spikes",
			#"description": "Place these on the track to pop bloons. Each pack of spikes can pop 11 bloons before being used up. Use these to get bloons that escape past your towers.",
			#"cost": 30,
			#"range": 20,
			#"occupied_space_radius": small,
			#"can_place_on_water": false,
			#"can_place_on_track": true,
			#"requires_track": true
		#},
		#"ExplodingPineapple": {
			#"label": "Exploding Pineapple",
			#"description": "This explosive fruit packs a real punch. When placed will explode violently after 3 seconds. Useful for destroying those bloons that require explosives to pop.",
			#"cost": 25,
			#"range": 100,
			#"occupied_space_radius": small,
			#"can_place_on_water": false,
			#"can_place_on_track": false
		#}
	#}
	#
	#return defs.get(tower_type, {})
