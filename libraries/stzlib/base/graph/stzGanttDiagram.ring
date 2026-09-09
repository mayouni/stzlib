#=====================================================================#
#  STZGANTTDIAGRAM -- DN14: a Gantt chart is a picture whose every     #
#  position is a datum, and whose every rule is about TIME             #
#=====================================================================#
/*
	THE CHEAPEST DOMAIN THE PLANE CAN TAKE, and it was chosen for that
	after the molecule, which was the dearest. A molecule's positions are
	solved; a Gantt's are computed. A task starts on a day and ends on a
	day, a lane is a row, and every pixel follows from those three numbers
	by arithmetic. Nothing is minted as an unknown, the solver reports
	"nothing to lay out", and the picture is still a mathematical diagram:
	it answers Fact(), carries marks, sits in a storyboard, is judged by
	the one gate, and renders through Rendition() like everything else.
	The dot domain -- Sierpinski, the Brownian walks -- is the precedent:
	shapes drawn from data through expressions, and no constraint.

	WHAT A GANTT IS HERE:

	    DOMAIN     Task, with Milestone as a subtype (a task of no
	               duration, drawn as a diamond); Dependency(Task, Task),
	               the arrow from one task's end to another's start; and
	               Tick, a day the axis names.

	    SUBSTANCE  built from a list of tasks -- [ name, start, finish ]
	               or [ name, start, finish, lane ] -- and a list of
	               dependencies by name. The builder assigns lanes, maps
	               days to pixels, chooses the axis step so the axis has
	               ten ticks or fewer, and puts every number on its object
	               as data: start and finish in DAYS for the rules and the
	               facts, x0, x1 and y in PIXELS for the style.

	    STYLE      a bar per task in the primary colour, its name in the
	               left column; a diamond per milestone; an elbow arrow per
	               dependency, leaving the predecessor's end and entering
	               the successor's start; a faint vertical per tick with
	               its day above the chart.

	WHAT THE DOMAIN OWES THE GATE, and it is the reason to draw a Gantt
	at all: the mistakes people make in one are about time, and none of
	them is visible in a drawing that simply draws what it is given.
	Three rules read the substance and recount:

	    dependency_forward_in_time   a successor may not start before its
	                                 predecessor ends
	    task_ends_after_it_starts    a task's finish is not before its start
	    lane_not_double_booked       two tasks on one lane do not overlap

	Each names the tasks by the names the author gave them and says by
	how many days, and each registers itself into the math governance from
	this file, as the chemistry rules do.

	WHAT IS SAID PLAINLY: days are numbers, not dates -- day 0 is whatever
	the author says it is, and a calendar is a labelling this item does
	not do. Percent complete, critical path, resources beyond a lane, and
	dependency kinds other than finish-to-start are not here.
*/

StzRegisterMathRuleSet("gantt", StzGanttRuleSet())

#---------------------------------------------------------------------#
#  THE DOMAIN                                                          #
#---------------------------------------------------------------------#

func StzGanttDomain()
	_o_ = new stzMathDomain("gantt")
	_o_.AddType("Task")
	_o_.AddSubtype("Milestone", "Task")
	_o_.AddType("Dependency")
	_o_.AddConstructor("Dependency", [ "Task", "Task" ])
	_o_.AddType("Tick")
	# a task that is not the first on its lane carries its name over its
	# bar rather than in the column, where the lane's first task's name is
	_o_.AddPredicate("OverBar", [ "Task" ])
	return _o_

# the paper: a fixed width, a height that follows the lanes
func StzGanttWidth()
	return 720

func StzGanttLeftColumn()
	return 170

func StzGanttRowHeight()
	return 34

func StzGanttTop()
	return 64

func StzGanttHeightFor(pnLanes)
	return StzGanttTop() + pnLanes * StzGanttRowHeight() + 30

#---------------------------------------------------------------------#
#  THE SUBSTANCE, FROM TASKS AND DEPENDENCIES                          #
#---------------------------------------------------------------------#

# paTasks: [ name, start, finish ] or [ name, start, finish, lane ] each,
# days as numbers; a task whose finish equals its start is a Milestone.
# paDeps: [ fromName, toName ] each. Lanes are 1-based; a task given none
# takes the next free lane in order.
#
# Objects are t1..tN, d1..dM, k1..kK; a task's LABEL is the name given.
func StzGanttFromTasks(paTasks, paDeps)
	_oS_ = new stzMathSubstance(StzGanttDomain())
	_nT_ = len(paTasks)
	if _nT_ = 0
		stzraise("StzGanttFromTasks: a Gantt needs at least one task.")
	ok
	_nMin_ = paTasks[1][2]
	_nMax_ = paTasks[1][3]
	_nLanes_ = 0
	_anLane_ = []
	for _i_ = 1 to _nT_
		_a_ = paTasks[_i_]
		if len(_a_) < 3 or NOT isNumber(_a_[2]) or NOT isNumber(_a_[3])
			stzraise("StzGanttFromTasks: task " + _i_ + " needs a name, a start day and a finish day.")
		ok
		_nL_ = 0
		if len(_a_) >= 4 and isNumber(_a_[4])  _nL_ = _a_[4]  ok
		if _nL_ < 1
			_nLanes_++
			_nL_ = _nLanes_
		but _nL_ > _nLanes_
			_nLanes_ = _nL_
		ok
		_anLane_ + _nL_
		if _a_[2] < _nMin_  _nMin_ = _a_[2]  ok
		if _a_[3] > _nMax_  _nMax_ = _a_[3]  ok
		if _a_[2] > _nMax_  _nMax_ = _a_[2]  ok
		if _a_[3] < _nMin_  _nMin_ = _a_[3]  ok
	next
	_nSpan_ = _nMax_ - _nMin_
	if _nSpan_ < 1  _nSpan_ = 1  ok

	# days to pixels: the chart area is the paper less the name column and
	# a right margin, and a day is its share of that
	_nX0_ = StzGanttLeftColumn()
	_nK_ = (StzGanttWidth() - _nX0_ - 40) / _nSpan_
	_anSeen_ = []
	for _i_ = 1 to _nT_
		_a_ = paTasks[_i_]
		_cT_ = "Task"
		if _a_[2] = _a_[3]  _cT_ = "Milestone"  ok
		_oS_.Declare(_cT_, "t" + _i_)
		_oS_.Label("t" + _i_, "" + _a_[1])
		# THE COLUMN NAMES THE LANE'S FIRST TASK; every later task on that
		# lane is named over its own bar. Two names in one column cell were
		# the first thing the gate found in a shared lane.
		_bFirst_ = TRUE
		for _j_ = 1 to len(_anSeen_)
			if _anSeen_[_j_] = _anLane_[_i_]  _bFirst_ = FALSE  ok
		next
		if _bFirst_
			_anSeen_ + _anLane_[_i_]
		else
			_oS_.Assert("OverBar", [ "t" + _i_ ])
		ok
		_oS_.SetData("t" + _i_, "start", _a_[2])
		_oS_.SetData("t" + _i_, "finish", _a_[3])
		_oS_.SetData("t" + _i_, "lane", _anLane_[_i_])
		_oS_.SetData("t" + _i_, "x0", _nX0_ + (_a_[2] - _nMin_) * _nK_)
		_oS_.SetData("t" + _i_, "x1", _nX0_ + (_a_[3] - _nMin_) * _nK_)
		_oS_.SetData("t" + _i_, "y", StzGanttTop() + (_anLane_[_i_] - 0.5) * StzGanttRowHeight())
	next

	# dependencies, by the names the author used
	_nD_ = len(paDeps)
	for _k_ = 1 to _nD_
		_cA_ = _GtTaskNamed(paTasks, paDeps[_k_][1])
		_cB_ = _GtTaskNamed(paTasks, paDeps[_k_][2])
		if _cA_ = "" or _cB_ = ""
			stzraise("StzGanttFromTasks: dependency " + _k_ + " names a task that is not " +
				"in the list -- '" + paDeps[_k_][1] + "' to '" + paDeps[_k_][2] + "'.")
		ok
		if _cA_ = _cB_
			stzraise("StzGanttFromTasks: '" + paDeps[_k_][1] + "' cannot depend on itself.")
		ok
		_oS_.Define("d" + _k_, "Dependency", [ _cA_, _cB_ ])
		_oS_.Label("d" + _k_, "")
	next

	# THE AXIS: a step that gives ten ticks or fewer, from the usual
	# ladder, and a tick on every multiple of it inside the span
	_nStep_ = _GtStepFor(_nSpan_)
	_nFirst_ = ceil(_nMin_ / _nStep_) * _nStep_
	_nK2_ = 0
	for _t_ = _nFirst_ to _nMax_ step _nStep_
		_nK2_++
		_oS_.Declare("Tick", "k" + _nK2_)
		_oS_.Label("k" + _nK2_, "d" + _t_)
		_oS_.SetData("k" + _nK2_, "t", _t_)
		_oS_.SetData("k" + _nK2_, "x", _nX0_ + (_t_ - _nMin_) * _nK_)
		_oS_.SetData("k" + _nK2_, "y0", StzGanttTop() - 14)
		_oS_.SetData("k" + _nK2_, "y1", StzGanttTop() + _nLanes_ * StzGanttRowHeight() + 6)
	next
	return _oS_

# the lanes a substance uses: the largest lane datum on any task
func StzGanttLanesOf(poSubstance)
	_ac_ = poSubstance.ObjectsOfType("Task")
	_n_ = 0
	for _i_ = 1 to len(_ac_)
		if poSubstance.DataOf(_ac_[_i_], "lane") > _n_  _n_ = poSubstance.DataOf(_ac_[_i_], "lane")  ok
	next
	return _n_

func _GtTaskNamed(paTasks, pcName)
	_c_ = StzLower(ring_trim("" + pcName))
	for _i_ = 1 to len(paTasks)
		if StzLower(ring_trim("" + paTasks[_i_][1])) = _c_  return "t" + _i_  ok
	next
	return ""

func _GtStepFor(pnSpan)
	_a_ = [ 1, 2, 5, 10, 20, 25, 50, 100, 200, 500, 1000 ]
	for _i_ = 1 to len(_a_)
		if pnSpan / _a_[_i_] <= 10  return _a_[_i_]  ok
	next
	return 1000

#---------------------------------------------------------------------#
#  THE STYLE -- no constraint, no unknown, every position a datum      #
#---------------------------------------------------------------------#

func StzGanttStyle(pnLanes)
	return StzGanttStyleXT(pnLanes, TRUE)

# pbGuides: whether the tick lines are declared GUIDES -- furniture the
# name rules read past. TRUE is the chart; FALSE exists so the gate can
# stand on the boundary: the same picture with its gridlines as ink has a
# name on one, and says so.
func StzGanttStyleXT(pnLanes, pbGuides)
	_nG_ = 0
	if pbGuides  _nG_ = 1  ok
	_o_ = new stzMathStyle()
	_o_.SetCanvas(StzGanttWidth(), StzGanttHeightFor(pnLanes))
	_o_.SetMargin(10)
	# A TICK is a faint vertical through the chart and its day above it.
	# The line is a GUIDE: a name over a bar must cross one, since no place
	# in the chart is free of gridlines, and a gridline carries no meaning
	# a name could hide -- so it is drawn, and the rules read past it.
	# The day is in NEUTRAL, not muted: muted measures 2.85:1 against the
	# light paper and the gate holds every name to 3:1 -- a label that is
	# furniture is still a label somebody reads. Its size is what says it
	# is furniture.
	_o_.ForAll("Tick k", [
		[ :shape, "k.icon", :line, [ :x1 = "k.x", :y1 = "k.y0", :x2 = "k.x", :y2 = "k.y1",
		                             :stroke = [ :alpha, "muted", 0.35 ], :strokeWidth = 1,
		                             :guide = _nG_ ] ],
		[ :shape, "k.text", :text, [ :cx = "k.x", :cy = "k.y0 - 10", :size = 11,
		                             :fill = "neutral" ] ] ])
	# A TASK is a bar from its start to its finish on its lane, and its
	# name in the column to the left, right-aligned against the column's
	# edge -- the name's own width is a measured number, so its centre is
	# an expression like everything else here.
	_o_.ForAll("Task t", [
		[ :shape, "t.bar", :rect, [ :cx = "(t.x0 + t.x1) / 2", :cy = "t.y",
		                            :w = "t.x1 - t.x0", :h = 18,
		                            :fill = "primary", :stroke = "background", :strokeWidth = 1 ] ],
		[ :shape, "t.text", :text, [ :cx = "170 - 12 - t.text.w / 2", :cy = "t.y", :size = 13,
		                             :fill = [ :on, "paper" ] ] ] ])
	# (the ticks are minted first, so a bar paints over a tick line without
	# a layer term -- which could not name the tick from this selector)
	# A LATER TASK ON A SHARED LANE is named over its own bar, smaller
	_o_.ForAllWhere("Task t", "OverBar(t)", [
		[ :delete, "t.text" ],
		[ :shape, "t.text", :text, [ :cx = "(t.x0 + t.x1) / 2", :cy = "t.y - 15", :size = 11,
		                             :fill = [ :on, "paper" ] ] ] ])
	# A MILESTONE has no length to draw: a diamond on its day, in the
	# colour that says "look here"
	_o_.ForAll("Milestone m", [
		[ :delete, "m.bar" ],
		[ :shape, "m.bar", :poly, [ :n = 4,
		    :x1 = "m.x0", :y1 = "m.y - 10", :x2 = "m.x0 + 10", :y2 = "m.y",
		    :x3 = "m.x0", :y3 = "m.y + 10", :x4 = "m.x0 - 10", :y4 = "m.y",
		    :fill = "danger", :stroke = "background", :strokeWidth = 1 ] ] ])
	# A DEPENDENCY is an elbow: out of the predecessor's end, down or up to
	# the successor's lane, and into the successor's start with a head. A
	# dependency that runs backwards in time is drawn exactly as given --
	# the arrow points left -- and the rule below says so in words.
	_o_.ForAllWhere("Dependency d; Task a; Task b", "d := Dependency(a, b)", [
		[ :field, "d.mx", "a.x1 + 10" ],
		[ :shape, "d.l1", :line, [ :x1 = "a.x1", :y1 = "a.y", :x2 = "d.mx", :y2 = "a.y",
		                           :stroke = "neutral", :strokeWidth = 1.5 ] ],
		[ :shape, "d.l2", :line, [ :x1 = "d.mx", :y1 = "a.y", :x2 = "d.mx", :y2 = "b.y",
		                           :stroke = "neutral", :strokeWidth = 1.5 ] ],
		[ :shape, "d.icon", :line, [ :x1 = "d.mx", :y1 = "b.y", :x2 = "b.x0 - 2", :y2 = "b.y",
		                             :stroke = "neutral", :strokeWidth = 1.5, :arrow = "end" ] ],
		[ :layer, "d.l1", :above, "a.bar" ], [ :layer, "d.icon", :above, "b.bar" ] ])
	return _o_

# the whole picture in one call: substance, a style sized to its lanes,
# and the diagram
func StzGanttDiagram(poFont, paTasks, paDeps)
	_oS_ = StzGanttFromTasks(paTasks, paDeps)
	_o_ = new stzMathDiagram(StzGanttDomain(), _oS_, StzGanttStyle(StzGanttLanesOf(_oS_)))
	if isObject(poFont)  _o_.SetFont(poFont, 13)  ok
	return _o_

#---------------------------------------------------------------------#
#  THE RULES, INTO THE ONE GATE -- every one about time                #
#---------------------------------------------------------------------#

func _GtIsGantt(poDg)
	if NOT isObject(poDg)  return FALSE  ok
	if StzLower(classname(poDg)) != "stzmathdiagram"  return FALSE  ok
	return StzLower("" + poDg.Substance().DomainQ().Name_()) = "gantt"

# the scope of every gantt rule: a picture's objects of one type when it
# is a gantt; the counter: every object of a math picture that is not
func _GtScope(poDg, pcType, pcPrefix)
	_r_ = []
	if NOT _GtIsGantt(poDg)  return _r_  ok
	_ac_ = poDg.Substance().ObjectsOfType(pcType)
	for _i_ = 1 to len(_ac_)  _r_ + (pcPrefix + _ac_[_i_])  next
	return _r_

func _GtCounter(poDg, pcPrefix)
	_r_ = []
	if NOT isObject(poDg) or _GtIsGantt(poDg)  return _r_  ok
	if StzLower(classname(poDg)) != "stzmathdiagram"  return _r_  ok
	_ac_ = poDg.Substance().ObjectNames()
	for _i_ = 1 to len(_ac_)  _r_ + (pcPrefix + _ac_[_i_])  next
	return _r_

func _GtName(poS, pcObj)
	_c_ = poS.LabelOf(pcObj)
	if _c_ = ""  _c_ = pcObj  ok
	return _c_

func _GtDays(pn)
	if pn = 1  return "1 day"  ok
	return StzFactNumText(pn) + " days"

func StzGanttRuleSet()
	_ao_ = []

	_o1_ = StzPlasticRule("dependency_forward_in_time")
	_o1_.SetClaim("a successor does not start before its predecessor ends")
	_o1_.SetOrder(50)
	_o1_.SetReads([ "substance" ])
	_o1_.SetScope(func(oDg) { return _GtScope(oDg, "Dependency", "dep:") })
	_o1_.SetCounter(func(oDg) { return _GtCounter(oDg, "dep:") })
	_o1_.SetClaimCheck(func(oDg, cSub) {
		_cD_ = StzStringSection(cSub, 5, len(cSub))
		_oS_ = oDg.Substance()
		_aD_ = _oS_.Definitions()
		for _i_ = 1 to len(_aD_)
			if _aD_[_i_][1] != _cD_  loop  ok
			_cA_ = "" + _aD_[_i_][3][1]
			_cB_ = "" + _aD_[_i_][3][2]
			_nEnd_ = _oS_.DataOf(_cA_, "finish")
			_nStart_ = _oS_.DataOf(_cB_, "start")
			if _nStart_ < _nEnd_
				return [ FALSE, "'" + _GtName(_oS_, _cB_) + "' starts on day " +
					StzFactNumText(_nStart_) + ", " + _GtDays(_nEnd_ - _nStart_) +
					" before '" + _GtName(_oS_, _cA_) + "' ends on day " +
					StzFactNumText(_nEnd_) + " -- the arrow runs backwards in time" ]
			ok
			return [ TRUE, "" ]
		next
		return [ TRUE, "" ]
	})
	_ao_ + _o1_

	_o2_ = StzPlasticRule("task_ends_after_it_starts")
	_o2_.SetClaim("no task finishes before it starts")
	_o2_.SetOrder(51)
	_o2_.SetReads([ "substance" ])
	_o2_.SetScope(func(oDg) { return _GtScope(oDg, "Task", "task:") })
	_o2_.SetCounter(func(oDg) { return _GtCounter(oDg, "task:") })
	_o2_.SetClaimCheck(func(oDg, cSub) {
		_cT_ = StzStringSection(cSub, 6, len(cSub))
		_oS_ = oDg.Substance()
		_nS_ = _oS_.DataOf(_cT_, "start")
		_nF_ = _oS_.DataOf(_cT_, "finish")
		if _nF_ < _nS_
			return [ FALSE, "'" + _GtName(_oS_, _cT_) + "' finishes on day " +
				StzFactNumText(_nF_) + ", " + _GtDays(_nS_ - _nF_) + " before it starts on day " +
				StzFactNumText(_nS_) ]
		ok
		return [ TRUE, "" ]
	})
	_ao_ + _o2_

	_o3_ = StzPlasticRule("lane_not_double_booked")
	_o3_.SetClaim("two tasks on one lane do not overlap in time")
	_o3_.SetOrder(52)
	_o3_.SetReads([ "substance" ])
	_o3_.SetScope(func(oDg) { return _GtScope(oDg, "Task", "task:") })
	_o3_.SetCounter(func(oDg) { return _GtCounter(oDg, "task:") })
	_o3_.SetClaimCheck(func(oDg, cSub) {
		_cT_ = StzStringSection(cSub, 6, len(cSub))
		_oS_ = oDg.Substance()
		_nS_ = _oS_.DataOf(_cT_, "start")
		_nF_ = _oS_.DataOf(_cT_, "finish")
		_nL_ = _oS_.DataOf(_cT_, "lane")
		_ac_ = _oS_.ObjectsOfType("Task")
		for _i_ = 1 to len(_ac_)
			_cO_ = _ac_[_i_]
			if _cO_ = _cT_  loop  ok
			if _oS_.DataOf(_cO_, "lane") != _nL_  loop  ok
			_nS2_ = _oS_.DataOf(_cO_, "start")
			_nF2_ = _oS_.DataOf(_cO_, "finish")
			# an overlap of positive length: touching ends are not one
			if _nS_ < _nF2_ and _nS2_ < _nF_
				_nLo_ = _nS_
				if _nS2_ > _nLo_  _nLo_ = _nS2_  ok
				_nHi_ = _nF_
				if _nF2_ < _nHi_  _nHi_ = _nF2_  ok
				return [ FALSE, "'" + _GtName(_oS_, _cT_) + "' and '" + _GtName(_oS_, _cO_) +
					"' share lane " + _nL_ + " and overlap by " + _GtDays(_nHi_ - _nLo_) +
					", from day " + StzFactNumText(_nLo_) + " to day " + StzFactNumText(_nHi_) ]
			ok
		next
		return [ TRUE, "" ]
	})
	_ao_ + _o3_

	return _ao_
