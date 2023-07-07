class_name DamageData
extends RefCounted


var damage: float
var dealer: Character
var target: Character


func _init(p_target: Character = null, p_damage: float = 0):
	target = p_target
	damage = p_damage
