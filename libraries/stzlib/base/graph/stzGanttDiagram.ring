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
	# THE THREE ROUTES A LINK CAN TAKE, decided by the builder, which sees
	# every bar: Straight along one lane; Roomy, out and down and in, when
	# the successor starts far enough after the vertical column; Tight,
	# through the gap between lanes and in from the left, when it does not
	_o_.AddPredicate("Straight", [ "Dependency" ])
	_o_.AddPredicate("Roomy", [ "Dependency" ])
	_o_.AddPredicate("Tight", [ "Dependency" ])
	# A FAULT IS DRAWN, NOT HIDDEN. A task that finishes before it starts
	# had a bar of negative width and drew nothing; two tasks double-booked
	# on a lane left a one-pixel seam where the later bar's edge crossed the
	# earlier. The builder marks both so the style can show them -- the
	# RULES still judge them from the days, and the gate holds the marks to
	# the verdicts.
	_o_.AddPredicate("Reversed", [ "Task" ])
	_o_.AddPredicate("Clashing", [ "Task" ])
	return _o_

# the paper: a fixed width, a height that follows the lanes
# THE HOUSE TYPE SIZE. This drew its labels at 11 to 13 points, which the
# Principal has called unreadable once per domain: "as usual, text is very
# small". The type is raised to the catalogue's own scale and every paired
# dimension -- the paper, the margins, the pitches -- is raised with it,
# because raising type on a sheet sized for smaller type only moves the
# problem into the collisions the rules then report.
func StzGanttWidth()
	return 1120

func StzGanttLeftColumn()
	return 265

func StzGanttRowHeight()
	return 52

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
		# WHERE AN ARROW ENTERS AND LEAVES: a bar's two ends; a milestone's
		# diamond is ten wide either side of its day, so its tips
		_nIn_ = _nX0_ + (_a_[2] - _nMin_) * _nK_
		_nOut_ = _nX0_ + (_a_[3] - _nMin_) * _nK_
		if _cT_ = "Milestone"  _nIn_ -= 10  _nOut_ += 10  ok
		_oS_.SetData("t" + _i_, "xin", _nIn_)
		_oS_.SetData("t" + _i_, "xout", _nOut_)
	next

	# THE FAULTS, MARKED FOR THE DRAWING: a task whose finish is before its
	# start, and every task that overlaps another on its lane
	for _i_ = 1 to _nT_
		if paTasks[_i_][3] < paTasks[_i_][2]  _oS_.Assert("Reversed", [ "t" + _i_ ])  ok
		for _j_ = 1 to _nT_
			if _j_ = _i_ or _anLane_[_j_] != _anLane_[_i_]  loop  ok
			if paTasks[_i_][2] < paTasks[_j_][3] and paTasks[_j_][2] < paTasks[_i_][3]
				_oS_.Assert("Clashing", [ "t" + _i_ ])
				exit
			ok
		next
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
		_GtRoute(_oS_, "d" + _k_, _cA_, _cB_)
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

# THE ROUTE OF ONE LINK, AS DATA. The builder sees every bar, so it is the
# one that can promise a link never crosses one: the vertical column is
# pushed right of every bar on a lane between the two tasks that would
# stand in its way, and the successor is entered from the left along its
# own lane. Three shapes of route, each a polyline the style draws with a
# small arc at every turn:
#
#   Straight  same lane, successor after: one segment
#   Roomy     the successor starts at least twenty pixels past the
#             column: out, down the column, and in -- four points
#   Tight     it does not (touching, overlapping, backwards, or a
#             milestone): out, down the column to the gap between lanes
#             on the successor's side, along the gap to twenty short of
#             the successor, down into its lane, and in -- six points
#
# The corner arc's radius is five, or half the shorter segment where a
# segment is shorter than ten. Segments are stored shortened to the arcs'
# tangent points; the arc is stored as its two tangents and its midpoint.
func _GtRoute(poS, pcD, pcA, pcB)
	_nAx_ = poS.DataOf(pcA, "xout")  _nAy_ = poS.DataOf(pcA, "y")
	_nBx_ = poS.DataOf(pcB, "xin")   _nBy_ = poS.DataOf(pcB, "y")  _nBo_ = poS.DataOf(pcB, "xout")
	_nLa_ = poS.DataOf(pcA, "lane")  _nLb_ = poS.DataOf(pcB, "lane")
	_nDir_ = 1
	if _nBy_ < _nAy_  _nDir_ = -1  ok

	# the bars the column must not cross: every task on a lane strictly
	# between the two, and on the successor's lane before the successor
	_aAvoid_ = []
	_ac_ = poS.ObjectsOfType("Task")
	for _i_ = 1 to len(_ac_)
		_cT_ = _ac_[_i_]
		if _cT_ = pcA or _cT_ = pcB  loop  ok
		_nL_ = poS.DataOf(_cT_, "lane")
		_bBetween_ = (_nL_ > _nLa_ and _nL_ < _nLb_) or (_nL_ < _nLa_ and _nL_ > _nLb_)
		if _bBetween_ or _nL_ = _nLb_
			_aAvoid_ + [ poS.DataOf(_cT_, "xin"), poS.DataOf(_cT_, "xout") ]
		ok
	next
	_nVx_ = _nAx_ + 8
	for _pass_ = 1 to 40
		_bMoved_ = FALSE
		for _i_ = 1 to len(_aAvoid_)
			if _nVx_ >= _aAvoid_[_i_][1] - 6 and _nVx_ <= _aAvoid_[_i_][2] + 6
				_nVx_ = _aAvoid_[_i_][2] + 8
				_bMoved_ = TRUE
			ok
		next
		if NOT _bMoved_  exit  ok
	next

	_aP_ = []
	if _nLa_ = _nLb_ and _nBx_ > _nAx_ + 14
		poS.Assert("Straight", [ pcD ])
		_aP_ = [ [ _nAx_, _nAy_ ], [ _nBx_ - 1, _nBy_ ] ]
	but _nBx_ >= _nVx_ + 20
		poS.Assert("Roomy", [ pcD ])
		_aP_ = [ [ _nAx_, _nAy_ ], [ _nVx_, _nAy_ ], [ _nVx_, _nBy_ ], [ _nBx_ - 1, _nBy_ ] ]
	else
		poS.Assert("Tight", [ pcD ])
		_nYm_ = _nBy_ - _nDir_ * 17
		if _nLa_ = _nLb_  _nYm_ = _nBy_ - 17  ok
		_nEx_ = _nBx_ - 20
		_aP_ = [ [ _nAx_, _nAy_ ], [ _nVx_, _nAy_ ], [ _nVx_, _nYm_ ], [ _nEx_, _nYm_ ],
		         [ _nEx_, _nBy_ ], [ _nBx_ - 1, _nBy_ ] ]
	ok

	# segments shortened to the tangent points, and the arcs between
	_nP_ = len(_aP_)
	poS.SetData(pcD, "n", _nP_)
	_anR_ = []
	for _j_ = 1 to _nP_
		_anR_ + 0
	next
	for _j_ = 2 to _nP_ - 1
		_nL1_ = _GtLen(_aP_[_j_ - 1], _aP_[_j_])
		_nL2_ = _GtLen(_aP_[_j_], _aP_[_j_ + 1])
		_nR_ = 5
		if _nL1_ / 2 < _nR_  _nR_ = _nL1_ / 2  ok
		if _nL2_ / 2 < _nR_  _nR_ = _nL2_ / 2  ok
		_anR_[_j_] = _nR_
	next
	for _j_ = 1 to _nP_ - 1
		_aU_ = _GtUnit(_aP_[_j_], _aP_[_j_ + 1])
		_nX1_ = _aP_[_j_][1] + _anR_[_j_] * _aU_[1]
		_nY1_ = _aP_[_j_][2] + _anR_[_j_] * _aU_[2]
		_nX2_ = _aP_[_j_ + 1][1] - _anR_[_j_ + 1] * _aU_[1]
		_nY2_ = _aP_[_j_ + 1][2] - _anR_[_j_ + 1] * _aU_[2]
		poS.SetData(pcD, "s" + _j_ + "x1", _nX1_)  poS.SetData(pcD, "s" + _j_ + "y1", _nY1_)
		poS.SetData(pcD, "s" + _j_ + "x2", _nX2_)  poS.SetData(pcD, "s" + _j_ + "y2", _nY2_)
	next
	for _j_ = 2 to _nP_ - 1
		_aUa_ = _GtUnit(_aP_[_j_], _aP_[_j_ - 1])
		_aUb_ = _GtUnit(_aP_[_j_], _aP_[_j_ + 1])
		_nR_ = _anR_[_j_]
		_c_ = "c" + (_j_ - 1)
		poS.SetData(pcD, _c_ + "ax", _aP_[_j_][1] + _nR_ * _aUa_[1])
		poS.SetData(pcD, _c_ + "ay", _aP_[_j_][2] + _nR_ * _aUa_[2])
		# the arc's midpoint: where a quarter circle inscribed in the
		# corner passes, 1 - 1/sqrt(2) of the radius along both tangents
		poS.SetData(pcD, _c_ + "mx", _aP_[_j_][1] + 0.2929 * _nR_ * (_aUa_[1] + _aUb_[1]))
		poS.SetData(pcD, _c_ + "my", _aP_[_j_][2] + 0.2929 * _nR_ * (_aUa_[2] + _aUb_[2]))
		poS.SetData(pcD, _c_ + "bx", _aP_[_j_][1] + _nR_ * _aUb_[1])
		poS.SetData(pcD, _c_ + "by", _aP_[_j_][2] + _nR_ * _aUb_[2])
	next

func _GtLen(pa, pb)
	return sqrt((pb[1] - pa[1]) * (pb[1] - pa[1]) + (pb[2] - pa[2]) * (pb[2] - pa[2]))

func _GtUnit(pa, pb)
	_n_ = _GtLen(pa, pb)
	if _n_ < 0.000001  return [ 0, 0 ]  ok
	return [ (pb[1] - pa[1]) / _n_, (pb[2] - pa[2]) / _n_ ]

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
		[ :shape, "k.text", :text, [ :cx = "k.x", :cy = "k.y0 - 10", :size = 17,
		                             :fill = "neutral" ] ] ])
	# A TASK is a bar from its start to its finish on its lane, and its
	# name in the column to the left, right-aligned against the column's
	# edge -- the name's own width is a measured number, so its centre is
	# an expression like everything else here.
	_o_.ForAll("Task t", [
		[ :shape, "t.bar", :rect, [ :cx = "(t.x0 + t.x1) / 2", :cy = "t.y",
		                            :w = "abs(t.x1 - t.x0)", :h = 18,
		                            :fill = "primary", :stroke = "background", :strokeWidth = 1 ] ],
		[ :shape, "t.text", :text, [ :cx = "170 - 12 - t.text.w / 2", :cy = "t.y", :size = 20,
		                             :fill = [ :on, "paper" ] ] ] ])
	# (the ticks are minted first, so a bar paints over a tick line without
	# a layer term -- which could not name the tick from this selector)
	# A FAULT IS DRAWN. A reversed task is a bar between its two days in the
	# colour that says "wrong", where it used to draw nothing; a task
	# double-booked on its lane keeps its bar and takes a red edge, so the
	# overlap is a red seam rather than a white one.
	_o_.ForAllWhere("Task t", "Reversed(t)", [
		[ :delete, "t.bar" ],
		[ :shape, "t.bar", :rect, [ :cx = "(t.x0 + t.x1) / 2", :cy = "t.y",
		                            :w = "abs(t.x1 - t.x0)", :h = 18,
		                            :fill = "danger", :stroke = "background", :strokeWidth = 1 ] ] ])
	_o_.ForAllWhere("Task t", "Clashing(t)", [
		[ :delete, "t.bar" ],
		[ :shape, "t.bar", :rect, [ :cx = "(t.x0 + t.x1) / 2", :cy = "t.y",
		                            :w = "abs(t.x1 - t.x0)", :h = 18,
		                            :fill = "primary", :stroke = "danger", :strokeWidth = 2 ] ] ])
	# A LATER TASK ON A SHARED LANE is named INSIDE its own bar, smaller, in
	# whichever of black and white reads on the bar. Inside, not above: the
	# gap above a bar is where a dependency's run between lanes goes, and a
	# name there sat two pixels from it.
	_o_.ForAllWhere("Task t", "OverBar(t)", [
		[ :delete, "t.text" ],
		[ :shape, "t.text", :text, [ :cx = "(t.x0 + t.x1) / 2", :cy = "t.y", :size = 17,
		                             :fill = [ :on, "t.bar" ] ] ],
		[ :layer, "t.text", :above, "t.bar" ] ])
	# A MILESTONE has no length to draw: a diamond on its day, in the
	# colour that says "look here"
	_o_.ForAll("Milestone m", [
		[ :delete, "m.bar" ],
		[ :shape, "m.bar", :poly, [ :n = 4,
		    :x1 = "m.x0", :y1 = "m.y - 10", :x2 = "m.x0 + 10", :y2 = "m.y",
		    :x3 = "m.x0", :y3 = "m.y + 10", :x4 = "m.x0 - 10", :y4 = "m.y",
		    :fill = "danger", :stroke = "background", :strokeWidth = 1 ] ] ])
	# A DEPENDENCY IS A STAIRCASE THAT ALWAYS ENTERS FROM THE LEFT: out of
	# the predecessor's end by eight, along to the boundary between lanes
	# on the successor's side, across that boundary to eight short of the
	# successor's start, down or up into its lane, and in with a head that
	# points right. The first version turned into the successor's lane at
	# once and ran straight to its start; for a task starting the day its
	# predecessor ends -- the commonest case -- that run went LEFT, the
	# head pointed backwards and lay on the bar, and the Principal saw
	# both. A dependency that runs backwards in time is drawn by the same
	# route -- its crossing along the boundary runs left, visibly -- and
	# the rule says so in words. The side of the successor the boundary is
	# on is a sign the tape computes without a branch.
	# THE ROUTE IS DATA, THE STYLE DRAWS IT: the builder chose the polyline,
	# pushed its column clear of every bar, and stored each segment
	# shortened to the arcs' tangents and each arc as three points. The
	# head is on the last segment, which always runs rightwards into the
	# successor. Three route kinds, three fixed sets of shapes.
	_o_.ForAllWhere("Dependency d; Task a; Task b", "d := Dependency(a, b); Straight(d)", [
		[ :shape, "d.icon", :line, [ :x1 = "d.s1x1", :y1 = "d.s1y1", :x2 = "d.s1x2", :y2 = "d.s1y2",
		                             :stroke = "neutral", :strokeWidth = 1.5, :arrow = "end" ] ] ])
	_o_.ForAllWhere("Dependency d; Task a; Task b", "d := Dependency(a, b); Roomy(d)", [
		[ :shape, "d.s1", :line, [ :x1 = "d.s1x1", :y1 = "d.s1y1", :x2 = "d.s1x2", :y2 = "d.s1y2",
		                           :stroke = "neutral", :strokeWidth = 1.5 ] ],
		[ :shape, "d.s2", :line, [ :x1 = "d.s2x1", :y1 = "d.s2y1", :x2 = "d.s2x2", :y2 = "d.s2y2",
		                           :stroke = "neutral", :strokeWidth = 1.5 ] ],
		[ :shape, "d.icon", :line, [ :x1 = "d.s3x1", :y1 = "d.s3y1", :x2 = "d.s3x2", :y2 = "d.s3y2",
		                             :stroke = "neutral", :strokeWidth = 1.5, :arrow = "end" ] ],
		[ :shape, "d.c1", :spline, [ :n = 3, :x1 = "d.c1ax", :y1 = "d.c1ay", :x2 = "d.c1mx", :y2 = "d.c1my",
		                             :x3 = "d.c1bx", :y3 = "d.c1by", :stroke = "neutral", :strokeWidth = 1.5 ] ],
		[ :shape, "d.c2", :spline, [ :n = 3, :x1 = "d.c2ax", :y1 = "d.c2ay", :x2 = "d.c2mx", :y2 = "d.c2my",
		                             :x3 = "d.c2bx", :y3 = "d.c2by", :stroke = "neutral", :strokeWidth = 1.5 ] ] ])
	_o_.ForAllWhere("Dependency d; Task a; Task b", "d := Dependency(a, b); Tight(d)", [
		[ :shape, "d.s1", :line, [ :x1 = "d.s1x1", :y1 = "d.s1y1", :x2 = "d.s1x2", :y2 = "d.s1y2",
		                           :stroke = "neutral", :strokeWidth = 1.5 ] ],
		[ :shape, "d.s2", :line, [ :x1 = "d.s2x1", :y1 = "d.s2y1", :x2 = "d.s2x2", :y2 = "d.s2y2",
		                           :stroke = "neutral", :strokeWidth = 1.5 ] ],
		[ :shape, "d.s3", :line, [ :x1 = "d.s3x1", :y1 = "d.s3y1", :x2 = "d.s3x2", :y2 = "d.s3y2",
		                           :stroke = "neutral", :strokeWidth = 1.5 ] ],
		[ :shape, "d.s4", :line, [ :x1 = "d.s4x1", :y1 = "d.s4y1", :x2 = "d.s4x2", :y2 = "d.s4y2",
		                           :stroke = "neutral", :strokeWidth = 1.5 ] ],
		[ :shape, "d.icon", :line, [ :x1 = "d.s5x1", :y1 = "d.s5y1", :x2 = "d.s5x2", :y2 = "d.s5y2",
		                             :stroke = "neutral", :strokeWidth = 1.5, :arrow = "end" ] ],
		[ :shape, "d.c1", :spline, [ :n = 3, :x1 = "d.c1ax", :y1 = "d.c1ay", :x2 = "d.c1mx", :y2 = "d.c1my",
		                             :x3 = "d.c1bx", :y3 = "d.c1by", :stroke = "neutral", :strokeWidth = 1.5 ] ],
		[ :shape, "d.c2", :spline, [ :n = 3, :x1 = "d.c2ax", :y1 = "d.c2ay", :x2 = "d.c2mx", :y2 = "d.c2my",
		                             :x3 = "d.c2bx", :y3 = "d.c2by", :stroke = "neutral", :strokeWidth = 1.5 ] ],
		[ :shape, "d.c3", :spline, [ :n = 3, :x1 = "d.c3ax", :y1 = "d.c3ay", :x2 = "d.c3mx", :y2 = "d.c3my",
		                             :x3 = "d.c3bx", :y3 = "d.c3by", :stroke = "neutral", :strokeWidth = 1.5 ] ],
		[ :shape, "d.c4", :spline, [ :n = 3, :x1 = "d.c4ax", :y1 = "d.c4ay", :x2 = "d.c4mx", :y2 = "d.c4my",
		                             :x3 = "d.c4bx", :y3 = "d.c4by", :stroke = "neutral", :strokeWidth = 1.5 ] ] ])
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
