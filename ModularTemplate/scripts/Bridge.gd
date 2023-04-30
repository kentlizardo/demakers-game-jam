extends Node3D

@export
var mesh : MeshInstance3D
@export
var collider : CollisionShape3D

func _ready():
	mesh.visible = false
	collider.disabled = true

func Draw():
	mesh.visible = true
	collider.disabled = false
