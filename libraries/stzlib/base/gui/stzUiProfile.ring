#---------------------------------------------------------------------------#
#  STZUIPROFILE -- the CSS/RCSS profile, WRITTEN DOWN AS DATA.               #
#---------------------------------------------------------------------------#
#
#     ? StzUiProfileProperties()          # what the emitter may use, closed
#     ? StzUiProfileSpelling("direction", :web)     # -> "direction"
#     ? StzUiProfileSpelling("direction", :native)  # -> "--rmlui-direction"
#     ? StzUiProfileDivergences()         # where the two tiers differ
#
# §3 of SOFTANZA_GUI_PLAN.md, and it is the section that turns a vendoring
# decision into an architecture:
#
#     "Name a CSS/RCSS profile. The emitter targets the PROFILE. RmlUi is
#      one conforming implementation; a browser is another. Fixtures
#      render the same document both ways and compare on stated
#      observables."
#
# WITHOUT THIS FILE, RMLUI'S COVERAGE SILENTLY BECOMES THE DEFINITION of
# what Softanza's UI can express, and the native and web tiers drift apart
# with nobody noticing -- which is the exact failure this whole project
# exists to prevent, reappearing at the rendering layer.
#
# §3 ASKED FOR THE PROFILE TO BE DATA and it was not: every divergence
# below lived as a constant inside the emitter, which is precisely
# "implied by whatever the emitter happens to produce". It is a table
# now, both projections read it, and a property that is not named here is
# not available to either -- because convenience is exactly how a profile
# rots.
#
# §3 ALSO SAID "G0 BEGINS THE FIXTURE, in embryo: one document, two
# renderings, compared. It does not wait for G6." It waited until now.
# The fixture is `ToFixture()` on stzUiDocument, and the observable it
# compares is the one that cannot be argued with: the laid-out BOX of
# every named element.

#-- the closed property list -------------------------------------------
#
# What the emitter may put in a rule. A property RmlUi supports and this
# list does not name is NOT available -- that is §3's rule, and the
# reason is that the web tier has to be able to say the same thing.

func StzUiProfileProperties()
	return [
		"box-sizing", "display", "flex-direction", "flex-grow",
		"flex-shrink", "width", "height", "padding", "margin", "gap",
		"align-items", "justify-content", "flex-wrap", "align-content",
		"background-color", "color", "font-family", "font-size",
		"text-align", "direction", "tab-index", "nav"
	]

func StzUiProfileHasProperty(pcName)
	return _StzUiProfileHas(StzUiProfileProperties(), "" + pcName)

#-- the divergences, which are the whole reason this is data -----------
#
# [ property, native spelling, web spelling, why ]
#
# Each of these cost a measurement to find. They were constants inside
# the emitter until now, which meant the web tier could not be written
# without re-deriving them.

func StzUiProfileDivergences()
	return [
		[ "direction", "--rmlui-direction", "direction",
		  "RCSS rejects the CSS spelling. It reaches the shaper's " +
		  "base-direction hint and NOTHING else -- every visible RTL " +
		  "consequence is the emitter's, in both tiers." ],

		[ "tab-index", "tab-index", "tabindex",
		  "RCSS spells it hyphenated as a PROPERTY; HTML spells it as " +
		  "an ATTRIBUTE. The web tier therefore moves it out of the " +
		  "rule and onto the element." ],

		[ "nav", "nav", "",
		  "RmlUi's spatial navigation, which defaults to NONE so arrow " +
		  "keys do nothing until set. A browser has no equivalent and " +
		  "needs none: the platform supplies arrow behaviour." ]
	]

# The spelling of one property in one tier. `:native` is RCSS, `:web` is
# CSS. An empty answer means the tier does not carry it at all, which is
# a real answer rather than a missing one.
func StzUiProfileSpelling(pcProperty, pcTier)
	_c_ = "" + pcProperty
	_aD_ = StzUiProfileDivergences()
	_n_ = len(_aD_)
	for _i_ = 1 to _n_
		if _aD_[_i_][1] = _c_
			if pcTier = :native or pcTier = "native"
				return _aD_[_i_][2]
			ok
			return _aD_[_i_][3]
		ok
	next
	# not a divergence: both tiers spell it the same, which is the
	# ordinary case and the point of naming the exceptions
	return _c_

func StzUiProfileIsDivergent(pcProperty)
	_aD_ = StzUiProfileDivergences()
	_n_ = len(_aD_)
	for _i_ = 1 to _n_
		if _aD_[_i_][1] = "" + pcProperty
			return TRUE
		ok
	next
	return FALSE

func StzUiProfileWhyDivergent(pcProperty)
	_aD_ = StzUiProfileDivergences()
	_n_ = len(_aD_)
	for _i_ = 1 to _n_
		if _aD_[_i_][1] = "" + pcProperty
			return _aD_[_i_][4]
		ok
	next
	return ""

#-- the stated observables ---------------------------------------------
#
# §3 says fixtures "compare on STATED observables", so they are stated
# here rather than chosen by whoever writes a fixture.
#
# THE BOX IS THE ONE THAT MATTERS and it is deliberately the only one for
# v0.1. Two engines agreeing on where every named element ended up is the
# claim the profile makes; colour and font rendering are not, because two
# rasterizers disagreeing on a pixel is not a profile failure and a
# fixture that flagged it would be abandoned within a week.
#
# What is NOT an observable is as important as what is:
#
#   antialiasing, glyph rasterization, subpixel positioning -- two
#   engines will differ and both are right;
#   scrollbar width, focus-ring style -- platform chrome, not layout;
#   colour after blending -- the graphics plane's tier agreement guard
#   already covers ours against itself.

func StzUiProfileObservables()
	return [ "box.x", "box.y", "box.width", "box.height" ]

# AND THE OBSERVABLE HAS A CONDITION, which the fixture's first run
# supplied and this section did not.
#
# A box whose geometry the DECLARATION determines is a strict observable:
# two conforming implementations must land within the tolerance, and the
# first run found ten that did not -- all of them the same defect, the
# native side reporting a CONTENT box where the emitter had said
# border-box.
#
# A box with an AUTO dimension is not. Its width comes from measuring
# text, the two tiers measure with different shapers, and they disagreed
# by up to 7 pixels on a row of tab labels in the same font. That is two
# shapers being two shapers, not a profile failure -- and a fixture that
# failed on it would be switched off within a week, which is the fate of
# every check that cries about something nobody can fix.
#
# It is REPORTED rather than ignored, because a shaper drifting far is
# still worth seeing.
# STRICTNESS IS PER AXIS, and the first version of this was wrong in the
# dangerous direction: it required BOTH axes to be declared, which made
# only 6 of the showcase's 23 boxes strict -- and every one of the ten
# the border-box defect had broken fell into the permissive bucket. A
# check calibrated so loosely that it would have missed the defect that
# motivated it is worse than none, because it reports green.
#
# A WIDTH is claimed when the declaration fixes it: a number, a
# percentage, or `fill`, which is deterministic given the parent. A
# HEIGHT likewise. They are judged separately because a sidebar with
# `WIDTH 210` and an auto height makes a claim about one axis and not
# the other, and the profile should hold it to the one it made.
func StzUiProfileIsStrictWidth(pbWidthDeclared)
	return pbWidthDeclared

func StzUiProfileIsStrictHeight(pbHeightDeclared)
	return pbHeightDeclared

# POSITION is stricter still, because a box sits where its predecessors
# left it: x and y are claimed only when this element AND every earlier
# sibling fix their size on the axis the parent lays out along. One
# auto-width label earlier in a row moves everything after it, and
# blaming those boxes for a shaper's measurement would be blaming the
# wrong thing.
func StzUiProfileIsStrictPosition(pbSelfStrict, pbAllEarlierSiblingsStrict)
	return pbSelfStrict and pbAllEarlierSiblingsStrict

# How far apart two conforming implementations may land on a box edge
# and still be called agreeing, in pixels.
#
# ONE PIXEL, and the reason is rounding rather than generosity: both
# engines lay out in floating point and round to device pixels, and a
# box whose edge falls on x.5 may land either side. A tolerance of zero
# would make the fixture fail on arithmetic; a loose one would let a real
# divergence hide.
func StzUiProfileTolerance()
	return 1.0

func _StzUiProfileHas(paList, pcItem)
	_n_ = len(paList)
	for _i_ = 1 to _n_
		if paList[_i_] = pcItem
			return TRUE
		ok
	next
	return FALSE
