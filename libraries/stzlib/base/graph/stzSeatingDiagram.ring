#=====================================================================#
#  STZSEATINGDIAGRAM -- DN23: a seating plan is tables where they      #
#  stand, seats around them, and guests in the seats                   #
#=====================================================================#
/*
	A SEATING PLAN is the floor plan's kind of picture with people in it.
	A table is a name, a kind, a number of seats and a place in the hall
	in metres; its seats are computed around it -- evenly on a ring for
	a round table, along both long sides for a long one -- and the guests
	take the seats in the order they are given, each name written beyond
	its seat, anchored by where it stands on the ring so it reads
	outward. Nothing is solved; the solver reports "nothing to lay out";
	and the picture is still a mathematical diagram -- it answers Fact(),
	carries marks, sits in a storyboard, is judged by the one gate and
	renders through Rendition() like everything else.

	WHAT A SEATING PLAN IS HERE:

	    DOMAIN     Table (Round or Long), Seat, Guest, and Apart(Guest,
	               Guest) -- two people the host says must not share a
	               table, the one claim a plan makes that the drawing
	               cannot show to be broken.

	    SUBSTANCE  built from tables -- [ name, kind, seats, x, y ] with
	               kind round or long and x, y in metres -- guests --
	               [ name, table ] in seating order -- and pairs to keep
	               apart -- [ name, name ]. The builder fits the hall to
	               the paper, seats every guest at the next free seat of
	               the table given, and puts every number on its object.

	    STYLE      a round table as a disc, a long one as a slab, its name
	               inside; a seat as a small ring, filled when taken; a
	               guest's name beyond the seat; the guests who found no
	               seat named in a line beneath the hall.

	WHAT THE DOMAIN OWES THE GATE -- the mistakes hosts make, and none of
	them is visible in a drawing that draws what it is given:

	    table_not_overbooked     a table given more guests than seats
	    a_guest_sits_once        one name seated at two tables
	    kept_apart_are_apart     a pair the host keeps apart, together
	    tables_stand_clear       two tables whose seats meet

	Each names the tables and the guests by the names the host gave them,
	and each registers itself into the math governance from this file.

	WHAT IS SAID PLAINLY: seats are not chosen, they are taken in order;
	a round table's size follows its seats; the hall is the paper and has
	no walls here; couples, dietary marks, and who faces the stage are
	not here.
*/

StzRegisterMathRuleSet("seating", StzSeatingRuleSet())

#---------------------------------------------------------------------#
#  THE DOMAIN                                                          #
#---------------------------------------------------------------------#

func StzSeatingDomain()
	_o_ = new stzMathDomain("seating")
	_o_.AddType("Table")
	_o_.AddType("Seat")
	_o_.AddType("Guest")
	_o_.AddType("Apart")
	_o_.AddConstructor("Apart", [ "Guest", "Guest" ])
	# the one line naming everyone who found no seat
	_o_.AddType("Unseated")
	_o_.AddPredicate("Round", [ "Table" ])
	_o_.AddPredicate("Long", [ "Table" ])
	_o_.AddPredicate("Taken", [ "Seat" ])
	# A FAULT IS DRAWN, NOT HIDDEN: an overbooked table, a guest seated
	# twice, a pair together, tables that meet
	_o_.AddPredicate("Overbooked", [ "Table" ])
	_o_.AddPredicate("Colliding", [ "Table" ])
	_o_.AddPredicate("Doubled", [ "Guest" ])
	_o_.AddPredicate("Clashing", [ "Guest" ])
	_o_.AddPredicate("Seatless", [ "Guest" ])
	return _o_

func StzSeatingWidth()
	return 760

func StzSeatingMargin()
	return 30

# the geometry of a table, in metres: a round table's radius grows with
# its seats; a seat is a small ring a little off the table's edge; a
# name stands beyond the seat
func StzSeatingRadiusFor(pnSeats)
	return 0.55 + 0.07 * pnSeats

func StzSeatingSeatRadius()
	return 0.18

func StzSeatingSeatGap()
	return 0.32

func StzSeatingNameGap()
	return 0.80

#---------------------------------------------------------------------#
#  THE SUBSTANCE, FROM TABLES, GUESTS AND PAIRS                        #
#---------------------------------------------------------------------#

# paTables: [ name, kind, seats, x, y ] each -- kind round or long, x
# and y the table's centre in metres. paGuests: [ name, table ] each,
# seated in this order. paApart: [ name, name ] each. Objects are
# t1..tN, t1s1..tNsK, g1..gM, p1..pP and, where anyone found no seat,
# un; a thing's LABEL is the name given.
func StzSeatingFromTables(paTables, paGuests, paApart)
	return StzSeatingFromTablesXT(NULL, paTables, paGuests, paApart)

func StzSeatingFromTablesXT(poFont, paTables, paGuests, paApart)
	_oS_ = new stzMathSubstance(StzSeatingDomain())
	_nT_ = len(paTables)
	if _nT_ = 0
		stzraise("StzSeatingFromTables: a seating plan needs at least one table.")
	ok
	_nX0_ = 0  _nY0_ = 0  _nX1_ = 0  _nY1_ = 0
	_anReach_ = []
	for _i_ = 1 to _nT_
		_a_ = paTables[_i_]
		if len(_a_) < 5 or NOT isNumber(_a_[3]) or NOT isNumber(_a_[4]) or NOT isNumber(_a_[5])
			stzraise("StzSeatingFromTables: table " + _i_ + " needs a name, a kind, a number of seats and a place.")
		ok
		_cK_ = StzLower(ring_trim("" + _a_[2]))
		if _cK_ != "round" and _cK_ != "long"
			stzraise("StzSeatingFromTables: a table is round or long, not '" + _a_[2] + "'.")
		ok
		if _a_[3] < 1 or _a_[3] != floor(_a_[3])
			stzraise("StzSeatingFromTables: table '" + _a_[1] + "' needs a whole number of seats, at least one.")
		ok
		for _j_ = 1 to _i_ - 1
			if StzLower(ring_trim("" + paTables[_j_][1])) = StzLower(ring_trim("" + _a_[1]))
				stzraise("StzSeatingFromTables: two tables are named '" + _a_[1] + "' -- a name must say which.")
			ok
		next
		_aR_ = _StReachOf(_a_)
		_anReach_ + _aR_
		if _i_ = 1
			_nX0_ = _a_[4] - _aR_[1]  _nX1_ = _a_[4] + _aR_[1]
			_nY0_ = _a_[5] - _aR_[2]  _nY1_ = _a_[5] + _aR_[2]
		else
			if _a_[4] - _aR_[1] < _nX0_  _nX0_ = _a_[4] - _aR_[1]  ok
			if _a_[4] + _aR_[1] > _nX1_  _nX1_ = _a_[4] + _aR_[1]  ok
			if _a_[5] - _aR_[2] < _nY0_  _nY0_ = _a_[5] - _aR_[2]  ok
			if _a_[5] + _aR_[2] > _nY1_  _nY1_ = _a_[5] + _aR_[2]  ok
		ok
	next
	# metres to pixels: the hall fills the paper's width less its margins
	_nM_ = StzSeatingMargin()
	_nK_ = (StzSeatingWidth() - 2 * _nM_) / (_nX1_ - _nX0_)
	_nH_ = ceil((_nY1_ - _nY0_) * _nK_ + 2 * _nM_)

	# THE TABLES AND THEIR SEATS
	for _i_ = 1 to _nT_
		_a_ = paTables[_i_]
		_cK_ = StzLower(ring_trim("" + _a_[2]))
		_nS_ = _a_[3]
		_cT_ = "t" + _i_
		_oS_.Declare("Table", _cT_)
		_oS_.Label(_cT_, "" + _a_[1])
		_oS_.SetData(_cT_, "seats", _nS_)
		_oS_.SetData(_cT_, "given", 0)
		_oS_.SetData(_cT_, "mx", _a_[4])
		_oS_.SetData(_cT_, "my", _a_[5])
		_nCx_ = _nM_ + (_a_[4] - _nX0_) * _nK_
		_nCy_ = _nM_ + (_a_[5] - _nY0_) * _nK_
		_oS_.SetData(_cT_, "cx", _nCx_)
		_oS_.SetData(_cT_, "cy", _nCy_)
		if _cK_ = "round"
			_oS_.Assert("Round", [ _cT_ ])
			_nR_ = StzSeatingRadiusFor(_nS_)
			_oS_.SetData(_cT_, "r", _nR_ * _nK_)
			_oS_.SetData(_cT_, "reach", _nR_ + StzSeatingSeatGap() + StzSeatingSeatRadius())
			for _k_ = 1 to _nS_
				_nA_ = 0 - 1.5707963 + 6.2831853 * (_k_ - 1) / _nS_
				_nSd_ = _nR_ + StzSeatingSeatGap()
				_nNd_ = _nR_ + StzSeatingNameGap()
				_StSeat(_oS_, _cT_, _k_, _nCx_ + _nSd_ * _nK_ * cos(_nA_), _nCy_ + _nSd_ * _nK_ * sin(_nA_),
					_nCx_ + _nNd_ * _nK_ * cos(_nA_), _nCy_ + _nNd_ * _nK_ * sin(_nA_), cos(_nA_), _nK_)
			next
		else
			_oS_.Assert("Long", [ _cT_ ])
			_nUp_ = ceil(_nS_ / 2)
			_nDn_ = _nS_ - _nUp_
			_nLen_ = 0.6 * _nUp_ + 0.3
			_oS_.SetData(_cT_, "w", _nLen_ * _nK_)
			_oS_.SetData(_cT_, "h", 0.9 * _nK_)
			_oS_.SetData(_cT_, "reach", _nLen_ / 2)
			_k_ = 0
			for _j_ = 1 to _nUp_
				_k_++
				_nSx_ = _nCx_ + (0.6 * (_j_ - 0.5) - _nLen_ / 2 + 0.15) * _nK_
				_StSeat(_oS_, _cT_, _k_, _nSx_, _nCy_ - (0.45 + StzSeatingSeatGap()) * _nK_,
					_nSx_, _nCy_ - (0.45 + StzSeatingNameGap()) * _nK_, 0, _nK_)
			next
			for _j_ = 1 to _nDn_
				_k_++
				_nSx_ = _nCx_ + (0.6 * (_j_ - 0.5) - _nLen_ / 2 + 0.15) * _nK_
				_StSeat(_oS_, _cT_, _k_, _nSx_, _nCy_ + (0.45 + StzSeatingSeatGap()) * _nK_,
					_nSx_, _nCy_ + (0.45 + StzSeatingNameGap()) * _nK_, 0, _nK_)
			next
		ok
	next
	# tables whose seats meet, marked on both
	for _i_ = 1 to _nT_
		for _j_ = 1 to _nT_
			if _i_ = _j_  loop  ok
			if _StCollide(paTables[_i_], paTables[_j_], _anReach_[_i_], _anReach_[_j_])
				_oS_.Assert("Colliding", [ "t" + _i_ ])
				exit
			ok
		next
	next

	# THE GUESTS, seated in order at the next free seat of their table
	_nG_ = len(paGuests)
	_acLost_ = []
	for _g_ = 1 to _nG_
		_a_ = paGuests[_g_]
		if len(_a_) < 2 or ring_trim("" + _a_[1]) = ""
			stzraise("StzSeatingFromTables: guest " + _g_ + " needs a name and a table.")
		ok
		_i_ = _StTableIndex(paTables, _a_[2])
		if _i_ = 0
			stzraise("StzSeatingFromTables: '" + _a_[1] + "' is seated at '" + _a_[2] + "', which is not a table of this plan.")
		ok
		_cG_ = "g" + _g_
		_oS_.Declare("Guest", _cG_)
		_oS_.Label(_cG_, "" + _a_[1])
		_oS_.SetData(_cG_, "table", _i_)
		_oS_.SetData(_cG_, "seat", 0)
		_oS_.SetData("t" + _i_, "given", _oS_.DataOf("t" + _i_, "given") + 1)
		_nSeat_ = _oS_.DataOf("t" + _i_, "given")
		if _nSeat_ <= _oS_.DataOf("t" + _i_, "seats")
			_cSt_ = "t" + _i_ + "s" + _nSeat_
			_oS_.SetData(_cG_, "seat", _nSeat_)
			_oS_.Assert("Taken", [ _cSt_ ])
			# the name beyond the seat, anchored so it reads outward: left
			# of the seat on the west of a ring, right of it on the east,
			# centred above or below
			_nNw_ = _StNameWidth(poFont, "" + _a_[1])
			_nSide_ = _oS_.DataOf(_cSt_, "side")
			_nNx_ = _oS_.DataOf(_cSt_, "nx")
			if _nSide_ > 0.3   _nNx_ += _nNw_ / 2  ok
			if _nSide_ < -0.3  _nNx_ -= _nNw_ / 2  ok
			_oS_.SetData(_cG_, "nx", _nNx_)
			_oS_.SetData(_cG_, "ny", _oS_.DataOf(_cSt_, "ny"))
			_oS_.SetData(_cG_, "nw", _nNw_)
		else
			_oS_.Assert("Seatless", [ _cG_ ])
			_oS_.Assert("Overbooked", [ "t" + _i_ ])
			_acLost_ + ("" + _a_[1])
			# a name with no seat has no place: it is written in the line
			_oS_.SetData(_cG_, "nx", 0)
			_oS_.SetData(_cG_, "ny", 0)
			_oS_.SetData(_cG_, "nw", 0)
		ok
	next
	# a guest seated twice, marked on every listing
	for _g_ = 1 to _nG_
		for _h_ = 1 to _nG_
			if _g_ = _h_  loop  ok
			if StzLower(ring_trim("" + paGuests[_g_][1])) = StzLower(ring_trim("" + paGuests[_h_][1]))
				_oS_.Assert("Doubled", [ "g" + _g_ ])
				exit
			ok
		next
	next
	# the line of those who found no seat
	if len(_acLost_) > 0
		_nH_ += 34
		_oS_.Declare("Unseated", "un")
		_oS_.Label("un", "Not seated: " + StzJoinWith(_acLost_, ", "))
		_oS_.SetData("un", "x", StzSeatingWidth() / 2)
		_oS_.SetData("un", "y", _nH_ - 24)
		_oS_.SetData("un", "w", _StNameWidth(poFont, "Not seated: " + StzJoinWith(_acLost_, ", ")) + 8)
	ok

	# THE PAIRS KEPT APART, by the names the host used
	_nP_ = len(paApart)
	for _p_ = 1 to _nP_
		if len(paApart[_p_]) < 2
			stzraise("StzSeatingFromTables: a pair to keep apart is two names.")
		ok
		_cA_ = _StGuestNamed(_oS_, paGuests, paApart[_p_][1])
		_cB_ = _StGuestNamed(_oS_, paGuests, paApart[_p_][2])
		if _cA_ = "" or _cB_ = ""
			stzraise("StzSeatingFromTables: the pair '" + paApart[_p_][1] + "' and '" + paApart[_p_][2] +
				"' names someone who is not a guest of this plan.")
		ok
		if _cA_ = _cB_
			stzraise("StzSeatingFromTables: '" + paApart[_p_][1] + "' cannot be kept apart from themself.")
		ok
		_oS_.Define("p" + _p_, "Apart", [ _cA_, _cB_ ])
		_oS_.Label("p" + _p_, "")
		if _oS_.DataOf(_cA_, "table") = _oS_.DataOf(_cB_, "table")
			_oS_.Assert("Clashing", [ _cA_ ])
			_oS_.Assert("Clashing", [ _cB_ ])
		ok
	next

	_oS_.SetData("t1", "paperw", StzSeatingWidth())
	_oS_.SetData("t1", "paperh", _nH_)
	return _oS_

# how far a table reaches from its centre, names included: [ x, y ] in metres
func _StReachOf(paT)
	_cK_ = StzLower(ring_trim("" + paT[2]))
	if _cK_ = "round"
		_nR_ = StzSeatingRadiusFor(paT[3]) + StzSeatingNameGap() + 0.35
		return [ _nR_ + 0.4, _nR_ ]
	ok
	_nUp_ = ceil(paT[3] / 2)
	return [ (0.6 * _nUp_ + 0.3) / 2 + 0.5, 0.45 + StzSeatingNameGap() + 0.25 ]

# do two tables' seats meet? Their seat reaches, added, against the
# distance between their centres
func _StCollide(paA, paB, paRa, paRb)
	_nDx_ = paA[4] - paB[4]
	_nDy_ = paA[5] - paB[5]
	_nD_ = sqrt(_nDx_ * _nDx_ + _nDy_ * _nDy_)
	return _nD_ < _StSeatReach(paA) + _StSeatReach(paB)

func _StSeatReach(paT)
	_cK_ = StzLower(ring_trim("" + paT[2]))
	if _cK_ = "round"
		return StzSeatingRadiusFor(paT[3]) + StzSeatingSeatGap() + StzSeatingSeatRadius()
	ok
	_nUp_ = ceil(paT[3] / 2)
	return (0.6 * _nUp_ + 0.3) / 2

func _StSeat(poS, pcT, pnK, pnX, pnY, pnNx, pnNy, pnSide, pnK2)
	_c_ = pcT + "s" + pnK
	poS.Declare("Seat", _c_)
	poS.Label(_c_, "")
	poS.SetData(_c_, "index", pnK)
	poS.SetData(_c_, "x", pnX)
	poS.SetData(_c_, "y", pnY)
	poS.SetData(_c_, "r", StzSeatingSeatRadius() * pnK2)
	poS.SetData(_c_, "nx", pnNx)
	poS.SetData(_c_, "ny", pnNy)
	poS.SetData(_c_, "side", pnSide)

func _StTableIndex(paTables, pcName)
	_c_ = StzLower(ring_trim("" + pcName))
	for _i_ = 1 to len(paTables)
		if StzLower(ring_trim("" + paTables[_i_][1])) = _c_  return _i_  ok
	next
	return 0

# the FIRST listing of a name -- a name listed twice is the second rule's
func _StGuestNamed(poS, paGuests, pcName)
	_c_ = StzLower(ring_trim("" + pcName))
	for _g_ = 1 to len(paGuests)
		if StzLower(ring_trim("" + paGuests[_g_][1])) = _c_  return "g" + _g_  ok
	next
	return ""

func _StNameWidth(poFont, pcText)
	if isObject(poFont)  return poFont.WidthOf(pcText, 11) + 6  ok
	return StzLen(pcText) * 6.2 + 6

func StzSeatingPaperOf(poSubstance)
	return [ poSubstance.DataOf("t1", "paperw"), poSubstance.DataOf("t1", "paperh") ]

#---------------------------------------------------------------------#
#  THE STYLE -- no constraint, no unknown, every position a datum      #
#---------------------------------------------------------------------#

func StzSeatingStyle(pnW, pnH)
	_o_ = new stzMathStyle()
	_o_.SetCanvas(pnW, pnH)
	_o_.SetMargin(10)
	# A TABLE: a disc or a slab in a light tint of the primary colour,
	# its name inside
	_o_.ForAllWhere("Table t", "Round(t)", [
		[ :shape, "t.top", :circle, [ :cx = "t.cx", :cy = "t.cy", :r = "t.r",
		                              :fill = [ :alpha, "primary", 0.15 ], :stroke = "primary", :strokeWidth = 1.5 ] ],
		[ :shape, "t.text", :text, [ :cx = "t.cx", :cy = "t.cy", :size = 13, :fill = [ :on, "paper" ] ] ],
		[ :layer, "t.text", :above, "t.top" ] ])
	_o_.ForAllWhere("Table t", "Long(t)", [
		[ :shape, "t.top", :rect, [ :cx = "t.cx", :cy = "t.cy", :w = "t.w", :h = "t.h",
		                            :fill = [ :alpha, "primary", 0.15 ], :stroke = "primary", :strokeWidth = 1.5 ] ],
		[ :shape, "t.text", :text, [ :cx = "t.cx", :cy = "t.cy", :size = 13, :fill = [ :on, "paper" ] ] ],
		[ :layer, "t.text", :above, "t.top" ] ])
	# A SEAT: a small ring, filled when somebody sits in it
	_o_.ForAll("Seat s", [
		[ :shape, "s.icon", :circle, [ :cx = "s.x", :cy = "s.y", :r = "s.r",
		                               :fill = "background", :stroke = "neutral", :strokeWidth = 1.2 ] ] ])
	_o_.ForAllWhere("Seat s", "Taken(s)", [
		[ :delete, "s.icon" ],
		[ :shape, "s.icon", :circle, [ :cx = "s.x", :cy = "s.y", :r = "s.r",
		                               :fill = "primary", :stroke = "primary", :strokeWidth = 1.2 ] ] ])
	# A GUEST: the name beyond the seat
	_o_.ForAll("Guest g", [
		[ :shape, "g.text", :text, [ :cx = "g.nx", :cy = "g.ny", :size = 11, :fill = [ :on, "paper" ] ] ] ])
	# A FAULT IS DRAWN: a name seated twice, or one of a pair kept apart
	# and together, on a plate of the fault's colour; a table overbooked
	# or standing into another, rimmed in it; the seatless named beneath
	_o_.ForAllWhere("Guest g", "Doubled(g)", [
		[ :delete, "g.text" ],
		[ :shape, "g.plate", :rect, [ :cx = "g.nx", :cy = "g.ny", :w = "g.nw", :h = 16,
		                              :fill = "danger", :stroke = "danger", :strokeWidth = 1 ] ],
		[ :shape, "g.text", :text, [ :cx = "g.nx", :cy = "g.ny", :size = 11, :fill = [ :on, "g.plate" ] ] ],
		[ :layer, "g.text", :above, "g.plate" ] ])
	_o_.ForAllWhere("Guest g", "Clashing(g)", [
		[ :delete, "g.text" ],
		[ :shape, "g.plate", :rect, [ :cx = "g.nx", :cy = "g.ny", :w = "g.nw", :h = 16,
		                              :fill = "danger", :stroke = "danger", :strokeWidth = 1 ] ],
		[ :shape, "g.text", :text, [ :cx = "g.nx", :cy = "g.ny", :size = 11, :fill = [ :on, "g.plate" ] ] ],
		[ :layer, "g.text", :above, "g.plate" ] ])
	_o_.ForAllWhere("Guest g", "Seatless(g)", [
		[ :delete, "g.text" ] ])
	_o_.ForAllWhere("Table t", "Overbooked(t)", [
		[ :delete, "t.top" ],
		[ :shape, "t.top", :circle, [ :cx = "t.cx", :cy = "t.cy", :r = "t.r",
		                              :fill = [ :alpha, "danger", 0.15 ], :stroke = "danger", :strokeWidth = 2 ] ] ])
	_o_.ForAllWhere("Table t", "Colliding(t)", [
		[ :delete, "t.top" ],
		[ :shape, "t.top", :circle, [ :cx = "t.cx", :cy = "t.cy", :r = "t.r",
		                              :fill = [ :alpha, "danger", 0.15 ], :stroke = "danger", :strokeWidth = 2 ] ] ])
	_o_.ForAll("Unseated u", [
		[ :shape, "u.plate", :rect, [ :cx = "u.x", :cy = "u.y", :w = "u.w", :h = 18,
		                              :fill = "danger", :stroke = "danger", :strokeWidth = 1 ] ],
		[ :shape, "u.text", :text, [ :cx = "u.x", :cy = "u.y", :size = 11, :fill = [ :on, "u.plate" ] ] ],
		[ :layer, "u.text", :above, "u.plate" ] ])
	return _o_

# the whole picture in one call
func StzSeatingDiagram(poFont, paTables, paGuests, paApart)
	_oS_ = StzSeatingFromTablesXT(poFont, paTables, paGuests, paApart)
	_aP_ = StzSeatingPaperOf(_oS_)
	_o_ = new stzMathDiagram(StzSeatingDomain(), _oS_, StzSeatingStyle(_aP_[1], _aP_[2]))
	if isObject(poFont)  _o_.SetFont(poFont, 11)  ok
	return _o_

#---------------------------------------------------------------------#
#  THE RULES, INTO THE ONE GATE -- every one about the plan            #
#---------------------------------------------------------------------#

func _StIsSeating(poDg)
	if NOT isObject(poDg)  return FALSE  ok
	if StzLower(classname(poDg)) != "stzmathdiagram"  return FALSE  ok
	return StzLower("" + poDg.Substance().DomainQ().Name_()) = "seating"

func _StScope(poDg, pcType, pcPrefix)
	_r_ = []
	if NOT _StIsSeating(poDg)  return _r_  ok
	_ac_ = poDg.Substance().ObjectsOfType(pcType)
	for _i_ = 1 to len(_ac_)  _r_ + (pcPrefix + _ac_[_i_])  next
	return _r_

func _StCounter(poDg, pcPrefix)
	_r_ = []
	if NOT isObject(poDg) or _StIsSeating(poDg)  return _r_  ok
	if StzLower(classname(poDg)) != "stzmathdiagram"  return _r_  ok
	_ac_ = poDg.Substance().ObjectNames()
	for _i_ = 1 to len(_ac_)  _r_ + (pcPrefix + _ac_[_i_])  next
	return _r_

func _StName(poS, pcObj)
	_c_ = poS.LabelOf(pcObj)
	if _c_ = ""  _c_ = pcObj  ok
	return _c_

func StzSeatingRuleSet()
	_ao_ = []

	_o1_ = StzPlasticRule("table_not_overbooked")
	_o1_.SetClaim("no table is given more guests than it has seats")
	_o1_.SetOrder(63)
	_o1_.SetReads([ "substance" ])
	_o1_.SetScope(func(oDg) { return _StScope(oDg, "Table", "table:") })
	_o1_.SetCounter(func(oDg) { return _StCounter(oDg, "table:") })
	_o1_.SetClaimCheck(func(oDg, cSub) {
		_cT_ = StzStringSection(cSub, 7, len(cSub))
		_oS_ = oDg.Substance()
		_nS_ = _oS_.DataOf(_cT_, "seats")
		_nG_ = _oS_.DataOf(_cT_, "given")
		if _nG_ > _nS_
			_acL_ = []
			_ag_ = _oS_.ObjectsOfType("Guest")
			for _i_ = 1 to len(_ag_)
				if "t" + _oS_.DataOf(_ag_[_i_], "table") = _cT_ and _oS_.Holds("Seatless", [ _ag_[_i_] ])
					_acL_ + ("'" + _StName(_oS_, _ag_[_i_]) + "'")
				ok
			next
			return [ FALSE, "'" + _StName(_oS_, _cT_) + "' seats " + _nS_ + " and was given " + _nG_ +
				" -- " + StzJoinWith(_acL_, ", ") + " found no seat" ]
		ok
		return [ TRUE, "" ]
	})
	_ao_ + _o1_

	_o2_ = StzPlasticRule("a_guest_sits_once")
	_o2_.SetClaim("no name is seated at two tables")
	_o2_.SetOrder(64)
	_o2_.SetReads([ "substance" ])
	_o2_.SetScope(func(oDg) { return _StScope(oDg, "Guest", "guest:") })
	_o2_.SetCounter(func(oDg) { return _StCounter(oDg, "guest:") })
	_o2_.SetClaimCheck(func(oDg, cSub) {
		_cG_ = StzStringSection(cSub, 7, len(cSub))
		_oS_ = oDg.Substance()
		_cN_ = StzLower(ring_trim(_oS_.LabelOf(_cG_)))
		_ag_ = _oS_.ObjectsOfType("Guest")
		for _i_ = 1 to len(_ag_)
			if _ag_[_i_] = _cG_  loop  ok
			if StzLower(ring_trim(_oS_.LabelOf(_ag_[_i_]))) = _cN_
				return [ FALSE, "'" + _StName(_oS_, _cG_) + "' is seated at '" +
					_StName(_oS_, "t" + _oS_.DataOf(_cG_, "table")) + "' and again at '" +
					_StName(_oS_, "t" + _oS_.DataOf(_ag_[_i_], "table")) + "' -- one guest, two seats" ]
			ok
		next
		return [ TRUE, "" ]
	})
	_ao_ + _o2_

	_o3_ = StzPlasticRule("kept_apart_are_apart")
	_o3_.SetClaim("two guests the host keeps apart do not share a table")
	_o3_.SetOrder(65)
	_o3_.SetReads([ "substance" ])
	_o3_.SetScope(func(oDg) { return _StScope(oDg, "Apart", "apart:") })
	_o3_.SetCounter(func(oDg) { return _StCounter(oDg, "apart:") })
	_o3_.SetClaimCheck(func(oDg, cSub) {
		_cP_ = StzStringSection(cSub, 7, len(cSub))
		_oS_ = oDg.Substance()
		_aD_ = _oS_.Definitions()
		for _i_ = 1 to len(_aD_)
			if _aD_[_i_][1] != _cP_  loop  ok
			_cA_ = "" + _aD_[_i_][3][1]
			_cB_ = "" + _aD_[_i_][3][2]
			if _oS_.DataOf(_cA_, "table") = _oS_.DataOf(_cB_, "table")
				return [ FALSE, "'" + _StName(_oS_, _cA_) + "' and '" + _StName(_oS_, _cB_) +
					"' are to be kept apart and sit together at '" +
					_StName(_oS_, "t" + _oS_.DataOf(_cA_, "table")) + "'" ]
			ok
			return [ TRUE, "" ]
		next
		return [ TRUE, "" ]
	})
	_ao_ + _o3_

	_o4_ = StzPlasticRule("tables_stand_clear")
	_o4_.SetClaim("no two tables' seats meet")
	_o4_.SetOrder(66)
	_o4_.SetReads([ "substance" ])
	_o4_.SetScope(func(oDg) { return _StScope(oDg, "Table", "table:") })
	_o4_.SetCounter(func(oDg) { return _StCounter(oDg, "table:") })
	_o4_.SetClaimCheck(func(oDg, cSub) {
		_cT_ = StzStringSection(cSub, 7, len(cSub))
		_oS_ = oDg.Substance()
		_at_ = _oS_.ObjectsOfType("Table")
		for _i_ = 1 to len(_at_)
			_cO_ = _at_[_i_]
			if _cO_ = _cT_  loop  ok
			_nDx_ = _oS_.DataOf(_cT_, "mx") - _oS_.DataOf(_cO_, "mx")
			_nDy_ = _oS_.DataOf(_cT_, "my") - _oS_.DataOf(_cO_, "my")
			_nD_ = sqrt(_nDx_ * _nDx_ + _nDy_ * _nDy_)
			_nNeed_ = _oS_.DataOf(_cT_, "reach") + _oS_.DataOf(_cO_, "reach")
			if _nD_ < _nNeed_
				decimals(1)
				_cMsg_ = "'" + _StName(_oS_, _cT_) + "' and '" + _StName(_oS_, _cO_) + "' stand " + _nD_ +
					" m apart and their seats need " + _nNeed_ + " m"
				decimals(2)
				return [ FALSE, _cMsg_ ]
			ok
		next
		return [ TRUE, "" ]
	})
	_ao_ + _o4_

	return _ao_
