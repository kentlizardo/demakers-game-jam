extends Node3D

var positionBind : Node3D

func _ready():
	positionBind = Root.getMainNode().player.get_node("LookPivot/CameraPosition")

func _process(delta):
	self.global_position = positionBind.global_position
	self.global_rotation = positionBind.global_rotation
