extends Node2D

class_name Module

const sfx_registerModule = preload("res://res/sfx/registerModule.wav")
const sfx_startup = preload("res://res/sfx/startup.wav")

@export
var subsystemsRoot : Node2D

@export
var cooldown : int = 10.0

var cabinet_prefab : PackedScene = preload("res://scenes/cabinet_section.tscn")
var cabinetSection : Control

const cabinetSize = Vector2(0.25, 0.25)
const realSize = Vector2(1, 1)

func _ready():
	pass

signal registered

var isRegistered = false
func registerModule():
	Root.getMainNode().player.playerAudio.stream = sfx_startup
	Root.getMainNode().player.playerAudio.play()
	get_tree().paused = true
	subsystems.clear()
	registerPrioritiesRecursive(subsystemsRoot)
	
	Root.getMainNode().allModules.append(self)
	
	var newSection = cabinet_prefab.instantiate()
	cabinetSection = newSection
	Root.getMainNode().cabinet.add_child(newSection)
	var label : Label = cabinetSection.get_node("Number")
	label.text = "" + str(Root.getMainNode().allModules.find(self) + 1)
	
	await Root.getMainNode().cabinet.sort_children
	for i in Root.getMainNode().getModules():
		if i != self:
			i.Refresh()
	await Switch(false)
	get_tree().paused = false
	isRegistered = true
	registered.emit()

func PickUpModule():
	if !isRegistered:
		registerModule()
		await registered
	Root.getMainNode().SwitchModule(self)

var subsystems : Array[Subsystem] = []
func registerPrioritiesRecursive(node : Node2D):
	if node is Subsystem:
		subsystems.append(node)
	for i in node.get_children():
		if i is Subsystem:
			registerPrioritiesRecursive(i)

const Opaque = Color(1, 1, 1, 1)
const Invis = Color(1, 1, 1, 0)

func Refresh():
	var isActive : bool = Root.getMainNode().currentModule == self
	Switch(isActive)

func Switch(isActive : bool):
	var label : Label = cabinetSection.get_node("Number")
	if isActive:
		var tw = self.create_tween()
		var cen : Control = get_node("/root/Main/2DUI/FullLayout/Center")
		tw.parallel().tween_property(self, "global_position", cen.global_position, 1.0).from_current().set_trans(Tween.TRANS_QUART)
		tw.parallel().tween_property(self, "scale", realSize, 1.2).from_current().set_trans(Tween.TRANS_QUAD)
		tw.parallel().tween_property(label, "modulate", Invis, 0.6).from_current().set_trans(Tween.TRANS_QUAD)
		tw.parallel().tween_property(self, "modulate", Opaque, 0.6).from_current().set_trans(Tween.TRANS_QUART)
		await tw.finished
		if Root.getMainNode().player.playerAudio.playing:
			await Root.getMainNode().player.playerAudio.finished
		Root.getMainNode().player.playerAudio.stream = sfx_registerModule
		Root.getMainNode().player.playerAudio.play()
	else:
		var tw = self.create_tween()
		tw.parallel().tween_property(self, "global_position", cabinetSection.global_position + (cabinetSection.size/2), 1.0).from_current().set_trans(Tween.TRANS_QUART)
		tw.parallel().tween_property(self, "scale", cabinetSize, 1.2).from_current().set_trans(Tween.TRANS_QUAD)
		tw.parallel().tween_property(label, "modulate", Opaque, 0.6).from_current().set_trans(Tween.TRANS_QUAD)
		tw.parallel().tween_property(self, "modulate", Opaque, 0.6).from_current().set_trans(Tween.TRANS_QUART)
		await tw.finished
	if IsDead():
		var tw = self.create_tween()
		var x = Color(0.3, 0.3, 0.3, 0.6)
		tw.parallel().tween_property(self, "modulate", x, 0.6).from_current().set_trans(Tween.TRANS_QUART)
		tw.parallel().tween_property(label, "modulate", Invis, 0.6).from_current().set_trans(Tween.TRANS_QUAD)
		await tw.finished

func DamageModule() -> bool:
	_damageSubsystem()
	RefreshList()
	return IsDead()

func _damageSubsystem():
	RecursiveApplyDamage(subsystemsRoot)

func IsDead():
	return RecursiveDamageCheck(subsystemsRoot)

func HealModule():
	RecursiveHeal(subsystemsRoot)
	RefreshList()
	Refresh()
	
func RecursiveHeal(node : Node2D):
	if node is Subsystem:
		if node.damaged:
			node.damaged = false
	for i in node.get_children():
		if i is Subsystem:
			RecursiveHeal(i)

func RecursiveApplyDamage(node : Node2D) -> bool:
	if node is Subsystem:
		if !node.damaged:
			node.DamageSubsystem()
			return true
	for i in node.get_children():
		if i is Subsystem:
			if RecursiveApplyDamage(i):
				return true
	return false

func RecursiveDamageCheck(node : Node2D) -> bool:
	if node is Subsystem:
		if !node.damaged:
			return false
	for i in node.get_children():
		if i is Subsystem:
			if !RecursiveDamageCheck(i):
				return false
	return true

func Push():
	await Switch(true)
	EquipSubsystems()
	RefreshList()

func Pop():
	await Switch(false)
	UnequipSubsystems()

func RefreshList():
	var dump : String = "console."+ self.name.to_lower() + ".launched()\n";
	dump += "/subsystem.s\n\n"
	dump += RecursiveSubsystemsList(subsystemsRoot)
	Root.getMainNode().typeConsole(dump)

func RecursiveSubsystemsList(node : Node2D) -> String:
	var tokens : String = ""
	if node is Subsystem:
		var token = node.name.replace(" ", "").to_camel_case()
		if node.damaged:
			token = "[ERROR]broken." + token
		token += "\n";
		tokens += token
	for i in node.get_children():
		if i is Subsystem:
			tokens += RecursiveSubsystemsList(i)
	return tokens

func RecursiveEquip(node : Node2D, equipOn : bool):
	if node is Subsystem:
		if equipOn:
			node.EquipSubsystem()
		else:
			node.UnequipSubsystem()
	for i in node.get_children():
		if i is Subsystem:
			RecursiveEquip(i, equipOn)

func EquipSubsystems() -> void:
	RecursiveEquip(subsystemsRoot, true)
func UnequipSubsystems() -> void:
	RecursiveEquip(subsystemsRoot, false)
