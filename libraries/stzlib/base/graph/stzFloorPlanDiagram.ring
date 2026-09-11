#=====================================================================#
#  STZFLOORPLANDIAGRAM -- DN22: a floor plan is rooms to scale, the   #
#  doors and windows on their walls, and the rules of a building      #
#=====================================================================#
/*
	DISTANCE MEANS LENGTH. A floor plan is the timeline's law turned into
	two dimensions: a room is four numbers in metres -- where it stands
	and how big it is -- a door and a window are a place on a wall and
	a width, and every pixel follows from those by one scale. Nothing is
	solved; the solver reports "nothing to lay out"; and the picture is
	still a mathematical diagram -- it answers Fact() in metres, carries
	marks, sits in a storyboard, is judged by the one gate and renders
	through Rendition() like everything else.

	WHAT A FLOOR PLAN IS HERE:

	    DOMAIN     Room, a rectangle with a name; Door and Window, each on
	               one side of one room at an offset along that wall, a
	               width wide; Scale, the bar that says what a metre is.

	    SUBSTANCE  built from rooms -- [ name, x, y, w, h ] in metres --
	               doors and windows -- [ room, side, offset, width ],
	               side one of n, e, s, w. The builder fits the plan to
	               the paper, puts every corner in pixels on its object,
	               reads which rooms abut which along which wall, and
	               says for every door and window what it faces: another
	               room, or the outside.

	    STYLE      a room as its walls and its name with its area inside;
	               a door as a gap in the wall with the leaf and its swing
	               drawn into the room; a window as a light band across
	               the wall; a scale bar of one metre.

	WHAT THE DOMAIN OWES THE GATE -- the mistakes people make in a plan,
	and none of them is visible in a drawing that draws what it is given:

	    rooms_do_not_overlap        two rooms sharing floor is one floor
	                                drawn twice
	    every_room_has_a_door       a room with no door is a cupboard
	    every_room_is_reachable     from outside, through doors, every
	                                room can be walked into
	    windows_face_outside        a window onto another room lights
	                                nothing

	Each names the rooms by the names the author gave them, and each
	registers itself into the math governance from this file.

	WHAT IS SAID PLAINLY: rooms are rectangles and walls are straight;
	wall thickness is drawn, not measured; stairs, furniture, fixtures,
	levels and the north arrow are not here. A door on a wall that abuts
	no room is an exterior door, which is how the plan is entered.
*/

StzRegisterMathRuleSet("floorplan", StzFloorPlanRuleSet())

#---------------------------------------------------------------------#
#  THE DOMAIN                                                          #
#---------------------------------------------------------------------#

func StzFloorPlanDomain()
	_o_ = new stzMathDomain("floorplan")
	_o_.AddType("Room")
	_o_.AddType("Door")
	_o_.AddType("Window")
	_o_.AddType("Scale")
	# a room's area, written under its name: a text shape draws its
	# owner's label, so the area is an object of its own
	_o_.AddType("Area")
	# which way a door or window faces: the outside, or a room
	_o_.AddPredicate("Exterior", [ "Door" ])
	_o_.AddPredicate("Outward", [ "Window" ])
	# A FAULT IS DRAWN, NOT HIDDEN: a room overlapping another, a room
	# with no door, a room no door reaches, a window onto a room
	_o_.AddPredicate("Overlapping", [ "Room" ])
	_o_.AddPredicate("Doorless", [ "Room" ])
	_o_.AddPredicate("Unreachable", [ "Room" ])
	_o_.AddPredicate("Inward", [ "Window" ])
	return _o_

func StzFloorPlanWidth()
	return 760

func StzFloorPlanMargin()
	return 40

func StzFloorPlanWall()
	return 4

#---------------------------------------------------------------------#
#  THE SUBSTANCE, FROM ROOMS, DOORS AND WINDOWS                        #
#---------------------------------------------------------------------#

# paRooms: [ name, x, y, w, h ] each, in metres, y down. paDoors and
# paWindows: [ room, side, offset, width ] each -- side n, e, s or w;
# the offset runs from the wall's left end (n, s) or its top (e, w).
# Objects are r1..rN, d1..dM, w1..wK and sc; a room's LABEL is its name.
func StzFloorPlanFromRooms(paRooms, paDoors, paWindows)
	_oS_ = new stzMathSubstance(StzFloorPlanDomain())
	_nR_ = len(paRooms)
	if _nR_ = 0
		stzraise("StzFloorPlanFromRooms: a floor plan needs at least one room.")
	ok
	_nX0_ = 0  _nY0_ = 0  _nX1_ = 0  _nY1_ = 0
	for _i_ = 1 to _nR_
		_a_ = paRooms[_i_]
		if len(_a_) < 5 or NOT isNumber(_a_[2]) or NOT isNumber(_a_[3]) or
		   NOT isNumber(_a_[4]) or NOT isNumber(_a_[5])
			stzraise("StzFloorPlanFromRooms: room " + _i_ + " needs a name, a corner and a size in metres.")
		ok
		if _a_[4] <= 0 or _a_[5] <= 0
			stzraise("StzFloorPlanFromRooms: room '" + _a_[1] + "' needs a positive width and depth.")
		ok
		for _j_ = 1 to _i_ - 1
			if StzLower(ring_trim("" + paRooms[_j_][1])) = StzLower(ring_trim("" + _a_[1]))
				stzraise("StzFloorPlanFromRooms: two rooms are named '" + _a_[1] + "' -- a name must say which.")
			ok
		next
		if _i_ = 1
			_nX0_ = _a_[2]  _nY0_ = _a_[3]  _nX1_ = _a_[2] + _a_[4]  _nY1_ = _a_[3] + _a_[5]
		else
			if _a_[2] < _nX0_  _nX0_ = _a_[2]  ok
			if _a_[3] < _nY0_  _nY0_ = _a_[3]  ok
			if _a_[2] + _a_[4] > _nX1_  _nX1_ = _a_[2] + _a_[4]  ok
			if _a_[3] + _a_[5] > _nY1_  _nY1_ = _a_[3] + _a_[5]  ok
		ok
	next

	# metres to pixels: the plan fills the paper's width less its margins
	_nM_ = StzFloorPlanMargin()
	_nK_ = (StzFloorPlanWidth() - 2 * _nM_) / (_nX1_ - _nX0_)
	_nH_ = ceil((_nY1_ - _nY0_) * _nK_ + 2 * _nM_ + 30)

	# the rooms
	for _i_ = 1 to _nR_
		_a_ = paRooms[_i_]
		_oS_.Declare("Room", "r" + _i_)
		_oS_.Label("r" + _i_, "" + _a_[1])
		_oS_.SetData("r" + _i_, "mx", _a_[2])
		_oS_.SetData("r" + _i_, "my", _a_[3])
		_oS_.SetData("r" + _i_, "mw", _a_[4])
		_oS_.SetData("r" + _i_, "mh", _a_[5])
		_oS_.SetData("r" + _i_, "area", _a_[4] * _a_[5])
		_oS_.SetData("r" + _i_, "x", _nM_ + (_a_[2] - _nX0_) * _nK_)
		_oS_.SetData("r" + _i_, "y", _nM_ + (_a_[3] - _nY0_) * _nK_)
		_oS_.SetData("r" + _i_, "w", _a_[4] * _nK_)
		_oS_.SetData("r" + _i_, "h", _a_[5] * _nK_)
		_oS_.SetData("r" + _i_, "cx", _nM_ + (_a_[2] - _nX0_ + _a_[4] / 2) * _nK_)
		_oS_.SetData("r" + _i_, "cy", _nM_ + (_a_[3] - _nY0_ + _a_[5] / 2) * _nK_)
		_oS_.SetData("r" + _i_, "doors", 0)
		_oS_.Declare("Area", "a" + _i_)
		_oS_.Label("a" + _i_, StzFloorPlanAreaText(_a_[4] * _a_[5]))
		_oS_.SetData("a" + _i_, "cx", _oS_.DataOf("r" + _i_, "cx"))
		_oS_.SetData("a" + _i_, "cy", _oS_.DataOf("r" + _i_, "cy") + 10)
	next
	# overlapping rooms, marked on both
	for _i_ = 1 to _nR_
		for _j_ = 1 to _nR_
			if _i_ = _j_  loop  ok
			if _FpOverlap(paRooms[_i_], paRooms[_j_])
				_oS_.Assert("Overlapping", [ "r" + _i_ ])
				exit
			ok
		next
	next

	# the doors and the windows: each on its wall, its ends in pixels,
	# and what it faces
	_nD_ = len(paDoors)
	for _k_ = 1 to _nD_
		_FpOpening(_oS_, paRooms, paDoors[_k_], "Door", "d" + _k_, _nX0_, _nY0_, _nK_, _nM_)
	next
	_nW_ = len(paWindows)
	for _k_ = 1 to _nW_
		_FpOpening(_oS_, paRooms, paWindows[_k_], "Window", "w" + _k_, _nX0_, _nY0_, _nK_, _nM_)
	next
	for _i_ = 1 to _nR_
		if _oS_.DataOf("r" + _i_, "doors") = 0  _oS_.Assert("Doorless", [ "r" + _i_ ])  ok
	next

	# REACH: from outside, through doors, into every room. A door faces
	# the outside or a room; the rooms a walk from outside never enters
	# are marked -- among those that have a door at all.
	_aReached_ = [ 0 ]
	_aFront_ = [ 0 ]
	while len(_aFront_) > 0
		_aNext_ = []
		for _f_ = 1 to len(_aFront_)
			_nFrom_ = _aFront_[_f_]
			for _k_ = 1 to _nD_
				_nA_ = _oS_.DataOf("d" + _k_, "room")
				_nB_ = _oS_.DataOf("d" + _k_, "faces")
				_nTo_ = -1
				if _nA_ = _nFrom_  _nTo_ = _nB_  ok
				if _nB_ = _nFrom_  _nTo_ = _nA_  ok
				if _nTo_ < 0  loop  ok
				_bSeen_ = FALSE
				for _s_ = 1 to len(_aReached_)
					if _aReached_[_s_] = _nTo_  _bSeen_ = TRUE  exit  ok
				next
				if _bSeen_  loop  ok
				_aReached_ + _nTo_
				_aNext_ + _nTo_
			next
		next
		_aFront_ = _aNext_
	end
	for _i_ = 1 to _nR_
		if _oS_.DataOf("r" + _i_, "doors") = 0  loop  ok
		_bIn_ = FALSE
		for _s_ = 1 to len(_aReached_)
			if _aReached_[_s_] = _i_  _bIn_ = TRUE  exit  ok
		next
		if NOT _bIn_  _oS_.Assert("Unreachable", [ "r" + _i_ ])  ok
	next

	# the scale bar: one metre, at the bottom left
	_oS_.Declare("Scale", "sc")
	_oS_.Label("sc", "1 m")
	_oS_.SetData("sc", "x0", _nM_)
	_oS_.SetData("sc", "x1", _nM_ + _nK_)
	_oS_.SetData("sc", "y", _nH_ - 22)
	_oS_.SetData("sc", "paperw", StzFloorPlanWidth())
	_oS_.SetData("sc", "paperh", _nH_)
	return _oS_

# do two rooms share floor of positive area?
func _FpOverlap(paA, paB)
	return paA[2] < paB[2] + paB[4] and paB[2] < paA[2] + paA[4] and
	       paA[3] < paB[3] + paB[5] and paB[3] < paA[3] + paA[5]

func _FpRoomIndex(paRooms, pcName)
	_c_ = StzLower(ring_trim("" + pcName))
	for _i_ = 1 to len(paRooms)
		if StzLower(ring_trim("" + paRooms[_i_][1])) = _c_  return _i_  ok
	next
	return 0

# ONE OPENING ON ONE WALL. Its two ends in metres and in pixels, the
# side it is on, and what lies across the wall at its middle: the room
# whose edge runs there, or the outside. An opening off its wall is
# refused: a door past the corner is not a door.
func _FpOpening(poS, paRooms, paO, pcType, pcObj, pnX0, pnY0, pnK, pnM)
	if len(paO) < 4 or NOT isNumber(paO[3]) or NOT isNumber(paO[4])
		stzraise("StzFloorPlanFromRooms: a " + StzLower(pcType) + " needs a room, a side, an offset and a width.")
	ok
	_i_ = _FpRoomIndex(paRooms, paO[1])
	if _i_ = 0
		stzraise("StzFloorPlanFromRooms: '" + paO[1] + "' is not a room of this plan.")
	ok
	_cSide_ = StzLower(ring_trim("" + paO[2]))
	if _cSide_ != "n" and _cSide_ != "e" and _cSide_ != "s" and _cSide_ != "w"
		stzraise("StzFloorPlanFromRooms: a side is n, e, s or w, not '" + paO[2] + "'.")
	ok
	_a_ = paRooms[_i_]
	_nOff_ = paO[3]
	_nWid_ = paO[4]
	_nLen_ = _a_[4]
	if _cSide_ = "e" or _cSide_ = "w"  _nLen_ = _a_[5]  ok
	if _nWid_ <= 0 or _nOff_ < 0 or _nOff_ + _nWid_ > _nLen_ + 0.000001
		stzraise("StzFloorPlanFromRooms: the " + StzLower(pcType) + " on the " + _cSide_ + " wall of '" +
			_a_[1] + "' runs from " + _nOff_ + " to " + (_nOff_ + _nWid_) + " m on a wall " + _nLen_ + " m long.")
	ok
	# the ends, in metres
	if _cSide_ = "n"
		_ax_ = _a_[2] + _nOff_          _ay_ = _a_[3]
		_bx_ = _a_[2] + _nOff_ + _nWid_ _by_ = _a_[3]
	but _cSide_ = "s"
		_ax_ = _a_[2] + _nOff_          _ay_ = _a_[3] + _a_[5]
		_bx_ = _a_[2] + _nOff_ + _nWid_ _by_ = _a_[3] + _a_[5]
	but _cSide_ = "w"
		_ax_ = _a_[2]                   _ay_ = _a_[3] + _nOff_
		_bx_ = _a_[2]                   _by_ = _a_[3] + _nOff_ + _nWid_
	else
		_ax_ = _a_[2] + _a_[4]          _ay_ = _a_[3] + _nOff_
		_bx_ = _a_[2] + _a_[4]          _by_ = _a_[3] + _nOff_ + _nWid_
	ok
	_mx_ = (_ax_ + _bx_) / 2
	_my_ = (_ay_ + _by_) / 2
	# what is across the wall at the middle: the room whose edge is there
	_nFaces_ = 0
	for _j_ = 1 to len(paRooms)
		if _j_ = _i_  loop  ok
		_b_ = paRooms[_j_]
		_bOn_ = FALSE
		if _cSide_ = "n" and fabs(_b_[3] + _b_[5] - _ay_) < 0.000001 and _mx_ > _b_[2] and _mx_ < _b_[2] + _b_[4]  _bOn_ = TRUE  ok
		if _cSide_ = "s" and fabs(_b_[3] - _ay_) < 0.000001 and _mx_ > _b_[2] and _mx_ < _b_[2] + _b_[4]  _bOn_ = TRUE  ok
		if _cSide_ = "w" and fabs(_b_[2] + _b_[4] - _ax_) < 0.000001 and _my_ > _b_[3] and _my_ < _b_[3] + _b_[5]  _bOn_ = TRUE  ok
		if _cSide_ = "e" and fabs(_b_[2] - _ax_) < 0.000001 and _my_ > _b_[3] and _my_ < _b_[3] + _b_[5]  _bOn_ = TRUE  ok
		if _bOn_  _nFaces_ = _j_  exit  ok
	next
	poS.Declare(pcType, pcObj)
	poS.Label(pcObj, "")
	poS.SetData(pcObj, "room", _i_)
	poS.SetData(pcObj, "faces", _nFaces_)
	poS.SetData(pcObj, "offset", _nOff_)
	poS.SetData(pcObj, "width", _nWid_)
	poS.SetData(pcObj, "x1", pnM + (_ax_ - pnX0) * pnK)
	poS.SetData(pcObj, "y1", pnM + (_ay_ - pnY0) * pnK)
	poS.SetData(pcObj, "x2", pnM + (_bx_ - pnX0) * pnK)
	poS.SetData(pcObj, "y2", pnM + (_by_ - pnY0) * pnK)
	# the swing: the leaf stands on the first end and turns into the room;
	# the free end of the leaf is one width in from the wall
	_nIx_ = 0  _nIy_ = 0
	if _cSide_ = "n"  _nIy_ = 1  ok
	if _cSide_ = "s"  _nIy_ = -1  ok
	if _cSide_ = "w"  _nIx_ = 1  ok
	if _cSide_ = "e"  _nIx_ = -1  ok
	_nLx_ = pnM + (_ax_ - pnX0) * pnK + _nIx_ * _nWid_ * pnK
	_nLy_ = pnM + (_ay_ - pnY0) * pnK + _nIy_ * _nWid_ * pnK
	poS.SetData(pcObj, "lx", _nLx_)
	poS.SetData(pcObj, "ly", _nLy_)
	# the arc's midpoint: on the quarter circle between the leaf's free
	# end and the far end of the opening, 1/sqrt(2) of the width out
	_nAx_ = pnM + (_ax_ - pnX0) * pnK
	_nAy_ = pnM + (_ay_ - pnY0) * pnK
	_nUx_ = (_bx_ - _ax_) / _nWid_
	_nUy_ = (_by_ - _ay_) / _nWid_
	poS.SetData(pcObj, "ax", _nAx_ + (_nIx_ + _nUx_) * 0.7071 * _nWid_ * pnK)
	poS.SetData(pcObj, "ay", _nAy_ + (_nIy_ + _nUy_) * 0.7071 * _nWid_ * pnK)
	# a door serves both rooms it stands between
	if pcType = "Door"
		poS.SetData("r" + _i_, "doors", poS.DataOf("r" + _i_, "doors") + 1)
		if _nFaces_ > 0
			poS.SetData("r" + _nFaces_, "doors", poS.DataOf("r" + _nFaces_, "doors") + 1)
		ok
	ok
	if _nFaces_ = 0
		if pcType = "Door"  poS.Assert("Exterior", [ pcObj ])  else  poS.Assert("Outward", [ pcObj ])  ok
	but pcType = "Window"
		poS.Assert("Inward", [ pcObj ])
	ok

func StzFloorPlanPaperOf(poSubstance)
	return [ poSubstance.DataOf("sc", "paperw"), poSubstance.DataOf("sc", "paperh") ]

# an area written as an architect reads it: whole square metres bare,
# otherwise one decimal
func StzFloorPlanAreaText(pnArea)
	if fabs(pnArea - floor(pnArea)) < 0.0001  return "" + floor(pnArea) + " m2"  ok
	decimals(1)
	_c_ = "" + pnArea
	decimals(2)
	return _c_ + " m2"

#---------------------------------------------------------------------#
#  THE STYLE -- no constraint, no unknown, every position a datum      #
#---------------------------------------------------------------------#

func StzFloorPlanStyle(pnW, pnH)
	_o_ = new stzMathStyle()
	_o_.SetCanvas(pnW, pnH)
	_o_.SetMargin(10)
	# A ROOM is its walls, and its name with its area inside. The floor
	# is the paper; the walls are heavy lines in the neutral colour.
	_o_.ForAll("Room r", [
		[ :shape, "r.wall", :rect, [ :cx = "r.cx", :cy = "r.cy", :w = "r.w", :h = "r.h",
		                             :fill = "background", :stroke = "neutral", :strokeWidth = 4 ] ],
		[ :shape, "r.text", :text, [ :cx = "r.cx", :cy = "r.cy - 8", :size = 13,
		                             :fill = [ :on, "paper" ] ] ] ])
	_o_.ForAll("Area a", [
		[ :shape, "a.text", :text, [ :cx = "a.cx", :cy = "a.cy", :size = 11, :fill = "neutral" ] ] ])
	# A DOOR is a gap in the wall, the leaf standing on one jamb and the
	# swing drawn into the room -- the gap painted in the paper's colour
	# over the wall, the leaf and the swing in the neutral
	_o_.ForAll("Door d", [
		[ :shape, "d.gap", :line, [ :x1 = "d.x1", :y1 = "d.y1", :x2 = "d.x2", :y2 = "d.y2",
		                            :stroke = "background", :strokeWidth = 6 ] ],
		[ :shape, "d.leaf", :line, [ :x1 = "d.x1", :y1 = "d.y1", :x2 = "d.lx", :y2 = "d.ly",
		                             :stroke = "neutral", :strokeWidth = 1.5 ] ],
		[ :shape, "d.icon", :spline, [ :n = 3, :x1 = "d.lx", :y1 = "d.ly", :x2 = "d.ax", :y2 = "d.ay",
		                               :x3 = "d.x2", :y3 = "d.y2",
		                               :stroke = [ :alpha, "neutral", 0.6 ], :strokeWidth = 1 ] ] ])
	# (the rooms are minted before the doors, so a gap paints over its
	# wall without a layer term -- which could not name the room anyway)
	# A WINDOW is a light band across the wall
	_o_.ForAll("Window w", [
		[ :shape, "w.icon", :line, [ :x1 = "w.x1", :y1 = "w.y1", :x2 = "w.x2", :y2 = "w.y2",
		                             :stroke = "info", :strokeWidth = 4 ] ] ])
	# THE SCALE: one metre, so a reader can measure the plan
	_o_.ForAll("Scale s", [
		[ :shape, "s.icon", :line, [ :x1 = "s.x0", :y1 = "s.y", :x2 = "s.x1", :y2 = "s.y",
		                             :stroke = "neutral", :strokeWidth = 2 ] ],
		[ :shape, "s.tick0", :line, [ :x1 = "s.x0", :y1 = "s.y - 5", :x2 = "s.x0", :y2 = "s.y + 5",
		                              :stroke = "neutral", :strokeWidth = 2 ] ],
		[ :shape, "s.tick1", :line, [ :x1 = "s.x1", :y1 = "s.y - 5", :x2 = "s.x1", :y2 = "s.y + 5",
		                              :stroke = "neutral", :strokeWidth = 2 ] ],
		[ :shape, "s.text", :text, [ :cx = "s.x1 + 22", :cy = "s.y", :size = 11, :fill = "neutral" ] ] ])
	# A FAULT IS DRAWN: a room overlapping another, a room with no door,
	# a room no door reaches -- each in the colour of a fault; a window
	# onto another room in that colour too
	_o_.ForAllWhere("Room r", "Overlapping(r)", [
		[ :delete, "r.wall" ],
		[ :shape, "r.wall", :rect, [ :cx = "r.cx", :cy = "r.cy", :w = "r.w", :h = "r.h",
		                             :fill = [ :alpha, "danger", 0.15 ], :stroke = "danger", :strokeWidth = 4 ] ] ])
	_o_.ForAllWhere("Room r", "Doorless(r)", [
		[ :delete, "r.wall" ],
		[ :shape, "r.wall", :rect, [ :cx = "r.cx", :cy = "r.cy", :w = "r.w", :h = "r.h",
		                             :fill = "background", :stroke = "danger", :strokeWidth = 4 ] ] ])
	_o_.ForAllWhere("Room r", "Unreachable(r)", [
		[ :delete, "r.wall" ],
		[ :shape, "r.wall", :rect, [ :cx = "r.cx", :cy = "r.cy", :w = "r.w", :h = "r.h",
		                             :fill = "background", :stroke = "danger", :strokeWidth = 4 ] ] ])
	_o_.ForAllWhere("Window w", "Inward(w)", [
		[ :delete, "w.icon" ],
		[ :shape, "w.icon", :line, [ :x1 = "w.x1", :y1 = "w.y1", :x2 = "w.x2", :y2 = "w.y2",
		                             :stroke = "danger", :strokeWidth = 4 ] ] ])
	return _o_

# the whole picture in one call
func StzFloorPlanDiagram(poFont, paRooms, paDoors, paWindows)
	_oS_ = StzFloorPlanFromRooms(paRooms, paDoors, paWindows)
	_aP_ = StzFloorPlanPaperOf(_oS_)
	_o_ = new stzMathDiagram(StzFloorPlanDomain(), _oS_, StzFloorPlanStyle(_aP_[1], _aP_[2]))
	if isObject(poFont)  _o_.SetFont(poFont, 12)  ok
	return _o_

#---------------------------------------------------------------------#
#  THE RULES, INTO THE ONE GATE -- every one about the building        #
#---------------------------------------------------------------------#

func _FpIsPlan(poDg)
	if NOT isObject(poDg)  return FALSE  ok
	if StzLower(classname(poDg)) != "stzmathdiagram"  return FALSE  ok
	return StzLower("" + poDg.Substance().DomainQ().Name_()) = "floorplan"

func _FpScope(poDg, pcType, pcPrefix)
	_r_ = []
	if NOT _FpIsPlan(poDg)  return _r_  ok
	_ac_ = poDg.Substance().ObjectsOfType(pcType)
	for _i_ = 1 to len(_ac_)  _r_ + (pcPrefix + _ac_[_i_])  next
	return _r_

func _FpCounter(poDg, pcPrefix)
	_r_ = []
	if NOT isObject(poDg) or _FpIsPlan(poDg)  return _r_  ok
	if StzLower(classname(poDg)) != "stzmathdiagram"  return _r_  ok
	_ac_ = poDg.Substance().ObjectNames()
	for _i_ = 1 to len(_ac_)  _r_ + (pcPrefix + _ac_[_i_])  next
	return _r_

func _FpName(poS, pcObj)
	_c_ = poS.LabelOf(pcObj)
	if _c_ = ""  _c_ = pcObj  ok
	return _c_

func StzFloorPlanRuleSet()
	_ao_ = []

	_o1_ = StzPlasticRule("rooms_do_not_overlap")
	_o1_.SetClaim("no two rooms share floor")
	_o1_.SetOrder(59)
	_o1_.SetReads([ "substance" ])
	_o1_.SetScope(func(oDg) { return _FpScope(oDg, "Room", "room:") })
	_o1_.SetCounter(func(oDg) { return _FpCounter(oDg, "room:") })
	_o1_.SetClaimCheck(func(oDg, cSub) {
		_cR_ = StzStringSection(cSub, 6, len(cSub))
		_oS_ = oDg.Substance()
		_ac_ = _oS_.ObjectsOfType("Room")
		for _i_ = 1 to len(_ac_)
			_cO_ = _ac_[_i_]
			if _cO_ = _cR_  loop  ok
			_aA_ = [ "", _oS_.DataOf(_cR_, "mx"), _oS_.DataOf(_cR_, "my"), _oS_.DataOf(_cR_, "mw"), _oS_.DataOf(_cR_, "mh") ]
			_aB_ = [ "", _oS_.DataOf(_cO_, "mx"), _oS_.DataOf(_cO_, "my"), _oS_.DataOf(_cO_, "mw"), _oS_.DataOf(_cO_, "mh") ]
			if _FpOverlap(_aA_, _aB_)
				_nW_ = min([ _aA_[2] + _aA_[4], _aB_[2] + _aB_[4] ]) - max([ _aA_[2], _aB_[2] ])
				_nH_ = min([ _aA_[3] + _aA_[5], _aB_[3] + _aB_[5] ]) - max([ _aA_[3], _aB_[3] ])
				return [ FALSE, "'" + _FpName(_oS_, _cR_) + "' and '" + _FpName(_oS_, _cO_) + "' share " +
					StzFloorPlanAreaText(_nW_ * _nH_) + " of floor" ]
			ok
		next
		return [ TRUE, "" ]
	})
	_ao_ + _o1_

	_o2_ = StzPlasticRule("every_room_has_a_door")
	_o2_.SetClaim("every room has at least one door")
	_o2_.SetOrder(60)
	_o2_.SetReads([ "substance" ])
	_o2_.SetScope(func(oDg) { return _FpScope(oDg, "Room", "room:") })
	_o2_.SetCounter(func(oDg) { return _FpCounter(oDg, "room:") })
	_o2_.SetClaimCheck(func(oDg, cSub) {
		_cR_ = StzStringSection(cSub, 6, len(cSub))
		_oS_ = oDg.Substance()
		if _oS_.DataOf(_cR_, "doors") = 0
			return [ FALSE, "'" + _FpName(_oS_, _cR_) + "' has no door -- it is a cupboard, or the door is missing" ]
		ok
		return [ TRUE, "" ]
	})
	_ao_ + _o2_

	# the rooms with a door are the ones this rule can say something
	# about; a room with none is the second rule's
	_o3_ = StzPlasticRule("every_room_is_reachable")
	_o3_.SetClaim("from outside, through doors, every room can be walked into")
	_o3_.SetOrder(61)
	_o3_.SetReads([ "substance" ])
	_o3_.SetScope(func(oDg) {
		_r_ = []
		if NOT _FpIsPlan(oDg)  return _r_  ok
		_oS_ = oDg.Substance()
		_ac_ = _oS_.ObjectsOfType("Room")
		for _i_ = 1 to len(_ac_)
			if _oS_.DataOf(_ac_[_i_], "doors") > 0  _r_ + ("room:" + _ac_[_i_])  ok
		next
		return _r_
	})
	_o3_.SetCounter(func(oDg) {
		_r_ = _FpCounter(oDg, "room:")
		if NOT _FpIsPlan(oDg)  return _r_  ok
		_oS_ = oDg.Substance()
		_ac_ = _oS_.ObjectsOfType("Room")
		for _i_ = 1 to len(_ac_)
			if _oS_.DataOf(_ac_[_i_], "doors") = 0  _r_ + ("room:" + _ac_[_i_])  ok
		next
		return _r_
	})
	_o3_.SetClaimCheck(func(oDg, cSub) {
		_cR_ = StzStringSection(cSub, 6, len(cSub))
		_oS_ = oDg.Substance()
		if _oS_.Holds("Unreachable", [ _cR_ ])
			return [ FALSE, "'" + _FpName(_oS_, _cR_) + "' cannot be reached from outside -- its doors open only into rooms nobody can enter" ]
		ok
		return [ TRUE, "" ]
	})
	_ao_ + _o3_

	_o4_ = StzPlasticRule("windows_face_outside")
	_o4_.SetClaim("every window is on an outside wall")
	_o4_.SetOrder(62)
	_o4_.SetReads([ "substance" ])
	_o4_.SetScope(func(oDg) { return _FpScope(oDg, "Window", "window:") })
	_o4_.SetCounter(func(oDg) { return _FpCounter(oDg, "window:") })
	_o4_.SetClaimCheck(func(oDg, cSub) {
		_cW_ = StzStringSection(cSub, 8, len(cSub))
		_oS_ = oDg.Substance()
		_nF_ = _oS_.DataOf(_cW_, "faces")
		if _nF_ > 0
			return [ FALSE, "the window on the " + _FpSideName(_oS_, _cW_) + " wall of '" +
				_FpName(_oS_, "r" + _oS_.DataOf(_cW_, "room")) + "' looks into '" + _FpName(_oS_, "r" + _nF_) +
				"' -- a window onto another room lights nothing" ]
		ok
		return [ TRUE, "" ]
	})
	_ao_ + _o4_

	return _ao_

func _FpSideName(poS, pcObj)
	_nDx_ = poS.DataOf(pcObj, "x2") - poS.DataOf(pcObj, "x1")
	_nDy_ = poS.DataOf(pcObj, "y2") - poS.DataOf(pcObj, "y1")
	_nR_ = poS.DataOf(pcObj, "room")
	if fabs(_nDx_) > fabs(_nDy_)
		if fabs(poS.DataOf(pcObj, "y1") - poS.DataOf("r" + _nR_, "y")) < 0.01  return "north"  ok
		return "south"
	ok
	if fabs(poS.DataOf(pcObj, "x1") - poS.DataOf("r" + _nR_, "x")) < 0.01  return "west"  ok
	return "east"
