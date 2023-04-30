extends Enemy

@export
var Projectile : PackedScene
@export
var Aim : Node3D

const ROTATE_SPEED = 0.4
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	super()
	print_debug("test")
	if randi_range(0, 1) == 1:
		direction = -1

var direction = 1
var elapsed = 0.0

var chargeUp = 0.0
var maxCharge = 3.0
	
func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	if dead:
		return
	
	elapsed += delta
	
	if tracking.size() > 0:
		self.look_at(tracking[0].position)
		chargeUp += delta
		if chargeUp >= maxCharge:
			if Projectile != null:
				chargeUp = 0.0
				var obj = Projectile.instantiate()
				get_parent().add_child.call_deferred(obj)
				obj.Launch.call_deferred(Aim)
	else:
		chargeUp = 0.0
		self.rotate_y(deg_to_rad( sin(elapsed) * delta * 45.0 * direction ))
	
	
	move_and_slide()
