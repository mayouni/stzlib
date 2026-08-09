#---------------------------------------------------------------------------#
#  STZSCENE -- a 3D scene: a camera, a light, and things placed in space.   #
#---------------------------------------------------------------------------#
#
#     oS = new stzScene(800, 600)
#     oS.SetBackground("#0c0e14")
#     oS.SetCamera(6, 4, 8, 0, 0, 0)
#     oS.SetLight(-0.5, -1, -0.4, "#fff4e0", "#2a3040")
#     oS.AddMesh(oCube, 0, 0, 0)
#     oS.SetColor(1, "#e0a030")
#     oS.ToPNG("frame.png")
#
#     # fluent -- every Q returns the SCENE
#     oS.SetCameraQ(6,4,8, 0,0,0).AddMeshQ(oCube, 0,0,0).ColorQ("#e0a030")
#
# WHAT THIS CLASS IS CAREFUL ABOUT: an instance's TRANSFORM is kept apart
# from its mesh and its material. Moving something (MoveTo, RotateTo,
# ScaleTo) re-sends matrices and never re-sends geometry -- so a physics
# or animation step can drive a scene at frame rate without touching what
# is being drawn. Stats() exposes both counters, so that claim is
# checkable rather than promised.
#
# All instances of one mesh are drawn in a SINGLE instanced call: a
# thousand cubes cost one draw, not a thousand.
#
# Project() turns a point in the scene into canvas pixels -- the bridge for
# putting a 2D label on a 3D thing.

func StzSceneQ(pnW, pnH)
	return new stzScene(pnW, pnH)

class stzScene from stzObject

	@nId = 0
	@nW = 0
	@nH = 0
	@nLast = 0          # the instance most recently added (what Q-styling hits)
	@aCam = [ 0, 0, 5, 0, 0, 0, 45, 0.1, 200 ]
	# TRANSFORM STATE, mirrored Ring-side so a partial change (move only,
	# rotate only) can be written without losing the other parts. This is
	# the CPU half of the separation the engine keeps on the GPU side.
	@aTransforms = []

	def init(pnW, pnH)
		if NOT (isNumber(pnW) and isNumber(pnH))
			StzRaise("stzScene: give a width and a height in pixels.")
		ok
		@nId = StzEngineGpuScene3dNew(pnW, pnH)
		if @nId = 0
			StzRaise("stzScene: refused a " + pnW + "x" + pnH + " scene.")
		ok
		@nW = pnW
		@nH = pnH
		This.SetCamera(0, 0, 5, 0, 0, 0)

	def Id_()
		return @nId

	def Width()
		return @nW

	def Height()
		return @nH

	# [ instances, meshesResident, drawCalls, geometryUploads, transformUploads ]
	def Stats()
		return StzEngineGpuScene3dStats(@nId)

	def InstanceCount()
		_a_ = This.Stats()
		if len(_a_) = 0
			return 0
		ok
		return _a_[1]

	#-- the frame -----------------------------------------------------------

	def SetBackground(pColor)
		StzEngineGpuScene3dClear(@nId, StzColorToNumber(pColor))

	def SetBackgroundQ(pColor)
		This.SetBackground(pColor)
		return This

	# Eye and target in scene units. Field of view, near and far are
	# optional -- 45 degrees over 0.1..200 suits most scenes.
	def SetCamera(pnEX, pnEY, pnEZ, pnTX, pnTY, pnTZ)
		# read the lens out BEFORE rebuilding the list -- reading @aCam[7]
		# inside the literal that replaces @aCam is a trap
		_aLens_ = This._Lens()
		@aCam = [ pnEX, pnEY, pnEZ, pnTX, pnTY, pnTZ,
			_aLens_[1], _aLens_[2], _aLens_[3] ]
		This._ApplyCamera()

	def SetCameraQ(pnEX, pnEY, pnEZ, pnTX, pnTY, pnTZ)
		This.SetCamera(pnEX, pnEY, pnEZ, pnTX, pnTY, pnTZ)
		return This

	def SetLens(pnFovDegrees, pnNear, pnFar)
		@aCam[7] = pnFovDegrees
		@aCam[8] = pnNear
		@aCam[9] = pnFar
		This._ApplyCamera()

	def SetLensQ(pnFovDegrees, pnNear, pnFar)
		This.SetLens(pnFovDegrees, pnNear, pnFar)
		return This

	def Camera()
		return @aCam

	# A directional light: the direction it SHINES (so 0,-1,0 is noon),
	# its colour, and the ambient that fills the shadows.
	def SetLight(pnDX, pnDY, pnDZ, pColor, pAmbient)
		StzEngineGpuScene3dLight(@nId, pnDX, pnDY, pnDZ,
			StzColorToNumber(pColor), StzColorToNumber(pAmbient))

	def SetLightQ(pnDX, pnDY, pnDZ, pColor, pAmbient)
		This.SetLight(pnDX, pnDY, pnDZ, pColor, pAmbient)
		return This

	#-- things in the scene -------------------------------------------------

	# Place a mesh. Returns nothing (the plain form's law); the index is
	# available as LastIndex(), and the Q twin keeps the chain on the scene.
	def AddMesh(poMesh, pnX, pnY, pnZ)
		if NOT isObject(poMesh)
			StzRaise("stzScene.AddMesh: give an stzMesh object.")
		ok
		_n_ = StzEngineGpuScene3dAdd(@nId, poMesh.Id_(), pnX, pnY, pnZ,
			0, 1, 0, 0, 1, 1, 1, StzColorToNumber(:White))
		if _n_ = 0
			StzRaise("stzScene.AddMesh: the mesh was refused -- is it still " +
				"alive (not Free()d)?")
		ok
		while len(@aTransforms) < _n_
			@aTransforms + [ 0, 0, 0, 0, 1, 0, 0, 1, 1, 1 ]
		end
		@aTransforms[_n_] = [ pnX, pnY, pnZ, 0, 1, 0, 0, 1, 1, 1 ]
		@nLast = _n_

	def AddMeshQ(poMesh, pnX, pnY, pnZ)
		This.AddMesh(poMesh, pnX, pnY, pnZ)
		return This

	def LastIndex()
		return @nLast

	#-- transform state (kept apart from what is drawn) ---------------------

	def MoveTo(pnIndex, pnX, pnY, pnZ)
		This._SetPart(pnIndex, [ pnX, pnY, pnZ ], NULL, NULL)

	def MoveToQ(pnIndex, pnX, pnY, pnZ)
		This.MoveTo(pnIndex, pnX, pnY, pnZ)
		return This

	def RotateTo(pnIndex, pnAX, pnAY, pnAZ, pnDegrees)
		This._SetPart(pnIndex, NULL, [ pnAX, pnAY, pnAZ, pnDegrees ], NULL)

	def RotateToQ(pnIndex, pnAX, pnAY, pnAZ, pnDegrees)
		This.RotateTo(pnIndex, pnAX, pnAY, pnAZ, pnDegrees)
		return This

	def ScaleTo(pnIndex, pnSX, pnSY, pnSZ)
		This._SetPart(pnIndex, NULL, NULL, [ pnSX, pnSY, pnSZ ])

	def ScaleToQ(pnIndex, pnSX, pnSY, pnSZ)
		This.ScaleTo(pnIndex, pnSX, pnSY, pnSZ)
		return This

	def SetColor(pnIndex, pColor)
		_n_ = StzEngineGpuScene3dSetColor(@nId, pnIndex, StzColorToNumber(pColor))
		if _n_ != 0
			StzRaise("stzScene.SetColor: there is no instance " + pnIndex + ".")
		ok

	def SetColorQ(pnIndex, pColor)
		This.SetColor(pnIndex, pColor)
		return This

	# The chain-friendly styling: acts on the instance most recently added,
	# so AddMeshQ(...).ColorQ(...) reads the way it looks.
	def Color(pColor)
		This.SetColor(@nLast, pColor)

	def ColorQ(pColor)
		This.SetColor(@nLast, pColor)
		return This

	def Move(pnX, pnY, pnZ)
		This.MoveTo(@nLast, pnX, pnY, pnZ)

	def MoveQ(pnX, pnY, pnZ)
		This.MoveTo(@nLast, pnX, pnY, pnZ)
		return This

	def Rotate(pnAX, pnAY, pnAZ, pnDegrees)
		This.RotateTo(@nLast, pnAX, pnAY, pnAZ, pnDegrees)

	def RotateQ(pnAX, pnAY, pnAZ, pnDegrees)
		This.RotateTo(@nLast, pnAX, pnAY, pnAZ, pnDegrees)
		return This

	def Scale(pnSX, pnSY, pnSZ)
		This.ScaleTo(@nLast, pnSX, pnSY, pnSZ)

	def ScaleQ(pnSX, pnSY, pnSZ)
		This.ScaleTo(@nLast, pnSX, pnSY, pnSZ)
		return This

	#-- where a 3D point lands on the picture -------------------------------

	# [ x, y, depth, bVisible ] in canvas pixels. bVisible is 0 for a point
	# behind the camera -- a real answer, not a NaN to trip over.
	def Project(pnX, pnY, pnZ)
		_aV_ = StzEngineGpuMat4LookAt(@aCam[1], @aCam[2], @aCam[3],
			@aCam[4], @aCam[5], @aCam[6], 0, 1, 0)
		_aP_ = StzEngineGpuMat4Perspective(@aCam[7], @nW / @nH, @aCam[8], @aCam[9])
		_aVP_ = StzEngineGpuMat4Mul(_aP_, _aV_)
		return StzEngineGpuMat4Project(_aVP_, pnX, pnY, pnZ, @nW, @nH)

	#-- letting the GPU drive the transforms --------------------------------

	# Hand the instance buffer to a compute kernel: from here the scene
	# stops rewriting transforms from its own state and draws whatever the
	# kernel leaves there. Render once first, so the buffer exists.
	def InstanceBuffer()
		return StzEngineGpuScene3dInstanceBuffer(@nId)

	def InstanceStride()
		return StzEngineGpuScene3dInstanceStride()

	def SetGpuDriven(pbOn)
		StzEngineGpuScene3dSetGpuDriven(@nId, pbOn)

	def SetGpuDrivenQ(pbOn)
		This.SetGpuDriven(pbOn)
		return This

	def IsGpuDriven()
		return StzEngineGpuScene3dIsGpuDriven(@nId) = 1

	#-- output --------------------------------------------------------------

	def ToPNG(pcPath)
		StzGraphicsDevice()
		_c_ = StzEngineGpuScene3dToPng(@nId, 1)
		if _c_ != "" and isString(pcPath) and pcPath != ""
			write(pcPath, _c_)
		ok
		return _c_

	def ToPixels()
		StzGraphicsDevice()
		return StzEngineGpuScene3dToPixels(@nId)

	def CanDrawPixels()
		return StzGraphicsDevice()

	def Show()
		_cPath_ = "stzscene_show.png"
		if This.ToPNG(_cPath_) = ""
			StzRaise("stzScene.Show: no GPU on this machine -- a 3D scene " +
				"has no vector tier to fall back to (2D does: stzCanvas).")
		ok
		if isWindows()
			system('start "" "' + _cPath_ + '"')
		but isMacOS()
			system('open "' + _cPath_ + '"')
		else
			system('xdg-open "' + _cPath_ + '" >/dev/null 2>&1 &')
		ok
		return _cPath_

	def Free()
		if @nId > 0
			StzEngineGpuScene3dFree(@nId)
			@nId = 0
		ok

	#-- internals -----------------------------------------------------------

	# The lens (fov, near, far), with the defaults if nothing set one yet.
	def _Lens()
		if len(@aCam) >= 9
			return [ @aCam[7], @aCam[8], @aCam[9] ]
		ok
		return [ 45, 0.1, 200 ]

	def _ApplyCamera()
		_n_ = StzEngineGpuScene3dCamera(@nId, @aCam[1], @aCam[2], @aCam[3],
			@aCam[4], @aCam[5], @aCam[6], @aCam[7], @aCam[8], @aCam[9])
		if _n_ != 0
			StzRaise("stzScene: that camera was refused -- near must be > 0 " +
				"and far > near.")
		ok

	# The engine takes a whole transform at once, so a partial change reads
	# what is there and writes it back with one part replaced.
	def _SetPart(pnIndex, paPos, paRot, paScale)
		if pnIndex < 1
			StzRaise("stzScene: instance numbers start at 1.")
		ok
		_a_ = This._TransformOf(pnIndex)
		if isList(paPos)     _a_[1] = paPos[1]  _a_[2] = paPos[2]  _a_[3] = paPos[3]  ok
		if isList(paRot)     _a_[4] = paRot[1]  _a_[5] = paRot[2]  _a_[6] = paRot[3]  _a_[7] = paRot[4]  ok
		if isList(paScale)   _a_[8] = paScale[1]  _a_[9] = paScale[2]  _a_[10] = paScale[3]  ok
		@aTransforms[pnIndex] = _a_
		_n_ = StzEngineGpuScene3dSetTransform(@nId, pnIndex,
			_a_[1], _a_[2], _a_[3], _a_[4], _a_[5], _a_[6], _a_[7],
			_a_[8], _a_[9], _a_[10])
		if _n_ != 0
			StzRaise("stzScene: there is no instance " + pnIndex + ".")
		ok

	def _TransformOf(pnIndex)
		while len(@aTransforms) < pnIndex
			@aTransforms + [ 0, 0, 0, 0, 1, 0, 0, 1, 1, 1 ]
		end
		return @aTransforms[pnIndex]
