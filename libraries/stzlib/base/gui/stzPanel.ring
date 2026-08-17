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
	@aFonts = []       # [ [ engineFontId, stzFont ], ... ] -- see UseFont

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
	#   generateCalls, keyboardActivations, widthCacheHits, shapeCalls,
	#   textMeshes, textDraws, textDrops, textReleases ]
	#
	# A bounded record COUNTS what it drops, which is why the second and
	# third entries exist: a panel that quietly rendered fewer triangles
	# than it was given would be indistinguishable from one that rendered
	# them all.
	#
	# The last two are G2's, and they are the phase's own gauge. G0
	# measured 988 GetStringWidth calls per re-layout, unmemoized by
	# RmlUi; at ~1 us per real shape that is ~1 ms/frame before a glyph
	# is drawn, so the plan made a width cache a PRECONDITION. widthCalls
	# is what RmlUi asked for and shapeCalls is what actually reached the
	# shaper -- the gap between them is the cache doing its job, and if
	# they ever converge the precondition has silently lapsed.
	def Counters()
		return StzEngineGuiCounters()

	def WidthCalls()
		_a_ = This.Counters()
		return _a_[4]

	def ShapeCalls()
		_a_ = This.Counters()
		return _a_[8]

	def WidthCacheHits()
		_a_ = This.Counters()
		return _a_[7]

	# Every string the font engine was asked to generate must become one
	# tagged mesh. TextMeshes() < GenerateCalls() means a string was
	# measured and then produced no geometry -- which is text vanishing
	# silently, with nothing else moving to say so.
	#
	# That is not hypothetical: registering one font family twice used to
	# free the id the existing faces pointed at, so widths came back -1,
	# the quads were zero-wide, RmlUi culled them, and whichever panel had
	# been built first lost its text. Two panels sharing a font is all it
	# took, and every single-panel guard stayed green. The invariant lives
	# here now so the next such bug is a failing number, not a screenshot.
	def TextMeshes()
		_a_ = This.Counters()
		return _a_[9]

	def GenerateCalls()
		_a_ = This.Counters()
		return _a_[5]

	def TextDraws()
		_a_ = This.Counters()
		return _a_[10]

	# TRUE when every generated string became geometry.
	def TextIsWhole()
		_a_ = This.Counters()
		return _a_[9] = _a_[5] and _a_[11] = 0

	def DroppedTexturedDraws()
		_a_ = This.Counters()
		return _a_[2]

	def IgnoredScissors()
		_a_ = This.Counters()
		return _a_[3]

	#-- fonts (G2) ----------------------------------------------------------

	# Bind a family name -- what a document's font-family refers to -- to
	# real TTF/OTF bytes. From here RmlUi lays out with SHAPED widths:
	# Arabic joins, kerning kerns, and a line breaks where the glyphs
	# actually end rather than where a monospace guess put them.
	#
	# The SAME bytes go to both DLLs: this one measures with them, the
	# graphics plane paints with them. Two copies of one pipeline over one
	# file cannot disagree; a protocol between them could.
	#
	# Answers an stzFont for the caller to paint with, or NULL on refusal.
	def UseFont(pcFamily, pcPathOrBytes)
		_cBytes_ = "" + pcPathOrBytes
		if len(_cBytes_) < 512 and fexists(_cBytes_)
			_cBytes_ = read(_cBytes_)
		ok
		if len(_cBytes_) = 0
			StzRaise("stzPanel.UseFont: nothing to load for family '" +
				pcFamily + "'.")
		ok
		_nId_ = StzEngineGuiFontRegister("" + pcFamily, _cBytes_)
		if _nId_ = 0
			return NULL
		ok
		_oF_ = new stzFont(_cBytes_)
		@aFonts + [ _nId_, _oF_ ]
		return _oF_

	def UseFontQ(pcFamily, pcPathOrBytes)
		This.UseFont(pcFamily, pcPathOrBytes)
		return This

	def FontCount()
		return StzEngineGuiFontCount()

	# The stzFont this panel paints a recorded command with. Matching is
	# by the engine font id the command carries -- not by family name,
	# which a fallback may have changed under us.
	def FontFor(pnEngineId)
		_n_ = len(@aFonts)
		for _i_ = 1 to _n_
			if @aFonts[_i_][1] = pnEngineId
				return @aFonts[_i_][2]
			ok
		next
		if _n_ > 0
			return @aFonts[1][2]
		ok
		return NULL

	#-- input, focus and events (G3) ----------------------------------------
	#
	# EVERY VERB TAKES PANEL PIXELS, and nothing else. The coordinate-space
	# frame is dissolved rather than surfaced (§7 of the plan): a panel has
	# exactly one space, so there is nothing to confuse it with, and the
	# conversions live at the boundary where they happen -- FromWindow for
	# a window's pixels, FromTexture for a panel hanging in a 3D scene.
	# There is no ambient "current space" and no mode.
	#
	# EVENTS ARE DRAINED, NEVER DISPATCHED. RmlUi routes and bubbles, the
	# engine writes down what arrived, and Events() hands over the list.
	# A callback per event would re-enter Ring from inside a C++ dispatch,
	# which is not safe, and the house has already settled this shape
	# twice: the display list and the text commands.

	def PointerMovedTo(pnX, pnY)
		return StzEngineGuiPointerMove(@nId, pnX, pnY, 0)

	def PointerPressed(pnX, pnY, pnButton)
		StzEngineGuiPointerMove(@nId, pnX, pnY, 0)
		return StzEngineGuiPointerButton(@nId, pnButton, 1, 0)

	def PointerReleased(pnX, pnY, pnButton)
		StzEngineGuiPointerMove(@nId, pnX, pnY, 0)
		return StzEngineGuiPointerButton(@nId, pnButton, 0, 0)

	# The whole gesture, because a click is a press AND a release and a
	# caller that forgets the second one gets a button stuck down.
	def ClickAt(pnX, pnY)
		This.PointerPressed(pnX, pnY, 0)
		return This.PointerReleased(pnX, pnY, 0)

	def PointerLeft()
		return StzEngineGuiPointerLeave(@nId)

	def KeyPressed(pnKey, pnMods)
		StzEngineGuiKey(@nId, pnKey, 1, pnMods)
		return StzEngineGuiKey(@nId, pnKey, 0, pnMods)

	def TypeText(pcText)
		return StzEngineGuiTextInput(@nId, "" + pcText)

	# The element under a point, by name. "" when the point hits nothing
	# that carries a name -- a fair answer, not a failure.
	def ElementAt(pnX, pnY)
		return StzEngineGuiElementAt(@nId, pnX, pnY)

	#-- the conversions, named at the boundary ------------------------------

	# A window's pixels are the panel's when the panel fills the window,
	# which is the case stzWindow.Draw arranges. Named anyway: the reader
	# of a frame loop should see WHERE the space changes.
	def FromWindow(poWindow, pnX, pnY)
		if NOT isObject(poWindow)
			StzRaise("stzPanel.FromWindow: give an stzWindow.")
		ok
		_nW_ = poWindow.Width()
		_nH_ = poWindow.Height()
		if _nW_ < 1 or _nH_ < 1
			return [ 0, 0 ]
		ok
		return [ pnX * @nW / _nW_, pnY * @nH / _nH_ ]

	# A panel hanging in a 3D scene is hit by a RAY, and what the caller
	# has after the intersection is a texture coordinate. This is the
	# whole of the in-scene input mapping (§6's tier): uv in, panel
	# pixels out. v is flipped because a texture's origin is bottom-left
	# and a panel's is top-left -- the one place that difference is
	# stated, so no caller has to remember it.
	def FromTexture(pnU, pnV)
		return [ pnU * @nW, (1 - pnV) * @nH ]

	#-- the update path (G5) -------------------------------------------------
	#
	# BEFORE THESE, THIS CLASS COULD ONLY LOAD. Everything after LoadMarkup
	# was a QUERY -- boxes, hit tests, focus, events -- so the only way to
	# change what a screen said was to build the whole document again.
	# `stzScenePanel.Shows` and the showcase's reload both do exactly that,
	# and both say in their comments that they are the shape G5 replaces.
	#
	# This is that replacement. RmlUi re-lays-out what depends on the
	# change and leaves every other string's shaped geometry alone -- which
	# is not an optimisation we perform but one it already performs, once
	# it is TOLD about the change instead of handed a new document.
	#
	# The difference is measurable, and the guard measures it: after a
	# rebuild every string is generated again; after a set, only the ones
	# that actually changed are. GenerateCalls() reports both.

	# One element's words. The value is DATA -- it is escaped at the seam,
	# so a model holding "<span>" cannot inject markup into a document the
	# court already passed.
	def SetTextOf(pcName, pcText)
		if @nId = 0
			return FALSE
		ok
		return StzEngineGuiSetText(@nId, "" + pcName, "" + pcText) = 0

	def SetTextOfQ(pcName, pcText)
		This.SetTextOf(pcName, pcText)
		return This

	# One RCSS property on one element. The property name is the RCSS one,
	# which §3's divergence table governs -- so a binding and a declaration
	# cannot disagree about spelling.
	#
	# An EMPTY value removes the property, handing the element back to the
	# stylesheet. Without that, a binding that had fired once could never
	# be undone.
	def SetStyleOf(pcName, pcProperty, pcValue)
		if @nId = 0
			return FALSE
		ok
		return StzEngineGuiSetStyle(@nId, "" + pcName,
			"" + pcProperty, "" + pcValue) = 0

	def SetStyleOfQ(pcName, pcProperty, pcValue)
		This.SetStyleOf(pcName, pcProperty, pcValue)
		return This

	def ClearStyleOf(pcName, pcProperty)
		return This.SetStyleOf(pcName, pcProperty, "")

	#-- focus ---------------------------------------------------------------
	#
	# Rule 80 (Keyboard Sovereignty) is `machine` tier, so this is legally
	# required rather than polish. RmlUi owns the traversal -- tab order in
	# document order, and a spatial heuristic for directional moves -- and
	# what is added here is the QUERY and the COUNTED refusal.

	def FocusOn(pcName)
		return StzEngineGuiFocus(@nId, "" + pcName)

	def ClearFocus()
		return StzEngineGuiFocus(@nId, "")

	# The focused element's name, or "" when nothing is focused.
	def Focused()
		return StzEngineGuiFocused(@nId)

	# TRUE when focus MOVED. A refusal at the end of a ring is a real
	# answer, not an error, so it answers FALSE rather than raising.
	def FocusNext()
		return StzEngineGuiFocusMove(@nId, 0) = 0

	def FocusPrevious()
		return StzEngineGuiFocusMove(@nId, 1) = 0

	# Directional moves, for an arrow key or a gamepad stick. RmlUi picks
	# the target by a spatial heuristic, which is what the WAI-ARIA APG
	# contract wants inside a composite widget.
	def FocusUp()
		return StzEngineGuiFocusMove(@nId, 2) = 0

	def FocusDown()
		return StzEngineGuiFocusMove(@nId, 3) = 0

	def FocusLeft()
		return StzEngineGuiFocusMove(@nId, 4) = 0

	def FocusRight()
		return StzEngineGuiFocusMove(@nId, 5) = 0

	# Walk the whole tab ring and answer the names in order. THE keyboard
	# contract made checkable: a screen whose ring omits an action is a
	# screen a keyboard cannot operate, and Rule 80 says that is a defect.
	# Bounded, because a ring that never closes would otherwise hang.
	#
	# A ring is a CYCLE, and this enters it wherever focus currently
	# sits: RmlUi resumes tabbing from the last focused element even
	# after a blur, so calling this with `cancel` focused answers the
	# same cycle rotated. The SET and the ORDER are stable; the entry
	# point is not. Call it before touching focus if the first stop
	# matters -- as the guard does.
	def TabRing()
		_a_ = []
		This.ClearFocus()
		for _i_ = 1 to 200
			if NOT This.FocusNext()
				exit
			ok
			_c_ = This.Focused()
			if _c_ = ""
				exit
			ok
			# a ring has closed when it returns to its first stop
			if len(_a_) > 0 and _c_ = _a_[1]
				exit
			ok
			_a_ + _c_
		next
		return _a_

	#-- events --------------------------------------------------------------

	# [ [ nKind, nSource, nX, nY, nButton, nKey, nMods, cTarget ], ... ]
	#
	# nKind:   1 click  2 pointerDown  3 pointerUp  4 pointerEnter
	#          5 pointerLeave  6 focus  7 blur  8 keyDown  9 text
	# nSource: 0 pointer  1 keyboard  2 gamepad  3 synthetic  4 assistive
	#
	# The SOURCE is the frame §7 chose to surface, and it earns its place:
	# Rule 80 makes "reachable by a human keyboard" materially different
	# from "something dispatched a click", and G4 needs an assistive
	# activation distinguishable from a pointer one.
	def Events()
		return StzEngineGuiEvents()

	def ClearEvents()
		StzEngineGuiEventsClear()

	# What the bounded queue threw away. A caller that stops draining
	# stops receiving, and this is how it finds out.
	def EventsDropped()
		return StzEngineGuiEventsDropped()

	def EventCount()
		return len(StzEngineGuiEvents())

	# Every event whose target is one named element.
	def EventsFor(pcName)
		_a_ = []
		_aE_ = StzEngineGuiEvents()
		_n_ = len(_aE_)
		for _i_ = 1 to _n_
			if _aE_[_i_][8] = "" + pcName
				_a_ + _aE_[_i_]
			ok
		next
		return _a_

	#-- the text the layout wants drawn (G2) --------------------------------

	# [ [ nFontId, nSize, nX, nY, nColour, cUtf8 ], ... ] -- what the last
	# render decided to draw, where (nX, nY) is the BASELINE origin.
	#
	# Text crosses as COMMANDS, not as quads. RmlUi asked our font engine
	# for the string; the engine recorded the request instead of
	# rasterizing it, and the canvas draws it with the same shaper. That
	# is why this plane owns no glyph atlas and no second rasterizer.
	def Texts()
		This.Record()
		return StzEngineGuiTexts()

	def TextCount()
		return len(This.Texts())

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
		This._DrawTexts(poCanvas)
		return TRUE

	def DrawIntoQ(poCanvas)
		This.DrawInto(poCanvas)
		return This

	# Paint what the layout asked for, in the order it asked. The chrome
	# went in as one mesh above, so text lands on top of the boxes it
	# belongs to -- which is the painter's order RmlUi already assumed.
	def _DrawTexts(poCanvas)
		_aT_ = StzEngineGuiTexts()
		_n_ = len(_aT_)
		for _i_ = 1 to _n_
			_oF_ = This.FontFor(_aT_[_i_][1])
			if _oF_ = NULL
				loop
			ok
			# AddText FIRST, then style it: stzCanvas styles the PENDING
			# shape, and setting the font first retargets the previous one.
			poCanvas.AddTextQ(_aT_[_i_][6], _aT_[_i_][3], _aT_[_i_][4]).
				SetFontQ(_oF_, _aT_[_i_][2]).ColorQ(_aT_[_i_][5])
		next

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
		# the engine keeps its own copy of every registered face; these
		# are OUR painting handles and they are ours to release
		_n_ = len(@aFonts)
		for _i_ = 1 to _n_
			@aFonts[_i_][2].Free()
		next
		@aFonts = []
