#---------------------------------------------------------------------------#
#  STZSCENEPANEL -- an interface hanging in a 3D world, and clickable there. #
#---------------------------------------------------------------------------#
#
#     oSP = new stzScenePanel(oPanel, oScene, 2.0)
#     oSP.Mount()                       # the panel becomes a quad
#     oSP.Refresh()                     # ...carrying its current pixels
#     oSP.ClickAtScreen(nMouseX, nMouseY)
#
# §6 of SOFTANZA_GUI_PLAN.md says this plane STARTS with the in-scene and
# game case -- "there the graphics plane's strengths are highest, RmlUi is
# proven, in-world panels are routine". It was then deferred three times:
# G1 rendered no scene, criterion 3 used a hand-drawn canvas rather than a
# panel, and G3 built the uv conversion but rehearsed it without a scene.
# This is that tier, finally standing up.
#
# THE WHOLE OF IT IS TWO CONVERSIONS, in opposite directions:
#
#   OUT   panel -> canvas -> pixels -> a GPU texture -> a quad's material
#   IN    a screen point -> a ray -> the quad's plane -> uv -> panel pixels
#
# and the second one is why §7 dissolved the coordinate-space frame rather
# than surfacing it: the panel still admits ONE space, its own pixels, and
# everything above is a named conversion at the boundary. Nothing about
# stzPanel knows it is in a scene.
#
# THE RAY IS COMPUTED FROM THE CAMERA, not from an inverted matrix, because
# the engine exposes no unproject. That is not a workaround -- it is the
# same arithmetic an unproject would do, and it is CHECKABLE: a uv mapped
# out to world and projected back by the engine's OWN Project() must
# return the screen point the ray started from. Two independent routes to
# one truth, which is the house's rule for a real self-check rather than
# an identity that cannot fail.
#
# The quad lies in XZ facing +Y (the engine's plane mesh), centred at the
# origin, `nSize` across. u runs with +x; v runs with -z and is FLIPPED on
# the way into the panel, because a texture's origin is bottom-left and a
# panel's is top-left -- stated once, here.

func StzScenePanelQ(poPanel, poScene, pnSize)
	return new stzScenePanel(poPanel, poScene, pnSize)

class stzScenePanel from stzObject

	@oPanel = NULL
	@oScene = NULL
	@oCanvas = NULL
	@oMaterial = NULL
	@nSize = 2
	@nTex = 0
	@bMounted = FALSE
	@aCam = []
	@nVW = 0
	@nVH = 0

	def init(poPanel, poScene, pnSize)
		if NOT (isObject(poPanel) and isObject(poScene))
			StzRaise("stzScenePanel: give an stzPanel and an stzScene.")
		ok
		if NOT (isNumber(pnSize) and pnSize > 0)
			StzRaise("stzScenePanel: the quad needs a positive size.")
		ok
		@oPanel = poPanel
		@oScene = poScene
		@nSize = pnSize
		@oCanvas = new stzCanvas(poPanel.Width(), poPanel.Height())
		This.LooksThrough(poScene)

	def Panel()
		return @oPanel

	def Scene()
		return @oScene

	def Size()
		return @nSize

	def IsMounted()
		return @bMounted

	#-- OUT: the panel becomes a surface in the world -----------------------

	# Put the panel on a quad in the scene. Answers FALSE with no device --
	# a machine that cannot rasterize cannot hang a panel in a world, and
	# that is a legitimate state rather than an error.
	def Mount()
		if NOT @oCanvas.CanDrawPixels()
			return FALSE
		ok
		if NOT This._Upload()
			return FALSE
		ok
		@oMaterial = new stzMaterialMaker()
		@oMaterial.TakesTexture(:skin)
		# the panel is EMITTED light, not a lit surface: a UI that dimmed
		# when the sun moved would be a UI nobody can read
		@oMaterial.ForEachFragment('{ @out = sample(skin, @uv) }')
		@oScene.AddMesh(new stzMesh([ :Plane, @nSize ]), 0, 0, 0)
		@oScene.SetMaterial(@oMaterial, [ :skin = @nTex ])
		@bMounted = TRUE
		return TRUE

	# Re-render the panel and push its pixels to the texture. Called when
	# the interface changed -- after a click, a focus move, a reload.
	def Refresh()
		if NOT @bMounted
			return FALSE
		ok
		return This._Upload()

	def _Upload()
		@oCanvas.Clear()
		@oPanel.DrawInto(@oCanvas)
		_c_ = @oCanvas.ToPixels()
		if len(_c_) = 0
			return FALSE
		ok
		if @nTex = 0
			# KIND 4 = sRGB-ENCODED, LINEAR FILTERING, and both halves
			# were paid for by looking at the picture:
			#
			# LINEAR, not nearest, because the quad is almost never seen
			# at 1:1 -- criterion 3 measured that bilinear holds up to a
			# hard graze, where an angle costs SIZE and not sharpness.
			#
			# sRGB, because a canvas hands over sRGB-encoded bytes and
			# the material's fragment tail encodes to sRGB again. The
			# first render came out washed pale -- a near-black #0d1219
			# background as mid slate -- and the kind is what makes the
			# SAMPLER decode instead. An interface is pictures of
			# colours, not data, so this is the correct half of the
			# distinction TEX_LINEAR draws.
			@nTex = StzEngineGpuTextureNew(@oPanel.Width(), @oPanel.Height(), 4)
			if @nTex = 0
				return FALSE
			ok
		ok
		return StzEngineGpuTextureWrite(@nTex, _c_) = 0

	#-- IN: a screen point becomes a point on the interface -----------------
	#
	# THE CAMERA IS COPIED IN, DELIBERATELY AND VISIBLY. Ring copies an
	# object on assignment, so a scene held as `@oScene` is a SNAPSHOT:
	# the panel kept answering with the old lens after the camera moved,
	# and both negative controls in the guard passed at zero error --
	# which is the engine-wrapper copy law arriving in a plane that has
	# no engine handle to hide behind.
	#
	# Rather than pretend the reference is live, the camera is DATA and
	# the sync is a verb a game loop calls beside Refresh():
	#
	#     oSP.LooksThrough(oScene)     # the camera moved
	#     oSP.Refresh()                # the interface changed
	#
	# One line per frame, in the loop that already redraws. A stale
	# mapping is now a missing call rather than an invisible fork.

	def LooksThrough(poScene)
		if NOT isObject(poScene)
			StzRaise("stzScenePanel.LooksThrough: give an stzScene.")
		ok
		@aCam = poScene.Camera()
		@nVW = poScene.Width()
		@nVH = poScene.Height()

	def LooksThroughQ(poScene)
		This.LooksThrough(poScene)
		return This

	# What the mapping is currently using -- so a caller can SEE the
	# snapshot rather than infer it from a wrong answer.
	def CameraInUse()
		return @aCam

	def ViewportInUse()
		return [ @nVW, @nVH ]

	# Where a screen pixel lands on the quad, as [u, v], or [] when the ray
	# misses the plane or hits it outside the quad. A miss is a real
	# answer: most of the screen is not the panel.
	def UvAtScreen(pnScreenX, pnScreenY)
		_aHit_ = This._RayHitsPlane(pnScreenX, pnScreenY)
		if len(_aHit_) = 0
			return []
		ok
		# READ OFF THE MESH, not guessed: buildPlane gives the corner at
		# (-h, +h) the uv (0,1) and the corner at (-h, -h) the uv (0,0),
		# so v grows with +z. The first draft had this backwards and the
		# corner assertion caught it -- which is why the corners are
		# checked at all.
		_nHalf_ = @nSize / 2
		_u_ = (_aHit_[1] + _nHalf_) / @nSize
		_v_ = (_aHit_[3] + _nHalf_) / @nSize
		# A CORNER LANDS EXACTLY ON THE EDGE, and floating point puts it
		# either side. Rejecting 1.0000000001 would make the quad's own
		# corner a miss, so the bound is tolerant by a hair and the
		# answer is clamped rather than refused.
		if _u_ < -0.000001 or _u_ > 1.000001 or _v_ < -0.000001 or _v_ > 1.000001
			return []          # the ray hit the plane, but beside the quad
		ok
		if _u_ < 0
			_u_ = 0
		but _u_ > 1
			_u_ = 1
		ok
		if _v_ < 0
			_v_ = 0
		but _v_ > 1
			_v_ = 1
		ok
		return [ _u_, _v_ ]

	# The same point in PANEL PIXELS -- which is the only space the panel
	# admits, and the reason nothing below here knows about a scene.
	def PanelPointAtScreen(pnScreenX, pnScreenY)
		_aUV_ = This.UvAtScreen(pnScreenX, pnScreenY)
		if len(_aUV_) = 0
			return []
		ok
		# v is flipped exactly once, by the panel's own conversion
		return @oPanel.FromTexture(_aUV_[1], _aUV_[2])

	# Move the pointer, click, or hover -- addressed by SCREEN pixel, acted
	# on in panel pixels. Answers FALSE when the ray missed, so a caller
	# can tell "clicked nothing" from "clicked the background".
	def PointerMovedToScreen(pnScreenX, pnScreenY)
		_a_ = This.PanelPointAtScreen(pnScreenX, pnScreenY)
		if len(_a_) = 0
			@oPanel.PointerLeft()
			return FALSE
		ok
		@oPanel.PointerMovedTo(_a_[1], _a_[2])
		return TRUE

	def ClickAtScreen(pnScreenX, pnScreenY)
		_a_ = This.PanelPointAtScreen(pnScreenX, pnScreenY)
		if len(_a_) = 0
			return FALSE
		ok
		@oPanel.ClickAt(_a_[1], _a_[2])
		return TRUE

	#-- the ray -------------------------------------------------------------

	# Where the ray through a screen pixel meets the quad's plane (y = 0),
	# as [x, y, z], or [] when it never does.
	#
	# Built from the camera rather than from an inverted view-projection,
	# because the engine exposes no unproject -- and it is the same
	# arithmetic one would do. VerifyAgainstProjection() is the check that
	# keeps it honest.
	def _RayHitsPlane(pnScreenX, pnScreenY)
		_aC_ = @aCam
		_nW_ = @nVW
		_nH_ = @nVH
		if _nW_ < 1 or _nH_ < 1 or len(_aC_) < 9
			return []
		ok

		# the camera basis
		_aF_ = This._Norm([ _aC_[4] - _aC_[1], _aC_[5] - _aC_[2], _aC_[6] - _aC_[3] ])
		_aR_ = This._Norm(This._Cross(_aF_, [ 0, 1, 0 ]))
		_aU_ = This._Cross(_aR_, _aF_)

		# the pixel, as an offset from the view centre in world units at
		# unit depth
		_nT_ = tan(_aC_[7] * 3.141592653589793 / 360)     # tan(fov/2)
		_nAsp_ = _nW_ / _nH_
		_nX_ = (2 * pnScreenX / _nW_ - 1) * _nT_ * _nAsp_
		_nY_ = (1 - 2 * pnScreenY / _nH_) * _nT_

		_aD_ = This._Norm([
			_aF_[1] + _nX_ * _aR_[1] + _nY_ * _aU_[1],
			_aF_[2] + _nX_ * _aR_[2] + _nY_ * _aU_[2],
			_aF_[3] + _nX_ * _aR_[3] + _nY_ * _aU_[3] ])

		# the plane is y = 0; a ray parallel to it never meets it
		if fabs(_aD_[2]) < 0.000001
			return []
		ok
		_nK_ = -_aC_[2] / _aD_[2]
		if _nK_ <= 0
			return []          # the plane is BEHIND the camera
		ok
		return [ _aC_[1] + _nK_ * _aD_[1], 0, _aC_[3] + _nK_ * _aD_[3] ]

	# The self-check, and it is a real one: a uv is mapped OUT to a world
	# point and projected back by the ENGINE's own Project(), then that
	# screen point is fed through the ray and must return the uv it began
	# with. Two independent routes to one truth -- the house's rule for a
	# check that can actually fail, rather than an identity computed from
	# one set of anchors.
	#
	# Answers the largest uv error over a grid, so a caller can assert a
	# bound rather than trust a boolean.
	def VerifyAgainstProjection(pnSteps)
		_nWorst_ = 0
		_nHalf_ = @nSize / 2
		for _i_ = 1 to pnSteps
			for _j_ = 1 to pnSteps
				_u_ = _i_ / (pnSteps + 1)
				_v_ = _j_ / (pnSteps + 1)
				# uv -> world on the quad
				_x_ = _u_ * @nSize - _nHalf_
				_z_ = _v_ * @nSize - _nHalf_
				# world -> screen, by the ENGINE
				_aP_ = @oScene.Project(_x_, 0, _z_)
				if len(_aP_) < 4 or _aP_[4] = 0
					loop           # behind the camera: not a disagreement
				ok
				# screen -> uv, by the ray
				_aBack_ = This.UvAtScreen(_aP_[1], _aP_[2])
				if len(_aBack_) = 0
					return 999     # the routes disagree completely
				ok
				_nE_ = fabs(_aBack_[1] - _u_)
				_nF_ = fabs(_aBack_[2] - _v_)
				if _nF_ > _nE_
					_nE_ = _nF_
				ok
				if _nE_ > _nWorst_
					_nWorst_ = _nE_
				ok
			next
		next
		return _nWorst_

	#-- small vector helpers ------------------------------------------------

	def _Norm(paV)
		_nL_ = sqrt(paV[1]*paV[1] + paV[2]*paV[2] + paV[3]*paV[3])
		if _nL_ = 0
			return [ 0, 0, 0 ]
		ok
		return [ paV[1]/_nL_, paV[2]/_nL_, paV[3]/_nL_ ]

	def _Cross(paA, paB)
		return [ paA[2]*paB[3] - paA[3]*paB[2],
			 paA[3]*paB[1] - paA[1]*paB[3],
			 paA[1]*paB[2] - paA[2]*paB[1] ]

	def Free()
		if @nTex != 0
			StzEngineGpuTextureFree(@nTex)
			@nTex = 0
		ok
		@bMounted = FALSE
