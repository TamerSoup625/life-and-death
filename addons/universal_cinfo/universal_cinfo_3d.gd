@tool
class_name UniversalCInfo3D
extends RefCounted


var collider: Object
var collider_rid: RID
var collider_shape_index: int
var collision_normal: Vector3
var collision_point: Vector3

var source
var extra_argument


func _init(p_source = null, p_extra_arg = null):
	if p_source != null:
		set_cinfo(p_source, p_extra_arg)


func set_cinfo(p_source, p_extra_arg = null):
	source = p_source
	extra_argument = p_extra_arg
	
	if source is Object:
		if source is RayCast3D:
			if OS.is_debug_build() and not source.is_colliding():
				push_warning("The RayCast3D passed as source is not currently colliding.")
			collider = source.get_collider()
			collider_rid = source.get_collider_rid()
			collider_shape_index = source.get_collider_shape()
			collision_normal = source.get_collision_normal()
			collision_point = source.get_collision_point()
		elif source is ShapeCast3D:
			assert(extra_argument is int, "If the source is a ShapeCast3D, the extra argument must be an integer")
			if OS.is_debug_build() and not source.is_colliding():
				push_warning("The ShapeCast3D passed as source is not currently colliding.")
			collider = source.get_collider(extra_argument)
			collider_rid = source.get_collider_rid(extra_argument)
			collider_shape_index = source.get_collider_shape(extra_argument)
			collision_normal = source.get_collision_normal(extra_argument)
			collision_point = source.get_collision_point(extra_argument)
		elif source is PhysicsDirectBodyState3D:
			assert(extra_argument is int, "If the source is a PhysicsDirectBodyState3D, the extra argument must be an integer")
			collider = source.get_contact_collider_object(extra_argument)
			collider_rid = source.get_contact_collider(extra_argument)
			collider_shape_index = source.get_contact_collider_shape(extra_argument)
			collision_normal = source.get_contact_local_normal(extra_argument)
			collision_point = source.get_contact_collider_position(extra_argument)
		elif source is KinematicCollision3D:
			if not extra_argument is int:
				extra_argument = 0
			collider = source.get_collider(extra_argument)
			collider_rid = source.get_collider_rid(extra_argument)
			collider_shape_index = source.get_collider_shape_index(extra_argument)
			collision_normal = source.get_normal(extra_argument)
			collision_point = source.get_position(extra_argument)
