extends MeshInstance

export var cloud_depth: float = 0.2
export var cloud_count: int = 30
export var cloud_vertices: int = 3
export var cloud_radius: float = 0.5
export var radius: float = 5
export var subdivisions: int = 4
export var rotation_rate: float = 1.0

export var cloud_material: Material

func _enter_tree():
	var clouds = Icosahedron.new()
	clouds.generate_shape(subdivisions)
	clouds.set_radius(radius)
	
	randomize()

	var vertices = clouds.get_vertices()
	var vertex_adjacent = clouds.get_vertex_adjacency()
	var cloud_centers: Array = []
	for i in range(cloud_count):
		var vi: int = randi() % vertices.size()
		for v in range(cloud_vertices):
			cloud_centers.push_back(vi)
			vi = vertex_adjacent[vi].front()

	var limit: float = cloud_radius  / (4.0 * radius / sqrt(10 + 2 * sqrt(5)))

	var faces = clouds.get_faces()
	var face_centers: Array = []
	for f in faces:
		var f0: Vector3 = vertices[f[0]]
		var f1: Vector3 = vertices[f[1]]
		var f2: Vector3 = vertices[f[2]]
		face_centers.push_back((f0 + f1 + f2).normalized())

	var filtered : Array = []
	for fi in range(face_centers.size()):
		var f: Vector3 = face_centers[fi]
		for ci in cloud_centers:
			var c: Vector3 = vertices[ci]
			if c.distance_to(f) < limit:
				filtered.push_back(fi)
	clouds.filter_faces(filtered)

	var m = ArrayMesh.new()	
	mesh = clouds.create_mesh_with_depth(m, cloud_depth)
	set_surface_material(0, cloud_material)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var r: Vector3 = get_rotation()
	r.y = r.y + delta * rotation_rate
	set_rotation(r)
	pass
