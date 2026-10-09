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

# Lays out an interface document with the RmlUi engine and hands the result over as triangles, text commands, boxes and events.
#
# A panel is neither a window nor a renderer: it computes where things go and leaves drawing to a
# canvas, so the same layout reaches an SVG on a machine with no graphics card. The markup is loaded
# as a text (LoadMarkup), never from a file, because it is meant to be emitted by a higher layer.
# After Layout the panel answers where an element sits (BoxOf), what lies under a point (ElementAt),
# which elements the keyboard reaches (TabRing) and what input produced (Events, drained by the
# caller and never dispatched back into Ring). SetTextOf and SetStyleOf change one element without
# loading the document again. RML has no default stylesheet, so give a div display: block and the
# body width: 100% to fill the panel. Pointer verbs act on the layout, so call Layout first. The
# event queue and the counters belong to the engine and are shared by every panel. Needs
# stz_gui.dll; ask StzGuiAvailable() first. Free the panel when done.
#
#   receiver   o1 = new stzPanel(320, 200)
#   example    o1.LoadMarkup('<rml><head><style>body { width: 100%; height: 100%; } div { display: block; } #bar { height: 48px; background-color: #2b6cb0; } .b { width: 100px; height: 30px; tab-index: auto; }</style></head><body><div id="bar"/><div id="one" class="b"/><div id="two" class="b"/></body></rml>')
#              o1.Layout()
#              ? @@( o1.BoxOf("bar") )
#              #--> [ 0, 0, 320, 48 ]
#              ? @@( o1.TabRing() )
#              #--> [ "one", "two" ]
#              ? o1.ElementAt(10, 10)
#              #--> bar
#              ? o1.TriangleCount()
#              #--> 2
#   see        stzCanvas, stzWindow, stzFont, StzGuiAvailable
class stzPanel from stzObject

	@nId = 0
	@nW = 0
	@nH = 0
	@bLoaded = FALSE
	@aFonts = []       # [ [ engineFontId, stzFont ], ... ] -- see UseFont

	# Builds a panel of the given size in pixels, backed by one engine layout context.
	#
	#   pnW        the width in pixels, from 1 to 16384
	#   pnH        the height in pixels, from 1 to 16384
	#   returns    nothing; the object is built
	#   note       ask StzGuiAvailable() first: an absent engine is a legitimate state
	#   warning    raises an error when the machine has no layout engine, when a size is not a
	#              number, and when a size is out of range (0 by 0 is refused)
	#   see        LoadMarkup, Free
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

	# Returns the number of the engine context that holds this panel.
	#
	#   returns    a number
	#   note       0 after Free
	#   see        IsAlive, Free
	#@ aka  -- identity ------------------------------------------------------------
	def Id_()
		return @nId

	# Returns the width of the panel in pixels.
	#
	#   returns    a number
	#   see        Height, Resize
	def Width()
		return @nW

	# Returns the height of the panel in pixels.
	#
	#   returns    a number
	#   see        Width, Resize
	def Height()
		return @nH

	# TRUE if the engine still holds this panel, FALSE after Free.
	#
	#   returns    TRUE or FALSE
	#   see        Free, Layout
	def IsAlive()
		return @nId > 0 and StzEngineGuiUpdate(@nId) = 0

	# Loads a document written in RML, the XML dialect of RmlUi, from a text; no file is read.
	#
	#   pcRml      the markup as text
	#   returns    nothing
	#   note       RML has no default stylesheet, so a div needs display: block to take a box; a
	#              body needs width: 100% to fill the panel; a box joins the tab ring with tab-
	#              index: auto
	#   warning    does not raise for malformed markup today: an unclosed br and the text this is
	#              not markup were both accepted, HasDocument answered TRUE, and only the first left
	#              an error text in LastEngineMessage
	#   see        LoadMarkupQ, Layout, LastEngineMessage
	#@ aka  -- the document --------------------------------------------------------
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

	# TRUE if markup has been loaded into this panel.
	#
	#   returns    TRUE or FALSE
	#   note       it records that a load was accepted, not that the markup was well formed
	#   see        LoadMarkup
	def HasDocument()
		return @bLoaded

	# Lays the loaded document out in the panel; cheap when nothing has changed.
	#
	#   returns    nothing
	#   note       pointer events and ElementAt see the layout, so call it before ClickAt and the
	#              other pointer verbs: a click made before the first Layout produced no event
	#   warning    raises an error once the panel has been freed
	#   see        Record, BoxOf, Resize
	#@ aka  Lay out. Cheap when nothing changed: G0 measured a still frame at 1/362 of a dirty one, and 500 still frames re-compiled zero geometry.
	def Layout()
		if StzEngineGuiUpdate(@nId) != 0
			StzRaise("stzPanel.Layout: the panel is no longer alive.")
		ok

	def LayoutQ()
		This.Layout()
		return This

	# Changes the panel size and lays the document out again; FALSE when the engine refuses the size.
	#
	#   pnW        the new width in pixels
	#   pnH        the new height in pixels
	#   returns    TRUE or FALSE
	#   note       a body with width: 100% follows the new width
	#   see        Width, Height, Layout
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

	# Sets the clock RmlUi animates by, in seconds, so a frame does not depend on when it ran.
	#
	#   pnSeconds   the time in seconds
	#   returns     nothing
	#   see         Layout
	#@ aka  RmlUi's clock, driven by the caller -- so a test frame is deterministic instead of depending on when it ran.
	def SetTime(pnSeconds)
		StzEngineGuiSetTime(pnSeconds)

	# Lays out if needed, then records the triangles and text commands the next reads will return.
	#
	#   returns    nothing
	#   note       DrawInto, Verts, Indices and TriangleCount call it for you
	#   warning    raises an error once the panel has been freed
	#   see        Verts, Indices, Texts
	#@ aka  -- the geometry --------------------------------------------------------
	def Record()
		This.Layout()
		if StzEngineGuiRender(@nId) != 0
			StzRaise("stzPanel.Record: the panel is no longer alive.")
		ok

	# Returns the vertices of the recorded triangles as one flat list of x, y, r, g, b, a per vertex.
	#
	#   returns    a list of numbers, six per vertex, in pixels and 0 to 255
	#   note       a document with no painted box answers an empty list; a div painted at all needs
	#              display: block
	#   see        Indices, TriangleCount
	#@ aka  Flat x, y, r, g, b, a per vertex -- pixel space, channels 0..255.
	def Verts()
		This.Record()
		return StzEngineGuiVerts()

	# Returns the 0-based triangle corners that index into the vertices.
	#
	#   returns    a list of numbers, three per triangle
	#   see        Verts, TriangleCount
	#@ aka  Flat 0-based triangle indices.
	def Indices()
		This.Record()
		return StzEngineGuiIndices()

	# Returns how many triangles the layout drew.
	#
	#   returns    a number
	#   note       one painted box is two triangles
	#   warning    raises an error once the panel has been freed
	#   see        Verts, Indices
	def TriangleCount()
		This.Record()
		return floor(len(StzEngineGuiIndices()) / 3)

	# Returns the twelve counters of the engine's last render as one list; the named readers pick single ones.
	#
	#   returns    a list of 12 numbers
	#   note       the twelve, in order, are draws, dropped textured draws, ignored scissors, width
	#              calls, generate calls, keyboard activations, width cache hits, shape calls, text
	#              meshes, text draws, text drops, text releases; they belong to the engine, not to
	#              one panel: a new panel reads the figures of the last render, and a fresh process
	#              starts at zeros
	#   see        WidthCalls, TextIsWhole, DroppedTexturedDraws
	#@ aka  [ draws, droppedTexturedDraws, ignoredScissors, widthCalls, generateCalls, keyboardActivations, widthCacheHits, shapeCalls, textMeshes, textDraws, textDrops, textReleases ]
	def Counters()
		return StzEngineGuiCounters()

	# Returns how many times RmlUi asked the font engine for a string width.
	#
	#   returns    a number
	#   see        ShapeCalls, WidthCacheHits
	def WidthCalls()
		_a_ = This.Counters()
		return _a_[4]

	# Returns how many width requests reached the shaper; the gap to WidthCalls is the width cache at work.
	#
	#   returns    a number
	#   see        WidthCalls, WidthCacheHits
	def ShapeCalls()
		_a_ = This.Counters()
		return _a_[8]

	# Returns how many width requests the cache answered without shaping.
	#
	#   returns    a number
	#   see        WidthCalls, ShapeCalls
	def WidthCacheHits()
		_a_ = This.Counters()
		return _a_[7]

	# Returns how many strings became one tagged text mesh.
	#
	#   returns    a number
	#   see        GenerateCalls, TextIsWhole
	#@ aka  Every string the font engine was asked to generate must become one tagged mesh. TextMeshes() < GenerateCalls() means a string was measured and then produced no geometry -- which is text vanishing silently, with nothing else moving to say so.
	def TextMeshes()
		_a_ = This.Counters()
		return _a_[9]

	# Returns how many strings the font engine was asked to generate.
	#
	#   returns    a number
	#   see        TextMeshes, TextIsWhole
	def GenerateCalls()
		_a_ = This.Counters()
		return _a_[5]

	# Returns how many text draw commands were recorded.
	#
	#   returns    a number
	#   see        TextMeshes, Texts
	def TextDraws()
		_a_ = This.Counters()
		return _a_[10]

	# TRUE if every generated string became geometry and none was released unused.
	#
	#   returns    TRUE or FALSE
	#   note       FALSE means text vanished silently; 1 with no font loaded and no text is still
	#              TRUE
	#   see        TextMeshes, GenerateCalls
	#@ aka  TRUE when every generated string became geometry.
	def TextIsWhole()
		_a_ = This.Counters()
		return _a_[9] = _a_[5] and _a_[11] = 0

	# Returns how many textured draws the bounded record had to drop.
	#
	#   returns    a number
	#   note       a dropped draw is counted, not hidden
	#   see        Counters, IgnoredScissors
	def DroppedTexturedDraws()
		_a_ = This.Counters()
		return _a_[2]

	# Returns how many scissor rectangles the record ignored.
	#
	#   returns    a number
	#   see        Counters, DroppedTexturedDraws
	def IgnoredScissors()
		_a_ = This.Counters()
		return _a_[3]

	# Binds a font family name used in the document to the bytes of a TTF or OTF font, and returns the stzFont to paint with.
	#
	#   pcFamily        the family name the document's font-family refers to
	#   pcPathOrBytes   a path to a font file, or the font bytes themselves
	#   returns         an stzFont, or NULL when the engine refuses the bytes
	#   note            text that is not a font, such as not a font at all, answers NULL; the font
	#                   engine measures with these bytes and the canvas paints with them
	#   warning         raises an error when the path or bytes are empty
	#   see             FontCount, FontFor, LoadMarkup
	#@ aka  -- fonts (G2) ----------------------------------------------------------
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

	# Returns how many font faces the engine holds.
	#
	#   returns    a number
	#   see        UseFont, FontFor
	def FontCount()
		return StzEngineGuiFontCount()

	# Returns the stzFont registered under an engine font id, or the first one when the id is unknown.
	#
	#   pnEngineId   the font id a text command carries, as in the first number of a row of Texts
	#   returns      an stzFont, or NULL when no font was registered
	#   note         the match is by engine id, not by family name
	#   see          UseFont, Texts
	#@ aka  The stzFont this panel paints a recorded command with. Matching is by the engine font id the command carries -- not by family name, which a fallback may have changed under us.
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

	# Moves the pointer to a point in panel pixels and lets the document see it.
	#
	#   pnX        the x in panel pixels
	#   pnY        the y in panel pixels
	#   returns    the engine status, 0 when the move was accepted
	#   note       it produces enter and leave events only after Layout has run
	#   see        PointerPressed, ClickAt, Events
	#@ aka  -- input, focus and events (G3) ----------------------------------------
	def PointerMovedTo(pnX, pnY)
		return StzEngineGuiPointerMove(@nId, pnX, pnY, 0)

	# Moves the pointer to a point and presses a button.
	#
	#   pnX        the x in panel pixels
	#   pnY        the y in panel pixels
	#   pnButton   the button number, 0 for the main one
	#   returns    the engine status, 0 when accepted
	#   note       a pressed button stays down until PointerReleased
	#   see        PointerReleased, ClickAt
	def PointerPressed(pnX, pnY, pnButton)
		StzEngineGuiPointerMove(@nId, pnX, pnY, 0)
		return StzEngineGuiPointerButton(@nId, pnButton, 1, 0)

	# Moves the pointer to a point and releases a button.
	#
	#   pnX        the x in panel pixels
	#   pnY        the y in panel pixels
	#   pnButton   the button number, 0 for the main one
	#   returns    the engine status, 0 when accepted
	#   see        PointerPressed, ClickAt
	def PointerReleased(pnX, pnY, pnButton)
		StzEngineGuiPointerMove(@nId, pnX, pnY, 0)
		return StzEngineGuiPointerButton(@nId, pnButton, 0, 0)

	# Presses and releases the main button at a point, as one gesture.
	#
	#   pnX        the x in panel pixels
	#   pnY        the y in panel pixels
	#   returns    the engine status of the release, 0 when accepted
	#   note       after Layout it queues enter, pointer down, pointer up and click events for the
	#              element hit
	#   see        PointerPressed, PointerReleased, EventsFor
	#@ aka  The whole gesture, because a click is a press AND a release and a caller that forgets the second one gets a button stuck down.
	def ClickAt(pnX, pnY)
		This.PointerPressed(pnX, pnY, 0)
		return This.PointerReleased(pnX, pnY, 0)

	# Tells the document the pointer left the panel.
	#
	#   returns    the engine status, 0 when accepted
	#   note       it queues leave events for the elements the pointer was over
	#   see        PointerMovedTo, Events
	def PointerLeft()
		return StzEngineGuiPointerLeave(@nId)

	# Sends a key down and then a key up to the focused element.
	#
	#   pnKey      the RmlUi key identifier
	#   pnMods     the modifier bits, 0 for none
	#   returns    the engine status of the key up, 0 when accepted
	#   note       only the key down arrives in Events, as a kind 8 event aimed at the focused
	#              element
	#   see        TypeText, Events
	def KeyPressed(pnKey, pnMods)
		StzEngineGuiKey(@nId, pnKey, 1, pnMods)
		return StzEngineGuiKey(@nId, pnKey, 0, pnMods)

	# Sends typed characters to the focused element.
	#
	#   pcText     the characters typed
	#   returns    the engine status, 0 when accepted
	#   note       it arrives in Events as a kind 9 event aimed at the focused element
	#   see        KeyPressed, Events
	def TypeText(pcText)
		return StzEngineGuiTextInput(@nId, "" + pcText)

	# Returns the name of the element under a point, or an empty text when it hits nothing that has a name.
	#
	#   pnX        the x in panel pixels
	#   pnY        the y in panel pixels
	#   returns    a text
	#   note       call Layout first
	#   see        BoxOf, ClickAt
	#@ aka  The element under a point, by name. "" when the point hits nothing that carries a name -- a fair answer, not a failure.
	def ElementAt(pnX, pnY)
		return StzEngineGuiElementAt(@nId, pnX, pnY)

	# Converts a point in a window's pixels to panel pixels, scaling by the two sizes.
	#
	#   poWindow   the stzWindow, or any object with Width and Height
	#   pnX        the x in window pixels
	#   pnY        the y in window pixels
	#   returns    a list [ x, y ] in panel pixels; [ 0, 0 ] for a window smaller than one pixel
	#   note       a 640 by 400 window and a 320 by 200 panel turn 320, 200 into 160, 100
	#   warning    raises an error when the argument is not an object
	#   see        FromTexture, ElementAt
	#@ aka  -- the conversions, named at the boundary ------------------------------
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

	# Converts a texture coordinate to panel pixels, flipping v because a texture starts at the bottom.
	#
	#   pnU        the horizontal texture coordinate, 0 to 1
	#   pnV        the vertical texture coordinate, 0 to 1
	#   returns    a list [ x, y ] in panel pixels
	#   note       on a 320 by 200 panel, 0.5 and 0.25 give 160 and 150
	#   see        FromWindow
	#@ aka  A panel hanging in a 3D scene is hit by a RAY, and what the caller has after the intersection is a texture coordinate. This is the whole of the in-scene input mapping (§6's tier): uv in, panel pixels out. v is flipped because a texture's origin is bottom-left and a panel's is top-left -- the one place that difference is stated, so no caller has to remember it.
	def FromTexture(pnU, pnV)
		return [ pnU * @nW, (1 - pnV) * @nH ]

	# Replaces the words of one element, without loading the document again; markup in the value stays text.
	#
	#   pcName     the id of the element
	#   pcText     the new words, as data
	#   returns    TRUE if the element was found and changed, FALSE otherwise
	#   note       the value is escaped, so a text holding a b tag is drawn as that text
	#   see        SetTextOfQ, SetStyleOf
	#@ aka  -- the update path (G5) -------------------------------------------------
	def SetTextOf(pcName, pcText)
		if @nId = 0
			return FALSE
		ok
		return StzEngineGuiSetText(@nId, "" + pcName, "" + pcText) = 0

	def SetTextOfQ(pcName, pcText)
		This.SetTextOf(pcName, pcText)
		return This

	# Sets one RCSS property on one element and lays out what depends on it; an empty value removes the property.
	#
	#   pcName       the id of the element
	#   pcProperty   the RCSS property name, for example width
	#   pcValue      the value, for example 150px
	#   returns      TRUE if the element was found, FALSE otherwise
	#   note         the box of an element changes at the next Layout, not at the call
	#   see          ClearStyleOf, SetTextOf
	#@ aka  One RCSS property on one element. The property name is the RCSS one, which §3's divergence table governs -- so a binding and a declaration cannot disagree about spelling.
	def SetStyleOf(pcName, pcProperty, pcValue)
		if @nId = 0
			return FALSE
		ok
		return StzEngineGuiSetStyle(@nId, "" + pcName,
			"" + pcProperty, "" + pcValue) = 0

	def SetStyleOfQ(pcName, pcProperty, pcValue)
		This.SetStyleOf(pcName, pcProperty, pcValue)
		return This

	# Removes one RCSS property from one element, handing it back to the stylesheet.
	#
	#   pcName       the id of the element
	#   pcProperty   the RCSS property name to remove
	#   returns      TRUE if the element was found, FALSE otherwise
	#   see          SetStyleOf
	def ClearStyleOf(pcName, pcProperty)
		return This.SetStyleOf(pcName, pcProperty, "")

	# Gives the keyboard focus to the named element.
	#
	#   pcName     the id of the element
	#   returns    the engine status: 0 when focus was placed, 4 for a name that does not exist
	#   note       an element that is not in the tab ring can still take focus by name
	#   see        Focused, ClearFocus, FocusNext
	#@ aka  -- focus ---------------------------------------------------------------
	def FocusOn(pcName)
		return StzEngineGuiFocus(@nId, "" + pcName)

	# Removes the keyboard focus from every element.
	#
	#   returns    the engine status, 0 when accepted
	#   see        FocusOn, Focused
	def ClearFocus()
		return StzEngineGuiFocus(@nId, "")

	# Returns the name of the focused element, or an empty text when none is.
	#
	#   returns    a text
	#   see        FocusOn, TabRing
	#@ aka  The focused element's name, or "" when nothing is focused.
	def Focused()
		return StzEngineGuiFocused(@nId)

	# Moves focus to the next stop of the tab ring, like Tab.
	#
	#   returns    TRUE if focus moved, FALSE when refused
	#   note       with nothing focused it lands on the first stop; the ring wraps, so after the
	#              last stop it returns to the first
	#   see        FocusPrevious, TabRing
	#@ aka  TRUE when focus MOVED. A refusal at the end of a ring is a real answer, not an error, so it answers FALSE rather than raising.
	def FocusNext()
		return StzEngineGuiFocusMove(@nId, 0) = 0

	# Moves focus to the previous stop of the tab ring, like Shift+Tab.
	#
	#   returns    TRUE if focus moved, FALSE when refused
	#   see        FocusNext, TabRing
	def FocusPrevious()
		return StzEngineGuiFocusMove(@nId, 1) = 0

	# Moves focus to the element above, for an arrow key or a gamepad stick.
	#
	#   returns    TRUE if focus moved, FALSE when refused
	#   note       in a column of three boxes with tab-index: auto all four directional moves
	#              answered FALSE and left focus where it was, while FocusNext moved it
	#   see        FocusDown, FocusNext
	#@ aka  Directional moves, for an arrow key or a gamepad stick. RmlUi picks the target by a spatial heuristic, which is what the WAI-ARIA APG contract wants inside a composite widget.
	def FocusUp()
		return StzEngineGuiFocusMove(@nId, 2) = 0

	# Moves focus to the element below, for an arrow key or a gamepad stick.
	#
	#   returns    TRUE if focus moved, FALSE when refused
	#   note       in a column of three boxes with tab-index: auto it answered FALSE and left focus
	#              where it was
	#   see        FocusUp, FocusNext
	def FocusDown()
		return StzEngineGuiFocusMove(@nId, 3) = 0

	# Moves focus to the element on the left, for an arrow key or a gamepad stick.
	#
	#   returns    TRUE if focus moved, FALSE when refused
	#   see        FocusRight, FocusNext
	def FocusLeft()
		return StzEngineGuiFocusMove(@nId, 4) = 0

	# Moves focus to the element on the right, for an arrow key or a gamepad stick.
	#
	#   returns    TRUE if focus moved, FALSE when refused
	#   see        FocusLeft, FocusNext
	def FocusRight()
		return StzEngineGuiFocusMove(@nId, 5) = 0

	# Walks the whole tab ring and returns the names of its stops in order.
	#
	#   returns    a list of texts; empty when no element has tab-index: auto
	#   note       it clears focus first and leaves focus on the first stop; the walk is bounded at
	#              200 stops
	#   see        FocusNext, Focused
	#@ aka  Walk the whole tab ring and answer the names in order. THE keyboard contract made checkable: a screen whose ring omits an action is a screen a keyboard cannot operate, and Rule 80 says that is a defect. Bounded, because a ring that never closes would otherwise hang.
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

	# Returns the events queued so far, each as [ kind, source, x, y, button, key, mods, target ].
	#
	#   returns    a list of lists of 8 values
	#   note       kind is 1 click, 2 pointer down, 3 pointer up, 4 pointer enter, 5 pointer leave,
	#              6 focus, 7 blur, 8 key down, 9 text; the list is the engine's, shared by every
	#              panel, and reading it does not empty it
	#   see        ClearEvents, EventsFor, EventCount
	#@ aka  -- events --------------------------------------------------------------
	def Events()
		return StzEngineGuiEvents()

	# Empties the event queue.
	#
	#   returns    nothing
	#   see        Events, EventsDropped
	def ClearEvents()
		StzEngineGuiEventsClear()

	# Returns how many events the bounded queue threw away because nobody drained it.
	#
	#   returns    a number
	#   see        Events, ClearEvents
	#@ aka  What the bounded queue threw away. A caller that stops draining stops receiving, and this is how it finds out.
	def EventsDropped()
		return StzEngineGuiEventsDropped()

	# Returns how many events are waiting.
	#
	#   returns    a number
	#   note       the queue is shared by every panel
	#   see        Events, EventsFor
	def EventCount()
		return len(StzEngineGuiEvents())

	# Returns the queued events whose target is the named element.
	#
	#   pcName     the id of the target element
	#   returns    a list of events, each of 8 values
	#   see        Events, ClickAt
	#@ aka  Every event whose target is one named element.
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

	# Returns the text commands of the last render, each as [ font id, size, x, y, colour, text ].
	#
	#   returns    a list of lists of 6 values; x and y are the baseline origin
	#   note       it records first, so it works on a freshly loaded document
	#   see        TextCount, UseFont, DrawInto
	#@ aka  -- the text the layout wants drawn (G2) --------------------------------
	def Texts()
		This.Record()
		return StzEngineGuiTexts()

	# Returns how many text commands the last render produced.
	#
	#   returns    a number
	#   see        Texts, TextDraws
	def TextCount()
		return len(This.Texts())

	# Returns the laid-out box of one element as [ x, y, w, h ] in panel pixels, or an empty list when it does not exist.
	#
	#   pcElementId   the id of the element
	#   returns       a list of 4 numbers, or [ ]
	#   note          call Layout first; asking for an element that is not there is a fair question
	#                 and does not raise
	#   see           Layout, ElementAt
	#@ aka  The laid-out box of one element: [x, y, w, h], in panel pixels. Empty when there is no such element -- an absence, not a raise, since asking about an element that may not exist is a fair question.
	def BoxOf(pcElementId)
		return StzEngineGuiElementBox(@nId, "" + pcElementId)

	# Returns the last error text the layout engine reported, for example why markup was refused.
	#
	#   returns    a text; empty when there is none
	#   note       the message is the engine's, so a new panel can read the last one of another
	#   see        LoadMarkup
	def LastEngineMessage()
		return StzEngineGuiLastError()

	# Adds the panel's triangles and text to a canvas; FALSE when there is nothing to draw.
	#
	#   poCanvas   the stzCanvas to draw into, and anything that is not an object raises an error
	#   returns    TRUE if something was drawn, FALSE for a document with no painted box
	#   note       the canvas decides the output: SVG with no device, PNG with one
	#   see        DrawIntoQ, ToCanvas, ToSVG
	#@ aka  -- output --------------------------------------------------------------
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

	# Returns a new stzCanvas of the panel's size with the panel drawn into it.
	#
	#   returns    a new stzCanvas
	#   note       free the canvas with Free when done
	#   see        DrawInto, ToSVG
	#@ aka  The panel as a picture, on the tier this machine can reach. A canvas is made, drawn into and answered -- so the caller gets ToSVG/ToPNG/ Show without assembling anything.
	def ToCanvas()
		_oC_ = new stzCanvas(@nW, @nH)
		This.DrawInto(_oC_)
		return _oC_

	# Returns the panel as an SVG picture, drawing into a canvas that is freed afterwards.
	#
	#   returns    a text holding the SVG
	#   note       it needs no graphics device
	#   see        ToCanvas, ToPNG
	def ToSVG()
		# the canvas is TRANSIENT: its engine scene (a target texture on the GPU
		# tier, vertex buffers, the command list) is freed once the answer is taken --
		# a picture per call used to leave a texture live per call (found 2026-09-11)
		_oCv_ = This.ToCanvas()
		_cOut_ = _oCv_.ToSVG()
		_oCv_.Free()
		return _cOut_

	# Draws the panel into a canvas, writes it as a PNG file at the path and frees the canvas.
	#
	#   pcPath     the file to write
	#   returns    whatever the canvas answers for the write
	#   note       the canvas is freed after the call
	#   warning    not run in this wave: it needs a graphics device
	#   see        ToSVG, ToCanvas
	def ToPNG(pcPath)
		# the canvas is TRANSIENT: its engine scene (a target texture on the GPU
		# tier, vertex buffers, the command list) is freed once the answer is taken --
		# a picture per call used to leave a texture live per call (found 2026-09-11)
		_oCv_ = This.ToCanvas()
		_cOut_ = _oCv_.ToPNG(pcPath)
		_oCv_.Free()
		return _cOut_

	# Releases the engine context and the fonts this panel bound; the panel is dead afterwards.
	#
	#   returns    nothing
	#   note       afterwards Layout, Record and TriangleCount raise an error, BoxOf answers [ ],
	#              SetTextOf answers FALSE and IsAlive answers FALSE
	#   see        IsAlive, UseFont
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
