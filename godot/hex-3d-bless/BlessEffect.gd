extends Spatial


export var m_period = 2.0
export var m_color = Color(0.9, 0.9, 1.0)
var m_t = 0

onready var m_layers = [
	$"tile-blessing0",
	$"tile-blessing1",
	$"tile-blessing2",
	$"tile-blessing3"
]

# Called when the node enters the scene tree for the first time.
func _ready():
	
	for layer in m_layers:
		layer.get_surface_material(0).set_shader_param("color", m_color)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	m_t += delta
	
	for i in m_layers.size():
		var layer = m_layers[i]

		var t = m_t + i * m_period / m_layers.size()
		t = (t - m_period * floor(t / m_period)) / m_period

		layer.set_scale(Vector3(t, (1.0 - t) + 0.2, t))
		layer.get_surface_material(0).set_shader_param("alpha", (1.0 - t))
	
	pass
