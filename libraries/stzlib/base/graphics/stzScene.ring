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

# Holds a 3D scene, a camera, a light and meshes placed in space, and renders it to a picture.
#
# Add meshes with AddMesh, which places one instance each; every instance has a position, a rotation
# and a scale kept apart from its mesh, so moving, rotating or scaling re-sends matrices and never
# geometry (Stats makes that checkable). All the instances of a mesh are drawn in one call. Set the
# eye and target with SetCamera, the lens with SetLens, the light with SetLight and the colour of
# each instance with SetColor. SetParent makes a chain, and WorldPosition says where an instance
# really ended up. Project turns a point of the scene into a pixel, for putting a 2D label on a 3D
# thing. ToPNG renders on the graphics device and returns empty text when there is none: a scene has
# no vector fallback. The plain forms act and return nothing, and the Q twins return the scene so
# calls chain.
#
#   receiver   oCube = new stzMesh([ :Cube, 1 ]); o1 = new stzScene(400, 300)
#   example    o1.SetCamera(6, 4, 8, 0, 0, 0)
#              o1.AddMesh(oCube, 0, 0, 0)
#              o1.AddMeshQ(oCube, 2, 0, 0).ColorQ("#30a0e0")
#              ? o1.InstanceCount()
#              #--> 2
#              ? o1.LastIndex()
#              #--> 2
#              o1.SetParent(2, 1)
#              o1.MoveTo(1, 0, 3, 0)
#              ? @@( o1.WorldPosition(2) )
#              #--> [ 2, 3, 0 ]
#              ? o1.HierarchyDepth()
#              #--> 1
#              ? @@( o1.Camera() )
#              #--> [ 6, 4, 8, 0, 0, 0, 45, 0.10, 200 ]
#              ? o1.Width()
#              #--> 400
#   see        stzMesh, stzCanvas, stzMaterialMaker, stzWindow
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

	# Creates an empty 3D scene of the given size in pixels, with the camera at 0, 0, 5 looking at the origin.
	#
	#   pnW        the width in pixels
	#   pnH        the height in pixels
	#   returns    nothing; the object is built
	#   warning    Raises an error when the width or height is not a number and when the engine
	#              refuses the size, as it does for 0 by 0
	#   see        AddMesh, SetCamera, ToPNG
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

	# Returns the engine's number for this scene, or 0 once it was freed.
	#
	#   returns    a number
	#   see        Free
	def Id_()
		return @nId

	# Returns the width the scene believes it has, in pixels.
	#
	#   returns    a number
	#   see        Height, Resize
	def Width()
		return @nW

	# Returns the height the scene believes it has, in pixels.
	#
	#   returns    a number
	#   see        Width, Resize
	def Height()
		return @nH

	# Adopts a new viewport size on the scene object, so that Project and screen-to-ray maths use the size of a resized window.
	#
	#   pnW        the new width in pixels
	#   pnH        the new height in pixels
	#   returns    1 when taken, 0 when a size is not a positive number
	#   warning    it changes only what the object reports; the engine retargets itself when the
	#              scene is drawn into a target of another size
	#   see        Project, Width
	#@ aka  Adopt a new viewport size. The ENGINE already does this by itself when a scene is drawn into a differently-sized target (that is what makes a resizable window work at all) -- this keeps the FACE's idea of its size equal to the engine's, exactly as stzWindow.Draw already does for a canvas.
	def Resize(pnW, pnH)
		if NOT (isNumber(pnW) and isNumber(pnH) and pnW > 0 and pnH > 0)
			return FALSE
		ok
		@nW = pnW
		@nH = pnH
		return TRUE

	def ResizeQ(pnW, pnH)
		This.Resize(pnW, pnH)
		return This

	# Returns the counters of the scene: instances, meshes resident on the device, draw calls, geometry uploads and transform uploads.
	#
	#   returns    a list of five numbers; [ ] once freed
	#   note       moving an instance and drawing again raises the transform uploads and leaves the
	#              geometry uploads where they were; before the first draw the last four are 0
	#   see        InstanceCount
	#@ aka  [ instances, meshesResident, drawCalls, geometryUploads, transformUploads ]
	def Stats()
		return StzEngineGpuScene3dStats(@nId)

	# Returns how many instances, placed meshes, the scene holds.
	#
	#   returns    a number
	#   see        Stats, AddMesh
	def InstanceCount()
		_a_ = This.Stats()
		if len(_a_) = 0
			return 0
		ok
		return _a_[1]

	# Sets the colour the scene is cleared to before it is drawn.
	#
	#   pColor     a colour name such as :Black or a hex text such as #0c0e14
	#   returns    nothing; SetBackgroundQ returns the scene
	#   see        SetLight
	#@ aka  -- the frame -----------------------------------------------------------
	def SetBackground(pColor)
		StzEngineGpuScene3dClear(@nId, StzColorToNumber(pColor))

	def SetBackgroundQ(pColor)
		This.SetBackground(pColor)
		return This

	# Places the eye and the point it looks at, in scene units, keeping the lens that was set.
	#
	#   pnEX       the eye's x
	#   pnEY       the eye's y
	#   pnEZ       the eye's z
	#   pnTX       the target's x
	#   pnTY       the target's y
	#   pnTZ       the target's z
	#   returns    nothing; SetCameraQ returns the scene
	#   note       the lens starts at 45 degrees from 0.1 to 200
	#   warning    raises an error when the lens held is invalid, so a refused SetLens leaves every
	#              later SetCamera failing until the lens is repaired
	#   see        SetLens, Camera, Project
	#@ aka  Eye and target in scene units. Field of view, near and far are optional -- 45 degrees over 0.1..200 suits most scenes.
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

	# Sets the field of view in degrees and the near and far limits of the camera.
	#
	#   pnFovDegrees   the vertical field of view in degrees
	#   pnNear         the nearest distance drawn, above 0
	#   pnFar          the farthest distance drawn, above pnNear
	#   returns        nothing; SetLensQ returns the scene
	#   note           repair it by calling SetLens again with valid numbers
	#   warning        raises an error for a near of 0 or less or a far not above near, yet the
	#                  invalid values stay in Camera and are sent again by the next SetCamera
	#                  (confirmed with 0 and 100, then 5 and 2)
	#   see            SetCamera, Camera
	def SetLens(pnFovDegrees, pnNear, pnFar)
		@aCam[7] = pnFovDegrees
		@aCam[8] = pnNear
		@aCam[9] = pnFar
		This._ApplyCamera()

	def SetLensQ(pnFovDegrees, pnNear, pnFar)
		This.SetLens(pnFovDegrees, pnNear, pnFar)
		return This

	# Returns the camera as eye, target and lens in one list.
	#
	#   returns    a list of nine numbers: the eye, the target, then the field of view, near and far
	#   see        SetCamera, SetLens
	def Camera()
		return @aCam

	# Sets one directional light: the direction it shines in, its colour and the ambient light that fills the shadows.
	#
	#   pnDX       the x of the direction the light shines in
	#   pnDY       the y of that direction, where 0, -1, 0 is noon
	#   pnDZ       the z of that direction
	#   pColor     the light's colour
	#   pAmbient   the ambient colour
	#   returns    nothing; SetLightQ returns the scene
	#   see        SetBackground, SetMaterial
	#@ aka  A directional light: the direction it SHINES (so 0,-1,0 is noon), its colour, and the ambient that fills the shadows.
	def SetLight(pnDX, pnDY, pnDZ, pColor, pAmbient)
		StzEngineGpuScene3dLight(@nId, pnDX, pnDY, pnDZ,
			StzColorToNumber(pColor), StzColorToNumber(pAmbient))

	def SetLightQ(pnDX, pnDY, pnDZ, pColor, pAmbient)
		This.SetLight(pnDX, pnDY, pnDZ, pColor, pAmbient)
		return This

	# Places a mesh in the scene at a position, as a new instance drawn white.
	#
	#   poMesh     an stzMesh that is still alive
	#   pnX        the x position
	#   pnY        the y position
	#   pnZ        the z position
	#   returns    nothing; AddMeshQ returns the scene, and LastIndex gives the instance's number
	#   note       all instances of one mesh are drawn in a single call
	#   warning    raises an error for anything that is not a mesh and for a mesh that was freed
	#   see        LastIndex, SetColor, MoveTo
	#@ aka  -- things in the scene -------------------------------------------------
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

	# Makes one instance the child of another, so that its transform becomes local to the parent and moving the parent moves the chain.
	#
	#   pnIndex         the child's instance number
	#   pnParentIndex   the parent's instance number
	#   returns         1 when accepted, 0 when refused
	#   note            numbers come from LastIndex
	#   warning         an instance parented to itself or to one that does not exist is refused; a
	#                   loop made of two parents is accepted when set and broken, and counted by
	#                   CyclesRefused, when the scene is resolved
	#   see             ClearParent, WorldPosition, HierarchyDepth
	#@ aka  GG3: make one instance the CHILD of another. Its transform becomes LOCAL -- relative to the parent -- so moving the parent moves the whole chain.
	def SetParent(pnIndex, pnParentIndex)
		return StzEngineGpuScene3dSetParent(@nId, pnIndex, pnParentIndex) = 0

	def SetParentQ(pnIndex, pnParentIndex)
		This.SetParent(pnIndex, pnParentIndex)
		return This

	# Detaches an instance from its parent, which keeps its local transform and becomes a root.
	#
	#   pnIndex    the instance's number
	#   returns    1 when done, 0 when the instance does not exist
	#   see        SetParent, HierarchyDepth
	#@ aka  Detach: the instance keeps its LOCAL transform and becomes a root.
	def ClearParent(pnIndex)
		return StzEngineGpuScene3dSetParent(@nId, pnIndex, -1) = 0

	# Returns how many links the longest parent chain has.
	#
	#   returns    a number; 0 for a flat scene
	#   see        SetParent, WorldPosition
	#@ aka  How many links the longest chain has. 0 means the scene is flat -- the witness that a hierarchy is actually a hierarchy.
	def HierarchyDepth()
		return StzEngineGpuScene3dHierarchyDepth(@nId)

	# Returns how many parent loops were broken instead of followed.
	#
	#   returns    a number
	#   see        SetParent
	def CyclesRefused()
		return StzEngineGpuScene3dCyclesRefused(@nId)

	# Returns where an instance really sits once its parents are applied, the number to assert on.
	#
	#   pnIndex    the instance's number
	#   returns    a list [ x, y, z ]
	#   see        SetParent, MoveTo
	#@ aka  Where an instance ACTUALLY ended up, after its parents were applied. The number to assert on: a child that did not follow its parent shows up here, not in the picture.
	def WorldPosition(pnIndex)
		return StzEngineGpuScene3dWorldPosition(@nId, pnIndex)

	def AddMeshQ(poMesh, pnX, pnY, pnZ)
		This.AddMesh(poMesh, pnX, pnY, pnZ)
		return This

	# Returns the number of the instance added most recently, which Color, Move, Rotate and Scale act on.
	#
	#   returns    a number; 0 before any mesh is added
	#   see        AddMesh
	def LastIndex()
		return @nLast

	# Sets the position of an instance and leaves its rotation and scale as they are.
	#
	#   pnIndex    the instance's number, from 1
	#   pnX        the new x
	#   pnY        the new y
	#   pnZ        the new z
	#   returns    nothing; MoveToQ returns the scene
	#   note       it re-sends the transform and never the geometry
	#   warning    raises an error for a number below 1 and for an instance that does not exist
	#   see        RotateTo, ScaleTo, Move
	#@ aka  -- transform state (kept apart from what is drawn) ---------------------
	def MoveTo(pnIndex, pnX, pnY, pnZ)
		This._SetPart(pnIndex, [ pnX, pnY, pnZ ], "", "")

	def MoveToQ(pnIndex, pnX, pnY, pnZ)
		This.MoveTo(pnIndex, pnX, pnY, pnZ)
		return This

	# Sets the rotation of an instance as an angle around an axis, and leaves its position and scale as they are.
	#
	#   pnIndex     the instance's number, from 1
	#   pnAX        the axis x
	#   pnAY        the axis y
	#   pnAZ        the axis z
	#   pnDegrees   the angle in degrees
	#   returns     nothing; RotateToQ returns the scene
	#   warning     raises an error for an instance that does not exist
	#   see         MoveTo, ScaleTo, Rotate
	def RotateTo(pnIndex, pnAX, pnAY, pnAZ, pnDegrees)
		This._SetPart(pnIndex, "", [ pnAX, pnAY, pnAZ, pnDegrees ], "")

	def RotateToQ(pnIndex, pnAX, pnAY, pnAZ, pnDegrees)
		This.RotateTo(pnIndex, pnAX, pnAY, pnAZ, pnDegrees)
		return This

	# Sets the scale of an instance along each axis, and leaves its position and rotation as they are.
	#
	#   pnIndex    the instance's number, from 1
	#   pnSX       the x factor
	#   pnSY       the y factor
	#   pnSZ       the z factor
	#   returns    nothing; ScaleToQ returns the scene
	#   warning    raises an error for an instance that does not exist
	#   see        MoveTo, RotateTo, Scale
	def ScaleTo(pnIndex, pnSX, pnSY, pnSZ)
		This._SetPart(pnIndex, "", "", [ pnSX, pnSY, pnSZ ])

	def ScaleToQ(pnIndex, pnSX, pnSY, pnSZ)
		This.ScaleTo(pnIndex, pnSX, pnSY, pnSZ)
		return This

	# Sets the colour of one instance.
	#
	#   pnIndex    the instance's number
	#   pColor     a colour name or a hex text
	#   returns    nothing; SetColorQ returns the scene
	#   warning    raises an error naming the instance when it does not exist
	#   see        Color, AddMesh
	def SetColor(pnIndex, pColor)
		_n_ = StzEngineGpuScene3dSetColor(@nId, pnIndex, StzColorToNumber(pColor))
		if _n_ != 0
			StzRaise("stzScene.SetColor: there is no instance " + pnIndex + ".")
		ok

	def SetColorQ(pnIndex, pColor)
		This.SetColor(pnIndex, pColor)
		return This

	# Sets the colour of the instance added most recently, so that AddMeshQ and ColorQ chain.
	#
	#   pColor     a colour name or a hex text
	#   returns    nothing; ColorQ returns the scene
	#   see        SetColor, LastIndex
	#@ aka  The chain-friendly styling: acts on the instance most recently added, so AddMeshQ(...).ColorQ(...) reads the way it looks.
	def Color(pColor)
		This.SetColor(@nLast, pColor)

	def ColorQ(pColor)
		This.SetColor(@nLast, pColor)
		return This

	# Sets the position of the instance added most recently.
	#
	#   pnX        the new x
	#   pnY        the new y
	#   pnZ        the new z
	#   returns    nothing; MoveQ returns the scene
	#   see        MoveTo, LastIndex
	def Move(pnX, pnY, pnZ)
		This.MoveTo(@nLast, pnX, pnY, pnZ)

	def MoveQ(pnX, pnY, pnZ)
		This.MoveTo(@nLast, pnX, pnY, pnZ)
		return This

	# Sets the rotation of the instance added most recently, as an angle around an axis.
	#
	#   pnAX        the axis x
	#   pnAY        the axis y
	#   pnAZ        the axis z
	#   pnDegrees   the angle in degrees
	#   returns     nothing; RotateQ returns the scene
	#   see         RotateTo, LastIndex
	def Rotate(pnAX, pnAY, pnAZ, pnDegrees)
		This.RotateTo(@nLast, pnAX, pnAY, pnAZ, pnDegrees)

	def RotateQ(pnAX, pnAY, pnAZ, pnDegrees)
		This.RotateTo(@nLast, pnAX, pnAY, pnAZ, pnDegrees)
		return This

	# Sets the scale of the instance added most recently along each axis.
	#
	#   pnSX       the x factor
	#   pnSY       the y factor
	#   pnSZ       the z factor
	#   returns    nothing; ScaleQ returns the scene
	#   see        ScaleTo, LastIndex
	def Scale(pnSX, pnSY, pnSZ)
		This.ScaleTo(@nLast, pnSX, pnSY, pnSZ)

	def ScaleQ(pnSX, pnSY, pnSZ)
		This.ScaleTo(@nLast, pnSX, pnSY, pnSZ)
		return This

	# Turns a point of the scene into a pixel of the picture, using the camera and the size the scene reports.
	#
	#   pnX        the point's x
	#   pnY        the point's y
	#   pnZ        the point's z
	#   returns    a list [ x, y, depth, visible ]; visible is 0 for a point behind the camera, and
	#              x and y are then 0
	#   warning    the point 0, 0, 0 lands at the centre of the picture for a camera looking at the
	#              origin
	#   see        Resize, Camera
	#@ aka  -- where a 3D point lands on the picture -------------------------------
	def Project(pnX, pnY, pnZ)
		_aV_ = StzEngineGpuMat4LookAt(@aCam[1], @aCam[2], @aCam[3],
			@aCam[4], @aCam[5], @aCam[6], 0, 1, 0)
		_aP_ = StzEngineGpuMat4Perspective(@aCam[7], @nW / @nH, @aCam[8], @aCam[9])
		_aVP_ = StzEngineGpuMat4Mul(_aP_, _aV_)
		return StzEngineGpuMat4Project(_aVP_, pnX, pnY, pnZ, @nW, @nH)

	# Replaces the built-in shading of the whole scene with a material written by the material maker, bound to colours and numbers.
	#
	#   poMaterial   an stzMaterialMaker
	#   paBindings   the values of its inputs, such as [ :tint = "#e0a030" ]
	#   returns      nothing; SetMaterialQ returns the scene
	#   note         the material applies to every instance, not to one
	#   warning      raises an error for anything that is not a material maker and when the engine
	#                or its textures are refused
	#   see          ClearMaterial, HasMaterial, MaterialTextureCount
	#@ aka  -- materials (GR4b) ----------------------------------------------------
	def SetMaterial(poMaterial, paBindings)
		if NOT isObject(poMaterial)
			StzRaise("stzScene.SetMaterial: give an stzMaterialMaker.")
		ok
		_n_ = StzEngineGpuScene3dSetMaterial(@nId, poMaterial.ToWGSL(),
			poMaterial.ParamsFrom(paBindings))
		if _n_ != 0
			StzRaise("stzScene.SetMaterial: refused (status " + _n_ + ").")
		ok
		# Textures ride SEPARATELY because they are handles, not values --
		# and AFTER the shader, because setting a shader drops whatever
		# textures the previous one had bound.
		_aT_ = poMaterial.TexturesFrom(paBindings)
		if len(_aT_) > 0
			_n_ = StzEngineGpuScene3dSetMaterialTextures(@nId, _aT_)
			if _n_ != 0
				StzRaise("stzScene.SetMaterial: the material's textures were " +
					"refused (status " + _n_ + "). A texture handle must be " +
					"live -- a freed or never-created one cannot be bound.")
			ok
		ok

	def SetMaterialQ(poMaterial, paBindings)
		This.SetMaterial(poMaterial, paBindings)
		return This

	# Removes the material so that the scene is shaded by the built-in forward lighting again.
	#
	#   returns    nothing; ClearMaterialQ returns the scene
	#   see        SetMaterial, HasMaterial
	def ClearMaterial()
		StzEngineGpuScene3dSetMaterial(@nId, "", [])

	def ClearMaterialQ()
		This.ClearMaterial()
		return This

	# TRUE if the scene is shaded by a material set with SetMaterial.
	#
	#   returns    1 or 0
	#   see        SetMaterial, ClearMaterial
	def HasMaterial()
		return StzEngineGpuScene3dHasMaterial(@nId) = 1

	# Returns how many textures the material has bound.
	#
	#   returns    a number
	#   see        SetMaterial
	#@ aka  How many textures the material bound. Worth exposing because the binding is the part that cannot report its own mistakes: a texture that failed to bind does not draw wrong, it panics at submit.
	def MaterialTextureCount()
		return StzEngineGpuScene3dMaterialTextureCount(@nId)

	# Returns the engine's handle of the buffer that holds the instances' transforms, for a compute kernel to write.
	#
	#   returns    a number; the buffer exists once the scene was drawn
	#   see        SetGpuDriven, InstanceStride
	#@ aka  -- letting the GPU drive the transforms --------------------------------
	def InstanceBuffer()
		return StzEngineGpuScene3dInstanceBuffer(@nId)

	# Returns how many bytes one instance takes in the instance buffer.
	#
	#   returns    a number, 36
	#   see        InstanceBuffer
	def InstanceStride()
		return StzEngineGpuScene3dInstanceStride()

	# Hands the instance buffer to a compute kernel, so that the scene draws whatever the kernel leaves there instead of its own transforms.
	#
	#   pbOn       1 to let the kernel drive the transforms, 0 to take them back
	#   returns    nothing; SetGpuDrivenQ returns the scene
	#   warning    draw the scene once first so that the buffer exists
	#   see        IsGpuDriven, InstanceBuffer
	def SetGpuDriven(pbOn)
		StzEngineGpuScene3dSetGpuDriven(@nId, pbOn)

	def SetGpuDrivenQ(pbOn)
		This.SetGpuDriven(pbOn)
		return This

	# TRUE if the transforms are driven by a compute kernel.
	#
	#   returns    1 or 0
	#   see        SetGpuDriven
	def IsGpuDriven()
		return StzEngineGpuScene3dIsGpuDriven(@nId) = 1

	# Renders the scene and returns the PNG bytes, writing them to a file when a path is given.
	#
	#   pcPath     the file to write, or empty text to write nothing
	#   returns    the PNG as a binary text; empty text when this machine has no graphics device
	#   note       the returned text is the picture itself, so do not print it
	#   warning    a scene has no vector fallback, so without a device nothing is drawn
	#   see        ToPixels, Show
	#@ aka  -- output --------------------------------------------------------------
	def ToPNG(pcPath)
		StzGraphicsDevice()
		_c_ = StzEngineGpuScene3dToPng(@nId, 1)
		if _c_ != "" and isString(pcPath) and pcPath != ""
			write(pcPath, _c_)
		ok
		return _c_

	# Renders the scene and returns its pixels.
	#
	#   returns    a binary text of the pixels, four bytes each, such as 480000 bytes for 400 by 300
	#   see        ToPNG, CanDrawPixels
	def ToPixels()
		StzGraphicsDevice()
		return StzEngineGpuScene3dToPixels(@nId)

	# TRUE if this machine has a graphics device that can render the scene.
	#
	#   returns    1 or 0
	#   see        ToPNG
	def CanDrawPixels()
		return StzGraphicsDevice()

	# Renders the scene to a PNG named stzscene_show.png in the current folder and opens it in the system's viewer.
	#
	#   returns    the path of the PNG
	#   warning    raises an error when there is no graphics device
	#   see        ToPNG
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

	# Releases the scene in the engine, after which every query answers 0 or empty.
	#
	#   returns    nothing
	#   note       call it when done, as the engine holds the scene until then
	#   see        Id_
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
