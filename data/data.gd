class_name Data
extends RefCounted

const MAPS: Dictionary[String, PackedScene] = {
	"forest" : preload("res://data/maps/forest/forest.tscn"),
}

const ARMOUR: Dictionary[String, Armour] = {
	"light_armour" : preload("res://data/armour/light_armour/light_armour.tres"),
	"heavy_armour" : preload("res://data/armour/heavy_armour/heavy_armour.tres"),
}

const WEAPONS: Dictionary[String, Weapon] = {
	"gun" : preload("res://data/weapons/ranged/gun/gun.tres"),
	"rifle" : preload("res://data/weapons/ranged/rifle/rifle.tres"),
	"sword" : preload("res://data/weapons/melee/sword/sword.tres"),
	"spear" : preload("res://data/weapons/melee/spear/spear.tres"),
}
