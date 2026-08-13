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

class stzMesh from stzObject

	@nId = 0
	@cKind = ""

	# pWhat is :Cube / :Sphere / :Plane, or a list:
	#   [ :Cube, nSize ]   [ :Sphere, nRadius, nSegments, nRings ]
	#   [ :Plane, nSize ]  [ :Obj, cObjText ]
	#   [ :Custom, aComponentCounts, aVertices, aIndices ]
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

	def Id_()
		return @nId

	def Kind()
		return @cKind

	def IsAlive()
		return len(StzEngineGpuMeshStats(@nId)) > 0

	def VertexCount()
		return _StzMeshStat(@nId, 1)

	def IndexCount()
		return _StzMeshStat(@nId, 2)

	def TriangleCount()
		return _StzMeshStat(@nId, 2) / 3

	def AttributeCount()
		return _StzMeshStat(@nId, 3)

	# Floats per vertex.
	def Stride()
		return _StzMeshStat(@nId, 4)

	# The vertex format the pipeline is built from ("3,3,2"). Derived from
	# the attributes -- extending the mesh extends this, and nothing else.
	def Format()
		_a_ = StzEngineGpuMeshStats(@nId)
		if len(_a_) < 5
			return ""
		ok
		return _a_[5]

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
