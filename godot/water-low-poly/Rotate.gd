extends Spatial

export var rate: float = 0.5

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var r = get_rotation()
	r.y += rate * (2.0 * PI) * delta
	set_rotation(r)
