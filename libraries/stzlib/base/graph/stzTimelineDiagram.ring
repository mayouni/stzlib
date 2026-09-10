#=====================================================================#
#  STZTIMELINEDIAGRAM -- DN19: a timeline is a scale, and every mark   #
#  on it is a datum; the rules are about time                          #
#=====================================================================#
/*
	THE RANK AXIS AS TIME. The Gantt (DN14) drew time as bars on lanes;
	the family tree (DN18) drew generations as ranks; a timeline is the
	axis itself: one ruled line where DISTANCE MEANS DURATION, events as
	dots on it named above, eras as bands beneath it. Every position is
	computed from a number the author gave, nothing is minted as an
	unknown, the solver reports "nothing to lay out" -- and the picture is
	still a mathematical diagram: it answers Fact() in the author's unit,
	carries marks, sits in a storyboard, is judged by the one gate and
	renders through Rendition() like everything else.

	WHAT A TIMELINE IS HERE:

	    DOMAIN     Event, a point in time; Era, a span with a band; Tick, a
	               time the axis names; Axis, the line itself; and
	               Belonging(Event, Era), an event the author places in an
	               era -- the one claim a timeline makes that its own
	               drawing cannot show to be false.

	    SUBSTANCE  built from a list of events -- [ name, t ] or
	               [ name, t, era ] -- and a list of eras -- [ name, from,
	               to ] or [ name, from, to, band ]. The builder maps time
	               to pixels, chooses the axis step so the axis has ten
	               ticks or fewer, assigns each era a band, and LAYS THE
	               NAMES: every event's name stands above the axis at a
	               level, centred on its stem or hung to one side of it,
	               so that no name covers another event's column and no
	               two names on one level touch. The stem is the one line
	               between a name and its dot, and a name over another
	               dot's column would put that dot's stem through it.

	    STYLE      the axis as one line; a tick as a short cross-mark with
	               its time beneath; an event as a dot on the axis, a stem
	               up to its name; an era as a band in the primary colour
	               beneath the axis with its name inside.

	WHAT THE DOMAIN OWES THE GATE -- the mistakes people make in a
	timeline are about time, and none of them is visible in a drawing that
	draws what it is given:

	    era_ends_after_it_starts     an era's end is not before its start
	    band_not_double_booked       two eras on one band do not overlap
	    event_within_its_era         an event placed in an era is dated
	                                 inside it

	Each names the things by the names the author gave them and says by
	how much, and each registers itself into the math governance from this
	file, as the Gantt's do.

	WHAT IS SAID PLAINLY: time is a number in the author's unit -- a year,
	a day, a second -- and the axis writes the number; a calendar is a
	labelling this item does not do. Names are laid above the axis only;
	a timeline dense enough to need both sides is a timeline that wants
	two pictures. Durations of events, uncertainty, and links between
	events are not here.
*/

StzRegisterMathRuleSet("timeline", StzTimelineRuleSet())

#---------------------------------------------------------------------#
#  THE DOMAIN                                                          #
#---------------------------------------------------------------------#

func StzTimelineDomain()
	_o_ = new stzMathDomain("timeline")
	_o_.AddType("Event")
	_o_.AddType("Era")
	_o_.AddType("Tick")
	_o_.AddType("Axis")
	_o_.AddType("Belonging")
	_o_.AddConstructor("Belonging", [ "Event", "Era" ])
	# A FAULT IS DRAWN, NOT HIDDEN -- the Gantt's lesson. An era whose end
	# is before its start is drawn between its two times in the colour of
	# a fault; an era overlapping another on its band takes a red edge; an
	# event dated outside the era it was placed in takes a red dot. The
	# RULES still judge from the numbers; the gate holds the marks to them.
	_o_.AddPredicate("Reversed", [ "Era" ])
	_o_.AddPredicate("Clashing", [ "Era" ])
	_o_.AddPredicate("Outside", [ "Event" ])
	# an era too short for its name writes the name beside its band
	_o_.AddPredicate("Beside", [ "Era" ])
	return _o_

# the paper: a fixed width, a height that follows the levels and bands
func StzTimelineWidth()
	return 760

func StzTimelineLeft()
	return 48

func StzTimelineTop()
	return 26

func StzTimelineLevelPitch()
	return 26

func StzTimelineBandPitch()
	return 26

func StzTimelineAxisYFor(pnLevels)
	return StzTimelineTop() + pnLevels * StzTimelineLevelPitch() + 12

func StzTimelineHeightFor(pnLevels, pnBands)
	return StzTimelineAxisYFor(pnLevels) + 34 + pnBands * StzTimelineBandPitch() + 18

#---------------------------------------------------------------------#
#  THE SUBSTANCE, FROM EVENTS AND ERAS                                 #
#---------------------------------------------------------------------#

# paEvents: [ name, t ] or [ name, t, eraName ] each; paEras: [ name,
# from, to ] or [ name, from, to, band ] each. Times are numbers in the
# author's unit. Bands are 1-based; an era given none takes the first
# band it does not overlap on. Objects are e1..eN, r1..rM, b1..bK (the
# belongings), k1.. (ticks) and ax; a thing's LABEL is the name given.
func StzTimelineFromEvents(paEvents, paEras)
	return StzTimelineFromEventsXT(NULL, paEvents, paEras)

# with a font, so the names are laid by their measured widths; without
# one, by seven pixels a character, which is the same law less exact
func StzTimelineFromEventsXT(poFont, paEvents, paEras)
	_oS_ = new stzMathSubstance(StzTimelineDomain())
	_nE_ = len(paEvents)
	_nR_ = len(paEras)
	if _nE_ = 0 and _nR_ = 0
		stzraise("StzTimelineFromEvents: a timeline needs at least one event or one era.")
	ok
	_bAny_ = FALSE
	_nMin_ = 0  _nMax_ = 0
	for _i_ = 1 to _nE_
		_a_ = paEvents[_i_]
		if len(_a_) < 2 or NOT isNumber(_a_[2])
			stzraise("StzTimelineFromEvents: event " + _i_ + " needs a name and a time.")
		ok
		for _j_ = 1 to _i_ - 1
			if StzLower(ring_trim("" + paEvents[_j_][1])) = StzLower(ring_trim("" + _a_[1]))
				stzraise("StzTimelineFromEvents: two events are named '" + _a_[1] + "' -- a name must say which.")
			ok
		next
		if NOT _bAny_  _nMin_ = _a_[2]  _nMax_ = _a_[2]  _bAny_ = TRUE  ok
		if _a_[2] < _nMin_  _nMin_ = _a_[2]  ok
		if _a_[2] > _nMax_  _nMax_ = _a_[2]  ok
	next
	for _i_ = 1 to _nR_
		_a_ = paEras[_i_]
		if len(_a_) < 3 or NOT isNumber(_a_[2]) or NOT isNumber(_a_[3])
			stzraise("StzTimelineFromEvents: era " + _i_ + " needs a name, a start and an end.")
		ok
		if NOT _bAny_  _nMin_ = _a_[2]  _nMax_ = _a_[2]  _bAny_ = TRUE  ok
		if _a_[2] < _nMin_  _nMin_ = _a_[2]  ok
		if _a_[3] < _nMin_  _nMin_ = _a_[3]  ok
		if _a_[2] > _nMax_  _nMax_ = _a_[2]  ok
		if _a_[3] > _nMax_  _nMax_ = _a_[3]  ok
	next
	_nSpan_ = _nMax_ - _nMin_
	if _nSpan_ < 1  _nSpan_ = 1  ok

	# time to pixels: the scale is the paper less its two margins, and a
	# unit of time is its share of it -- distance means duration.
	# THE MARGINS HOLD THE FIRST AND THE LAST NAME: the earliest event's
	# name, centred on its dot, ran seven pixels off the paper's left
	# edge, and hanging it inward would have covered the next event's
	# column. A margin is at least half the name that stands over it.
	_nX0_ = StzTimelineLeft()
	_nXR_ = StzTimelineLeft()
	for _i_ = 1 to _nE_
		_nNw_ = _TlNameWidth(poFont, "" + paEvents[_i_][1])
		if paEvents[_i_][2] <= _nMin_ + 0.000001 and _nNw_ / 2 + 14 > _nX0_
			_nX0_ = _nNw_ / 2 + 14
		ok
		if paEvents[_i_][2] >= _nMax_ - 0.000001 and _nNw_ / 2 + 14 > _nXR_
			_nXR_ = _nNw_ / 2 + 14
		ok
	next
	_nK_ = (StzTimelineWidth() - _nX0_ - _nXR_) / _nSpan_

	# THE BANDS, greedily: an era given none takes the first band where it
	# overlaps nothing placed before it; touching ends are not an overlap
	_anBand_ = []
	_nBands_ = 0
	for _i_ = 1 to _nR_
		_a_ = paEras[_i_]
		_nB_ = 0
		if len(_a_) >= 4 and isNumber(_a_[4])  _nB_ = _a_[4]  ok
		if _nB_ < 1
			_nB_ = 1
			while TRUE
				_bFree_ = TRUE
				for _j_ = 1 to _i_ - 1
					if _anBand_[_j_] != _nB_  loop  ok
					if _TlOverlap(paEras[_j_][2], paEras[_j_][3], _a_[2], _a_[3])
						_bFree_ = FALSE
						exit
					ok
				next
				if _bFree_  exit  ok
				_nB_++
			end
		ok
		_anBand_ + _nB_
		if _nB_ > _nBands_  _nBands_ = _nB_  ok
	next

	# THE NAMES ARE LAID BEFORE THE OBJECTS EXIST, because the axis's own
	# height follows how many levels they take
	_aLay_ = _TlLayNames(poFont, paEvents, _nX0_, _nMin_, _nK_)
	_nLevels_ = 0
	for _i_ = 1 to _nE_
		if _aLay_[_i_][1] > _nLevels_  _nLevels_ = _aLay_[_i_][1]  ok
	next
	if _nLevels_ < 1  _nLevels_ = 1  ok
	_nAy_ = StzTimelineAxisYFor(_nLevels_)

	# the axis itself
	_oS_.Declare("Axis", "ax")
	_oS_.Label("ax", "")
	_oS_.SetData("ax", "x0", _nX0_ - 10)
	_oS_.SetData("ax", "x1", _nX0_ + _nSpan_ * _nK_ + 10)
	_oS_.SetData("ax", "y", _nAy_)
	_oS_.SetData("ax", "levels", _nLevels_)
	_oS_.SetData("ax", "bands", _nBands_)

	# the events: a dot on the axis, a stem, a name at its level
	for _i_ = 1 to _nE_
		_a_ = paEvents[_i_]
		_oS_.Declare("Event", "e" + _i_)
		_oS_.Label("e" + _i_, "" + _a_[1])
		_oS_.SetData("e" + _i_, "t", _a_[2])
		_oS_.SetData("e" + _i_, "x", _nX0_ + (_a_[2] - _nMin_) * _nK_)
		_oS_.SetData("e" + _i_, "y", _nAy_)
		_oS_.SetData("e" + _i_, "level", _aLay_[_i_][1])
		_oS_.SetData("e" + _i_, "lx", _aLay_[_i_][2])
		_oS_.SetData("e" + _i_, "ly", _nAy_ - 30 - (_aLay_[_i_][1] - 1) * StzTimelineLevelPitch())
		_oS_.SetData("e" + _i_, "lw", _aLay_[_i_][3])
	next

	# the eras: a band beneath the axis, from one time to the other
	for _i_ = 1 to _nR_
		_a_ = paEras[_i_]
		_oS_.Declare("Era", "r" + _i_)
		_oS_.Label("r" + _i_, "" + _a_[1])
		_oS_.SetData("r" + _i_, "from", _a_[2])
		_oS_.SetData("r" + _i_, "to", _a_[3])
		_oS_.SetData("r" + _i_, "band", _anBand_[_i_])
		_oS_.SetData("r" + _i_, "x0", _nX0_ + (_a_[2] - _nMin_) * _nK_)
		_oS_.SetData("r" + _i_, "x1", _nX0_ + (_a_[3] - _nMin_) * _nK_)
		_oS_.SetData("r" + _i_, "y", _nAy_ + 44 + (_anBand_[_i_] - 1) * StzTimelineBandPitch())
		# A NAME WIDER THAN ITS BAND STANDS BESIDE IT. An era of a year on
		# a scale of decades is a sliver, and its name inside it would lie
		# across its neighbours' bands; beside the band it names it as a
		# mark's name beside the mark does.
		if isObject(poFont)
			_nLw_ = poFont.WidthOf("" + _a_[1], 11) + 8
		else
			_nLw_ = StzLen("" + _a_[1]) * 6.5 + 8
		ok
		_oS_.SetData("r" + _i_, "lw", _nLw_)
		if _nLw_ > fabs(_a_[3] - _a_[2]) * _nK_ - 4
			_oS_.Assert("Beside", [ "r" + _i_ ])
		ok
		if _a_[3] < _a_[2]  _oS_.Assert("Reversed", [ "r" + _i_ ])  ok
		for _j_ = 1 to _nR_
			if _j_ = _i_ or _anBand_[_j_] != _anBand_[_i_]  loop  ok
			if _TlOverlap(_a_[2], _a_[3], paEras[_j_][2], paEras[_j_][3])
				_oS_.Assert("Clashing", [ "r" + _i_ ])
				exit
			ok
		next
	next

	# the belongings, by the names the author used
	_nB_ = 0
	for _i_ = 1 to _nE_
		_a_ = paEvents[_i_]
		if len(_a_) < 3  loop  ok
		_cEra_ = ring_trim("" + _a_[3])
		if _cEra_ = ""  loop  ok
		_cR_ = _TlEraNamed(paEras, _cEra_)
		if _cR_ = ""
			stzraise("StzTimelineFromEvents: event '" + _a_[1] + "' is placed in '" + _cEra_ +
				"', which is not an era of this timeline.")
		ok
		_nB_++
		_oS_.Define("b" + _nB_, "Belonging", [ "e" + _i_, _cR_ ])
		_oS_.Label("b" + _nB_, "")
		_nLo_ = paEras[ _TlEraIndex(paEras, _cEra_) ][2]
		_nHi_ = paEras[ _TlEraIndex(paEras, _cEra_) ][3]
		if _nHi_ < _nLo_  _nT_ = _nLo_  _nLo_ = _nHi_  _nHi_ = _nT_  ok
		if _a_[2] < _nLo_ or _a_[2] > _nHi_
			_oS_.Assert("Outside", [ "e" + _i_ ])
		ok
	next

	# THE AXIS'S TICKS: a step that gives ten ticks or fewer, from the
	# usual ladder, and a tick on every multiple of it inside the span
	_nStep_ = _TlStepFor(_nSpan_)
	_nFirst_ = ceil(_nMin_ / _nStep_) * _nStep_
	_nK2_ = 0
	for _t_ = _nFirst_ to _nMax_ step _nStep_
		_nK2_++
		_oS_.Declare("Tick", "k" + _nK2_)
		_oS_.Label("k" + _nK2_, "" + _t_)
		_oS_.SetData("k" + _nK2_, "t", _t_)
		_oS_.SetData("k" + _nK2_, "x", _nX0_ + (_t_ - _nMin_) * _nK_)
		_oS_.SetData("k" + _nK2_, "y", _nAy_)
	next
	return _oS_

# the levels the names take, and the bands the eras take, off the axis
func StzTimelineLevelsOf(poSubstance)
	return poSubstance.DataOf("ax", "levels")

func StzTimelineBandsOf(poSubstance)
	return poSubstance.DataOf("ax", "bands")

# an overlap of positive length; touching ends are not one
func _TlOverlap(pnA0, pnA1, pnB0, pnB1)
	_a0_ = pnA0  _a1_ = pnA1
	if _a1_ < _a0_  _a0_ = pnA1  _a1_ = pnA0  ok
	_b0_ = pnB0  _b1_ = pnB1
	if _b1_ < _b0_  _b0_ = pnB1  _b1_ = pnB0  ok
	return _a0_ < _b1_ and _b0_ < _a1_

func _TlEraIndex(paEras, pcName)
	_c_ = StzLower(ring_trim("" + pcName))
	for _i_ = 1 to len(paEras)
		if StzLower(ring_trim("" + paEras[_i_][1])) = _c_  return _i_  ok
	next
	return 0

func _TlEraNamed(paEras, pcName)
	_i_ = _TlEraIndex(paEras, pcName)
	if _i_ = 0  return ""  ok
	return "r" + _i_

# an event's name, as wide as it will be drawn, and a little air
func _TlNameWidth(poFont, pcName)
	if isObject(poFont)  return poFont.WidthOf(pcName, 12) + 8  ok
	return StzLen(pcName) * 7 + 8

func _TlStepFor(pnSpan)
	_a_ = [ 1, 2, 5, 10, 20, 25, 50, 100, 200, 250, 500, 1000, 2000, 5000 ]
	for _i_ = 1 to len(_a_)
		if pnSpan / _a_[_i_] <= 10  return _a_[_i_]  ok
	next
	return 10000

# THE NAMES, LAID. Each event's name stands above the axis at a level;
# a stem joins it to its dot, and the stem crosses every level below
# the name's. Two laws, checked in the order the events happen: a name
# covers no column whose stem reaches its level -- a stem through a
# name is a line through a word -- and two names on one level do not
# touch. A name is centred on its stem when it can be, hung to the
# right of it when it cannot, to the left when it still cannot, and
# takes the next level up otherwise; and a name at a level a lower name
# already spans its column on can go no higher, since its own stem would
# cross that name. Returns [ level, name centre x, name width ] per
# event, in the events' order. A name that can be placed nowhere --
# events denser than their names -- is centred on a fresh level and the
# gate's name rules say so.
func _TlLayNames(poFont, paEvents, pnX0, pnMin, pnK)
	_nE_ = len(paEvents)
	_anX_ = []
	_anW_ = []
	for _i_ = 1 to _nE_
		_anX_ + (pnX0 + (paEvents[_i_][2] - pnMin) * pnK)
		_anW_ + _TlNameWidth(poFont, "" + paEvents[_i_][1])
	next
	# in time order
	_aOrd_ = []
	for _i_ = 1 to _nE_  _aOrd_ + [ paEvents[_i_][2], _i_ ]  next
	_aOrd_ = sort(_aOrd_, 1)
	_aOut_ = []
	for _i_ = 1 to _nE_  _aOut_ + [ 0, 0, 0 ]  next
	_aPlaced_ = []          # [ level, lo, hi, event ]
	_nGap_ = 8
	_nMaxL_ = 0
	for _o_ = 1 to _nE_
		_i_ = _aOrd_[_o_][2]
		_x_ = _anX_[_i_]
		_w_ = _anW_[_i_]
		_bDone_ = FALSE
		for _L_ = 1 to _nMaxL_ + 1
			# the stem would cross a name laid below this level on its
			# column: no level from here up can hold it
			_bCut_ = FALSE
			for _p_ = 1 to len(_aPlaced_)
				if _aPlaced_[_p_][1] >= _L_  loop  ok
				if _x_ > _aPlaced_[_p_][2] - 3 and _x_ < _aPlaced_[_p_][3] + 3
					_bCut_ = TRUE
					exit
				ok
			next
			if _bCut_  exit  ok
			for _s_ = 1 to 3
				if _s_ = 1
					_lo_ = _x_ - _w_ / 2
				but _s_ = 2
					_lo_ = _x_ + 6
				else
					_lo_ = _x_ - 6 - _w_
				ok
				_hi_ = _lo_ + _w_
				# on the paper: a name centred on the first event ran off
				# the left edge by seven pixels
				if _lo_ < 12 or _hi_ > StzTimelineWidth() - 12  loop  ok
				# no column whose stem reaches this level under this
				# name: a placed event's stem reaches its own level, an
				# unplaced one's may reach any
				_bOk_ = TRUE
				for _j_ = 1 to _nE_
					if _j_ = _i_  loop  ok
					if fabs(_anX_[_j_] - _x_) < 0.01  loop  ok
					if _aOut_[_j_][1] > 0 and _aOut_[_j_][1] < _L_  loop  ok
					if _anX_[_j_] > _lo_ - 3 and _anX_[_j_] < _hi_ + 3
						_bOk_ = FALSE
						exit
					ok
				next
				if NOT _bOk_  loop  ok
				# no name on this level within a gap
				for _p_ = 1 to len(_aPlaced_)
					if _aPlaced_[_p_][1] != _L_  loop  ok
					if _lo_ < _aPlaced_[_p_][3] + _nGap_ and _hi_ > _aPlaced_[_p_][2] - _nGap_
						_bOk_ = FALSE
						exit
					ok
				next
				if NOT _bOk_  loop  ok
				_aOut_[_i_] = [ _L_, (_lo_ + _hi_) / 2, _w_ ]
				_aPlaced_ + [ _L_, _lo_, _hi_, _i_ ]
				if _L_ > _nMaxL_  _nMaxL_ = _L_  ok
				_bDone_ = TRUE
				exit
			next
			if _bDone_  exit  ok
		next
		if NOT _bDone_
			_nMaxL_++
			_aOut_[_i_] = [ _nMaxL_, _x_, _w_ ]
			_aPlaced_ + [ _nMaxL_, _x_ - _w_ / 2, _x_ + _w_ / 2, _i_ ]
		ok
	next
	return _aOut_

#---------------------------------------------------------------------#
#  THE STYLE -- no constraint, no unknown, every position a datum      #
#---------------------------------------------------------------------#

func StzTimelineStyle(pnLevels, pnBands)
	_o_ = new stzMathStyle()
	_o_.SetCanvas(StzTimelineWidth(), StzTimelineHeightFor(pnLevels, pnBands))
	_o_.SetMargin(10)
	# THE AXIS is one line, and the ticks stand on it: a short cross-mark
	# with its time beneath in neutral, at a smaller size that says it is
	# furniture; the line and the marks are ink, since the scale is the
	# claim the whole picture makes
	_o_.ForAll("Axis a", [
		[ :shape, "a.icon", :line, [ :x1 = "a.x0", :y1 = "a.y", :x2 = "a.x1", :y2 = "a.y",
		                             :stroke = "neutral", :strokeWidth = 1.5 ] ] ])
	_o_.ForAll("Tick k", [
		[ :shape, "k.icon", :line, [ :x1 = "k.x", :y1 = "k.y - 4", :x2 = "k.x", :y2 = "k.y + 4",
		                             :stroke = "neutral", :strokeWidth = 1 ] ],
		[ :shape, "k.text", :text, [ :cx = "k.x", :cy = "k.y + 16", :size = 11,
		                             :fill = "neutral" ] ] ])
	# AN EVENT is a dot on the axis, a stem up to its name, and the name
	# at the level and the place the builder laid it
	_o_.ForAll("Event e", [
		[ :shape, "e.stem", :line, [ :x1 = "e.x", :y1 = "e.y - 6", :x2 = "e.x", :y2 = "e.ly + 14",
		                             :stroke = [ :alpha, "neutral", 0.6 ], :strokeWidth = 1 ] ],
		[ :shape, "e.icon", :circle, [ :cx = "e.x", :cy = "e.y", :r = 4.5,
		                               :fill = "primary", :stroke = "background", :strokeWidth = 1 ] ],
		[ :shape, "e.text", :text, [ :cx = "e.lx", :cy = "e.ly", :size = 12,
		                             :fill = [ :on, "paper" ] ] ] ])
	# an event dated outside the era it was placed in: its dot says so
	_o_.ForAllWhere("Event e", "Outside(e)", [
		[ :delete, "e.icon" ],
		[ :shape, "e.icon", :circle, [ :cx = "e.x", :cy = "e.y", :r = 4.5,
		                               :fill = "danger", :stroke = "background", :strokeWidth = 1 ] ] ])
	# AN ERA is a band beneath the axis from one time to the other, its
	# name inside in whichever of black and white reads on the band
	_o_.ForAll("Era r", [
		[ :shape, "r.band", :rect, [ :cx = "(r.x0 + r.x1) / 2", :cy = "r.y",
		                             :w = "abs(r.x1 - r.x0)", :h = 20,
		                             :fill = "primary", :stroke = "background", :strokeWidth = 1 ] ],
		[ :shape, "r.text", :text, [ :cx = "(r.x0 + r.x1) / 2", :cy = "r.y", :size = 11,
		                             :fill = [ :on, "r.band" ] ] ],
		[ :layer, "r.text", :above, "r.band" ] ])
	_o_.ForAllWhere("Era r", "Beside(r)", [
		[ :delete, "r.text" ],
		[ :shape, "r.text", :text, [ :cx = "max(r.x0, r.x1) + 6 + r.lw / 2", :cy = "r.y", :size = 11,
		                             :fill = [ :on, "paper" ] ] ] ])
	# A FAULT IS DRAWN: an era ending before it starts is a band between
	# its two times in the colour of a fault; an era double-booked on its
	# band keeps its band and takes a red edge, so the overlap is a red seam
	_o_.ForAllWhere("Era r", "Reversed(r)", [
		[ :delete, "r.band" ],
		[ :shape, "r.band", :rect, [ :cx = "(r.x0 + r.x1) / 2", :cy = "r.y",
		                             :w = "abs(r.x1 - r.x0)", :h = 20,
		                             :fill = "danger", :stroke = "background", :strokeWidth = 1 ] ] ])
	_o_.ForAllWhere("Era r", "Clashing(r)", [
		[ :delete, "r.band" ],
		[ :shape, "r.band", :rect, [ :cx = "(r.x0 + r.x1) / 2", :cy = "r.y",
		                             :w = "abs(r.x1 - r.x0)", :h = 20,
		                             :fill = "primary", :stroke = "danger", :strokeWidth = 2 ] ] ])
	return _o_

# the whole picture in one call: substance, a style sized to its levels
# and bands, and the diagram
func StzTimelineDiagram(poFont, paEvents, paEras)
	_oS_ = StzTimelineFromEventsXT(poFont, paEvents, paEras)
	_o_ = new stzMathDiagram(StzTimelineDomain(), _oS_,
		StzTimelineStyle(StzTimelineLevelsOf(_oS_), StzTimelineBandsOf(_oS_)))
	if isObject(poFont)  _o_.SetFont(poFont, 12)  ok
	return _o_

#---------------------------------------------------------------------#
#  THE RULES, INTO THE ONE GATE -- every one about time                #
#---------------------------------------------------------------------#

func _TlIsTimeline(poDg)
	if NOT isObject(poDg)  return FALSE  ok
	if StzLower(classname(poDg)) != "stzmathdiagram"  return FALSE  ok
	return StzLower("" + poDg.Substance().DomainQ().Name_()) = "timeline"

# the scope of every timeline rule: a picture's objects of one type when
# it is a timeline; the counter: every object of a math picture that is not
func _TlScope(poDg, pcType, pcPrefix)
	_r_ = []
	if NOT _TlIsTimeline(poDg)  return _r_  ok
	_ac_ = poDg.Substance().ObjectsOfType(pcType)
	for _i_ = 1 to len(_ac_)  _r_ + (pcPrefix + _ac_[_i_])  next
	return _r_

func _TlCounter(poDg, pcPrefix)
	_r_ = []
	if NOT isObject(poDg) or _TlIsTimeline(poDg)  return _r_  ok
	if StzLower(classname(poDg)) != "stzmathdiagram"  return _r_  ok
	_ac_ = poDg.Substance().ObjectNames()
	for _i_ = 1 to len(_ac_)  _r_ + (pcPrefix + _ac_[_i_])  next
	return _r_

func _TlName(poS, pcObj)
	_c_ = poS.LabelOf(pcObj)
	if _c_ = ""  _c_ = pcObj  ok
	return _c_

func StzTimelineRuleSet()
	_ao_ = []

	_o1_ = StzPlasticRule("era_ends_after_it_starts")
	_o1_.SetClaim("no era ends before it starts")
	_o1_.SetOrder(53)
	_o1_.SetReads([ "substance" ])
	_o1_.SetScope(func(oDg) { return _TlScope(oDg, "Era", "era:") })
	_o1_.SetCounter(func(oDg) { return _TlCounter(oDg, "era:") })
	_o1_.SetClaimCheck(func(oDg, cSub) {
		_cR_ = StzStringSection(cSub, 5, len(cSub))
		_oS_ = oDg.Substance()
		_nA_ = _oS_.DataOf(_cR_, "from")
		_nB_ = _oS_.DataOf(_cR_, "to")
		if _nB_ < _nA_
			return [ FALSE, "'" + _TlName(_oS_, _cR_) + "' ends at " + StzFactNumText(_nB_) +
				", " + StzFactNumText(_nA_ - _nB_) + " before it starts at " + StzFactNumText(_nA_) ]
		ok
		return [ TRUE, "" ]
	})
	_ao_ + _o1_

	_o2_ = StzPlasticRule("band_not_double_booked")
	_o2_.SetClaim("two eras on one band do not overlap in time")
	_o2_.SetOrder(54)
	_o2_.SetReads([ "substance" ])
	_o2_.SetScope(func(oDg) { return _TlScope(oDg, "Era", "era:") })
	_o2_.SetCounter(func(oDg) { return _TlCounter(oDg, "era:") })
	_o2_.SetClaimCheck(func(oDg, cSub) {
		_cR_ = StzStringSection(cSub, 5, len(cSub))
		_oS_ = oDg.Substance()
		_nA_ = _oS_.DataOf(_cR_, "from")
		_nB_ = _oS_.DataOf(_cR_, "to")
		_nBand_ = _oS_.DataOf(_cR_, "band")
		_ac_ = _oS_.ObjectsOfType("Era")
		for _i_ = 1 to len(_ac_)
			_cO_ = _ac_[_i_]
			if _cO_ = _cR_  loop  ok
			if _oS_.DataOf(_cO_, "band") != _nBand_  loop  ok
			_nA2_ = _oS_.DataOf(_cO_, "from")
			_nB2_ = _oS_.DataOf(_cO_, "to")
			if _TlOverlap(_nA_, _nB_, _nA2_, _nB2_)
				_nLo_ = min([ _nA_, _nB_ ])
				if min([ _nA2_, _nB2_ ]) > _nLo_  _nLo_ = min([ _nA2_, _nB2_ ])  ok
				_nHi_ = max([ _nA_, _nB_ ])
				if max([ _nA2_, _nB2_ ]) < _nHi_  _nHi_ = max([ _nA2_, _nB2_ ])  ok
				return [ FALSE, "'" + _TlName(_oS_, _cR_) + "' and '" + _TlName(_oS_, _cO_) +
					"' share band " + _nBand_ + " and overlap by " + StzFactNumText(_nHi_ - _nLo_) +
					", from " + StzFactNumText(_nLo_) + " to " + StzFactNumText(_nHi_) ]
			ok
		next
		return [ TRUE, "" ]
	})
	_ao_ + _o2_

	_o3_ = StzPlasticRule("event_within_its_era")
	_o3_.SetClaim("an event placed in an era is dated inside it")
	_o3_.SetOrder(55)
	_o3_.SetReads([ "substance" ])
	_o3_.SetScope(func(oDg) { return _TlScope(oDg, "Belonging", "in:") })
	_o3_.SetCounter(func(oDg) { return _TlCounter(oDg, "in:") })
	_o3_.SetClaimCheck(func(oDg, cSub) {
		_cB_ = StzStringSection(cSub, 4, len(cSub))
		_oS_ = oDg.Substance()
		_aD_ = _oS_.Definitions()
		for _i_ = 1 to len(_aD_)
			if _aD_[_i_][1] != _cB_  loop  ok
			_cE_ = "" + _aD_[_i_][3][1]
			_cR_ = "" + _aD_[_i_][3][2]
			_nT_ = _oS_.DataOf(_cE_, "t")
			_nLo_ = min([ _oS_.DataOf(_cR_, "from"), _oS_.DataOf(_cR_, "to") ])
			_nHi_ = max([ _oS_.DataOf(_cR_, "from"), _oS_.DataOf(_cR_, "to") ])
			if _nT_ < _nLo_
				return [ FALSE, "'" + _TlName(_oS_, _cE_) + "' is dated " + StzFactNumText(_nT_) +
					", " + StzFactNumText(_nLo_ - _nT_) + " before '" + _TlName(_oS_, _cR_) +
					"' begins at " + StzFactNumText(_nLo_) ]
			ok
			if _nT_ > _nHi_
				return [ FALSE, "'" + _TlName(_oS_, _cE_) + "' is dated " + StzFactNumText(_nT_) +
					", " + StzFactNumText(_nT_ - _nHi_) + " after '" + _TlName(_oS_, _cR_) +
					"' ends at " + StzFactNumText(_nHi_) ]
			ok
			return [ TRUE, "" ]
		next
		return [ TRUE, "" ]
	})
	_ao_ + _o3_

	return _ao_
