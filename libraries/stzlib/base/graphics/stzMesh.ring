#---------------------------------------------------------------------------#
#  STZMESH -- geometry: a primitive, a file, or your own vertex layout.     #
#---------------------------------------------------------------------------#
#
#     oCube = StzMeshQ(:Cube)
#     oBall = new stzMesh([ :Sphere, 1.0, 32, 16 ])
#     oPart = StzMeshFromObjQ(read("part.obj"))
#     ? oCube.VertexCount()  ? oCube.Format()      # "3,3,2"
#
# A mesh knows its own ATTRIBUTE LAYOUT, and its pipeline is derived from
# it -- so adding an attribute (a vertex colour today, skin weights when
# animation arrives) needs no change in the renderer. Format() is that
# hinge, made visible.
#
# Cube note worth knowing: a cube is 24 vertices, not 8. A shared corner
# cannot carry three different face normals, and sharing them is how a
# cube ends up shaded like a sphere.

func StzMeshQ(pWhat)
	return new stzMesh(pWhat)

func StzMeshFromObjQ(pcObjText)
	return new stzMesh([ :Obj, pcObjText ])

# Holds a piece of 3D geometry in the engine, a primitive, an OBJ file or your own vertex layout, and reports its counts and format.
#
# A mesh knows its own attribute layout and the pipeline that draws it is derived from that layout,
# so a new attribute needs no change in the renderer; Format is that layout made visible. A cube is
# 24 vertices and not 8, because a shared corner cannot carry three face normals. The mesh lives in
# the engine and is released with Free; after that its counts answer -1. Building a mesh draws
# nothing and opens no window.
#
#   receiver   o1 = new stzMesh(:Cube)
#   example    ? o1.VertexCount()
#              #--> 24
#              ? o1.TriangleCount()
#              #--> 12
#              ? o1.Format()
#              #--> 3,3,2
#              ? o1.Stride()
#              #--> 8
#              o2 = new stzMesh([ :Sphere, 1.0, 8, 4 ])
#              ? o2.VertexCount()
#              #--> 45
#              ? o2.TriangleCount()
#              #--> 64
#              o1.Free()
#              ? o1.IsAlive()
#              #--> 0
#   see        stzScene, stzMaterialMaker, stzMaterialGraph
class stzMesh from stzObject

	@nId = 0
	@cKind = ""

	# Builds a mesh in the engine from a primitive, an OBJ text or a custom vertex layout, and keeps its handle.
	#
	#   pWhat      a kind as a symbol, :Cube, :Sphere, :Torus or :Plane, or a list such as [ :Cube,
	#              nSize ], [ :Sphere, nRadius, nSegments, nRings ], [ :Torus, nRingRadius,
	#              nTubeRadius, nSegments, nSides ], [ :Plane, nSize ], [ :Obj, cObjText ] or [
	#              :Custom, aComponentCounts, aVertices, aIndices ]
	#   returns    nothing; the object is built
	#   note       omitted numbers take defaults: size 1, sphere 24 segments and 12 rings, torus
	#              0.35 tube radius, 64 segments and 32 sides; StzMeshQ and StzMeshFromObjQ build
	#              the same object
	#   warning    an empty list raises error stzMesh: nothing to build; an unknown kind raises
	#              error stzMesh: unknown kind ... use :Cube, :Sphere, :Torus, :Plane, :Obj or
	#              :Custom; an OBJ text with no v and f lines, or a custom layout whose vertex count
	#              does not divide evenly or whose index is out of range, raises an error saying the
	#              engine refused it
	#   see        Kind, Format, Free
	#@ aka  pWhat is :Cube / :Sphere / :Plane, or a list: [ :Cube, nSize ] [ :Sphere, nRadius, nSegments, nRings ] [ :Plane, nSize ] [ :Obj, cObjText ] [ :Custom, aComponentCounts, aVertices, aIndices ]
	def init(pWhat)
		_aW_ = pWhat
		if NOT isList(_aW_)
			_aW_ = [ pWhat ]
		ok
		if len(_aW_) = 0
			StzRaise("stzMesh: nothing to build.")
		ok
		@cKind = lower("" + _aW_[1])

		switch @cKind
		on "cube"
			@nId = StzEngineGpuMeshCube(_StzMeshArg(_aW_, 2, 1))
		on "sphere"
			@nId = StzEngineGpuMeshSphere(_StzMeshArg(_aW_, 2, 1),
				_StzMeshArg(_aW_, 3, 24), _StzMeshArg(_aW_, 4, 12))
		on "plane"
			@nId = StzEngineGpuMeshPlane(_StzMeshArg(_aW_, 2, 1))
		on "obj"
			if len(_aW_) < 2
				StzRaise("stzMesh: [ :Obj, cText ] needs the OBJ text.")
			ok
			@nId = StzEngineGpuMeshFromObj("" + _aW_[2])
			if @nId = 0
				StzRaise("stzMesh: that OBJ text has no usable geometry " +
					"(needs v lines and f faces).")
			ok
		on "torus"
			# [ :Torus, nRingRadius, nTubeRadius, nSegments, nSides ]
			@nId = StzEngineGpuMeshTorus(_StzMeshArg(_aW_, 2, 1),
				_StzMeshArg(_aW_, 3, 0.35),
				_StzMeshArg(_aW_, 4, 64), _StzMeshArg(_aW_, 5, 32))
		on "custom"
			if len(_aW_) < 4
				StzRaise("stzMesh: [ :Custom, aComps, aVerts, aIndices ].")
			ok
			@nId = StzEngineGpuMeshCustom(_aW_[2], _aW_[3], _aW_[4])
			if @nId = 0
				StzRaise("stzMesh: that custom layout was refused -- check " +
					"that the vertex count divides evenly and every index " +
					"is in range.")
			ok
		other
			StzRaise("stzMesh: unknown kind '" + @cKind + "' -- use :Cube, " +
				":Sphere, :Torus, :Plane, :Obj or :Custom.")
		off

		if @nId = 0
			StzRaise("stzMesh: the engine refused to build a " + @cKind + ".")
		ok

	# Returns the engine handle of the mesh.
	#
	#   returns    a number above 0, or 0 after Free
	#   see        IsAlive, Free
	def Id_()
		return @nId

	# Returns the kind the mesh was built as, in lower case.
	#
	#   returns    the kind as text, such as cube, sphere, obj or custom
	#   see        Format
	def Kind()
		return @cKind

	# TRUE if the engine still holds the mesh.
	#
	#   returns    TRUE or FALSE, as 1 or 0; 0 after Free
	#   see        Free, Id_
	def IsAlive()
		return len(StzEngineGpuMeshStats(@nId)) > 0

	# Returns how many vertices the mesh holds.
	#
	#   returns    a number; -1 after Free
	#   note       a cube has 24, not 8, because a shared corner cannot carry three face normals; a
	#              sphere of 8 segments and 4 rings has (8 + 1) x (4 + 1) = 45
	#   see        IndexCount, TriangleCount
	def VertexCount()
		return _StzMeshStat(@nId, 1)

	# Returns how many indices the mesh holds, three per triangle.
	#
	#   returns    a number; -1 after Free
	#   note       a cube has 36
	#   see        TriangleCount, VertexCount
	def IndexCount()
		return _StzMeshStat(@nId, 2)

	# Returns how many triangles the mesh draws.
	#
	#   returns    a number, the index count divided by three; a negative fraction after Free
	#   note       a cube has 12 and a plane 2
	#   see        IndexCount, VertexCount
	def TriangleCount()
		return _StzMeshStat(@nId, 2) / 3

	# Returns how many attributes each vertex carries.
	#
	#   returns    a number such as 3 for position, normal and texture coordinates; -1 after Free
	#   note       a custom layout of [ 3 ] has one
	#   see        Stride, Format
	def AttributeCount()
		return _StzMeshStat(@nId, 3)

	# Returns how many floats make up one vertex.
	#
	#   returns    a number such as 8; -1 after Free
	#   note       the sum of the components in Format
	#   see        AttributeCount, Format
	#@ aka  Floats per vertex.
	def Stride()
		return _StzMeshStat(@nId, 4)

	# Returns the vertex layout as text, the components of each attribute, from which the pipeline is built.
	#
	#   returns    text such as 3,3,2 for position, normal and texture coordinates; an empty text
	#              after Free
	#   note       extending the mesh with an attribute extends this text and nothing else
	#   see        Stride, AttributeCount
	#@ aka  The vertex format the pipeline is built from ("3,3,2"). Derived from the attributes -- extending the mesh extends this, and nothing else.
	def Format()
		_a_ = StzEngineGpuMeshStats(@nId)
		if len(_a_) < 5
			return ""
		ok
		return _a_[5]

	# Releases the mesh in the engine and zeroes the handle.
	#
	#   returns    nothing; Id_ then answers 0
	#   note       freeing twice does nothing the second time
	#   see        IsAlive, Id_
	def Free()
		if @nId > 0
			StzEngineGpuMeshFree(@nId)
			@nId = 0
		ok

func _StzMeshArg(paList, pnAt, pnDefault)
	if len(paList) >= pnAt and isNumber(paList[pnAt])
		return paList[pnAt]
	ok
	return pnDefault

func _StzMeshStat(pnId, pnAt)
	_a_ = StzEngineGpuMeshStats(pnId)
	if len(_a_) < pnAt
		return -1
	ok
	return _a_[pnAt]
