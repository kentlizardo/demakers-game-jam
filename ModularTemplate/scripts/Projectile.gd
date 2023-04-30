extends Node3D

class_name Projectile

@export
var damage = 1
@export
var hitbox : Area3D
@export
var launchVelocity = 25
@export
var lifeTime = 2.0
@export
var gravity = false

@export
var targetGroup : String

@export
var ownerGroup : String

var gravityVal = ProjectSettings.get_setting("physics/3d/default_gravity")

var velocity = Vector3.ZERO

func _ready():
	hitbox.area_entered.connect(_hit)
	hitbox.body_entered.connect(_bodyHit)

func Launch(aimObject : Node3D):
	global_position = aimObject.global_position
	global_transform.basis = aimObject.global_transform.basis
	self.velocity = (-aimObject.global_transform.basis.z) * launchVelocity

var lifeLine = 0.0
func _process(delta):
	lifeLine += delta
	if lifeLine > lifeTime:
		queue_free.call_deferred()
func _physics_process(delta):
	if gravity:
		velocity.y -= gravityVal * delta
	look_at(transform.origin + velocity.normalized(), Vector3.UP)
	transform.origin += velocity * delta

var consumed = false
func _hit(area : Area3D):
	if consumed:
		return
	if area is ProjectileReceiver:
		var pR = area as ProjectileReceiver
		if pR.is_in_group(targetGroup):
			pR.ReceiveProjectile.emit(self)
		if !pR.is_in_group(ownerGroup):
			consumed = true
			print_debug("consumed")
			queue_free.call_deferred()
func _bodyHit(body):
	if consumed:
		return
	if body is Player:
		if body.is_in_group(targetGroup):
			Root.getMainNode().TakeDamage()
		if !body.is_in_group(ownerGroup):
			consumed = true
			print_debug("consumed")
			queue_free.call_deferred()
