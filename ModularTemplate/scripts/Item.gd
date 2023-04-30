extends Node3D

class_name Item

@export
var PickUpRange : Area3D
@export
var HoverText : String = "Press E to pick up"

func GetHoverText() -> String:
	if cooldownTime > 0:
		return "Wait for %s seconds" % (cooldownTime as int)
	return HoverText

var cooldownTime : float = 0.0

signal pickUp

# Called when the node enters the scene tree for the first time.
func _ready():
	PickUpRange.body_entered.connect(bodyEnter)
	PickUpRange.body_exited.connect(bodyExit)

func _process(delta):
	if cooldownTime > 0:
		cooldownTime -= delta

func PickUp():
	if cooldownTime <= 0:
		pickUp.emit()
		self.queue_free()

func bodyEnter(body : Node3D):
	if body.is_in_group("Player"):
		Root.getMainNode().promptedItem = self
func bodyExit(body : Node3D):
	if body.is_in_group("Player"):
		if Root.getMainNode().promptedItem == self:
			Root.getMainNode().promptedItem = null

