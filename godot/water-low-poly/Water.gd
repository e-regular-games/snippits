extends MeshInstance
tool

export(float) var height: float = 0 setget set_height, get_height
export(float) var width: float = 0 setget set_width, get_width
export(int) var sub_divisions: int = -1 setget set_subdivs, get_subdivs

var r: float = 1.0
var d: int = 1
var setup: int = 0


var vertices = []
var faces = []
var subdivides = {}

func set_subdivs(sub_divisions: int):
	d = sub_divisions
	setup |= 0x02
	complete()
	pass
	
func get_subdivs():
	return d

func set_width(w: float):
	width = w
	setup |= 0x04
	complete()
	pass
	
func get_width():
	return width;

func set_height(h: float):
	height = h
	setup |= 0x01
	complete()
	pass
	
func get_height():
	return height;

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

func subdivide_face(v1i : int, v2i : int, v3i : int, depth : int):
	if depth == 0:
		var vs : Array = []
		vs.push_back(v1i)
		vs.push_back(v2i)
		vs.push_back(v3i)
		faces.push_back(vs)
		return
	
	var v1 : Vector3 = vertices[v1i]
	var v2 : Vector3 = vertices[v2i]
	var v3 : Vector3 = vertices[v3i]
	
	var v12 = (v1 + v2) / 2
	var v23 = (v2 + v3) / 2
	var v31 = (v3 + v1) / 2
	
	var v12i : int = push_back_subdivided_vertex(v1i, v2i, v12)
	var v23i : int = push_back_subdivided_vertex(v2i, v3i, v23)
	var v31i : int = push_back_subdivided_vertex(v3i, v1i, v31)
	
	subdivide_face(v1i, v12i, v31i, depth - 1)
	subdivide_face(v2i, v23i, v12i, depth - 1)
	subdivide_face(v3i, v31i, v23i, depth - 1)
	subdivide_face(v12i, v23i, v31i, depth - 1)
	
	return

func generate_shape():
	var t : float = sqrt(3.0) / 2.0
	
	subdivides = {}
	vertices = []
	faces = []
	
	var dims: Vector3 = Vector3(width, 0, height / 2.0)
	
	vertices.push_back(dims * Vector3(0, 0, 0))
	vertices.push_back(dims * Vector3(0, 0, 1))
	vertices.push_back(dims * Vector3(0, 0, -1))
	vertices.push_back(dims * Vector3(0.5, 0, 0.5))
	vertices.push_back(dims * Vector3(-0.5, 0, 0.5))
	vertices.push_back(dims * Vector3(0.5, 0, -0.5))
	vertices.push_back(dims * Vector3(-0.5, 0, -0.5))
	
	var init_faces : Array = []
	init_faces.push_back([0, 1, 4])
	init_faces.push_back([0, 4, 6])
	init_faces.push_back([0, 6, 2])
	init_faces.push_back([0, 2, 5])
	init_faces.push_back([0, 5, 3])
	init_faces.push_back([0, 3, 1])

	for f in init_faces:
		subdivide_face(f[0], f[1], f[2], d)

func create_mesh(m : ArrayMesh):
	var st : SurfaceTool = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for f in faces:
		for vi in f:
			st.add_vertex(vertices[vi])
	
	return st.commit(m)

func complete():
	if setup != 0x07:
		return false
	
	generate_shape()
	
	var m : ArrayMesh = ArrayMesh.new()
	m = create_mesh(m)
	set_mesh(m)
		
	return true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
