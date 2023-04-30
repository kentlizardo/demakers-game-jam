extends Enemy

@export
var Projectile : PackedScene
@export
var Aim : Node3D

const SPEED = 3.5
const ROTATE_SPEED = 0.4
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	super()
	if randi_range(0, 1) == 1:
		direction = -1
var direction = 1

const MELEE_DISTANCE_SQUARED = 2
var chargeUp = 0.0
var maxCharge = 0.8

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	if dead:
		return
	
	if tracking.size() > 0:
		var dif = (tracking[0].global_position - self.global_position)
		var dist2 = dif.length_squared()
		if dist2 <= MELEE_DISTANCE_SQUARED:
			chargeUp += delta
			if chargeUp >= maxCharge:
				if Projectile != null:
					chargeUp = 0.0
					var obj = Projectile.instantiate()
					get_parent().add_child.call_deferred(obj)
					obj.Launch.call_deferred(Aim)
		else:
			chargeUp = 0.0
		
		dif.y = 0
		dif = dif.normalized()
		look_at(tracking[0].global_position)
		if dist2 > MELEE_DISTANCE_SQUARED:
			if dif:
				velocity.x = dif.x * SPEED
				velocity.z = dif.z * SPEED
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
				velocity.z = move_toward(velocity.z, 0, SPEED)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
		self.rotate_y(deg_to_rad(delta * 45.0 * direction))
	
	move_and_slide()
