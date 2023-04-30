extends CharacterBody3D

class_name Enemy

@export
var driverRoot : Node3D

var drivers : Array[EnemyDriver] = []
var dead : bool = false

func _ready():
	for i in driverRoot.get_children():
		if i is EnemyDriver:
			i.Bind(self)

var tracking : Array[Node3D]

func getTargets() -> Array[Node3D]:
	var targets : Array[Node3D] = []
	for i in drivers:
		if i.awareness.detected:
			targets.append(i.awareness.target)
	return targets

signal onDeath
func Die():
	dead = true
	var t = get_tree().create_timer(0.3)
	onDeath.emit()
	await t.timeout
	self.queue_free.call_deferred()

func _process(delta):
	if dead:
		return
	if drivers.size() == 0:
		Die()
	tracking = getTargets()
