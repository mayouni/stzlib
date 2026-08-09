#---------------------------------------------------------------------------#
#  STZGRAPHCANVAS -- a graph draws itself, and what it looks like is        #
#  COMPUTED FROM WHAT IT IS (GG2 of SOFTANZA_GRAPH_PLANE_PLAN.md).          #
#---------------------------------------------------------------------------#
#
#     oG = new stzGraph("supply")
#     oG.AddNodes([ "mine", "smelt", "chip", "car" ])
#     oG.AddEdge("mine", "smelt")   ...
#
#     oC = oG.ToCanvasQ([ :Layout = :Hierarchical,
#                         :SizeBy = :Impact,
#                         :ColorBy = :Impact ])
#     oC.ToPNG("supply.png")        # and ToSVG() with no GPU at all
#
# THE POINT, and it is the whole reason this class exists: SizeBy and
# ColorBy bind to properties the graph COMPUTES ABOUT ITSELF, not to
# attributes somebody set by hand. :Impact is "how many nodes fail if this
# one does" -- a reachability count. :Depth is the layer. :Degree is the
# edge count. A node is big because it is important, and it is important
# because of the graph's shape.
#
# That binding is what no shader graph can do. A shader graph's nodes are
# SYNTAX: an authoring UI consumed at compile time, which your program can
# never interrogate. Here the graph is a computational object, so the
# picture is a QUESTION ANSWERED about it.
#
# Two layouts, both from the GG1 tier:
#   :Hierarchical  longest-path layers, then the engine's barycentre sweep
#                  (best-keeping, so it never makes a picture worse)
#   :Force         Fruchterman-Reingold, seeded and deterministic
#
# Both come back in RAW coordinates, so this class normalises them into the
# canvas -- fitting the bounding box with a margin. Without that a caller
# gets numbers in whatever range the layout happened to produce, which is
# not a picture.
#
# It answers an stzCanvas, so it inherits BOTH output tiers free: ToSVG()
# with no device anywhere, ToPNG() through one. Same trick plots and org
# charts used in GR6.

func StzGraphCanvasQ(poGraph, paOptions)
	return new stzGraphCanvas(poGraph, paOptions)

# Named so it reads as a question about the graph. Values are computed on
# demand -- nothing is stored on the nodes, so a graph that changes gives a
# different picture without anything being invalidated by hand.
func StzGraphMetric(poGraph, cWhich)
	_ids_ = poGraph.NodesIds()
	_n_ = len(_ids_)
	_out_ = []

	switch StzLower("" + cWhich)
	on "impact"
		# how many OTHER nodes are reachable from this one -- "if this
		# fails, how much fails with it"
		for _i_ = 1 to _n_
			_c_ = 0
			for _j_ = 1 to _n_
				if _i_ != _j_ and poGraph.PathExists(_ids_[_i_], _ids_[_j_])
					_c_++
				ok
			next
			_out_ + _c_
		next
	on "depth"
		_out_ = _StzGraphLayers(poGraph)
	on "degree"
		_d_ = _StzGraphDegrees(poGraph)
		for _i_ = 1 to _n_  _out_ + (_d_[1][_i_] + _d_[2][_i_])  next
	on "indegree"
		_out_ = _StzGraphDegrees(poGraph)[1]
	on "outdegree"
		_out_ = _StzGraphDegrees(poGraph)[2]
	other
		StzRaise("stzGraphCanvas: I do not compute '" + cWhich + "'. " +
			"Use :Impact, :Depth, :Degree, :InDegree or :OutDegree.")
	off
	return _out_

func _StzGraphDegrees(poGraph)
	_ids_ = poGraph.NodesIds()
	_n_ = len(_ids_)
	_idx_ = []
	for _i_ = 1 to _n_  _idx_ + [ _ids_[_i_], _i_ ]  next
	_in_ = []  _out_ = []
	for _i_ = 1 to _n_  _in_ + 0  _out_ + 0  next
	_aE_ = poGraph.Edges()
	_ne_ = len(_aE_)
	for _e_ = 1 to _ne_
		_u_ = _StzIndexOfId(_idx_, _aE_[_e_][:from])
		_v_ = _StzIndexOfId(_idx_, _aE_[_e_][:to])
		if _u_ > 0  _out_[_u_]++  ok
		if _v_ > 0  _in_[_v_]++   ok
	next
	return [ _in_, _out_ ]

func _StzIndexOfId(paIdx, cId)
	_n_ = len(paIdx)
	for _i_ = 1 to _n_
		if paIdx[_i_][1] = cId  return paIdx[_i_][2]  ok
	next
	return 0

# Longest-path layering, done here in Ring because a graph small enough to
# LOOK at is small enough to layer sequentially. The GPU tier exists for
# the 10,000-node case and is reached through the layout, not through this.
func _StzGraphLayers(poGraph)
	_ids_ = poGraph.NodesIds()
	_n_ = len(_ids_)
	_idx_ = []
	for _i_ = 1 to _n_  _idx_ + [ _ids_[_i_], _i_ ]  next
	_aE_ = poGraph.Edges()
	_ne_ = len(_aE_)
	_eu_ = []  _ev_ = []
	for _e_ = 1 to _ne_
		_u_ = _StzIndexOfId(_idx_, _aE_[_e_][:from])
		_v_ = _StzIndexOfId(_idx_, _aE_[_e_][:to])
		if _u_ > 0 and _v_ > 0
			_eu_ + _u_
			_ev_ + _v_
		ok
	next
	_lay_ = []
	for _i_ = 1 to _n_  _lay_ + 0  next
	# relax until stable; a cycle would never settle, so the round count is
	# capped at n and the result is still a usable (if arbitrary) layering
	for _r_ = 1 to _n_
		_moved_ = FALSE
		for _e_ = 1 to len(_eu_)
			if _lay_[_ev_[_e_]] < _lay_[_eu_[_e_]] + 1
				_lay_[_ev_[_e_]] = _lay_[_eu_[_e_]] + 1
				_moved_ = TRUE
			ok
		next
		if NOT _moved_  exit  ok
	next
	return _lay_

class stzGraphCanvas from stzObject

	@oGraph = NULL
	@aOpt = []
	@nW = 1000
	@nH = 620
	@aX = []
	@aY = []
	@aIds = []
	@aSize = []
	@aColor = []

	def init(poGraph, paOptions)
		if NOT isObject(poGraph)
			StzRaise("stzGraphCanvas: give me an stzGraph.")
		ok
		@oGraph = poGraph
		@aOpt = paOptions
		if NOT isList(@aOpt)  @aOpt = []  ok
		@aIds = poGraph.NodesIds()
		if len(@aIds) = 0
			StzRaise("stzGraphCanvas: that graph has no nodes to draw.")
		ok
		This._Compute()

	def Width()   return @nW
	def Height()  return @nH

	# Validate HERE. Passing 0 used to be accepted and then surfaced much
	# later as "stzCanvas refused a 0x0 canvas" from inside ToCanvas -- an
	# error naming a class the caller never touched, pointing away from the
	# line responsible. A window reports 0x0 while mapping and while
	# minimised, so this is an ordinary input, not an exotic one.
	def SetSize(pnW, pnH)
		if NOT (isNumber(pnW) and isNumber(pnH))
			StzRaise("stzGraphCanvas.SetSize: give a width and a height.")
		ok
		if pnW < 1 or pnH < 1
			StzRaise("stzGraphCanvas.SetSize: refused " + pnW + "x" + pnH +
				" -- a drawing needs area. A window reports 0x0 while it " +
				"is minimised; skip the frame rather than lay out into it.")
		ok
		@nW = pnW
		@nH = pnH
		This._Compute()

	def SetSizeQ(pnW, pnH)
		This.SetSize(pnW, pnH)
		return This

	# The computed values behind the picture, so a caller can ASSERT on
	# them instead of squinting at pixels.
	def MetricValues(cWhich)
		return StzGraphMetric(@oGraph, cWhich)

	def Positions()
		_a_ = []
		_n_ = len(@aIds)
		for _i_ = 1 to _n_
			_a_ + [ @aIds[_i_], @aX[_i_], @aY[_i_] ]
		next
		return _a_

	#-- the two tiers, inherited by handing back an stzCanvas --------------

	def ToCanvas()
		_oC_ = new stzCanvas(@nW, @nH)
		_oC_.SetBackground(This._Opt(:Background, "#0B1020"))

		# edges first, so nodes sit on top of them
		_aE_ = @oGraph.Edges()
		_ne_ = len(_aE_)
		for _e_ = 1 to _ne_
			_u_ = This._IndexOf(_aE_[_e_][:from])
			_v_ = This._IndexOf(_aE_[_e_][:to])
			if _u_ > 0 and _v_ > 0
				_oC_.AddLineQ(@aX[_u_], @aY[_u_], @aX[_v_], @aY[_v_]).
					Stroke(This._Opt(:EdgeColor, "#43558A"), 1)
			ok
		next

		_n_ = len(@aIds)
		for _i_ = 1 to _n_
			_oC_.AddCircleQ(@aX[_i_], @aY[_i_], @aSize[_i_]).
				StrokeQ("#0B1020", 2).Fill(@aColor[_i_])
		next

		# labels are optional: they need a font, and a caller without one
		# still gets the picture
		_oF_ = This._Opt(:Font, NULL)
		if isObject(_oF_)
			_nS_ = This._Opt(:LabelSize, 13)
			for _i_ = 1 to _n_
				_w_ = _oF_.WidthOf("" + @aIds[_i_], _nS_)
				_oC_.AddTextQ("" + @aIds[_i_],
					@aX[_i_] - _w_ / 2,
					@aY[_i_] + @aSize[_i_] + _nS_ + 4).
					SetFontQ(_oF_, _nS_).Color(This._Opt(:LabelColor, "#9FB0D8"))
			next
		ok
		return _oC_

	def ToCanvasQ()
		return This.ToCanvas()

	def ToSVG()
		_o_ = This.ToCanvas()
		return _o_.ToSVG()

	def ToPNG(pcPath)
		_o_ = This.ToCanvas()
		return _o_.ToPNG(pcPath)

	#-- internals ----------------------------------------------------------

	def _Opt(cKey, xDefault)
		_n_ = len(@aOpt)
		for _i_ = 1 to _n_
			if isList(@aOpt[_i_]) and len(@aOpt[_i_]) = 2
				if StzLower("" + @aOpt[_i_][1]) = StzLower("" + cKey)
					return @aOpt[_i_][2]
				ok
			ok
		next
		return xDefault

	def _IndexOf(cId)
		_n_ = len(@aIds)
		for _i_ = 1 to _n_
			if @aIds[_i_] = cId  return _i_  ok
		next
		return 0

	def _Compute()
		_n_ = len(@aIds)
		_cLay_ = StzLower("" + This._Opt(:Layout, :Hierarchical))

		if _cLay_ = "force"
			This._LayoutForce()
		else
			This._LayoutHierarchical()
		ok
		This._Normalise()

		# SIZE and COLOUR come from a COMPUTED property, which is the whole
		# claim of this class. Both default to :Degree so a caller who names
		# neither still gets a picture that MEANS something.
		_aS_ = StzGraphMetric(@oGraph, This._Opt(:SizeBy, :Degree))
		_aC_ = StzGraphMetric(@oGraph, This._Opt(:ColorBy, :Degree))

		_sMin_ = This._Opt(:MinRadius, 7)
		_sMax_ = This._Opt(:MaxRadius, 26)

		# FIT THE RADII TO THE ROOM THERE ACTUALLY IS. A node's size comes
		# from the metric, but the space between layers comes from the
		# canvas -- and nothing was reconciling the two, so a tall metric on
		# a short canvas drew a node straight through the label beneath it
		# and into the next layer. Found by looking at the picture; the
		# numbers were all correct.
		_gap_ = This._RowGap()
		if _gap_ > 0
			_need_ = 2 * _sMax_ + This._Opt(:LabelSize, 13) + 8
			if _need_ > _gap_
				_k_ = _gap_ / _need_
				_sMax_ = _sMax_ * _k_
				_sMin_ = _sMin_ * _k_
				if _sMin_ < 2  _sMin_ = 2  ok
				if _sMax_ < _sMin_ + 1  _sMax_ = _sMin_ + 1  ok
			ok
		ok
		@aSize = _StzScaleList(_aS_, _sMin_, _sMax_)

		# hue runs green (low) -> red (high): the convention every risk
		# picture already uses, so the reader needs no legend to start
		_h0_ = This._Opt(:HueLow, 140)
		_h1_ = This._Opt(:HueHigh, 0)
		_aH_ = _StzScaleList(_aC_, _h0_, _h1_)
		@aColor = []
		for _i_ = 1 to _n_
			@aColor + StzColorFromHSL(_aH_[_i_], 62, 55)
		next

	# The tightest vertical gap between two rows that actually hold nodes.
	# Returns 0 when there is only one row, or for a free-form layout where
	# rows are not a meaningful idea.
	def _RowGap()
		_n_ = len(@aY)
		if _n_ < 2  return 0  ok
		_ys_ = []
		for _i_ = 1 to _n_
			_seen_ = FALSE
			for _k_ = 1 to len(_ys_)
				if fabs(_ys_[_k_] - @aY[_i_]) < 0.5  _seen_ = TRUE  exit  ok
			next
			if NOT _seen_  _ys_ + @aY[_i_]  ok
		next
		if len(_ys_) < 2  return 0  ok
		_ys_ = ring_sort(_ys_)
		_g_ = _ys_[2] - _ys_[1]
		for _k_ = 3 to len(_ys_)
			if _ys_[_k_] - _ys_[_k_-1] < _g_  _g_ = _ys_[_k_] - _ys_[_k_-1]  ok
		next
		return _g_

	def _LayoutHierarchical()
		_lay_ = _StzGraphLayers(@oGraph)
		_n_ = len(@aIds)
		_max_ = 0
		for _i_ = 1 to _n_
			if _lay_[_i_] > _max_  _max_ = _lay_[_i_]  ok
		next

		# group by layer, then let the ENGINE reduce crossings -- the same
		# sweep the GG1 stress suite ran over eight topologies
		_buck_ = []
		for _L_ = 0 to _max_  _buck_ + []  next
		for _i_ = 1 to _n_
			_buck_[_lay_[_i_] + 1] + (_i_ - 1)
		next
		_order_ = []
		_starts_ = []
		_acc_ = 0
		for _L_ = 1 to _max_ + 1
			_starts_ + _acc_
			for _k_ = 1 to len(_buck_[_L_])
				_order_ + _buck_[_L_][_k_]
			next
			_acc_ += len(_buck_[_L_])
		next
		_starts_ + _acc_

		_aE_ = @oGraph.Edges()
		_eu_ = []  _ev_ = []
		for _e_ = 1 to len(_aE_)
			_u_ = This._IndexOf(_aE_[_e_][:from])
			_v_ = This._IndexOf(_aE_[_e_][:to])
			if _u_ > 0 and _v_ > 0
				_eu_ + (_u_ - 1)
				_ev_ + (_v_ - 1)
			ok
		next

		_lay0_ = []
		for _i_ = 1 to _n_  _lay0_ + _lay_[_i_]  next

		if len(_eu_) > 0 and _max_ > 0
			_csr_ = _StzInCsr(_eu_, _ev_, _n_)
			_order_ = StzEngineGraphLayoutSweep(_csr_[1], _csr_[2], _lay0_,
				_order_, _starts_, 12, _eu_, _ev_)
		ok

		# x from the position within the layer, y from the layer
		@aX = []  @aY = []
		for _i_ = 1 to _n_  @aX + 0  @aY + 0  next
		for _L_ = 1 to _max_ + 1
			_w_ = _starts_[_L_ + 1] - _starts_[_L_]
			_p_ = 1
			for _k_ = _starts_[_L_] + 1 to _starts_[_L_ + 1]
				_id_ = _order_[_k_] + 1
				@aX[_id_] = _p_ / (_w_ + 1)
				@aY[_id_] = (_L_ - 1) / (_max_ + 1)
				_p_++
			next
		next

	def _LayoutForce()
		_n_ = len(@aIds)
		# a golden-angle seed: a FORMULA, so the layout reproduces
		@aX = []  @aY = []
		for _i_ = 1 to _n_
			_a_ = (_i_ - 1) * 2.399963229728653
			_r_ = sqrt(_i_)
			@aX + (_r_ * cos(_a_))
			@aY + (_r_ * sin(_a_))
		next
		_aE_ = @oGraph.Edges()
		_k_ = 1.2
		for _it_ = 1 to 240
			_t_ = 0.9 * pow(0.97, _it_ - 1)
			_dx_ = []  _dy_ = []
			for _i_ = 1 to _n_  _dx_ + 0  _dy_ + 0  next
			for _i_ = 1 to _n_
				for _j_ = 1 to _n_
					if _i_ = _j_  loop  ok
					_ox_ = @aX[_i_] - @aX[_j_]
					_oy_ = @aY[_i_] - @aY[_j_]
					_d2_ = _ox_*_ox_ + _oy_*_oy_
					if _d2_ < 0.01  _d2_ = 0.01  ok
					_f_ = (_k_*_k_) / _d2_
					_dx_[_i_] += _ox_ * _f_
					_dy_[_i_] += _oy_ * _f_
				next
			next
			for _e_ = 1 to len(_aE_)
				_u_ = This._IndexOf(_aE_[_e_][:from])
				_v_ = This._IndexOf(_aE_[_e_][:to])
				if _u_ > 0 and _v_ > 0
					_ox_ = @aX[_v_] - @aX[_u_]
					_oy_ = @aY[_v_] - @aY[_u_]
					_d_ = sqrt(_ox_*_ox_ + _oy_*_oy_)
					if _d_ > 0.0001
						_f_ = _d_ / _k_
						_dx_[_u_] += _ox_ * _f_
						_dy_[_u_] += _oy_ * _f_
						_dx_[_v_] -= _ox_ * _f_
						_dy_[_v_] -= _oy_ * _f_
					ok
				ok
			next
			for _i_ = 1 to _n_
				_m_ = sqrt(_dx_[_i_]*_dx_[_i_] + _dy_[_i_]*_dy_[_i_])
				if _m_ > 0.0001
					_c_ = _m_
					if _c_ > _t_  _c_ = _t_  ok
					@aX[_i_] += _dx_[_i_] / _m_ * _c_
					@aY[_i_] += _dy_[_i_] / _m_ * _c_
				ok
			next
		next

	# Fit the raw layout into the canvas. Without this a caller gets
	# coordinates in whatever range the layout happened to produce, which is
	# not a picture -- and it is why every layout above may emit raw numbers
	# and let ONE place do the fitting.
	def _Normalise()
		_n_ = len(@aX)
		_x0_ = @aX[1]  _x1_ = @aX[1]
		_y0_ = @aY[1]  _y1_ = @aY[1]
		for _i_ = 2 to _n_
			if @aX[_i_] < _x0_  _x0_ = @aX[_i_]  ok
			if @aX[_i_] > _x1_  _x1_ = @aX[_i_]  ok
			if @aY[_i_] < _y0_  _y0_ = @aY[_i_]  ok
			if @aY[_i_] > _y1_  _y1_ = @aY[_i_]  ok
		next
		_mx_ = This._Opt(:Margin, 70)
		_my_ = This._Opt(:Margin, 70)
		_sw_ = _x1_ - _x0_
		_sh_ = _y1_ - _y0_
		for _i_ = 1 to _n_
			if _sw_ > 0.000001
				@aX[_i_] = _mx_ + (@aX[_i_] - _x0_) / _sw_ * (@nW - 2 * _mx_)
			else
				@aX[_i_] = @nW / 2
			ok
			if _sh_ > 0.000001
				@aY[_i_] = _my_ + (@aY[_i_] - _y0_) / _sh_ * (@nH - 2 * _my_)
			else
				@aY[_i_] = @nH / 2
			ok
		next

#-- shared helpers ---------------------------------------------------------

func _StzScaleList(paVals, nLo, nHi)
	_n_ = len(paVals)
	_min_ = paVals[1]  _max_ = paVals[1]
	for _i_ = 2 to _n_
		if paVals[_i_] < _min_  _min_ = paVals[_i_]  ok
		if paVals[_i_] > _max_  _max_ = paVals[_i_]  ok
	next
	_o_ = []
	for _i_ = 1 to _n_
		if _max_ = _min_
			# every node equal: the MIDPOINT, not the low end -- a flat
			# metric should look deliberate, not look like the minimum
			_o_ + ((nLo + nHi) / 2)
		else
			_o_ + (nLo + (paVals[_i_] - _min_) / (_max_ - _min_) * (nHi - nLo))
		ok
	next
	return _o_

func _StzInCsr(paU, paV, n)
	_cnt_ = []
	for _i_ = 1 to n  _cnt_ + 0  next
	_ne_ = len(paU)
	for _e_ = 1 to _ne_  _cnt_[paV[_e_] + 1]++  next
	_off_ = []  _acc_ = 0
	for _i_ = 1 to n  _off_ + _acc_  _acc_ += _cnt_[_i_]  next
	_off_ + _acc_
	_src_ = []
	for _i_ = 1 to _acc_  _src_ + 0  next
	_fill_ = []
	for _i_ = 1 to n  _fill_ + 0  next
	for _e_ = 1 to _ne_
		_v_ = paV[_e_]
		_src_[_off_[_v_ + 1] + _fill_[_v_ + 1] + 1] = paU[_e_]
		_fill_[_v_ + 1]++
	next
	return [ _off_, _src_ ]
