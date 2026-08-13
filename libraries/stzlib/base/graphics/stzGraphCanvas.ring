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
# ONE call into the engine, over the graph THAT ALREADY LIVES THERE.
#
# This function has been wrong twice, and the second version is instructive.
#
#   v1  computed everything in Ring. :Impact called PathExists for every
#       ORDERED PAIR -- quadratic work with a language boundary inside the
#       loop. 300 nodes: 2,684 ms.
#   v2  moved the algorithms into the engine but still MARSHALLED: walk the
#       edge list in Ring, map every endpoint to an index by linear search,
#       hand two arrays across. 300 nodes: 30 ms -- and at 1,000 nodes all
#       three metrics cost the same ~200 ms, which is the tell: the metric
#       was no longer the cost, the marshalling was.
#   v3  this. stzGraph is ENGINE-BACKED. The adjacency is already there, so
#       a metric over it takes the GRAPH, not a copy of the graph.
#
# The lesson is the one the house rule states: push the processing into the
# engine -- and pushing the ALGORITHM while leaving the DATA in Ring only
# moves the bottleneck.
func StzGraphMetric(poGraph, cWhich)
	_n_ = len(poGraph.NodesIds())
	if _n_ = 0
		return []
	ok

	switch StzLower("" + cWhich)
	on "impact"    return _StzGraphAllMetric(poGraph, :Impact, _n_)
	on "depth"     return _StzGraphAllMetric(poGraph, :Depth, _n_)
	on "degree"    return _StzGraphAllMetric(poGraph, :Degree, _n_)
	on "indegree"  return _StzGraphAllMetric(poGraph, :InDegree, _n_)
	on "outdegree" return _StzGraphAllMetric(poGraph, :OutDegree, _n_)
	other
		StzRaise("stzGraphCanvas: I do not compute '" + cWhich + "'. " +
			"Use :Impact, :Depth, :Degree, :InDegree or :OutDegree.")
	off

# The engine returns [ [name, value], ... ] in NODE ORDER, the shape every
# whole-graph metric in stz_graph already uses. Only the values are wanted
# here; the names are the graph's own and already known.
func _StzGraphAllMetric(poGraph, cWhich, nCount)
	if NOT poGraph.HasEngine()
		StzRaise("stzGraphCanvas: this graph is not engine-backed, so its " +
			"metrics cannot be computed. The engine is where the work " +
			"belongs -- Ring is the face, not the tier that computes.")
	ok
	_h_ = poGraph.EngineHandle()

	switch StzLower("" + cWhich)
	on "impact"    _r_ = StzEngineGraphImpactAll(_h_)
	on "depth"     _r_ = StzEngineGraphLayersAll(_h_)
	on "degree"    _r_ = StzEngineGraphDegreeAll(_h_)
	on "indegree"  _r_ = StzEngineGraphInDegreeAll(_h_)
	on "outdegree" _r_ = StzEngineGraphOutDegreeAll(_h_)
	off

	if len(_r_) = 0
		if StzLower("" + cWhich) = "impact"
			StzRaise("stzGraphCanvas: :Impact is exact transitive " +
				"reachability and its bitset is O(n^2/8) -- refused above " +
				"20,000 nodes. Use :Degree or :Depth on a graph that large.")
		ok
		# :Depth is longest-path layering, a propagation to a fixed point.
		# On a CYCLE there is no fixed point -- every node is deeper than
		# itself -- so the engine refuses rather than handing back the
		# state its pass cap happened to stop at. Measured before the
		# refusal existed: a 6-node cycle answered [42,37,38,39,40,41].
		if StzLower("" + cWhich) = "depth"
			StzRaise("stzGraphCanvas: :Depth is longest-path layering, and " +
				"this graph has a CYCLE -- a node cannot be deeper than " +
				"itself, so no layering exists. Break the cycle, or bind " +
				":Degree or :Impact, which are defined on cyclic graphs.")
		ok
		StzRaise("stzGraphCanvas: the engine refused " + cWhich + ".")
	ok

	_o_ = []
	for _i_ = 1 to len(_r_)
		_o_ + _r_[_i_][2]
	next
	return _o_

# ---- layout inputs ------------------------------------------------------
#
# The LAYOUTS still take arrays, and that is legitimate: a sweep needs an
# order and layer starts, which are properties of the drawing rather than of
# the graph, so there is nothing resident to point at. What is NOT legitimate
# is paying O(n*e) to build them -- the id->index map is a HASHLIST lookup,
# not a linear scan through every node for every endpoint.

func _StzGraphEdgeArrays(poGraph, paIds)
	_n_ = len(paIds)
	_map_ = []
	for _i_ = 1 to _n_
		_map_ + [ "" + paIds[_i_], _i_ ]
	next
	_aE_ = poGraph.Edges()
	_ne_ = len(_aE_)
	_u_ = []  _v_ = []
	for _e_ = 1 to _ne_
		_a_ = _map_[ "" + _aE_[_e_][:from] ]
		_b_ = _map_[ "" + _aE_[_e_][:to] ]
		if isNumber(_a_) and isNumber(_b_) and _a_ > 0 and _b_ > 0
			_u_ + (_a_ - 1)
			_v_ + (_b_ - 1)
		ok
	next
	return [ _u_, _v_ ]

# CSR keyed by the FIRST array: _StzCsr(from, to, n) indexes, for each
# `from`, the `to`s that leave it. Swap the arguments for the other
# direction -- one builder, not two.
func _StzCsr(paFrom, paTo, n)
	_cnt_ = []
	for _i_ = 1 to n  _cnt_ + 0  next
	_ne_ = len(paFrom)
	for _e_ = 1 to _ne_  _cnt_[paFrom[_e_] + 1]++  next
	_off_ = []  _acc_ = 0
	for _i_ = 1 to n  _off_ + _acc_  _acc_ += _cnt_[_i_]  next
	_off_ + _acc_
	_src_ = []
	for _i_ = 1 to _acc_  _src_ + 0  next
	_fill_ = []
	for _i_ = 1 to n  _fill_ + 0  next
	for _e_ = 1 to _ne_
		_f_ = paFrom[_e_]
		_src_[_off_[_f_ + 1] + _fill_[_f_ + 1] + 1] = paTo[_e_]
		_fill_[_f_ + 1]++
	next
	return [ _off_, _src_ ]

class stzGraphCanvas from stzObject

	@oGraph = ""
	@aOpt = []
	@nW = 1000
	@nH = 620
	@aX = []
	@aY = []
	@aIds = []
	@aSize = []
	@aColor = []
	@aIdMap = []

	def init(poGraph, paOptions)
		if NOT isObject(poGraph)
			StzRaise("stzGraphCanvas: give me an stzGraph.")
		ok
		@oGraph = poGraph
		@aOpt = paOptions
		if NOT isList(@aOpt)  @aOpt = []  ok
		@aIds = poGraph.NodesIds()
		@aIdMap = []
		for _i_ = 1 to len(@aIds)
			@aIdMap + [ "" + @aIds[_i_], _i_ ]
		next
		if len(@aIds) = 0
			StzRaise("stzGraphCanvas: that graph has no nodes to draw.")
		ok

		# :Width and :Height are OPTIONS like every other. They were not
		# read here, so a caller passing them got the 1000x620 default and
		# a layout that did not fit whatever it was drawing into -- an
		# options list that silently ignores two of its keys, which is the
		# port-knob trap: what the caller SENDS and what the face READS
		# have to be the same list.
		_w_ = This._Opt(:Width, 0)
		_h_ = This._Opt(:Height, 0)
		if isNumber(_w_) and _w_ >= 1  @nW = _w_  ok
		if isNumber(_h_) and _h_ >= 1  @nH = _h_  ok

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
		_oF_ = This._Opt(:Font, "")
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

	# O(1). It was a linear scan over every node, called twice per edge --
	# O(n*e), which on a 1,000-node chain was most of the frame and looked
	# like the metric's fault.
	def _IndexOf(cId)
		_v_ = @aIdMap[ "" + cId ]
		if isNumber(_v_)
			return _v_
		ok
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
			_seen_ = 0
			for _k_ = 1 to len(_ys_)
				if fabs(_ys_[_k_] - @aY[_i_]) < 0.5  _seen_ = 1  exit  ok
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
		_lay_ = StzGraphMetric(@oGraph, :Depth)
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

		_aXe_ = []
		if len(_eu_) > 0 and _max_ > 0
			_csr_ = _StzCsr(_ev_, _eu_, _n_)          # predecessors of v
			_order_ = StzEngineGraphLayoutSweep(_csr_[1], _csr_[2], _lay0_,
				_order_, _starts_, 12, _eu_, _ev_)

			# ORDER IS NOT PLACEMENT. The sweep above settles who sits beside
			# whom; it says nothing about WHERE. This face used to answer that
			# with `position / (width + 1)` -- every layer stretched across the
			# whole picture whatever its population -- so a node's children
			# were placed by ordinal rather than under their parent. On a
			# 40-node binary tree the bottom row fanned across the entire
			# canvas and its edges became long diagonals crossing three rows.
			# The crossing count was optimal and the drawing was still wrong.
			_outc_ = _StzCsr(_eu_, _ev_, _n_)         # successors of u
			_aXe_ = StzEngineGraphLayoutCoords(_csr_[1], _csr_[2],
				_outc_[1], _outc_[2], _order_, _starts_, 1.0, 8)
		ok

		# y from the layer; x from the engine when it answered
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
		if len(_aXe_) = _n_
			for _i_ = 1 to _n_  @aX[_i_] = _aXe_[_i_]  next
		ok

	# The ENGINE lays this out. The face used to carry its own Ring copy of
	# Fruchterman-Reingold: 443 ms for 40 nodes, 3.7 s for 120, 24.5 s for
	# 300 -- while the tier below had already been measured doing 10,000
	# nodes in 152 ms. A second implementation of what the layer beneath
	# already does does not stay equal, and this one had diverged by three
	# orders of magnitude on the path users actually take.
	def _LayoutForce()
		_n_ = len(@aIds)

		# a golden-angle seed: a FORMULA, so the layout reproduces
		_seed_ = []
		for _i_ = 1 to _n_
			_a_ = (_i_ - 1) * 2.399963229728653
			_r_ = 12 * sqrt(_i_)
			_seed_ + (_r_ * cos(_a_))
			_seed_ + (_r_ * sin(_a_))
		next

		# UNDIRECTED for layout: an edge pulls both ends together, so the
		# engine is handed each edge in both directions. Feeding only the
		# in-edges would let a node with no predecessors drift free of the
		# graph it belongs to.
		_aE_ = @oGraph.Edges()
		_eu_ = []  _ev_ = []
		for _e_ = 1 to len(_aE_)
			_u_ = This._IndexOf(_aE_[_e_][:from])
			_v_ = This._IndexOf(_aE_[_e_][:to])
			if _u_ > 0 and _v_ > 0
				_eu_ + (_u_ - 1)  _ev_ + (_v_ - 1)
				_eu_ + (_v_ - 1)  _ev_ + (_u_ - 1)
			ok
		next

		if len(_eu_) = 0
			# no edges: the seed spiral IS the layout, and repulsion alone
			# would only push it apart without saying anything
			@aX = []  @aY = []
			for _i_ = 1 to _n_
				@aX + _seed_[_i_ * 2 - 1]
				@aY + _seed_[_i_ * 2]
			next
			return
		ok

		_csr_ = _StzCsr(_ev_, _eu_, _n_)
		_k_ = sqrt((1000 * 1000) / _n_)
		_out_ = StzEngineGraphLayoutForce(_csr_[1], _csr_[2], _seed_,
			This._Opt(:Iterations, 160), _k_)

		@aX = []  @aY = []
		for _i_ = 1 to _n_
			@aX + _out_[_i_ * 2 - 1]
			@aY + _out_[_i_ * 2]
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

