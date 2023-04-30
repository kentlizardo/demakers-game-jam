extends Node3D

class_name EnemyAwareness

@export var viewArea : Area3D

var collided : Array[Node3D] = []

@onready var space_state = get_world_3d().direct_space_state

func _ready():
	viewArea.body_entered.connect(collider_on_enter)
	viewArea.body_exited.connect(collider_on_exit)

signal target_detected
signal target_hidden

var detected : bool = false
var oldDetected : bool = false

var target : Node3D = null

func _process(delta):
	detected = false
	if collided.size() > 0:
		for c in collided:
			# Line of sight
			var los = PhysicsRayQueryParameters3D.new()
			los.from = self.global_position
			los.to = c.global_position
			var rc = space_state.intersect_ray(los)
			if rc:
				if rc.collider.is_in_group("Player"):
					detected = true
					target = rc.collider
	if detected != oldDetected:
		if detected:
			target_detected.emit()
		else:
			target = null
			target_hidden.emit()
	oldDetected = detected

func collider_on_enter(body):
	if body.is_in_group("Player"):
		if !collided.has(body):
			collided.append(body)

func collider_on_exit(body):
	if body.is_in_group("Player"):
		if collided.has(body):
			collided.remove_at(collided.find(body))
