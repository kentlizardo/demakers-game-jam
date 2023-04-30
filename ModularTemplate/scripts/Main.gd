extends Node

class_name Main

const sfx_damageModule = preload("res://res/sfx/damageModule.wav")
const sfx_damageSubsystem = preload("res://res/sfx/damageSubsystem.wav")
const sfx_keyPress = preload("res://res/sfx/keyPress.wav")
const sfx_lineBreak = preload("res://res/sfx/lineBreak.wav")

@export
var cabinet : HBoxContainer
@export
var center : Control
@export
var startingModule : Module
@export
var subsystemsList : RichTextLabel

@export
var currentLevel : Level

var allModules : Array[Module] = []
func getModules() -> Array[Module]:
	return allModules

@export
var player : Player

var currentModule : Module
var currentlySwitching = false
func SwitchModule(val : Module):
	if currentlySwitching:
		return;
	if val:
		if val.IsDead():
			return
	if currentModule == val:
		return;
	currentlySwitching = true
	get_tree().paused = true
	if currentModule != null:
		await currentModule.Pop()
	currentModule = val
	if val != null:
		val.get_parent().move_child(val, val.get_child_count() - 1)
		await currentModule.Push()
	currentlySwitching = false
	get_tree().paused = false

var promptedItem : Item = null:
	set(val):
		if val == null:
			pass
		if promptedItem != val:
			promptedItem = val
	get:
		return promptedItem

func setCaption(txt : String):
	var label : Label = get_node("2DUI/FullLayout/MainCaption")
	label.text = txt

var consoleDump : Array[String] = []:
	set(val):
		consoleDump = val
	get:
		return consoleDump

func typeConsole(dump : String, lineBreakTime : float = 0.01, charBreakTime : float = 0.003):
	charTimerSet = charBreakTime
	lineTimerSet = lineBreakTime
	
	subsystemsList.clear()
	consoleDump = []
	charBuffer = ""
	
	for i in dump.split("\n"):
		consoleDump.append(i)
	terminalWriting = true

var charTimerSet = 0.0
var lineTimerSet = 0.0

var charTimer = 0.0
var lineTimer = 0.0

var charBuffer : String = ""
var popNumber : int = 0


var terminalWriting = false
var oldTerminalWriting = false
signal terminalBufferFinished
func writeToTerminalBuffer(delta):
	terminalWriting = false
	if charBuffer.length() > 0:
		terminalWriting = true
		if charTimer < 0:
			var char : String = charBuffer[0]
			charBuffer = charBuffer.substr(1, -1)
			subsystemsList.append_text(char)
			player.writerAudio.stream = sfx_keyPress
			player.writerAudio.play()
			charTimer = charTimerSet
		else:
			charTimer -= delta
	else:
		for i in range(0, popNumber):
			subsystemsList.pop()
		if consoleDump.size() > 0:
			terminalWriting = true
			if lineTimer < 0:
				player.writerAudio.stream = sfx_lineBreak
				player.writerAudio.play()
				
				var line : String = consoleDump.front()
				consoleDump.remove_at(consoleDump.find(line))
				charBuffer = line + "\n";
				popNumber = 0
				if line.begins_with("[ERROR]"):
					subsystemsList.push_color(Color('#DC143C'))
					popNumber += 1
				lineTimer = lineTimerSet
			else:
				lineTimer -= delta
	if terminalWriting != oldTerminalWriting:
		if !terminalWriting:
			terminalBufferFinished.emit()
	oldTerminalWriting = terminalWriting


var isReady : bool = false

const page1 = "[ERROR]/subsystem.s permanently disabled
[ERROR]/time.date.system.s permanently disabled
Attempting to search for a backup."
const page2 = "[ERROR]DATA(\"root.consoles.*\") is corrupted
Attempting to search for a backup online
[ERROR]Connection was destroyed..."
const page3 = "[ERROR]/subsystem.s permanently disabled
/sensors.* have recorded new stimulus data
/sensors.* sending signal
[WARNING]MODE.HIBERNATION is ending. switching to MODE.STANDBY"

func _ready():
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	isReady = true
	typeConsole(page1, 0.2, 0.03)
	await terminalBufferFinished
	typeConsole(page2, 0.2, 0.03)
	await terminalBufferFinished
	typeConsole(page3, 0.2, 0.03)
	await terminalBufferFinished
	get_tree().paused = false

func FindRemainingModule() -> Module:
	var module = null
	for i in getModules():
		if !i.IsDead():
			module = i
	return module

var iframes = 0.0
const iframesOnHit = 0.1
func TakeDamage():
	if iframes > 0:
		return
	if currentModule.DamageModule():
		player.playerAudio.stream = sfx_damageModule
		player.playerAudio.play()
		var nextModule = FindRemainingModule()
		if nextModule != null:
			SwitchModule(nextModule)
		else:
			# No more modules
			Lose()
	else:
		player.playerAudio.stream = sfx_damageSubsystem
		player.playerAudio.play()
	iframes += iframesOnHit

func Lose():
	Respawn()

const page5 = "[WARNING]MotherBoard(3.0L) systems engaged
[WARNING]remaining data of MotherBoard(3.0L) systems does not exist.
[ERROR]Unable to load next chamber of demaker.MotherBoard
[ERROR]/subsystem.s failing...
[ERROR]DATA(\"root.consoles.*\") is being lost...
[WARNING]MODE.COMBAT is ending. switching to MODE.HIBERNATION"

func CompleteGame():
	SwitchModule(null)
	typeConsole(page5, 0.2, 0.03)
	await terminalBufferFinished
	var tw = self.create_tween()
	tw.tween_property(get_node("2DUI/FullLayout/OverlayColor"), "modulate", Color(1, 1, 1, 1), 4.0).from_current().set_trans(Tween.TRANS_QUINT)
	await tw.finished
	get_tree().quit()

func Respawn():
	player.global_position = currentLevel.spawnPoint.global_position
	player.global_rotation = currentLevel.spawnPoint.global_rotation
	HealAll()

func NextLevel():
	if currentLevel.nextLevel:
		currentLevel = currentLevel.nextLevel
		Respawn()
	else:
		CompleteGame()

func HealAll():
	for i in allModules:
		i.HealModule()
	
func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta):
	writeToTerminalBuffer(delta)
	if iframes > 0:
		iframes -= delta
	if promptedItem != null:
		setCaption(promptedItem.GetHoverText())
	else:
		setCaption("")
	if Input.is_action_just_pressed("ui_page_down"):
		TakeDamage()
	if Input.is_action_just_pressed("pick_up"):
		if promptedItem != null:
			promptedItem.PickUp()
	if Input.is_action_just_pressed("m1"):
		if getModules().size() >= 1:
			SwitchModule(getModules()[0])
	if Input.is_action_just_pressed("m2"):
		if getModules().size() >= 2:
			SwitchModule(getModules()[1])
	if Input.is_action_just_pressed("m3"):
		if getModules().size() >= 3:
			SwitchModule(getModules()[2])
	if Input.is_action_just_pressed("m4"):
		if getModules().size() >= 4:
			SwitchModule(getModules()[3])
	if Input.is_action_just_pressed("m5"):
		if getModules().size() >= 5:
			SwitchModule(getModules()[4])
	if Input.is_action_just_pressed("m6"):
		if getModules().size() >= 6:
			SwitchModule(getModules()[5])
	if Input.is_action_just_pressed("m7"):
		if getModules().size() >= 7:
			SwitchModule(getModules()[6])
