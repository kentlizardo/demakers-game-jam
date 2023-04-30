extends Node3D

class_name EnemyDriver

const sfx_passive = preload("res://res/sfx/passive.wav")
const sfx_hostile = preload("res://res/sfx/hostile.wav")
const sfx_hit = preload("res://res/sfx/hit.wav")
const sfx_death = preload("res://res/sfx/death.wav")

var boundEnemy : Enemy:
	set(val):
		if boundEnemy != null and boundEnemy != val:
			boundEnemy.drivers.remove_at(boundEnemy.drivers.find(self))
		if boundEnemy != val:
			boundEnemy = val
			if val != null:
				boundEnemy.drivers.append(self)
			if val == null:
				DeadDrive()
	get:
		return boundEnemy
func Bind(enemy : Enemy):
	boundEnemy = enemy
func Unbind():
	boundEnemy = null

@export
var enemyAudio : AudioStreamPlayer3D

@export
var screenAnim : AnimationPlayer

@export
var awareness : EnemyAwareness

@export
var maxHealth = 2
var health = maxHealth

var lights : Array[Light3D] = []
var PassiveColor : Color
const HostileColor = Color(0.8, 0.3, 0.3)
const InactiveColor = Color(0.0, 0.0, 0.0, 0.0)

func getTarget() -> Node3D:
	return awareness.target

func _ready():
	awareness.target_detected.connect(HostileDrive)
	awareness.target_hidden.connect(PassiveDrive)
	for i in get_children():
		if i is Light3D:
			lights.append(i)
	for i in lights:
		PassiveColor = i.light_color

func _process(delta : float):
	if awareness.detected:
		look_at(awareness.target.position)
	if iframes >= 0:
		iframes -= delta

var iframes = 0.0
const iframesOnHit = 0.3
func Damage(prj : Projectile):
	if iframes > 0:
		return
	iframes += iframesOnHit
	health -= prj.damage
	if screenAnim.has_animation("hit"):
		screenAnim.play("hit")
	if health <= 0:
		Unbind()
	else:
		if enemyAudio:
			enemyAudio.stream = sfx_hit
			enemyAudio.play()

func PassiveDrive():
	setColor(PassiveColor)
	if enemyAudio:
		enemyAudio.stream = sfx_passive
		enemyAudio.play()
	
func HostileDrive():
	setColor(HostileColor)
	if enemyAudio:
		enemyAudio.stream = sfx_hostile
		enemyAudio.play()

func DeadDrive():
	setColor(InactiveColor)
	if enemyAudio:
		enemyAudio.stream = sfx_death
		enemyAudio.play()

func setColor(color : Color):
	for i in lights:
		var tw = i.create_tween()
		tw.tween_property(i, "light_color", color, 0.2).from_current()
