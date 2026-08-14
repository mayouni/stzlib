# G4a -- THE ACCESSIBILITY TREE, EMITTED NOT INFERRED.
#
# The survey's one genuinely optimistic finding, and the reason this
# phase sits before the faces rather than after them:
#
#   A browser INFERS an accessibility tree from markup. Softanza EMITS
#   one from declared intent, which is strictly better information.
#
# THIS IS THE HALF NO LIBRARY REMOVES. AccessKit's platform adapters run
# 3,763 lines on Windows, 2,590 on macOS, 2,403 on Android; the survey's
# own accounting says the semantics tree -- merging, dirty tracking,
# stable IDs, traversal order -- is "comparable in size again". It is
# ours with AccessKit, with a hand-written bridge, with a web mirror DOM,
# or with nothing, so it is a precondition of all four and wasted work in
# none. (G4b, the adapter, is blocked on a decision recorded in the plan:
# AccessKit ships no binaries in 60 releases, so it means cargo as a hard
# build dependency -- which §2.1 gave up CSS Grid to avoid.)
#
# WHAT IS ASSERTED, and most of it is a LAW rather than a shape:
#   - every focusable node has a ROLE and a NAME, because a focusable
#     thing a reader cannot announce is unusable
#   - the reading order and the KEYBOARD order agree, or a screen-reader
#     user and a keyboard user are on different screens
#   - every node has a description, because the commons made RATIONALE
#     mandatory and it turns out to be exactly that
#   - name-from-content is gated by ROLE, as ARIA gates it
#   - bounds come from the real layout, and unknown is NULL not zero
#
# Needs stz_gui.dll; needs no GPU.

load "../../stzBase.ring"

nPass = 0
nFail = 0

if NOT StzGuiAvailable()
	? "No layout engine on this machine -- nothing to describe."
	? " 0 ok, 0 failed"
	return
ok

oU = new stzUiDocument("form.stzui")
chk("the form document is clean", oU.IsClean())
oU.UseFont("../gpu/fixtures/amiri_arabic_subset.ttf")
oP = oU.ToPanel()
oP.FocusOn("confirm")
oT = new stzAccessibilityTree(oU, oP)

? "-- Scene 1: a tree exists, and it covers the screen --"
? "   " + oT.NodeCount() + " nodes"
chk("every declaration became a node", oT.NodeCount() = len(oU.Declarations()) - 3)
chk("the root is the panel", oT.HasNode("form"))
chk("...and it is a window", oT.RoleOf("form") = "window")
chk("a leaf deep in the tree is there too", oT.HasNode("confirm_text"))
chk("something never declared is not", NOT oT.HasNode("no_such_thing"))

? ""
? "-- Scene 2: THE LAW -- a focusable thing must be announceable --"
# A focusable node with no role or no name is a thing a screen-reader
# user can land on and learn nothing about. That is not a style
# preference; it is the failure mode Rule 60 exists to forbid, and it is
# checkable here rather than in a manual audit.
aFocusable = oT.FocusableIds()
? "   focusable: " + @@(aFocusable)
chk("the form has focusable nodes at all", len(aFocusable) = 4)
bAllNamed = 1
bAllRoled = 1
cWorst = ""
nF = len(aFocusable)
for i = 1 to nF
	if oT.NameOf(aFocusable[i]) = ""
		bAllNamed = 0
		cWorst = aFocusable[i]
	ok
	if oT.RoleOf(aFocusable[i]) = "" or oT.RoleOf(aFocusable[i]) = "group"
		bAllRoled = 0
	ok
next
chk("EVERY focusable node has a name", bAllNamed = 1)
chk("EVERY focusable node has a role better than 'group'", bAllRoled = 1)
# the negative sibling: the check must be able to FAIL, so a form whose
# button is unnamed has to be caught
chk("...and an unnamed focusable IS caught", _HasUnnamedFocusable(
	'DEFINE PANEL p ( SIZE [100,50], FONT "app", CHILDREN [b] ) RATIONALE "x"' + char(10) +
	'DEFINE BOX b ( FOCUSABLE yes, HEIGHT 20 ) RATIONALE "a button with nothing to say"'))

? ""
? "-- Scene 3: the reading order and the KEYBOARD order agree --"
# If these two drift, a screen-reader user and a keyboard user are
# operating different screens. The tab ring is a CYCLE entered wherever
# focus sits, so the SETS are compared rather than the rotations.
aRing = oP.TabRing()
? "   tree says: " + @@(aFocusable)
? "   ring says: " + @@(aRing)
chk("the same number of stops", len(aRing) = len(aFocusable))
chk("...and the same ones", _SameSet(aRing, aFocusable))

? ""
? "-- Scene 4: RATIONALE became the description, for free --"
# The commons made RATIONALE mandatory on every declaration for its own
# reasons -- a rationale is prose, never compared, never normative. It
# turns out to be a sentence per region saying why that region exists,
# which is exactly what a description field wants and what no HTML
# document has.
? "   confirm: " + oT.DescriptionOf("confirm")
chk("the act carries its reason", oT.DescriptionOf("confirm") = "The act.")
chk("...and so does the way back",
    StzFindFirst("Rule 80", oT.DescriptionOf("cancel")) > 0)
bAllDescribed = 1
aN = oT.Nodes()
nN = len(aN)
for i = 1 to nN
	if aN[i][:description] = ""
		bAllDescribed = 0
	ok
next
chk("EVERY node has a description, because every declaration must",
    bAllDescribed = 1)

? ""
? "-- Scene 5: name-from-content is gated by ROLE, as ARIA gates it --"
# The first tree named every box from its descendants, so the window
# announced the ENTIRE SCREEN as its name and a plain grouping row
# announced "Confirm Cancel". A reader that says the whole screen before
# every element is worse than one that says nothing.
chk("a button takes its name from its label", oT.NameOf("confirm") = "Confirm")
chk("the window does NOT take the whole screen as its name",
    oT.NameOf("form") = "")
chk("...nor does a plain grouping row", oT.NameOf("actions") = "")
# a textbox is named by its LABEL, never by its content -- its content is
# its VALUE, and a reader announcing the value as the name is a classic
# form-field defect
chk("a textbox takes its LABEL", oT.NameOf("row_one") = "From account")

? ""
? "-- Scene 6: bounds come from the REAL layout --"
aB = oT.NodeOf("confirm")[:bounds]
aL = oP.BoxOf("confirm")
? "   confirm bounds: " + @@(aB)
chk("a node's bounds are the laid-out box", len(aB) = 4 and aB[1] = aL[1] and
    aB[2] = aL[2] and aB[3] = aL[3] and aB[4] = aL[4])
# the panel is the document ROOT and carries no element id of its own,
# so its bounds are the panel's -- answering [] there would tell a
# magnifier the whole screen has no position
aR = oT.NodeOf("form")[:bounds]
chk("the root's bounds are the whole panel",
    len(aR) = 4 and aR[3] = oP.Width() and aR[4] = oP.Height())
# and UNKNOWN is null, never a zero rectangle a magnifier would fly to
oNoPanel = new stzAccessibilityTree(oU, NULL)
chk("with no panel, bounds are UNKNOWN rather than zero",
    len(oNoPanel.NodeOf("confirm")[:bounds]) = 0)
chk("...and the JSON says null, not [0,0,0,0]",
    StzFindFirst('"bounds": null', oNoPanel.ToJSON()) > 0)

? ""
? "-- Scene 7: focus is reported, and it is the panel's real focus --"
chk("the focused node is marked", oT.NodeOf("confirm")[:focused])
chk("...and its neighbour is not", NOT oT.NodeOf("cancel")[:focused])
oP.FocusOn("cancel")
oT2 = new stzAccessibilityTree(oU, oP)
chk("moving focus moves the mark", oT2.NodeOf("cancel")[:focused])
chk("...and clears the old one", NOT oT2.NodeOf("confirm")[:focused])

? ""
? "-- Scene 8: the tree is DATA -- Rule 104's requirement --"
# "What a screen reader can operate, an agent can operate." A tree only
# a C++ adapter can read serves the first and not the second.
cJson = oT.ToJSON()
chk("it serialises", len(cJson) > 400)
chk("...with every node", len(StzFindCS('"id":', cJson, 1)) = oT.NodeCount())
chk("...carrying its role", StzFindFirst('"role": "button"', cJson) > 0)
chk("...its name", StzFindFirst('"name": "Confirm"', cJson) > 0)
chk("...and what can be DONE with it",
    StzFindFirst('"actions": ["focus", "click"]', cJson) > 0)
chk("a node nobody can act on says so",
    StzFindFirst('"actions": []', cJson) > 0)
# the quoting has to survive prose, since every description is prose
chk("a description with punctuation survives the quoting",
    StzFindFirst("A small operator form", cJson) > 0)

? ""
? "-- Scene 9: there is NO FLAG to turn it off --"
# The survey's second structural warning: EVERY toolkit gates
# accessibility behind a performance flag, and that is where users
# silently get nothing. A tree built on demand from data that already
# exists has nothing to gate -- so the assertion is that building one
# needs no setup at all, and that a fresh document yields the same tree.
oFresh = new stzUiDocument("form.stzui")
oTFresh = new stzAccessibilityTree(oFresh, NULL)
chk("a tree can be built with no panel, no font and no device",
    oTFresh.NodeCount() = oT.NodeCount())
chk("...and it describes the same screen",
    oTFresh.NameOf("confirm") = "Confirm")
# and it REFUSES on a broken contract rather than describing a screen
# nobody can see
bRaised = 0
try
	oBad = new stzAccessibilityTree(
		new stzUiDocument('DEFINE PANEL p ( CHILDREN [ghost] ) RATIONALE "x"'), NULL)
catch
	bRaised = 1
done
chk("an unclean document is refused, not described", bRaised = 1)

oT.SaveTo("gui_form_a11y.json")
oP.Free()

? ""
? "=============================================================="
? " " + nPass + " ok, " + nFail + " failed"
? "=============================================================="

#-- helpers ---------------------------------------------------------------

func _SameSet aA, aB
	if len(aA) != len(aB)
		return 0
	ok
	_n_ = len(aA)
	for _i_ = 1 to _n_
		_bFound_ = 0
		for _j_ = 1 to _n_
			if aA[_i_] = aB[_j_]
				_bFound_ = 1
			ok
		next
		if NOT _bFound_
			return 0
		ok
	next
	return 1

# TRUE when a document has a focusable node with no name -- the check
# Scene 2 needs to be able to FAIL.
func _HasUnnamedFocusable cDoc
	_oD_ = new stzUiDocument(cDoc)
	if NOT _oD_.IsClean()
		return 0
	ok
	_oT_ = new stzAccessibilityTree(_oD_, NULL)
	_a_ = _oT_.FocusableIds()
	_n_ = len(_a_)
	for _i_ = 1 to _n_
		if _oT_.NameOf(_a_[_i_]) = ""
			return 1
		ok
	next
	return 0

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
