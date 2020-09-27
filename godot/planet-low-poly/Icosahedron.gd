class_name Icosahedron

var vertices: Array
var vertex_radius: Array
var subdivides : Dictionary
var faces : Array
var vertex_adjacent: Array

func get_vertex_count():
	return vertices.size()

func get_vertices():
	return vertices
	
func get_vertex_adjacency():
	return vertex_adjacent
	
func get_faces():
	return faces
	
func filter_faces(indices):
	var filtered = []
	for idx in indices:
		filtered.push_back(faces[idx])
	faces = filtered

func subdiv_key(v1i : int, v2i : int):
	if v1i < v2i:
		return String(v1i) + "|" + String(v2i)
	else:
		return String(v2i) + "|" + String(v1i)

func push_back_subdivided_vertex(v1i : int, v2i : int, v12 : Vector3):
	var v12i : int
	var k : String = subdiv_key(v1i, v2i)
	if not subdivides.has(k):
		subdivides[k] = vertices.size()
		v12i = vertices.size()
		vertices.push_back(v12)
	else:
		v12i = subdivides.get(k)
	return v12i

func track_adjacent_vertices(v1i : int, v2i : int, v3i : int):
	# assume vertex_adjacent is the correct size.
	vertex_adjacent[v1i].push_back(v2i)
	vertex_adjacent[v1i].push_back(v3i)
	vertex_adjacent[v2i].push_back(v1i)
	vertex_adjacent[v2i].push_back(v3i)
	vertex_adjacent[v3i].push_back(v1i)
	vertex_adjacent[v3i].push_back(v2i)

func subdivide_face(v1i : int, v2i : int, v3i : int, depth : int):
	if depth == 0:
		var vs : Array = []
		vs.push_back(v1i)
		vs.push_back(v2i)
		vs.push_back(v3i)
		faces.push_back(vs)
		track_adjacent_vertices(v1i, v2i, v3i)
		return
	
	var v1 : Vector3 = vertices[v1i]
	var v2 : Vector3 = vertices[v2i]
	var v3 : Vector3 = vertices[v3i]
	
	var v12 = (v1 + v2).normalized()
	var v23 = (v2 + v3).normalized()
	var v31 = (v3 + v1).normalized()
	
	var v12i : int = push_back_subdivided_vertex(v1i, v2i, v12)
	var v23i : int = push_back_subdivided_vertex(v2i, v3i, v23)
	var v31i : int = push_back_subdivided_vertex(v3i, v1i, v31)
	
	subdivide_face(v1i, v12i, v31i, depth - 1)
	subdivide_face(v2i, v23i, v12i, depth - 1)
	subdivide_face(v3i, v31i, v23i, depth - 1)
	subdivide_face(v12i, v23i, v31i, depth - 1)
	
	return

func generate_shape(subs: int):
	var t : float = (1.0 + sqrt(5.0)) / 2.0;
	
	subdivides = {}
	vertices = []
	faces = []
	
	vertices.push_back(Vector3(-1, t, 0).normalized())
	vertices.push_back(Vector3(1, t, 0).normalized())
	vertices.push_back(Vector3(-1, -t, 0).normalized())
	vertices.push_back(Vector3(1, -t, 0).normalized())
	vertices.push_back(Vector3(0, -1, t).normalized())
	vertices.push_back(Vector3(0, 1, t).normalized())
	vertices.push_back(Vector3(0, -1, -t).normalized())
	vertices.push_back(Vector3(0, 1, -t).normalized())
	vertices.push_back(Vector3(t, 0, -1).normalized())
	vertices.push_back(Vector3(t, 0, 1).normalized())
	vertices.push_back(Vector3(-t, 0, -1).normalized())
	vertices.push_back(Vector3(-t, 0, 1).normalized())

	var init_faces : Array = []
	init_faces.push_back([5, 11, 0])
	init_faces.push_back([1, 5, 0])
	init_faces.push_back([7, 1, 0])
	init_faces.push_back([10, 7, 0])
	init_faces.push_back([11, 10, 0])
	init_faces.push_back([9, 5, 1])
	init_faces.push_back([4, 11, 5])
	init_faces.push_back([2, 10, 11])
	init_faces.push_back([6, 7, 10])
	init_faces.push_back([8, 1, 7])
	init_faces.push_back([4, 9, 3])
	init_faces.push_back([2, 4, 3])
	init_faces.push_back([6, 2, 3])
	init_faces.push_back([8, 6, 3])
	init_faces.push_back([9, 8, 3])
	init_faces.push_back([5, 9, 4])
	init_faces.push_back([11, 4, 2])
	init_faces.push_back([10, 2, 6])
	init_faces.push_back([7, 6, 8])
	init_faces.push_back([1, 8, 9])

	vertex_adjacent.resize(20 * pow(4, subs))
	for i in range(vertex_adjacent.size()):
		vertex_adjacent[i] = []

	for f in init_faces:
		subdivide_face(f[0], f[1], f[2], subs)

	set_radius(1.0)
	
func create_mesh(m : ArrayMesh, r : float):
	var st : SurfaceTool = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var r_min = vertex_radius.min()
	var r_max = vertex_radius.max()
	var dr_min = 2 * (r - r_min)
	var dr_max = 2 * (r_max - r)
	if dr_min == 0:
		dr_min = 1
	if dr_max == 0:
		dr_max = 1
	
	for f in faces:
		var e1 : Vector3 = vertices[f[1]] - vertices[f[0]]
		var e2 : Vector3 = vertices[f[2]] - vertices[f[0]]
		var norm : Vector3 = e1.cross(e2).normalized()
		for vi in f:
			var v : Vector3 = vertices[vi]
			var vr = vertex_radius[vi]
			if vr < r:
				st.add_uv(Vector2((vr - r_min) / dr_min, 0.0))
			else:
				st.add_uv(Vector2(1.0 - (r_max - vr) / dr_max, 0.0))
			st.add_normal(-1.0 * norm)
			st.add_vertex(v * vr)
	
	return st.commit(m)

func create_mesh_with_depth(m: ArrayMesh, depth: float):
	var st: SurfaceTool = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var min_radius = vertex_radius.min()
	var max_radius = vertex_radius.max()
	var delta_radius = max_radius - min_radius
	if delta_radius == 0:
		delta_radius = 1.0
	
	var vis = [0, 1, 2, 0]
	
	for f in faces:
		var e1: Vector3 = vertices[f[1]] - vertices[f[0]]
		var e2: Vector3 = vertices[f[2]] - vertices[f[0]]
		var norm_top : Vector3 = e1.cross(e2).normalized()
		for i in range(f.size() - 1, -1, -1): #bottom of the cloud
			var v: Vector3 = vertices[f[i]]
			st.add_uv(Vector2(0.0, 0.0))
			st.add_normal(norm_top)
			st.add_vertex(v * vertex_radius[f[i]])
			
		for vi in f: #top of the cloud
			var v: Vector3 = vertices[vi]
			st.add_uv(Vector2(1.0, 0.0))
			st.add_normal(-1.0 * norm_top)
			st.add_vertex(v * (vertex_radius[vi] + depth))
		
		for i in range(vis.size() - 1):
			var v0: Vector3 = vertices[f[vis[i]]]
			var v1: Vector3 = vertices[f[vis[i + 1]]]
			var e1_side: Vector3 = v1 - v0
			var e2_side: Vector3 = v0
			var norm_side: Vector3 = -1.0 * e1_side.cross(e2_side).normalized()
			
			st.add_uv(Vector2(0.0, 0.0))
			st.add_normal(norm_side)
			st.add_vertex(v0 * vertex_radius[f[vis[i]]])
			
			st.add_uv(Vector2(0.0, 0.0))
			st.add_normal(norm_side)
			st.add_vertex(v1 * vertex_radius[f[vis[i + 1]]])

			st.add_uv(Vector2(1.0, 0.0))
			st.add_normal(norm_side)
			st.add_vertex(v0 * (vertex_radius[f[vis[i]]] + depth))
			
			st.add_uv(Vector2(1.0, 0.0))
			st.add_normal(norm_side)
			st.add_vertex(v0 * (vertex_radius[f[vis[i]]] + depth))

			st.add_uv(Vector2(1.0, 0.0))
			st.add_normal(norm_side)
			st.add_vertex(v1 * vertex_radius[f[vis[i + 1]]])
			
			st.add_uv(Vector2(1.0, 0.0))
			st.add_normal(norm_side)
			st.add_vertex(v1 * (vertex_radius[f[vis[i + 1]]] + depth))
			
	return st.commit(m)

func raise_area(v1i: int, r: int, height: float):
	var to_raise: Dictionary = {}
	var raise: Array = []
	var d: Array = []
	raise.push_back(v1i)
	d.push_back(r)
	
	while not raise.empty():
		var vi = raise.front()
		raise.pop_front()
		var di = d.front()
		d.pop_front()
		
		if to_raise.has(vi):
			continue
		
		to_raise[vi] = true
		if di > 0:
			for v2i in vertex_adjacent[vi]:
				raise.push_back(v2i)
				d.push_back(di - 1)

	for vi in to_raise.keys():
		vertex_radius[vi] += height

func set_radius(r: float):
	vertex_radius = []
	for v in vertices:
		vertex_radius.push_back(r)
