extends Node3D

@export
var item : Item

@export
var moduleName : String

var mod : Module
# Called when the node enters the scene tree for the first time.
func _ready():
	mod = Root.getMainNode().get_node("2DUI/FullLayout/Modules/" + moduleName)
	item.pickUp.connect(activatePickUp)

func activatePickUp():
	mod.PickUpModule()
	queue_free.call_deferred()
