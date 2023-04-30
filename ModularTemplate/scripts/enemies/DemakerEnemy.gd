extends Enemy

var initialSize : int

func _ready():
	super()
	initialSize = self.drivers.size()

var compleated = false
func CompleteDemake():
	compleated = true
	Root.getMainNode().NextLevel()
	await Die()

func _process(delta):
	if !compleated:
		if self.drivers.size() < initialSize:
			CompleteDemake()
