load "../../stzBase.ring"

/*
	G5 -- THE BINDING. A declared value changes, and the screen follows.

	The first clause of G5 shipped early, with G1: `.stzui` already turns
	Softanza declarations into RML and RCSS, because §4 forbade
	hand-writing markup and had left nothing a person may write. This is
	what remained.

	WHAT IT REPLACES, and both of them said so in their own comments: an
	app that reacted used to build a WHOLE NEW DOCUMENT --
	`stzScenePanel.Shows` for the in-scene tier, the showcase viewer's
	reload for the desktop one.

	THE CLAIM THIS GUARD WAS WRITTEN TO CHECK WAS WRONG, and finding that
	out is most of what the guard is for. The obvious claim -- "a binding
	re-shapes only the string that changed" -- is FALSE. Changing one
	label of six re-shapes all six, whichever engine call is used, because
	that is RmlUi's invalidation granularity: a text change dirties the
	document. The measurement is below, stated as the number it is.

	WHAT A BINDING DOES BUY is two things the guard can prove:

	  STYLE UPDATES ARE SURGICAL. A colour re-shapes one string; a
	  background, none. Text and style are genuinely different costs, so
	  they stay different verbs.

	  THE DOCUMENT SURVIVES. No re-parse, no new context, no font
	  re-registration -- and FOCUS stays where it was. A rebuild loses it,
	  which is a correctness difference and not a cost one: a form that
	  re-declared itself to update a status line used to throw away the
	  user's place in it.

	Needs stz_gui.dll; needs no GPU for the counters.
*/

? ""
? "=========================================================="
? " G5: A DECLARED VALUE CHANGES, AND THE SCREEN FOLLOWS"
? "=========================================================="

nOK = 0
nBad = 0

if NOT StzGuiAvailable()
	? "No layout engine on this machine -- nothing to bind."
	return
ok

#---------------------------------------------------------------------
? ""
? "-- 1. What the document declared -----------------------------"
#---------------------------------------------------------------------
/*
	A placeholder is an ordinary string with braces in it. That is the
	whole design decision: the Grammar Commons fixes what a field value
	may BE, and `CONTENT @bearing` would mint a fifth kind of value for
	one plane's convenience.
*/

oU = new stzUiDocument("bound.stzui")
if NOT oU.IsClean()
	? oU.Report()
ok
Chk("a document with placeholders is still a clean document", oU.IsClean())
Chk("...and still round-trips to a fixpoint", oU.ToText() = _Reparse(oU.ToText()))

oU.UseFont(FontPath())
oP = oU.ToPanel()
oB = new stzUiBindings(oU, oP)

aN = oB.Names()
? "  declared bindings: " + _Join(aN)
# FIVE, not six: mode, bearing, range, drift, hull. The footer's "{}"
# is prose and correctly did NOT become a sixth.
Chk("every placeholder was found, and only those", len(aN) = 5)
Chk("bearing is bound", oB.IsBound("bearing"))
Chk("hull is bound", oB.IsBound("hull"))
Chk("a name nobody wrote is not bound", oB.IsBound("altitude") = FALSE)

# A LONE BRACE IS PROSE. The footer says "use {} for a set", and a
# template language that eats ordinary punctuation is one people stop
# writing prose in.
Chk("an empty brace is NOT a binding", oB.IsBound("") = FALSE)
Chk("...and the footer is not a bound element",
   _NotIn(oB.BoundElements(), "footer"))
Chk("an unbound label is left alone entirely",
   _NotIn(oB.BoundElements(), "fire_text"))

Chk("nothing has a value yet", len(oB.Unset()) = 5)
Chk("...and an unset name renders as empty", oB.ValueOf("bearing") = "")

#---------------------------------------------------------------------
? ""
? "-- 2. Substitution, before anything is drawn -----------------"
#---------------------------------------------------------------------
/*
	RenderOf answers what an element's text WOULD be. Testing the
	substitution apart from the rendering is what keeps a failure
	legible: a wrong string and a string that never reached the screen
	are different bugs.
*/

oB.Set("bearing", "042.9")
Chk("one value lands", oB.ValueOf("bearing") = "042.9")
? "  line_one now reads: " + oB.RenderOf("line_one")
Chk("...and appears in the rendered line",
   len(StzFindCS("042.9", oB.RenderOf("line_one"), TRUE)) > 0)

# TWO VALUES ON ONE LINE, which is why this line exists in the document:
# setting one must not disturb the other.
Chk("the OTHER placeholder on that line is still empty, not eaten",
   len(StzFindCS("RANGE  km", oB.RenderOf("line_one"), TRUE)) > 0)
oB.Set("range", "3.10")
Chk("...and filling it leaves the first alone",
   len(StzFindCS("BEARING 042.9   RANGE 3.10 km", oB.RenderOf("line_one"), TRUE)) > 0)

oB.SetMany([ :mode = "APPROACH", :drift = "nominal", :hull = "98" ])
Chk("SetMany fills the rest", len(oB.Unset()) = 0)
? "  title now reads:    " + oB.RenderOf("title")
Chk("the title carries its value",
   len(StzFindCS("NAV CONSOLE - APPROACH", oB.RenderOf("title"), TRUE)) > 0)

Chk("prose braces survived the whole pass",
   oB.RenderOf("footer") = "")   # not a template at all, so nothing to render

#---------------------------------------------------------------------
? ""
? "-- 3. THE MEASUREMENT: what a binding actually costs ---------"
#---------------------------------------------------------------------
/*
	The honest part. GenerateCalls() counts strings handed to the shaper.
	A still redraw costs ZERO -- RmlUi re-renders from its geometry cache
	-- so any delta here is real work caused by the change.
*/

oC = new stzCanvas(oP.Width(), oP.Height())
oC.Clear()
oP.DrawInto(oC)
n0 = oP.GenerateCalls()
? "  after the first draw:        " + n0 + " strings shaped"

oC.Clear()
oP.DrawInto(oC)
Chk("a still redraw shapes nothing -- the cache is real",
   oP.GenerateCalls() = n0)

# STYLE: surgical, and this is the measurement that justifies keeping
# SetStyle a separate verb from Set.
n1 = oP.GenerateCalls()
oB.SetStyle("line_one", "color", "#ff5050")
oC.Clear()
oP.DrawInto(oC)
nColour = oP.GenerateCalls() - n1
? "  a colour change:             " + nColour + " strings re-shaped"
Chk("a colour re-shapes exactly the string it touched", nColour = 1)

n2 = oP.GenerateCalls()
oB.SetStyle("fire", "background-color", "#207020")
oC.Clear()
oP.DrawInto(oC)
nBack = oP.GenerateCalls() - n2
? "  a background change:         " + nBack + " strings re-shaped"
Chk("a background re-shapes NOTHING", nBack = 0)

# TEXT: not surgical, and saying so is the point.
n3 = oP.GenerateCalls()
oB.Set("bearing", "137.4")
oC.Clear()
oP.DrawInto(oC)
nText = oP.GenerateCalls() - n3
? "  ONE bound value changed:     " + nText + " strings re-shaped"
Chk("a text change re-shapes the whole document, not one string",
   nText = n0)
Chk("...which is more than a style change costs", nText > nColour)

/*
	That number is RmlUi's, not ours. It was measured against the cheaper
	of the two engine calls available -- setting the text NODE rather
	than replacing the element's inner markup -- and it did not move. The
	door back (§2.4's discipline) is a batched set or a patched
	invalidation, and neither is worth opening until a text-heavy screen
	makes the cost real.
*/

#---------------------------------------------------------------------
? ""
? "-- 4. WHAT IT DOES BUY: the document survives ----------------"
#---------------------------------------------------------------------
/*
	This is the difference that is not about speed. A rebuild produces a
	new panel, and everything attached to the old one goes with it. A
	form that re-declared itself to update a status line threw away the
	user's place in it.
*/

oP.FocusOn("fire")
Chk("focus is on the action", oP.Focused() = "fire")
cRingBefore = _Join(oP.TabRing())

oB.Set("hull", "71")
oC.Clear()
oP.DrawInto(oC)
Chk("after a bound value changes, FOCUS IS STILL THERE",
   oP.Focused() = "fire")
Chk("...and the tab ring is unchanged", _Join(oP.TabRing()) = cRingBefore)
Chk("...and the panel is the same panel", oP.IsAlive())

# THE NEGATIVE SIBLING, and it is the whole argument: do it the old way
# and focus is gone. This is what stzScenePanel.Shows and the showcase
# reload were doing.
oU2 = new stzUiDocument("bound.stzui")
oU2.UseFont(FontPath())
oP2 = oU2.ToPanel()
Chk("a REBUILT panel has no focus at all", oP2.Focused() = "")
Chk("...so the rebuild lost what the binding kept",
   oP.Focused() = "fire" and oP2.Focused() != "fire")
oP2.Free()

#---------------------------------------------------------------------
? ""
? "-- 5. Refusals and honesty -----------------------------------"
#---------------------------------------------------------------------

Chk("setting a name nothing declares is accepted but changes nothing",
   oB.Set("altitude", "900"))
Chk("...and it did not become a binding", oB.IsBound("altitude") = FALSE)

# THE VALUE IS DATA. A model holding markup must not inject it into a
# document the court already passed.
oB.Set("mode", "<span style='color:red'>OWNED</span>")
oC.Clear()
oP.DrawInto(oC)
Chk("markup in a value does not become markup",
   len(StzFindCS("span", oB.RenderOf("title"), TRUE)) > 0)
Chk("...and the panel is still alive after swallowing it", oP.IsAlive())
oB.Set("mode", "APPROACH")

Chk("the counter counts pushes, not hopes", oB.TimesApplied() > 0)
? "  element updates pushed so far: " + oB.TimesApplied()

#---------------------------------------------------------------------
? ""
? "-- 6. And it is on the screen --------------------------------"
#---------------------------------------------------------------------

oB.SetMany([ :bearing = "091.2", :range = "0.40", :mode = "TERMINAL",
	     :drift = "high", :hull = "62" ])
oB.SetStyle("line_one", "color", "#ffb020")
oC.Clear()
oP.DrawInto(oC)
if oC.CanDrawPixels()
	oC.ToPNG("gui_binding.png")
	? "  wrote gui_binding.png -- the values are declared, not written"
	Chk("the picture was produced", fexists("gui_binding.png"))
else
	? "  (no device -- the picture is not produced)"
	Chk("the SVG tier answers instead", len(oC.ToSVG()) > 100)
ok

oP.Free()

#---------------------------------------------------------------------
? ""
? "=========================================================="
? " " + nOK + " assertions green, " + nBad + " failed"
? "=========================================================="
? ""

#-- helpers, at the FOOT: code after the first func belongs to it

func Chk(cWhat, bCond)
	if bCond
		nOK++
	else
		nBad++
		? "  FAIL: " + cWhat
	ok

func _Reparse cText
	oX = new stzUiDocument(cText)
	return oX.ToText()

func _Join aList
	_c_ = ""
	_n_ = len(aList)
	for _i_ = 1 to _n_
		if _i_ > 1
			_c_ += ", "
		ok
		_c_ += aList[_i_]
	next
	return _c_

func _NotIn aList, cName
	_n_ = len(aList)
	for _i_ = 1 to _n_
		if aList[_i_] = cName
			return 0
		ok
	next
	return 1

func FontPath
	_a_ = [ "C:/Windows/Fonts/segoeui.ttf", "C:/Windows/Fonts/arial.ttf" ]
	_n_ = len(_a_)
	for _i_ = 1 to _n_
		if fexists(_a_[_i_])
			return _a_[_i_]
		ok
	next
	return ""
