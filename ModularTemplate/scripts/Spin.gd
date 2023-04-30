extends Node3D


func _process(delta):
	self.rotate_y(deg_to_rad(35.0 * delta))
