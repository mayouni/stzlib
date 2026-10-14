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

# Hangs an interface panel as a quad in a 3D scene and turns a click on the screen into a click on the panel.
#
# Two conversions in opposite directions. Out: the panel is drawn to pixels, uploaded as a texture
# and worn by a quad lying flat at the origin. In: a screen pixel becomes a ray from the camera, the
# ray meets the quad's plane, the hit becomes a texture point and the texture point becomes panel
# pixels, so the panel itself knows nothing of a scene. The camera is copied in and not shared, so
# call LooksThrough beside Refresh when the camera moves. VerifyAgainstProjection checks the ray
# against the engine's own projection. The mapping is arithmetic and needs no device; Mount and
# Refresh upload a texture and need one, but no window is opened.
#
#   receiver   oDoc = new stzUiDocument('DEFINE PANEL console ( SIZE [400, 300], DIRECTION column,
#              BACKGROUND "#101820", PADDING 40, CHILDREN [row] ) RATIONALE "A control surface."' +
#              char(10) + 'DEFINE BOX row ( DIRECTION row, HEIGHT 90, GAP 20, CHILDREN [fire, abort]
#              ) RATIONALE "The two commands."' + char(10) + 'DEFINE BOX fire ( WIDTH 140,
#              BACKGROUND "#b03030", FOCUSABLE yes, ROLE button, LABEL "Fire" ) RATIONALE "The one
#              that does the thing."' + char(10) + 'DEFINE BOX abort ( WIDTH 140, BACKGROUND
#              "#3a4450", FOCUSABLE yes, ROLE button, LABEL "Abort" ) RATIONALE "The one that does
#              not."') oPanel = oDoc.ToPanel() oScene = new stzScene(800, 600) oScene.SetCamera(0,
#              3, 4, 0, 0, 0) oScene.SetLens(60, 0.1, 100) o1 = new stzScenePanel(oPanel, oScene,
#              2.0)
#   example    ? @@( o1.UvAtScreen(400, 300) )
#              #--> [ 0.50, 0.50 ]
#              ? @@( o1.PanelPointAtScreen(400, 300) )
#              #--> [ 200, 150 ]
#              ? @@( o1.UvAtScreen(5, 5) )
#              #--> [ ]
#              ? o1.ClickAtScreen(5, 5)
#              #--> 0
#              ? o1.VerifyAgainstProjection(5) < 0.000001
#              #--> 1
#              ? o1.IsMounted()
#              #--> 0
#              ? @@( o1.ViewportInUse() )
#              #--> [ 800, 600 ]
#   see        stzPanel, stzScene, stzUiDocument
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

	# Prepares a panel to hang as a quad in a 3D scene, copying the scene's camera and viewport for the click mapping.
	#
	#   poPanel    the stzPanel to show
	#   poScene    the stzScene it hangs in
	#   pnSize     the width of the square quad in world units, above 0
	#   returns    nothing; the object is built and nothing is mounted yet
	#   note       StzScenePanelQ builds the same object; the quad lies flat in the x and z plane
	#              facing up, centred on the origin
	#   warning    an argument that is not a panel and a scene raises error stzScenePanel: give an
	#              stzPanel and an stzScene; a size that is not a number above 0 raises error
	#              stzScenePanel: the quad needs a positive size
	#   see        Mount, LooksThrough, UvAtScreen
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

	# Returns the panel the quad currently shows.
	#
	#   returns    a stzPanel
	#   see        Shows, Scene
	def Panel()
		return @oPanel

	# Returns the scene the panel hangs in.
	#
	#   returns    a stzScene
	#   note       it is a copy taken when the object was made: the camera the click mapping uses is
	#              the one CameraInUse reports
	#   see        Panel, LooksThrough
	def Scene()
		return @oScene

	# Returns the width of the quad in world units.
	#
	#   returns    a number
	#   see        init
	def Size()
		return @nSize

	# TRUE if the panel has been put on a quad in the scene.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   see        Mount, Free
	def IsMounted()
		return @bMounted

	# Puts the panel on a quad in the scene, as emitted light that does not dim with the sun.
	#
	#   returns    TRUE once mounted, and again TRUE on a repeat call; FALSE when the machine cannot
	#              draw pixels
	#   note       it is idempotent: a second call hangs no second quad; it needs a graphics device
	#              but opens no window
	#   see        Refresh, Shows, IsMounted
	#@ aka  -- OUT: the panel becomes a surface in the world -----------------------
	def Mount()
		# IDEMPOTENT, and it has to be: AddMesh APPENDS, so a second
		# Mount() would hang a second quad in the same place and the
		# scene would carry a growing stack of identical panels nobody
		# asked for. The same shape as the font-family bug in G2 --
		# a registration that is not idempotent damages the thing it
		# was called to refresh.
		if @bMounted
			return TRUE
		ok
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

	# Puts a different panel on the same quad, keeping the quad.
	#
	#   poPanel    the stzPanel to show instead
	#   returns    TRUE when the new pixels were uploaded, or when nothing is mounted yet; FALSE
	#              when the upload failed. ShowsQ returns the panel object for chaining
	#   note       a panel of another size gets a new texture; use it when a click re-declares the
	#              interface and so produces a new panel
	#   warning    a value that is not a panel raises error stzScenePanel.Shows: give an stzPanel
	#   see        Mount, Refresh
	#@ aka  Put a DIFFERENT panel on the same quad.
	def Shows(poPanel)
		if NOT isObject(poPanel)
			StzRaise("stzScenePanel.Shows: give an stzPanel.")
		ok
		_bSize_ = (poPanel.Width() != @oPanel.Width()) or
			(poPanel.Height() != @oPanel.Height())
		@oPanel = poPanel
		if _bSize_
			@oCanvas = new stzCanvas(poPanel.Width(), poPanel.Height())
			if @nTex != 0
				StzEngineGpuTextureFree(@nTex)
				@nTex = 0
			ok
		ok
		if NOT @bMounted
			return TRUE
		ok
		_b_ = This._Upload()
		if _b_ and _bSize_
			# a NEW texture id must be re-bound; the material holds the
			# old one and would sample a freed handle
			@oScene.SetMaterial(@oMaterial, [ :skin = @nTex ])
		ok
		return _b_

	def ShowsQ(poPanel)
		This.Shows(poPanel)
		return This

	# Draws the panel again and pushes its pixels to the quad's texture.
	#
	#   returns    TRUE when uploaded; FALSE when not mounted or when the device refused
	#   note       call it after a click, a focus move or a reload; it needs a graphics device
	#   see        Mount, Shows
	#@ aka  Re-render the panel and push its pixels to the texture. Called when the interface changed -- after a click, a focus move, a reload.
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

	# Copies the scene's camera and viewport into the panel, so the click mapping follows the camera.
	#
	#   poScene    the stzScene whose camera and size to copy
	#   returns    nothing; the camera is stored. LooksThroughQ returns the panel object for
	#              chaining
	#   note       the camera is copied, not shared: after the scene's camera moves, call it again
	#              beside Refresh or the mapping keeps the old lens
	#   warning    a value that is not a scene raises error stzScenePanel.LooksThrough: give an
	#              stzScene
	#   see        CameraInUse, ViewportInUse
	#@ aka  -- IN: a screen point becomes a point on the interface -----------------
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

	# Returns the camera the click mapping is using.
	#
	#   returns    a list of nine numbers: the eye x, y, z, the target x, y, z, the field of view in
	#              degrees, the near and the far distance
	#   see        LooksThrough, ViewportInUse
	#@ aka  What the mapping is currently using -- so a caller can SEE the snapshot rather than infer it from a wrong answer.
	def CameraInUse()
		return @aCam

	# Returns the size of the screen the click mapping is using.
	#
	#   returns    a list [ width, height ] in pixels
	#   see        LooksThrough, CameraInUse
	def ViewportInUse()
		return [ @nVW, @nVH ]

	# Returns where a screen pixel lands on the quad, as a point of the texture.
	#
	#   pnScreenX   the pixel's x, from the left
	#   pnScreenY   the pixel's y, from the top
	#   returns     a list [ u, v ] each from 0 to 1; [ ] when the ray through the pixel misses the
	#               quad, runs parallel to its plane or meets it behind the camera
	#   note        u grows with x and v with z; looking through the centre of the screen at a
	#               camera aimed at the origin gives [ 0.5, 0.5 ]
	#   see         PanelPointAtScreen, VerifyAgainstProjection
	#@ aka  Where a screen pixel lands on the quad, as [u, v], or [] when the ray misses the plane or hits it outside the quad. A miss is a real answer: most of the screen is not the panel.
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

	# Returns where a screen pixel lands on the panel, in the panel's own pixels.
	#
	#   pnScreenX   the pixel's x, from the left
	#   pnScreenY   the pixel's y, from the top
	#   returns     a list [ x, y ] from the top left of the panel; [ ] when the pixel misses the
	#               quad
	#   note        the texture's bottom-left origin is flipped once into the panel's top-left
	#   see         UvAtScreen, ClickAtScreen
	#@ aka  The same point in PANEL PIXELS -- which is the only space the panel admits, and the reason nothing below here knows about a scene.
	def PanelPointAtScreen(pnScreenX, pnScreenY)
		_aUV_ = This.UvAtScreen(pnScreenX, pnScreenY)
		if len(_aUV_) = 0
			return []
		ok
		# v is flipped exactly once, by the panel's own conversion
		return @oPanel.FromTexture(_aUV_[1], _aUV_[2])

	# Moves the panel's pointer to where a screen pixel lands on it, or tells it the pointer left.
	#
	#   pnScreenX   the pixel's x, from the left
	#   pnScreenY   the pixel's y, from the top
	#   returns     TRUE when the pixel is on the quad; FALSE when it missed, and the panel is told
	#               the pointer left
	#   see         ClickAtScreen, PanelPointAtScreen
	#@ aka  Move the pointer, click, or hover -- addressed by SCREEN pixel, acted on in panel pixels. Answers FALSE when the ray missed, so a caller can tell "clicked nothing" from "clicked the background".
	def PointerMovedToScreen(pnScreenX, pnScreenY)
		_a_ = This.PanelPointAtScreen(pnScreenX, pnScreenY)
		if len(_a_) = 0
			@oPanel.PointerLeft()
			return FALSE
		ok
		@oPanel.PointerMovedTo(_a_[1], _a_[2])
		return TRUE

	# Clicks the panel at the point where a screen pixel lands on it.
	#
	#   pnScreenX   the pixel's x, from the left
	#   pnScreenY   the pixel's y, from the top
	#   returns     TRUE when the pixel is on the quad and the click was delivered; FALSE when it
	#               missed
	#   note        the answer separates clicked nothing from clicked the background; a click on a
	#               focusable box gives it the focus
	#   see         PointerMovedToScreen, PanelPointAtScreen
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

	# Checks the click mapping against the engine's own projection, over a grid of points of the quad, and returns the worst error.
	#
	#   pnSteps    the grid is pnSteps by pnSteps points inside the quad
	#   returns    a number: the largest difference in u or v, 0 when the two routes agree, and 999
	#              when a point does not come back at all
	#   note       the two routes share no code; after LooksThrough is fed a different lens it
	#              reports an error above 0.01
	#   see        UvAtScreen, LooksThrough
	#@ aka  The self-check, and it is a real one: a uv is mapped OUT to a world point and projected back by the ENGINE's own Project(), then that screen point is fed through the ray and must return the uv it began with. Two independent routes to one truth -- the house's rule for a check that can actually fail, rather than an identity computed from one set of anchors.
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

	# Releases the quad's texture and marks the panel as not mounted.
	#
	#   returns    nothing; the panel is no longer mounted
	#   note       freeing twice does nothing the second time
	#   see        Mount, IsMounted
	def Free()
		if @nTex != 0
			StzEngineGpuTextureFree(@nTex)
			@nTex = 0
		ok
		@bMounted = FALSE
