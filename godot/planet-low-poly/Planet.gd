extends MeshInstance

export var raise_land_ops: int = 20
export var raise_radius: int = 2
export var land_height: float = 0.5
export var ocean_height: float = 0.4
export var radius: float = 5
export var subdivisions: int = 4
export var rotation_rate: float = 1.0

export var land_material: Material
export var ocean_material: Material

func create_land(m: ArrayMesh):
	var land: Icosahedron = Icosahedron.new()
	land.generate_shape(subdivisions)
	land.set_radius(radius)
	for i in range(raise_land_ops):
		land.raise_area(randi() % land.get_vertex_count(), raise_radius, land_height)
		
	return land.create_mesh(m, radius + ocean_height)

func create_ocean(m: ArrayMesh):
	var ocean: Icosahedron = Icosahedron.new()
	ocean.generate_shape(subdivisions)
	ocean.set_radius(radius + ocean_height)
	return ocean.create_mesh(m, radius + ocean_height)

func _enter_tree():
	randomize()
	var m = ArrayMesh.new()	
	m = create_land(m)
	m = create_ocean(m)
	mesh = m
	set_surface_material(0, land_material)
	set_surface_material(1, ocean_material)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var r: Vector3 = get_rotation()
	r.y = r.y + delta * rotation_rate
	set_rotation(r)
	pass
