#---------------------------------------------------------------------------#
#  STZPANEL -- a laid-out interface, drawn wherever the graphics plane can.  #
#---------------------------------------------------------------------------#
#
#     oP = new stzPanel(640, 400)
#     oP.LoadMarkup(cRml)                 # EMITTED markup, never authored
#     oP.Layout()
#     oP.DrawInto(oCanvas)                # ...and now it is a picture
#
#     ? oP.BoxOf("sidebar")               # [x, y, w, h], laid out
#     ? oP.Counters()                     # what it drew, and what it did not
#
# WHAT A PANEL IS: RmlUi's box tree, laid out, handed to Softanza as
# TRIANGLES. It is not a window (stzWindow is), not a renderer (stzCanvas
# is), and not a meaning (StzZui is). It computes WHERE things go and
# leaves every other question to the layer that owns it.
#
# WHY IT DRAWS THROUGH A CANVAS instead of painting: the house settled
# this in GR2b -- one display list, two renderers, so the GPU and SVG
# tiers cannot disagree about where anything sits. A panel that painted
# itself would be a third renderer outside that discipline. Because it
# draws into a canvas, a panel gets ToSVG() on a machine with no GPU at
# all, and ToPNG() on one with a device, for free and without knowing
# which it is on.
#
# THE MARKUP IS EMITTED, NEVER AUTHORED (§4 of SOFTANZA_GUI_PLAN.md).
# There is deliberately no LoadFile(): Softanza declarations are the
# contract, RML is one projection of them and HTML is another. Writing RML
# by hand bypasses the semantic layer exactly as hand-writing CSS does --
# and RML is a dialect no browser will check, so the pressure to do it is
# higher and the feedback is worse. LoadMarkup takes a STRING, which is
# what an emitter produces.
#
# State is one number (the engine context id), so Ring's copy-on-assign is
# harmless: copies share the same laid-out context, and a freed id answers
# by NAME rather than with another panel's geometry.

func StzPanelQ(pnW, pnH)
	return new stzPanel(pnW, pnH)

# TRUE when this machine can lay a panel out at all. A box without
# stz_gui.dll is a legitimate state, not an error -- the same graceful
# absence stzWindow established -- so ask before assuming.
func StzGuiAvailable()
	if NOT StzGuiEngineLoaded()
		return FALSE
	ok
	return StzEngineGuiIsAvailable() = 1

class stzPanel from stzObject

	@nId = 0
	@nW = 0
	@nH = 0
	@bLoaded = FALSE

	def init(pnW, pnH)
		if NOT (isNumber(pnW) and isNumber(pnH))
			StzRaise("stzPanel: give a width and a height in pixels.")
		ok
		if NOT StzGuiAvailable()
			StzRaise("stzPanel: this machine has no layout engine " +
				"(stz_gui.dll is absent or refused to start). Ask " +
				"StzGuiAvailable() first -- absence is a legitimate state.")
		ok
		@nId = StzEngineGuiContextNew(pnW, pnH)
		if @nId = 0
			StzRaise("stzPanel: refused a " + pnW + "x" + pnH + " panel " +
				"(sizes run from 1 to 16384).")
		ok
		@nW = pnW
		@nH = pnH

	#-- identity ------------------------------------------------------------

	def Id_()
		return @nId

	def Width()
		return @nW

	def Height()
		return @nH

	def IsAlive()
		return @nId > 0 and StzEngineGuiUpdate(@nId) = 0

	#-- the document --------------------------------------------------------

	# Markup as a STRING, because markup is emitted. See the header.
	def LoadMarkup(pcRml)
		_n_ = StzEngineGuiLoadRml(@nId, "" + pcRml)
		if _n_ != 0
			StzRaise("stzPanel.LoadMarkup: refused (" + _n_ + "). " +
				"RmlUi said: " + This.LastEngineMessage() + " -- note RML is " +
				"XML syntax, so <br> and <img> must be closed.")
		ok
		@bLoaded = TRUE

	def LoadMarkupQ(pcRml)
		This.LoadMarkup(pcRml)
		return This

	def HasDocument()
		return @bLoaded

	# Lay out. Cheap when nothing changed: G0 measured a still frame at
	# 1/362 of a dirty one, and 500 still frames re-compiled zero geometry.
	def Layout()
		if StzEngineGuiUpdate(@nId) != 0
			StzRaise("stzPanel.Layout: the panel is no longer alive.")
		ok

	def LayoutQ()
		This.Layout()
		return This

	def Resize(pnW, pnH)
		if StzEngineGuiContextResize(@nId, pnW, pnH) != 0
			return FALSE
		ok
		@nW = pnW
		@nH = pnH
		This.Layout()
		return TRUE

	def ResizeQ(pnW, pnH)
		This.Resize(pnW, pnH)
		return This

	# RmlUi's clock, driven by the caller -- so a test frame is
	# deterministic instead of depending on when it ran.
	def SetTime(pnSeconds)
		StzEngineGuiSetTime(pnSeconds)

	#-- the geometry --------------------------------------------------------

	# Lay out if needed, then record the triangles. Called for you by
	# DrawInto and by Verts/Indices; a caller driving its own frame loop
	# may call it directly.
	def Record()
		This.Layout()
		if StzEngineGuiRender(@nId) != 0
			StzRaise("stzPanel.Record: the panel is no longer alive.")
		ok

	# Flat x, y, r, g, b, a per vertex -- pixel space, channels 0..255.
	def Verts()
		This.Record()
		return StzEngineGuiVerts()

	# Flat 0-based triangle indices.
	def Indices()
		This.Record()
		return StzEngineGuiIndices()

	def TriangleCount()
		This.Record()
		return floor(len(StzEngineGuiIndices()) / 3)

	# [ draws, droppedTexturedDraws, ignoredScissors, widthCalls,
	#   generateCalls, keyboardActivations ]
	#
	# A bounded record COUNTS what it drops, which is why the second and
	# third entries exist. In G1 the font engine is a stub that generates
	# no textures, so a nonzero dropped count means geometry arrived that
	# this phase cannot draw -- and that is precisely what G2 turns on. A
	# panel that quietly rendered fewer triangles than it was given would
	# be indistinguishable from one that rendered them all.
	def Counters()
		return StzEngineGuiCounters()

	def DroppedTexturedDraws()
		_a_ = This.Counters()
		return _a_[2]

	def IgnoredScissors()
		_a_ = This.Counters()
		return _a_[3]

	# The laid-out box of one element: [x, y, w, h], in panel pixels.
	# Empty when there is no such element -- an absence, not a raise, since
	# asking about an element that may not exist is a fair question.
	def BoxOf(pcElementId)
		return StzEngineGuiElementBox(@nId, "" + pcElementId)

	def LastEngineMessage()
		return StzEngineGuiLastError()

	#-- output --------------------------------------------------------------

	# Put the panel's triangles into a canvas. The canvas decides what
	# happens next -- ToSVG() with no device, ToPNG() with one, a window,
	# or a texture mapped onto a quad in a 3D scene. The panel does not
	# know and must not care.
	def DrawInto(poCanvas)
		if NOT isObject(poCanvas)
			StzRaise("stzPanel.DrawInto: give an stzCanvas.")
		ok
		This.Record()
		_aV_ = StzEngineGuiVerts()
		_aI_ = StzEngineGuiIndices()
		if len(_aI_) < 3
			return FALSE     # nothing to draw is a valid answer
		ok
		poCanvas.AddMesh(_aV_, _aI_)
		return TRUE

	def DrawIntoQ(poCanvas)
		This.DrawInto(poCanvas)
		return This

	# The panel as a picture, on the tier this machine can reach. A canvas
	# is made, drawn into and answered -- so the caller gets ToSVG/ToPNG/
	# Show without assembling anything.
	def ToCanvas()
		_oC_ = new stzCanvas(@nW, @nH)
		This.DrawInto(_oC_)
		return _oC_

	def ToSVG()
		return This.ToCanvas().ToSVG()

	def ToPNG(pcPath)
		return This.ToCanvas().ToPNG(pcPath)

	def Free()
		if @nId > 0
			StzEngineGuiContextFree(@nId)
			@nId = 0
			@bLoaded = FALSE
		ok
