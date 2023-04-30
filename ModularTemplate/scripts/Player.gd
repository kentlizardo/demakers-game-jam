extends CharacterBody3D

class_name Player

const SPEED = 5.5
const JUMP_VELOCITY = 5.5

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready
var lookPivot : Node3D = $LookPivot
@onready
var weaponPivot : Node3D = $LookPivot/WeaponPivot
@onready
var secondaryPivot : Node3D = $LookPivot/SecondaryPivot
@onready
var playerAudio : AudioStreamPlayer3D = $LookPivot/PlayerAudio
@onready
var writerAudio : AudioStreamPlayer3D = $LookPivot/WriterAudio

var weaponStockPile : Dictionary = {}
	
func equipWeaponStockPile(weaponSubsystem : Subsystem, weaponSet: Array[Weapon]):
	if !weaponStockPile.has(weaponSubsystem):
		weaponStockPile[weaponSubsystem] = weaponSet
		refreshWeaponStockpile()
func unequipWeaponStockPile(weaponSubsystem : Subsystem):
	weaponStockPile.erase(weaponSubsystem)
	refreshWeaponStockpile()
func refreshWeaponStockpile():
	if weaponStockPile.size() == 0:
		currentWeapons = []
		return;
	var activeSystem : Subsystem = null
	for i in weaponStockPile.keys():
		var weaponPriority = i.GetModule().subsystems.find(i);
		if activeSystem == null or weaponPriority < activeSystem.GetModule().subsystems.find(activeSystem):
			activeSystem = i
	currentWeapons = weaponStockPile[activeSystem]

var currentWeapons : Array[Weapon] = []:
	set(val):
		if val != currentWeapons:
			for i in currentWeapons:
				i.SetMeshesVisible(false)
			currentWeapons = val
			if currentWeapons.size() > 1:
				currentWeapons[1].global_position = secondaryPivot.global_position
			for i in currentWeapons:
				i.SetMeshesVisible(true)
	get:
		return currentWeapons

func _input(event):
	if Input.is_action_just_pressed("fire") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		FireVolley(false)
	if Input.is_action_just_pressed("secondary") and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		FireVolley(true)

func FireVolley(isSecondary : bool):
	if currentWeapons.size() > 0:
		for i in currentWeapons:
			if isSecondary:
				if i.secondary == "":
					continue;
			if i.Shoot(isSecondary):
				return;

var horizontalMov : Vector2 = Vector2.ZERO
var verticalMov : Vector2 = Vector2.ZERO
var dashAccel : Vector2 = Vector2.ZERO
var dashVelocity : Vector3 = Vector3.ZERO
var moveVelocity : Vector3 = Vector3.ZERO
var canJump : bool = false

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and canJump:
		velocity.y = JUMP_VELOCITY

	var direction = (transform.basis * Vector3(horizontalMov.x, 0, verticalMov.y)).normalized()
	if direction:
		moveVelocity.x = direction.x * SPEED
		moveVelocity.z = direction.z * SPEED
	else:
		moveVelocity.x = move_toward(moveVelocity.x, 0, SPEED)
		moveVelocity.z = move_toward(moveVelocity.z, 0, SPEED)
	
	horizontalMov = Vector2.ZERO
	verticalMov = Vector2.ZERO
	
	var dashDirection = (transform.basis * Vector3(dashAccel.x, 0, dashAccel.y)).normalized()
	if dashDirection:
		dashVelocity.x = dashDirection.x * 50
		dashVelocity.z = dashDirection.z * 50
		dashAccel = Vector2.ZERO
	
	dashVelocity.x = move_toward(dashVelocity.x, 0, SPEED)
	dashVelocity.z = move_toward(dashVelocity.z, 0, SPEED)
	
	velocity.x = moveVelocity.x + dashVelocity.x
	velocity.z = moveVelocity.z + dashVelocity.z
	
	move_and_slide()
