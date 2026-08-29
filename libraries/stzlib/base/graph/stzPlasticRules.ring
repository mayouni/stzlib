#==============================================================#
#  STZPLASTICRULES -- this plane's visual contract, declared    #
#==============================================================#

/*--- The rules the pictures are actually drawn by, each with the scope
	it governs and the scope it must not.

	These are not new rules. Every one is already enforced somewhere in
	stzDiagram, stzGraphCanvas or graph_layout.zig, and most were minted
	by a mark on a printed picture. What is new is that each now STATES
	the set of subjects it applies to, separately from what it asserts
	about them -- which is the half that had no tests and where every
	scope defect of this plane has lived.

	READING THE SUBJECT KEYS. A subject is a string that names one thing
	in one picture: "node:api", "edge:c>p", "pair:pay|store", "paper".
	Two rules governing the same string is exactly the CONTESTED case the
	governor looks for, so the spelling has to be shared and stable --
	hence _NodeKey / _EdgeKey rather than each rule inventing its own.
*/

# IS THIS NODE THE REFUSED SIDE OF A YES/NO FORK?
#
# The happy-path rule steps the negative branch off the main line ON
# PURPOSE, so such a node is DELIBERATELY not on its neighbour's line.
# Without this, leaf_follows_its_neighbour convicts it of the very bend
# the other rule just created -- which is not a picture defect, it is two
# rules reaching for one subject with nothing said about which wins.
#
# The governance found it that way: as a failing picture, because the
# precedence had not been declared. Declaring it is the fix; this
# predicate is what makes the boundary sayable.
func _PlIsRefusedBranch(poDg, pcId)
	_k_ = StzLower("" + pcId)
	_a_ = poDg.Edges()
	_n_ = len(_a_)
	for _i_ = 1 to _n_
		if StzLower("" + _a_[_i_][:to]) != _k_  loop  ok
		if NOT poDg._IsNegative("" + _a_[_i_][:label])  loop  ok
		# ...and its source really does offer an affirmative alternative
		_src_ = StzLower("" + _a_[_i_][:from])
		for _j_ = 1 to _n_
			if StzLower("" + _a_[_j_][:from]) != _src_  loop  ok
			if poDg._IsAffirmative("" + _a_[_j_][:label])  return 1  ok
		next
	next
	return 0

func _PlKeyNode(pcId)   return "node:" + StzLower("" + pcId)
func _PlKeyEdge(pcF, pcT)
	return "edge:" + StzLower("" + pcF) + ">" + StzLower("" + pcT)

# THE CROSS AXIS, and every rule below needs it. A left-to-right picture
# stacks its ranks along x and spreads each rank along y; a top-down one
# does the opposite.
#
# THIS FUNCTION COMMITTED THIS FILE'S OWN DEFECT ON ITS FIRST RUN, and it
# is left documented rather than quietly corrected. It asked
#
#     if _c_ = "lr" or _c_ = "rl"  return 2  ok
#     return 1
#
# and stzDiagram.Layout() answers "lefttoright". So the test never matched,
# the function fell through to its default, and six rules measured every
# distance along the RANK axis while believing it was the cross axis. The
# output was not an error: it was six confident findings, each naming a
# real node and quoting an offset to two decimal places -- 307.35px -- and
# every one of them false.
#
# That is the whole thesis of this layer, demonstrated by the layer: a
# scope predicate that never matches does not fail loudly. It selects the
# wrong subjects and judges them with total confidence, and the only clue
# is that the numbers are too large to be plausible.
#
# So it does two things now. It accepts the spellings the library actually
# uses, and where it CANNOT tell, it returns 0 -- and every rule below
# abstains on 0 rather than guessing. A rule that cannot establish its own
# frame of reference has nothing to say, and saying nothing is a verdict a
# reader can act on where a wrong axis is not.
func _PlCrossAxis(poDg)
	_c_ = StzLower("" + poDg.Layout())
	if _c_ = "lr" or _c_ = "rl" or
	   StzFindFirst("lefttoright", _c_) > 0 or
	   StzFindFirst("righttoleft", _c_) > 0  return 2  ok
	if _c_ = "tb" or _c_ = "bt" or
	   StzFindFirst("topdown", _c_) > 0 or
	   StzFindFirst("toptobottom", _c_) > 0 or
	   StzFindFirst("bottomup", _c_) > 0 or
	   StzFindFirst("bottomtotop", _c_) > 0  return 1  ok
	return 0

func _PlRankAxis(poDg)
	_x_ = _PlCrossAxis(poDg)
	if _x_ = 0  return 0  ok
	if _x_ = 2  return 1  ok
	return 2

# centre of a node as drawn, on one axis, or -1000000 when it is not drawn
func _PlCentre(poDg, pcId, nAxis)
	_a_ = poDg.RenderNodeRects()
	_n_ = len(_a_)
	_k_ = StzLower("" + pcId)
	for _i_ = 1 to _n_
		if StzLower("" + _a_[_i_][5]) != _k_  loop  ok
		if nAxis = 1  return _a_[_i_][1] + _a_[_i_][3] / 2  ok
		return _a_[_i_][2] + _a_[_i_][4] / 2
	next
	return -1000000

# every node id this picture drew
func _PlDrawnIds(poDg)
	_a_ = poDg.RenderNodeRects()
	_r_ = []
	_n_ = len(_a_)
	for _i_ = 1 to _n_  _r_ + StzLower("" + _a_[_i_][5])  next
	return _r_

# the neighbours of a node, both directions, never itself
func _PlNeighbours(poDg, pcId)
	_k_ = StzLower("" + pcId)
	_r_ = []
	_a_ = poDg.Edges()
	_n_ = len(_a_)
	for _i_ = 1 to _n_
		_f_ = StzLower("" + _a_[_i_][:from])
		_t_ = StzLower("" + _a_[_i_][:to])
		if _f_ = _t_  loop  ok
		if _f_ = _k_  _r_ + _t_  ok
		if _t_ = _k_  _r_ + _f_  ok
	next
	return _r_

# nodes sharing a rank with this one -- same rank-axis coordinate, drawn
func _PlRankPeers(poDg, pcId)
	_ax_ = _PlRankAxis(poDg)
	_me_ = _PlCentre(poDg, pcId, _ax_)
	_r_ = []
	if _me_ < -999999  return _r_  ok
	_a_ = _PlDrawnIds(poDg)
	_n_ = len(_a_)
	_k_ = StzLower("" + pcId)
	for _i_ = 1 to _n_
		if _a_[_i_] = _k_  loop  ok
		if fabs(_PlCentre(poDg, _a_[_i_], _ax_) - _me_) < 1  _r_ + _a_[_i_]  ok
	next
	return _r_

# the turn column of an ortho edge: the cross-axis coordinate of its
# first corner. -1000000 when the path has no corner to read.
func _PlTurnOf(poDg, pcF, pcT)
	_k_ = StzLower("" + pcF) + ">" + StzLower("" + pcT)
	_a_ = poDg.@aEdgePaths
	_n_ = len(_a_)
	for _i_ = 1 to _n_
		if StzLower("" + _a_[_i_][1]) != _k_  loop  ok
		_f_ = _a_[_i_][2]
		if len(_f_) < 6  return -1000000  ok
		if _PlCrossAxis(poDg) = 2  return _f_[3]  ok
		return _f_[4]
	next
	return -1000000

# how many genuine corners a drawn path turns
func _PlTurnsOf(poDg, pcF, pcT)
	_k_ = StzLower("" + pcF) + ">" + StzLower("" + pcT)
	_a_ = poDg.@aEdgePaths
	_n_ = len(_a_)
	for _i_ = 1 to _n_
		if StzLower("" + _a_[_i_][1]) != _k_  loop  ok
		_f_ = _a_[_i_][2]
		_t_ = 0
		for _j_ = 1 to len(_f_) - 5 step 2
			_dx1_ = _f_[_j_ + 2] - _f_[_j_]
			_dy1_ = _f_[_j_ + 3] - _f_[_j_ + 1]
			_dx2_ = _f_[_j_ + 4] - _f_[_j_ + 2]
			_dy2_ = _f_[_j_ + 5] - _f_[_j_ + 3]
			if fabs(_dx1_) + fabs(_dy1_) < 0.5  loop  ok
			if fabs(_dx2_) + fabs(_dy2_) < 0.5  loop  ok
			_h1_ = fabs(_dx1_) > fabs(_dy1_)
			_h2_ = fabs(_dx2_) > fabs(_dy2_)
			if _h1_ != _h2_  _t_++  ok
		next
		return _t_
	next
	return -1

#--------------------------------------------------------------#
#  THE RULE SET                                                 #
#--------------------------------------------------------------#

func StzPlasticRuleSet()
	_ao_ = []

	# --- A LEAF FOLLOWS THE THING IT HANGS FROM -----------------
	#
	# Minted 2026-08-29 from two marks. Its scope is the narrow one the
	# engine settled on after the first draft moved siblings too: a leaf
	# ALONE on its rank in hanging from its neighbour.
	_o1_ = StzPlasticRule("leaf_follows_its_neighbour")
	_o1_.SetClaim("a node with one neighbour and no rank peer stands on " +
		"the line that reaches it")
	_o1_.SetOrder(40)
	_o1_.SetReads([ "node.cross" ])
	_o1_.SetWrites([ "node.cross" ])
	_o1_.SetScope(func(oDg) {
		_r_ = []
		if _PlCrossAxis(oDg) = 0  return _r_  ok
		_ids_ = _PlDrawnIds(oDg)
		_n_ = len(_ids_)
		for _i_ = 1 to _n_
			_nb_ = _PlNeighbours(oDg, _ids_[_i_])
			if len(_nb_) != 1  loop  ok
			# ...and alone in hanging from it, or these are siblings
			_peers_ = _PlRankPeers(oDg, _ids_[_i_])
			_share_ = 0
			_np_ = len(_peers_)
			for _ip_ = 1 to _np_
				_pn_ = _PlNeighbours(oDg, _peers_[_ip_])
				_npn_ = len(_pn_)
				for _ipn_ = 1 to _npn_
					if _pn_[_ipn_] = _nb_[1]  _share_ = 1  exit  ok
				next
				if _share_  exit  ok
			next
			if _share_  loop  ok
			# ...and the refused branch of a yes/no fork is stepped
			# aside by the happy-path rule, which outranks this one
			if _PlIsRefusedBranch(oDg, _ids_[_i_])  loop  ok
			_r_ + _PlKeyNode(_ids_[_i_])
		next
		return _r_
	})
	_o1_.SetCounter(func(oDg) {
		# leaves that DO share their neighbour with a rank peer -- these
		# straddle, and pulling them onto the parent would collapse them
		# -- and the refused branch of a yes/no fork, which the happy
		# path steps aside deliberately
		_r_ = []
		if _PlCrossAxis(oDg) = 0  return _r_  ok
		_aRf_ = _PlDrawnIds(oDg)
		_nRf_ = len(_aRf_)
		for _iRf_ = 1 to _nRf_
			if _PlIsRefusedBranch(oDg, _aRf_[_iRf_])
				_r_ + _PlKeyNode(_aRf_[_iRf_])
			ok
		next
		_ids_ = _PlDrawnIds(oDg)
		_n_ = len(_ids_)
		for _i_ = 1 to _n_
			_nb_ = _PlNeighbours(oDg, _ids_[_i_])
			if len(_nb_) != 1  loop  ok
			_peers_ = _PlRankPeers(oDg, _ids_[_i_])
			_np_ = len(_peers_)
			for _ip_ = 1 to _np_
				_pn_ = _PlNeighbours(oDg, _peers_[_ip_])
				_npn_ = len(_pn_)
				for _ipn_ = 1 to _npn_
					if _pn_[_ipn_] = _nb_[1]
						_r_ + _PlKeyNode(_ids_[_i_])
						exit
					ok
				next
			next
		next
		return _r_
	})
	_o1_.SetClaimCheck(func(oDg, cSub) {
		_id_ = StzSubStr(cSub, 6, StzLen(cSub) - 5)
		_nb_ = _PlNeighbours(oDg, _id_)
		if len(_nb_) != 1  return [ 1, "" ]  ok
		_ax_ = _PlCrossAxis(oDg)
		_a_ = _PlCentre(oDg, _id_, _ax_)
		_b_ = _PlCentre(oDg, _nb_[1], _ax_)
		if _a_ < -999999 or _b_ < -999999  return [ 1, "" ]  ok
		if fabs(_a_ - _b_) < 1  return [ 1, "" ]  ok
		return [ 0, "it stands " + (fabs(_a_ - _b_)) +
			"px off " + _nb_[1] + ", so the one line between them bends " +
			"for nothing" ]
	})
	_ao_ + _o1_

	# --- SIBLINGS STRADDLE THEIR PARENT -- I7 -------------------
	_o2_ = StzPlasticRule("siblings_straddle_their_parent")
	_o2_.SetClaim("two children of one parent on one rank stand on " +
		"either side of it")
	_o2_.SetOrder(30)
	_o2_.SetReads([ "node.cross" ])
	_o2_.SetWrites([ "node.cross" ])
	_o2_.SetScope(func(oDg) {
		_r_ = []
		if _PlCrossAxis(oDg) = 0  return _r_  ok
		_ids_ = _PlDrawnIds(oDg)
		_n_ = len(_ids_)
		for _i_ = 1 to _n_
			_kids_ = []
			_a_ = oDg.Edges()
			_na_ = len(_a_)
			for _ia_ = 1 to _na_
				if StzLower("" + _a_[_ia_][:from]) != _ids_[_i_]  loop  ok
				_t_ = StzLower("" + _a_[_ia_][:to])
				if _t_ = _ids_[_i_]  loop  ok
				_kids_ + _t_
			next
			if len(_kids_) < 2  loop  ok
			_ax_ = _PlRankAxis(oDg)
			if fabs(_PlCentre(oDg, _kids_[1], _ax_) -
			        _PlCentre(oDg, _kids_[2], _ax_)) > 1  loop  ok
			_r_ + _PlKeyNode(_ids_[_i_])
		next
		return _r_
	})
	_o2_.SetCounter(func(oDg) {
		# a parent with exactly ONE child has nothing to straddle it
		_r_ = []
		_ids_ = _PlDrawnIds(oDg)
		_n_ = len(_ids_)
		for _i_ = 1 to _n_
			_k_ = 0
			_a_ = oDg.Edges()
			_na_ = len(_a_)
			for _ia_ = 1 to _na_
				if StzLower("" + _a_[_ia_][:from]) != _ids_[_i_]  loop  ok
				if StzLower("" + _a_[_ia_][:to]) = _ids_[_i_]  loop  ok
				_k_++
			next
			if _k_ = 1  _r_ + _PlKeyNode(_ids_[_i_])  ok
		next
		return _r_
	})
	_o2_.SetClaimCheck(func(oDg, cSub) {
		_id_ = StzSubStr(cSub, 6, StzLen(cSub) - 5)
		_kids_ = []
		_a_ = oDg.Edges()
		_na_ = len(_a_)
		for _ia_ = 1 to _na_
			if StzLower("" + _a_[_ia_][:from]) != _id_  loop  ok
			_t_ = StzLower("" + _a_[_ia_][:to])
			if _t_ = _id_  loop  ok
			_kids_ + _t_
		next
		if len(_kids_) < 2  return [ 1, "" ]  ok
		_ax_ = _PlCrossAxis(oDg)
		_p_ = _PlCentre(oDg, _id_, _ax_)
		_lo_ = 0  _hi_ = 0
		_nk_ = len(_kids_)
		for _ik_ = 1 to _nk_
			_c_ = _PlCentre(oDg, _kids_[_ik_], _ax_)
			if _c_ < _p_ - 0.5  _lo_++  ok
			if _c_ > _p_ + 0.5  _hi_++  ok
		next
		if _lo_ > 0 and _hi_ > 0  return [ 1, "" ]  ok
		return [ 0, "all " + _nk_ + " children sit on one side, which " +
			"says one of them continues the line and the others hang off it" ]
	})
	_ao_ + _o2_

	# --- A FAN LEAVES ON ONE STEM -------------------------------
	#
	# Minted 2026-08-29 from the mark on : Cart. Scope is deliberately the
	# NON-branching cell: the very defect was this rule's inverse being
	# applied to every labelled fan-out in the library.
	_o3_ = StzPlasticRule("a_fan_leaves_on_one_stem")
	_o3_.SetClaim("two lines leaving one plain cell turn at one column")
	_o3_.SetOrder(60)
	_o3_.SetReads([ "node.cross", "edge.channel" ])
	_o3_.SetWrites([ "edge.channel" ])
	_o3_.SetScope(func(oDg) {
		_r_ = []
		if _PlCrossAxis(oDg) = 0  return _r_  ok
		_ids_ = _PlDrawnIds(oDg)
		_n_ = len(_ids_)
		for _i_ = 1 to _n_
			if oDg._IsBranchCell(_ids_[_i_])  loop  ok
			_k_ = 0
			_a_ = oDg.Edges()
			_na_ = len(_a_)
			for _ia_ = 1 to _na_
				if StzLower("" + _a_[_ia_][:from]) != _ids_[_i_]  loop  ok
				if StzLower("" + _a_[_ia_][:to]) = _ids_[_i_]  loop  ok
				if _PlTurnOf(oDg, _ids_[_i_], _a_[_ia_][:to]) < -999999
					loop
				ok
				_k_++
			next
			if _k_ >= 2  _r_ + _PlKeyNode(_ids_[_i_])  ok
		next
		return _r_
	})
	_o3_.SetCounter(func(oDg) {
		# a BRANCH cell -- whose answers must each quit on their own
		_r_ = []
		_ids_ = _PlDrawnIds(oDg)
		_n_ = len(_ids_)
		for _i_ = 1 to _n_
			if NOT oDg._IsBranchCell(_ids_[_i_])  loop  ok
			_r_ + _PlKeyNode(_ids_[_i_])
		next
		return _r_
	})
	_o3_.SetClaimCheck(func(oDg, cSub) {
		_id_ = StzSubStr(cSub, 6, StzLen(cSub) - 5)
		_t_ = []
		_a_ = oDg.Edges()
		_na_ = len(_a_)
		for _ia_ = 1 to _na_
			if StzLower("" + _a_[_ia_][:from]) != _id_  loop  ok
			if StzLower("" + _a_[_ia_][:to]) = _id_  loop  ok
			_v_ = _PlTurnOf(oDg, _id_, _a_[_ia_][:to])
			if _v_ > -999999  _t_ + _v_  ok
		next
		if len(_t_) < 2  return [ 1, "" ]  ok
		_lo_ = _t_[1]  _hi_ = _t_[1]
		_nt_ = len(_t_)
		for _it_ = 2 to _nt_
			if _t_[_it_] < _lo_  _lo_ = _t_[_it_]  ok
			if _t_[_it_] > _hi_  _hi_ = _t_[_it_]  ok
		next
		if _hi_ - _lo_ < 1  return [ 1, "" ]  ok
		return [ 0, "its " + _nt_ + " lines turn across " + (_hi_ - _lo_) +
			"px of columns -- one origin drawn as several" ]
	})
	_ao_ + _o3_

	# --- AN ALIGNED EDGE DOES NOT BEND -- I4 --------------------
	#
	# The sharpest statable form of "a bend is a constraint": if the two
	# ends already share a cross-coordinate, every corner in between is
	# uncaused. This is the rule the two marked pictures broke.
	_o4_ = StzPlasticRule("an_aligned_edge_does_not_bend")
	_o4_.SetClaim("an edge whose ends share a column runs straight")
	_o4_.SetOrder(70)
	_o4_.SetReads([ "node.cross", "edge.channel" ])
	_o4_.SetWrites([])
	_o4_.SetScope(func(oDg) {
		_r_ = []
		_ax_ = _PlCrossAxis(oDg)
		if _ax_ = 0  return _r_  ok
		_a_ = oDg.Edges()
		_na_ = len(_a_)
		for _ia_ = 1 to _na_
			_f_ = StzLower("" + _a_[_ia_][:from])
			_t_ = StzLower("" + _a_[_ia_][:to])
			if _f_ = _t_  loop  ok
			if _PlTurnsOf(oDg, _f_, _t_) < 0  loop  ok
			_ca_ = _PlCentre(oDg, _f_, _ax_)
			_cb_ = _PlCentre(oDg, _t_, _ax_)
			if _ca_ < -999999 or _cb_ < -999999  loop  ok
			if fabs(_ca_ - _cb_) >= 1  loop  ok
			_r_ + _PlKeyEdge(_f_, _t_)
		next
		return _r_
	})
	_o4_.SetCounter(func(oDg) {
		# edges whose ends do NOT share a column: they must bend, and a
		# rule that convicted them would be the opposite defect
		_r_ = []
		_ax_ = _PlCrossAxis(oDg)
		if _ax_ = 0  return _r_  ok
		_a_ = oDg.Edges()
		_na_ = len(_a_)
		for _ia_ = 1 to _na_
			_f_ = StzLower("" + _a_[_ia_][:from])
			_t_ = StzLower("" + _a_[_ia_][:to])
			if _f_ = _t_  loop  ok
			_ca_ = _PlCentre(oDg, _f_, _ax_)
			_cb_ = _PlCentre(oDg, _t_, _ax_)
			if _ca_ < -999999 or _cb_ < -999999  loop  ok
			if fabs(_ca_ - _cb_) < 1  loop  ok
			_r_ + _PlKeyEdge(_f_, _t_)
		next
		return _r_
	})
	_o4_.SetClaimCheck(func(oDg, cSub) {
		_p_ = StzSplit(StzSubStr(cSub, 6, StzLen(cSub) - 5), ">")
		if len(_p_) != 2  return [ 1, "" ]  ok
		_n_ = _PlTurnsOf(oDg, _p_[1], _p_[2])
		if _n_ <= 0  return [ 1, "" ]  ok
		return [ 0, "its ends share a column and it still turns " + _n_ +
			" time(s) -- a bend a reader must find a reason for" ]
	})
	_ao_ + _o4_

	# --- A LABEL CLEARS ITS OWN BEND ----------------------------
	_o5_ = StzPlasticRule("a_label_clears_its_own_bend")
	_o5_.SetClaim("a label's plate covers no corner of the edge it names")
	_o5_.SetOrder(90)
	_o5_.SetReads([ "edge.channel", "label.spot" ])
	_o5_.SetWrites([ "label.spot" ])
	_o5_.SetScope(func(oDg) {
		_r_ = []
		_a_ = oDg.@aRenderLabels
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			if StzTrim("" + _a_[_i_][6]) = ""  loop  ok
			_r_ + ("label:" + StzLower("" + _a_[_i_][6]))
		next
		return _r_
	})
	_o5_.SetCounter(func(oDg) {
		# a picture drawn under :Middle puts the word ON its line by
		# design, so its labels are outside this rule entirely
		if oDg.@cLabelPlacement != "middle"  return []  ok
		_r_ = []
		_a_ = oDg.@aRenderLabels
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			if StzTrim("" + _a_[_i_][6]) = ""  loop  ok
			_r_ + ("label:" + StzLower("" + _a_[_i_][6]))
		next
		return _r_
	})
	_o5_.SetClaimCheck(func(oDg, cSub) {
		if oDg.@cLabelPlacement = "middle"  return [ 1, "" ]  ok
		_k_ = StzSubStr(cSub, 7, StzLen(cSub) - 6)
		_a_ = oDg.@aRenderLabels
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			if StzLower("" + _a_[_i_][6]) != _k_  loop  ok
			_L_ = _a_[_i_][2] - _a_[_i_][4] / 2
			_T_ = _a_[_i_][3] - _a_[_i_][5] / 2
			_R_ = _a_[_i_][2] + _a_[_i_][4] / 2
			_B_ = _a_[_i_][3] + _a_[_i_][5] / 2
			_p_ = oDg.@aEdgePaths
			_np_ = len(_p_)
			for _ip_ = 1 to _np_
				if StzLower("" + _p_[_ip_][1]) != _k_  loop  ok
				_f_ = _p_[_ip_][2]
				for _j_ = 3 to len(_f_) - 3 step 2
					if _f_[_j_] > _L_ and _f_[_j_] < _R_ and
					   _f_[_j_ + 1] > _T_ and _f_[_j_ + 1] < _B_
						return [ 0, "the plate for '" + _a_[_i_][1] +
							"' covers a corner of its own edge, so the " +
							"line appears to begin in mid-air" ]
					ok
				next
			next
		next
		return [ 1, "" ]
	})
	_ao_ + _o5_

	# --- EQUAL AIR -- I3 ----------------------------------------
	_o6_ = StzPlasticRule("the_paper_holds_equal_air")
	_o6_.SetClaim("the margin above equals the margin below, and left " +
		"equals right")
	_o6_.SetOrder(95)
	_o6_.SetReads([ "node.cross", "edge.channel", "label.spot" ])
	_o6_.SetWrites([ "paper.extent" ])
	_o6_.SetUniversal("every picture has a paper and every paper has " +
		"four margins, so there is no picture this rule could fail to " +
		"govern -- the boundary is absent because the claim is genuinely " +
		"universal, not because a predicate broke")
	_o6_.SetScope(func(oDg) {
		if len(oDg.RenderNodeRects()) = 0  return []  ok
		return [ "paper" ]
	})
	_o6_.SetCounter(func(oDg) {
		# a picture with nothing drawn has no air to balance
		if len(oDg.RenderNodeRects()) = 0  return [ "paper" ]  ok
		return []
	})
	_o6_.SetClaimCheck(func(oDg, cSub) {
		_a_ = oDg.RenderNodeRects()
		_n_ = len(_a_)
		if _n_ = 0  return [ 1, "" ]  ok
		_x0_ = _a_[1][1]  _y0_ = _a_[1][2]
		_x1_ = _a_[1][1] + _a_[1][3]
		_y1_ = _a_[1][2] + _a_[1][4]
		for _i_ = 2 to _n_
			if _a_[_i_][1] < _x0_  _x0_ = _a_[_i_][1]  ok
			if _a_[_i_][2] < _y0_  _y0_ = _a_[_i_][2]  ok
			if _a_[_i_][1] + _a_[_i_][3] > _x1_  _x1_ = _a_[_i_][1] + _a_[_i_][3]  ok
			if _a_[_i_][2] + _a_[_i_][4] > _y1_  _y1_ = _a_[_i_][2] + _a_[_i_][4]  ok
		next
		_W_ = oDg.LastCanvas().Width()
		_H_ = oDg.LastCanvas().Height()
		# GENEROUS ON PURPOSE. A glyph that writes its name underneath, a
		# self-loop, a lifeline -- all reach past the node box this reads,
		# so a tight tolerance here would convict correct pictures. It is
		# a gross-imbalance detector, not a placement law.
		_tolX_ = max([ 24, _W_ * 0.10 ])
		_tolY_ = max([ 24, _H_ * 0.10 ])
		if fabs(_x0_ - (_W_ - _x1_)) > _tolX_
			return [ 0, "left margin " + _x0_ + "px against right " +
				(_W_ - _x1_) + "px" ]
		ok
		if fabs(_y0_ - (_H_ - _y1_)) > _tolY_
			return [ 0, "top margin " + _y0_ + "px against bottom " +
				(_H_ - _y1_) + "px" ]
		ok
		return [ 1, "" ]
	})
	_ao_ + _o6_

	# --- THE HAPPY PATH HOLDS THE MAIN LINE ---------------------
	#
	# Declared here because it was NOT declared anywhere, and that is why
	# nothing caught it. The Principal ruled it months ago; it was built
	# as an early return inside _ApplySpineRows gated on a notation
	# profile, so it applied to BPMN and to nothing else, and a plain
	# diagram drew "fails -> Reject" down its spine with "passes ->
	# Accept" hanging off to the side for as long as the rule existed.
	#
	# The governance could not have found that: it governs rules that
	# declare themselves, and this one lived in a conditional. A rule
	# nobody declares is a rule nobody can check, which is the argument
	# for the whole layer stated by its own worst omission.
	_o7_ = StzPlasticRule("the_happy_path_holds_the_main_line")
	_o7_.SetClaim("where a cell's answers disagree in mood, the " +
		"affirmative one continues down the main line")
	_o7_.SetOrder(20)
	_o7_.SetReads([ "edge.label", "node.cross" ])
	_o7_.SetWrites([ "node.cross" ])
	_o7_.SetScope(func(oDg) {
		# the forks that actually say yes AND no -- self-scoping, so a
		# dependency graph with no mood is outside the rule rather than
		# compliant with it
		_r_ = []
		if _PlCrossAxis(oDg) = 0  return _r_  ok
		_ids_ = _PlDrawnIds(oDg)
		_n_ = len(_ids_)
		for _i_ = 1 to _n_
			_y_ = 0  _no_ = 0
			_a_ = oDg.Edges()
			_na_ = len(_a_)
			for _ia_ = 1 to _na_
				if StzLower("" + _a_[_ia_][:from]) != _ids_[_i_]  loop  ok
				if oDg._IsAffirmative("" + _a_[_ia_][:label])  _y_++  ok
				if oDg._IsNegative("" + _a_[_ia_][:label])  _no_++  ok
			next
			if _y_ > 0 and _no_ > 0  _r_ + _PlKeyNode(_ids_[_i_])  ok
		next
		return _r_
	})
	_o7_.SetCounter(func(oDg) {
		# a fork whose answers carry no mood -- the package diagram's
		# case, which says so in its own words: a dependency graph has no
		# happy path and claiming one would be a claim the model does
		# not make
		_r_ = []
		if _PlCrossAxis(oDg) = 0  return _r_  ok
		_ids_ = _PlDrawnIds(oDg)
		_n_ = len(_ids_)
		for _i_ = 1 to _n_
			_k_ = 0  _y_ = 0  _no_ = 0
			_a_ = oDg.Edges()
			_na_ = len(_a_)
			for _ia_ = 1 to _na_
				if StzLower("" + _a_[_ia_][:from]) != _ids_[_i_]  loop  ok
				if StzLower("" + _a_[_ia_][:to]) = _ids_[_i_]  loop  ok
				_k_++
				if oDg._IsAffirmative("" + _a_[_ia_][:label])  _y_++  ok
				if oDg._IsNegative("" + _a_[_ia_][:label])  _no_++  ok
			next
			if _k_ < 2  loop  ok
			if _y_ > 0 and _no_ > 0  loop  ok
			_r_ + _PlKeyNode(_ids_[_i_])
		next
		return _r_
	})
	_o7_.SetClaimCheck(func(oDg, cSub) {
		_id_ = StzSubStr(cSub, 6, StzLen(cSub) - 5)
		_ax_ = _PlCrossAxis(oDg)
		_me_ = _PlCentre(oDg, _id_, _ax_)
		if _me_ < -999999  return [ 1, "" ]  ok
		_yes_ = ""  _nos_ = []
		_a_ = oDg.Edges()
		_na_ = len(_a_)
		for _ia_ = 1 to _na_
			if StzLower("" + _a_[_ia_][:from]) != _id_  loop  ok
			if oDg._IsAffirmative("" + _a_[_ia_][:label])
				_yes_ = StzLower("" + _a_[_ia_][:to])
			ok
			if oDg._IsNegative("" + _a_[_ia_][:label])
				_nos_ + StzLower("" + _a_[_ia_][:to])
			ok
		next
		if _yes_ = ""  return [ 1, "" ]  ok
		_cy_ = _PlCentre(oDg, _yes_, _ax_)
		if _cy_ < -999999  return [ 1, "" ]  ok
		if fabs(_cy_ - _me_) >= 1
			return [ 0, "the affirmative answer '" + _yes_ + "' stands " +
				(fabs(_cy_ - _me_)) + "px off the line, so the picture " +
				"puts the refusal where the reader looks first" ]
		ok
		# ...and a refusal must NOT be on it
		_nn_ = len(_nos_)
		for _in_ = 1 to _nn_
			_cn_ = _PlCentre(oDg, _nos_[_in_], _ax_)
			if _cn_ < -999999  loop  ok
			if fabs(_cn_ - _me_) < 1
				return [ 0, "the refusal '" + _nos_[_in_] + "' shares " +
					"the main line with the affirmative answer, so " +
					"nothing in the geometry says which way is forward" ]
			ok
		next
		return [ 1, "" ]
	})
	_ao_ + _o7_

	return _ao_

# THE GOVERNANCE, with the precedences this plane has actually settled.
#
# Both declared precedences were paid for. The first is the engine's
# ordering: siblingStraddle runs before followLeaves, so a child that is
# BOTH a lone leaf and a straddling sibling is straddled, never pulled.
# The second is the mark of 2026-08-29: a fan shares a stem unless its
# source is a branch cell, in which case the answers part.
func StzPlasticGovernanceOf(pcName)
	_g_ = StzPlasticGovernance(pcName)
	_ao_ = StzPlasticRuleSet()
	_n_ = len(_ao_)
	for _i_ = 1 to _n_  _g_.AddRule(_ao_[_i_])  next
	_g_.DeclarePrecedence("siblings_straddle_their_parent",
		"leaf_follows_its_neighbour",
		"a child that is both a lone leaf and one of two siblings is " +
		"straddled, never pulled -- collapsing two siblings onto their " +
		"parent's column would deny I7, and the engine runs " +
		"siblingStraddle before followLeaves to say so")
	_g_.DeclarePrecedence("the_happy_path_holds_the_main_line",
		"leaf_follows_its_neighbour",
		"the refused branch of a yes/no fork is stepped off the main " +
		"line on purpose, so it is not a leaf that failed to align -- " +
		"the author said which way is forward and the picture obeys them")
	_g_.DeclarePrecedence("a_fan_leaves_on_one_stem",
		"an_aligned_edge_does_not_bend",
		"a fan's members share a stem and then part, so the second and " +
		"later members turn twice by construction -- the stem is the " +
		"constraint that the bend rule asks for")
	return _g_
