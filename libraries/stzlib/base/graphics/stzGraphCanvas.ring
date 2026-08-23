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

	# What the layout KNEW before _Normalise stretched it to the canvas:
	# the raw coordinate span, the layer count, and whether x is unit-true
	# (engine slot units, 1.0 = one minimum separation) or ordinal. A face
	# doing NATURAL sizing needs these to derive the picture's size from
	# the content -- without them it can only stretch, and stretching is
	# how a 1-unit minimum gap became 2px in a crowded rank.
	@nRawSpanX = 0
	@nRawSpanY = 0
	@nLayerCount = 1
	@bUnitX = 0

	# [ [ fromId, toId, [ [x,y], ... ] ], ... ] -- the route a long edge
	# takes through the ranks it crosses, in the same coordinate space as
	# Positions(). Empty for a graph whose edges are all rank-adjacent.
	@aBendOf = []
	@aDumEdge = []
	@nRealCount = 0

	# The layout's own x per node, kept before _Normalise rewrites it into
	# canvas pixels -- the space a pin lives in, and the one a cursor
	# position must be translated back into for a drag to become a pin.
	@aXRaw = []

	# The crossing count of the FINAL order -- after the engine sweep AND
	# after cluster compaction, because that is the order that is drawn.
	# A structure fact the graph tier answers so a face (or a guard) can
	# ask "does this picture contain only the crossings the graph
	# requires?" without rebuilding CSR arrays by hand. -1 = no
	# hierarchical layout has run.
	@nLayoutCrossings = -1

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

	# The bend points of every edge that spans more than one rank, in the
	# SAME normalised space as Positions() -- so a face transforms both
	# with one rule and cannot place an edge in a different frame from the
	# nodes it joins.
	def EdgeRoutes()  return @aBendOf

	def RawSpanX()    return @nRawSpanX
	def RawSpanY()    return @nRawSpanY
	def LayerCount()  return @nLayerCount
	def IsUnitX()     return @bUnitX
	def LayoutCrossings()  return @nLayoutCrossings

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

	# The layout's OWN coordinates, before the fit to the canvas -- the
	# space a pin is expressed in, and therefore the space a cursor
	# position has to be translated back into.
	def RawPositions()
		_a_ = []
		_n_ = len(@aIds)
		for _i_ = 1 to _n_
			_rv_ = 0
			if _i_ <= len(@aXRaw)  _rv_ = @aXRaw[_i_]  ok
			_a_ + [ @aIds[_i_], _rv_ ]
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
		but _cLay_ = "ring" or _cLay_ = "circular"
			This._LayoutRing()
		else
			This._LayoutHierarchical()
		ok
		This._Normalise()
		This._ExtractRoutes()

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

	#-- THE RING: a space with states around its border ---------------------
	#
	# The Principal's correction, and it is the deep one: A STATE MACHINE IS
	# NOT A TREE. Layered layout answers "what flows into what" -- it is
	# built for a DAG and it reads a cycle as a defect to be oriented away.
	# A statechart has no flow direction: its states are PEERS, and its
	# edges are EVENTS fired between them. Graphviz says the same thing by
	# shipping two engines: `dot` for hierarchies, `circo`/`neato` for
	# everything cyclic. Drawing a machine with `dot`'s model was the fault
	# under every mark he made -- the knot of channels, the scrambling, the
	# arbitrary up-down of states that have no up or down.
	#
	# His metaphor is the template: A SPACE, with the states as cells
	# sitting around its BORDER, and the ones that need it in the MIDDLE.
	# So:
	#
	#   THE BORDER   states on a circle, every one a peer of every other,
	#                and no state above another because none is
	#   THE MIDDLE   a HUB -- a state most of the others talk to -- moves
	#                inside, where its edges become short radials instead
	#                of long chords sawing the space in half
	#   THE ORDER    neighbours on the ring are states that talk, so an
	#                event is a SHORT chord; found by traversal (which
	#                follows the machine's own sequences) and improved by
	#                adjacent swaps against a real crossing count
	#   THE ENTRY    the initial pseudostate opens the ring at the top,
	#                where every convention puts it, and reading runs
	#                clockwise from there
	#
	# Crossings are counted, not hoped for: two chords (a,b) and (c,d)
	# cross iff exactly one of c,d lies strictly between a and b around
	# the ring. That is the whole geometry of a circular layout, and it
	# makes the improvement pass an honest hill-climb rather than a shuffle.
	def _LayoutRing()
		@nLayoutCrossings = 0
		_n_ = len(@aIds)
		@aX = []  @aY = []
		for _i_ = 1 to _n_  @aX + 0  @aY + 0  next
		if _n_ = 0  return  ok
		if _n_ = 1
			@aX[1] = 0  @aY[1] = 0
			@nLayerCount = 1
			@aBendOf = []
			@nRealCount = 1
			@aDumEdge = []
			return
		ok

		# undirected adjacency: an event relates two states whichever way
		# it fires, and the ring is about relation, not direction
		_aAdj_ = []
		for _i_ = 1 to _n_  _aAdj_ + []  next
		_aDeg_ = []
		for _i_ = 1 to _n_  _aDeg_ + 0  next
		_aIn_ = []
		for _i_ = 1 to _n_  _aIn_ + 0  next
		for _e_ in @oGraph.Edges()
			_u_ = This._IndexOf(_e_[:from])
			_v_ = This._IndexOf(_e_[:to])
			if _u_ < 1 or _v_ < 1 or _u_ = _v_  loop  ok
			_bDup_ = 0
			for _k_ in _aAdj_[_u_]
				if _k_ = _v_  _bDup_ = 1  exit  ok
			next
			if _bDup_  loop  ok
			_aAdj_[_u_] + _v_
			_aAdj_[_v_] + _u_
			_aDeg_[_u_]++
			_aDeg_[_v_]++
			_aIn_[_v_]++
		next

		# THE MIDDLE: a hub talks to at least half the machine and to four
		# states at least. Below that, the ring is the better place -- an
		# interior node with two neighbours is not central to anything, it
		# is just off the border where the reader's eye does not expect it.
		_aInner_ = []
		_aRing_ = []
		for _i_ = 1 to _n_
			if _aDeg_[_i_] >= 4 and _aDeg_[_i_] * 2 >= _n_ - 1
				_aInner_ + _i_
			else
				_aRing_ + _i_
			ok
		next
		# a ring of fewer than three is not a ring
		if len(_aRing_) < 3
			_aRing_ = []
			_aInner_ = []
			for _i_ = 1 to _n_  _aRing_ + _i_  next
		ok

		# THE ENTRY opens the ring: a state nothing transitions into is
		# where reading starts, and it goes to the top
		_nStart_ = _aRing_[1]
		for _i_ in _aRing_
			if _aIn_[_i_] = 0  _nStart_ = _i_  exit  ok
		next

		# THE ORDER: a traversal, so states that talk end up adjacent --
		# the machine's own sequences become the ring's arcs
		_aOrd_ = []
		_aSeen_ = []
		for _i_ = 1 to _n_  _aSeen_ + 0  next
		_bOnRing_ = []
		for _i_ = 1 to _n_  _bOnRing_ + 0  next
		for _i_ in _aRing_  _bOnRing_[_i_] = 1  next
		_aStack_ = [ _nStart_ ]
		_aSeen_[_nStart_] = 1
		while len(_aStack_) > 0
			_u_ = _aStack_[ len(_aStack_) ]
			_aNew_ = []
			for _k_ = 1 to len(_aStack_) - 1  _aNew_ + _aStack_[_k_]  next
			_aStack_ = _aNew_
			if _bOnRing_[_u_]  _aOrd_ + _u_  ok
			# push neighbours in reverse so the first-declared is visited
			# first: a machine reads in the order its author wrote it
			for _k_ = len(_aAdj_[_u_]) to 1 step -1
				_v_ = _aAdj_[_u_][_k_]
				if _aSeen_[_v_]  loop  ok
				_aSeen_[_v_] = 1
				_aStack_ + _v_
			next
		end
		for _i_ in _aRing_
			if _aSeen_[_i_] = 0  _aOrd_ + _i_  ok
		next

		# IMPROVE BY MEASUREMENT: adjacent swaps kept only when the counted
		# crossing number falls. Bounded passes, deterministic order.
		_nBest_ = This._RingCrossings(_aOrd_, _aAdj_)
		_m_ = len(_aOrd_)
		for _pass_ = 1 to 6
			_bMoved_ = 0
			for _k_ = 1 to _m_
				_k2_ = _k_ + 1
				if _k2_ > _m_  _k2_ = 1  ok
				_t_ = _aOrd_[_k_]
				_aOrd_[_k_] = _aOrd_[_k2_]
				_aOrd_[_k2_] = _t_
				_nTry_ = This._RingCrossings(_aOrd_, _aAdj_)
				if _nTry_ < _nBest_
					_nBest_ = _nTry_
					_bMoved_ = 1
				else
					_t_ = _aOrd_[_k_]
					_aOrd_[_k_] = _aOrd_[_k2_]
					_aOrd_[_k2_] = _t_
				ok
			next
			if NOT _bMoved_  exit  ok
		next
		@nLayoutCrossings = _nBest_

		# ...and the entry state is rotated to the top, where every
		# convention puts it, without disturbing the order around it
		_nAt_ = 0
		for _k_ = 1 to _m_
			if _aOrd_[_k_] = _nStart_  _nAt_ = _k_  exit  ok
		next
		if _nAt_ > 1
			_aRot_ = []
			for _k_ = _nAt_ to _m_  _aRot_ + _aOrd_[_k_]  next
			for _k_ = 1 to _nAt_ - 1  _aRot_ + _aOrd_[_k_]  next
			_aOrd_ = _aRot_
		ok

		# THE SPACE. Radius 1 in layout units; _Normalise fits it to the
		# canvas, and the diagram keeps the canvas square so a circle
		# cannot arrive as an ellipse.
		_pi2_ = 6.283185307179586
		for _k_ = 1 to _m_
			_ang_ = -1.5707963267948966 + (_k_ - 1) * _pi2_ / _m_
			@aX[ _aOrd_[_k_] ] = cos(_ang_)
			@aY[ _aOrd_[_k_] ] = sin(_ang_)
		next

		# THE MIDDLE, placed where its own edges pull it, then pushed
		# apart so two hubs never share a point
		for _i_ in _aInner_
			_sx_ = 0  _sy_ = 0  _c_ = 0
			for _v_ in _aAdj_[_i_]
				if NOT _bOnRing_[_v_]  loop  ok
				_sx_ += @aX[_v_]
				_sy_ += @aY[_v_]
				_c_++
			next
			if _c_ > 0
				@aX[_i_] = _sx_ / _c_ * 0.34
				@aY[_i_] = _sy_ / _c_ * 0.34
			else
				@aX[_i_] = 0
				@aY[_i_] = 0
			ok
		next
		_nI_ = len(_aInner_)
		if _nI_ > 1
			for _k_ = 1 to _nI_
				_ang_ = (_k_ - 1) * _pi2_ / _nI_
				@aX[ _aInner_[_k_] ] += cos(_ang_) * 0.22
				@aY[ _aInner_[_k_] ] += sin(_ang_) * 0.22
			next
		ok

		# a ring has no layers, and says so: nothing downstream may read
		# rank meaning out of a picture that has none
		@nLayerCount = 1
		@aBendOf = []
		@nRealCount = _n_
		@aDumEdge = []

	# Chords (a,b) and (c,d) on a circle cross iff exactly one of c,d lies
	# strictly between a and b going one way round. Counted over the ring
	# order, which is the only geometry a circular layout has.
	def _RingCrossings(paOrd, paAdj)
		_m_ = len(paOrd)
		_aPos_ = []
		for _i_ = 1 to len(@aIds)  _aPos_ + 0  next
		for _k_ = 1 to _m_  _aPos_[ paOrd[_k_] ] = _k_  next
		_aCh_ = []
		for _k_ = 1 to _m_
			_u_ = paOrd[_k_]
			for _v_ in paAdj[_u_]
				if _aPos_[_v_] = 0  loop  ok
				if _aPos_[_v_] <= _k_  loop  ok
				_aCh_ + [ _k_, _aPos_[_v_] ]
			next
		next
		_nC_ = len(_aCh_)
		_nX_ = 0
		for _i_ = 1 to _nC_
			for _j_ = _i_ + 1 to _nC_
				_a_ = _aCh_[_i_][1]  _b_ = _aCh_[_i_][2]
				_c_ = _aCh_[_j_][1]  _d_ = _aCh_[_j_][2]
				# share an endpoint: meeting, not crossing
				if _a_ = _c_ or _a_ = _d_ or _b_ = _c_ or _b_ = _d_  loop  ok
				_bC_ = (_c_ > _a_ and _c_ < _b_)
				_bD_ = (_d_ > _a_ and _d_ < _b_)
				if (_bC_ and NOT _bD_) or (_bD_ and NOT _bC_)  _nX_++  ok
			next
		next
		return _nX_

	# THE RANK OF EVERY NODE, and cycles are a LAYOUT question here, not a
	# metric one -- DN2, where the first cyclic domain arrived.
	#
	# :Depth is a graph FACT: longest-path depth, which does not exist on
	# a cycle, and the engine rightly refuses to invent it. But a state
	# machine's whole vocabulary is cycles -- open/close, lock/unlock --
	# and "draw me" is not a question about depth. dot answered this in
	# 1993: pick an acyclic ORIENTATION (reverse the back edges found by a
	# DFS), rank against that, and draw the original arrows -- a back edge
	# simply points up the picture, which is exactly how a reader knows it
	# returns. The orientation is layout-private; no fact is misreported,
	# because no face ever sees it.
	#
	# Ring-side, deliberately, where everything else here is engine-first:
	# the DFS runs once per RENDER on a picture-sized graph (a drawable
	# state machine is tens of states), and crossing the seam would mean
	# teaching the engine a second, weaker meaning of :Depth. The acyclic
	# case keeps the engine's exact metric, so DAGs pay nothing.
	def _Layering()
		# back edges, by iterative DFS from every root (or node 1 when the
		# cycle leaves no roots at all)
		_n_ = len(@aIds)
		_aAdj_ = []
		for _i_ = 1 to _n_  _aAdj_ + []  next
		_aIn_ = []
		for _i_ = 1 to _n_  _aIn_ + 0  next
		_aE_ = @oGraph.Edges()
		_nE_ = len(_aE_)
		_aFwd_ = []                    # [ u, v ] pairs kept for ranking
		for _ei_ = 1 to _nE_
			_u_ = This._IndexOf(_aE_[_ei_][:from])
			_v_ = This._IndexOf(_aE_[_ei_][:to])
			if _u_ < 1 or _v_ < 1 or _u_ = _v_  loop  ok
			_aAdj_[_u_] + _v_
			_aIn_[_v_]++
		next

		_aState_ = []                  # 0 unseen, 1 on stack, 2 done
		for _i_ = 1 to _n_  _aState_ + 0  next
		_bCyc_ = 0
		for _root_ = 1 to _n_
			if _aState_[_root_] != 0  loop  ok
			if _aIn_[_root_] > 0 and _bCyc_ = 0  loop  ok
			_bCyc_ = This._DfsOrient(_root_, _aAdj_, _aState_, _aFwd_) or _bCyc_
		next
		# a pure cycle has no roots; sweep whatever is still unseen
		for _root_ = 1 to _n_
			if _aState_[_root_] = 0
				_bCyc_ = This._DfsOrient(_root_, _aAdj_, _aState_, _aFwd_) or _bCyc_
			ok
		next

		if NOT _bCyc_
			return StzGraphMetric(@oGraph, :Depth)
		ok

		# longest-path ranks over the kept orientation: relax until fixed.
		# Bounded by n passes -- the orientation is acyclic by construction.
		_lay_ = []
		for _i_ = 1 to _n_  _lay_ + 0  next
		_nF_ = len(_aFwd_)
		for _pass_ = 1 to _n_
			_bMoved_ = 0
			for _k_ = 1 to _nF_
				if _lay_[_aFwd_[_k_][2]] < _lay_[_aFwd_[_k_][1]] + 1
					_lay_[_aFwd_[_k_][2]] = _lay_[_aFwd_[_k_][1]] + 1
					_bMoved_ = 1
				ok
			next
			if NOT _bMoved_  exit  ok
		next
		return _lay_

	# One DFS from pnRoot: forward/cross edges join paFwd, back edges are
	# dropped (they become the upward arrows). Answers whether it saw a
	# back edge at all. Iterative -- a chain-shaped machine is as deep as
	# it is long.
	def _DfsOrient(pnRoot, paAdj, paState, paFwd)
		_bCyc_ = 0
		_aStack_ = [ [ pnRoot, 1 ] ]
		paState[pnRoot] = 1
		while len(_aStack_) > 0
			_top_ = _aStack_[ len(_aStack_) ]
			_u_ = _top_[1]
			_k_ = _top_[2]
			if _k_ > len(paAdj[_u_])
				paState[_u_] = 2
				_aNew_ = []
				for _i_ = 1 to len(_aStack_) - 1  _aNew_ + _aStack_[_i_]  next
				_aStack_ = _aNew_
				loop
			ok
			_aStack_[ len(_aStack_) ][2] = _k_ + 1
			_v_ = paAdj[_u_][_k_]
			if paState[_v_] = 1
				_bCyc_ = 1               # back edge: dropped from ranking
			but paState[_v_] = 0
				paFwd + [ _u_, _v_ ]
				paState[_v_] = 1
				_aStack_ + [ _v_, 1 ]
			else
				paFwd + [ _u_, _v_ ]     # cross/forward edge: kept
			ok
		end
		return _bCyc_

	def _LayoutHierarchical()
		# a single rank, or a graph with no edges, crosses nothing
		@nLayoutCrossings = 0
		_lay_ = This._Layering()
		_nReal_ = len(@aIds)
		_max_ = 0
		for _i_ = 1 to _nReal_
			if _lay_[_i_] > _max_  _max_ = _lay_[_i_]  ok
		next

		# DUMMY NODES FOR LONG EDGES -- the step of the Sugiyama pipeline
		# that was missing, and the one whose absence is impossible to miss
		# once drawn. An edge spanning more than one rank was a straight
		# line from source to target, so it went THROUGH every node box in
		# between: a 9-stage pipeline with a 1->9 edge drew that edge across
		# seven boxes. Nothing was wrong with the layout; the edge simply
		# had no presence in the ranks it crossed, so nothing reserved room
		# for it and nothing could route it.
		#
		# Every long edge is now CHAINED through one dummy per intervening
		# rank. Those dummies are real participants: they take part in the
		# crossing sweep (so a long edge is ordered against the nodes it
		# passes) and in the coordinate pass (so it is placed in the gap
		# rather than over a box). The chain read back out is the edge's
		# ROUTE -- which is also what turns a straight line into a curve
		# that bends the way dot's do.
		@aBendOf = []
		_aE0_ = @oGraph.Edges()
		_dumLay_ = []
		_dumEdge_ = []          # [ eIndex, [ dummy indices, in rank order ] ]
		_n_ = _nReal_
		for _ei_ = 1 to len(_aE0_)
			_u_ = This._IndexOf(_aE0_[_ei_][:from])
			_v_ = This._IndexOf(_aE0_[_ei_][:to])
			if _u_ < 1 or _v_ < 1  loop  ok
			_span_ = _lay_[_v_] - _lay_[_u_]
			if _span_ <= 1  loop  ok
			_chain_ = []
			for _dL_ = _lay_[_u_] + 1 to _lay_[_v_] - 1
				_n_++
				_dumLay_ + [ _n_, _dL_ ]
				_chain_ + _n_
			next
			_dumEdge_ + [ _ei_, _chain_ ]
		next

		# layers for the expanded node set
		_layX_ = []
		for _i_ = 1 to _nReal_  _layX_ + _lay_[_i_]  next
		for _d_ in _dumLay_  _layX_ + _d_[2]  next

		# group by layer, then let the ENGINE reduce crossings -- the same
		# sweep the GG1 stress suite ran over eight topologies
		_buck_ = []
		for _L_ = 0 to _max_  _buck_ + []  next
		for _i_ = 1 to _n_
			_buck_[_layX_[_i_] + 1] + (_i_ - 1)
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

		# the edge list the sweep sees is the CHAINED one: a long edge is
		# its segments, so every rank it crosses has a node to order it
		# against
		_aE_ = _aE0_
		_eu_ = []  _ev_ = []
		for _e_ = 1 to len(_aE_)
			_u_ = This._IndexOf(_aE_[_e_][:from])
			_v_ = This._IndexOf(_aE_[_e_][:to])
			if _u_ < 1 or _v_ < 1  loop  ok
			_ch_ = []
			for _de_ in _dumEdge_
				if _de_[1] = _e_  _ch_ = _de_[2]  exit  ok
			next
			if len(_ch_) = 0
				_eu_ + (_u_ - 1)
				_ev_ + (_v_ - 1)
			else
				_prev_ = _u_
				for _dn_ in _ch_
					_eu_ + (_prev_ - 1)
					_ev_ + (_dn_ - 1)
					_prev_ = _dn_
				next
				_eu_ + (_prev_ - 1)
				_ev_ + (_v_ - 1)
			ok
		next

		_lay0_ = []
		for _i_ = 1 to _n_  _lay0_ + _layX_[_i_]  next

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
			# CLUSTERS CONSTRAIN THE ORDER, and they have to do it HERE --
			# between the sweep and the placement. A cluster was previously
			# a box drawn around whatever the layout produced, so a cluster
			# whose members did not happen to land together got a box
			# containing strangers: two databases at opposite ends of a rank
			# gave a "Data" box with the logger sitting inside it. Nothing
			# was wrong with the drawing; the box faithfully bounded its
			# members, and its members were scattered.
			#
			# Contiguity is an ORDERING property, so it is imposed on the
			# order the sweep produced -- not on the coordinates afterwards,
			# where moving a node would break the separation the placement
			# has just guaranteed.
			# INNERMOST FIRST, and the direction is the whole trick for
			# nesting. Compacting by the outer key preserves each group's
			# INTERNAL order, so an inner block made contiguous first stays
			# contiguous when the outer pass gathers its members. Going the
			# other way, the outer pass would be undone by the inner one.
			_cmd_ = This._ClusterMaxDepth()
			if _cmd_ = 0
				_clOf_ = This._ClusterOf(_n_, 0)
				_order_ = This._ClusterCompact(_order_, _starts_, _max_, _clOf_)
			else
				for _dpt_ = _cmd_ to 1 step -1
					_clOf_ = This._ClusterOf(_n_, _dpt_)
					_order_ = This._ClusterCompact(_order_, _starts_, _max_,
						_clOf_)
				next
			ok

			# the fact is measured on what will be DRAWN: the sweep's order
			# as constrained by the clusters, not the sweep's optimum. A
			# cluster gathering its members can buy contiguity with a
			# crossing, and the honest count includes that price.
			_aPosF_ = []
			for _i_ = 1 to _n_  _aPosF_ + 0  next
			for _L_ = 1 to _max_ + 1
				for _k_ = _starts_[_L_] + 1 to _starts_[_L_ + 1]
					_aPosF_[ _order_[_k_] + 1 ] = _k_ - _starts_[_L_]
				next
			next
			@nLayoutCrossings = StzEngineGraphLayoutCrossings(_eu_, _ev_,
				_lay0_, _aPosF_, _starts_)

			_outc_ = _StzCsr(_eu_, _ev_, _n_)         # successors of u
			# :NodeExtra is a per-node half-width demand in SLOT units --
			# a node asking for more elbow room than a slot gives. The
			# face that knows why (an edge label wider than the node it
			# points at) computes it; this tier only carries it.
			_xtra_ = This._Opt(:NodeExtra, [])
			if NOT isList(_xtra_)  _xtra_ = []  ok
			if len(_xtra_) != _n_
				_xtra_ = []
				for _i_ = 1 to _n_  _xtra_ + 0  next
			ok
			# PINS: positions the layout may not argue with. The face
			# that knows which cells a user has moved sends them in slot
			# units, parallel to the nodes; -999999999 means free (a
			# position no picture reaches, and one Ring can write --
			# 1.0e18 is a parse error here). A batch picture sends none and is laid
			# out exactly as before.
			_apin_ = This._Opt(:Pins, [])
			if NOT isList(_apin_)  _apin_ = []  ok
			# PADDED, not discarded. The node set here is the REAL nodes
			# plus one dummy per rank a long edge crosses, so a vector
			# sized to the real nodes -- which is the only size the face
			# can build -- is shorter than this tier's `n`. Rejecting it
			# for the mismatch threw every pin away and laid the picture
			# out as if none had been set: a feature that silently did
			# nothing. Dummies are never pinned, so the tail is free.
			_apinN_ = []
			for _i_ = 1 to _n_
				if _i_ <= len(_apin_)
					_apinN_ + _apin_[_i_]
				else
					_apinN_ + (0 - 999999999)
				ok
			next
			_apin_ = _apinN_

			# A PIN DECIDES ORDER, NOT ONLY POSITION -- and without this
			# it decided neither that anyone could see. The rank ORDER is
			# settled by the crossing sweep before any coordinate exists,
			# and the coordinate pass only spaces a rank out while
			# preserving that order. So a pinned cell could shift its
			# whole rank sideways and never pass a sibling -- and since
			# _Normalise then refits the bounding box to the canvas, a
			# uniform shift disappears entirely. The engine honoured
			# every pin exactly and the picture was identical, which is
			# the most expensive kind of correct.
			#
			# Dragging a cell between two others has to MEAN that, so a
			# pin now sorts its rank: lay the graph out once free, then
			# order each rank by where its members actually are -- the
			# pin's own value for a pinned cell, the free layout's answer
			# for the rest -- and lay it out again with the pins held.
			# Two layouts of a 100-node graph cost 0.02s together, which
			# is the cheapest honest way to let a position outrank a
			# heuristic.
			_bAnyPin_ = 0
			for _pi_ = 1 to _n_
				if _apin_[_pi_] > (0 - 100000000)  _bAnyPin_ = 1  exit  ok
			next
			if _bAnyPin_
				_aFree_ = StzEngineGraphLayoutCoords(_csr_[1], _csr_[2],
					_outc_[1], _outc_[2], _order_, _starts_, 1.0, 8, _xtra_, [])
				if len(_aFree_) = _n_
					for _L2_ = 1 to _max_ + 1
						_aKey_ = []
						for _k2_ = _starts_[_L2_] + 1 to _starts_[_L2_ + 1]
							_id2_ = _order_[_k2_] + 1
							_kv_ = _aFree_[_id2_]
							if _apin_[_id2_] > (0 - 100000000)
								_kv_ = _apin_[_id2_]
							ok
							_aKey_ + [ _kv_, _order_[_k2_] ]
						next
						_aKey_ = sort(_aKey_, 1)
						for _k3_ = 1 to len(_aKey_)
							_order_[ _starts_[_L2_] + _k3_ ] = _aKey_[_k3_][2]
						next
					next
				ok
			ok

			_aXe_ = StzEngineGraphLayoutCoords(_csr_[1], _csr_[2],
				_outc_[1], _outc_[2], _order_, _starts_, 1.0, 8, _xtra_,
				_apin_)
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
			@bUnitX = 1

			# A CLUSTER IS DRAWN WITH CHROME -- a padded border and a label
			# above it -- and the placement knows only about node centres.
			# Two clusters sitting one slot apart therefore produce two
			# boxes that touch or overlap, which reads as one box. Half a
			# slot of extra air at every boundary where the cluster changes
			# costs nothing when there are no clusters, and is the
			# difference between two groups and one blur when there are.
			#
			# Applied AFTER placement and only ever as a rightward shift, so
			# the order and the minimum separation both survive it.
			_cmd2_ = This._ClusterMaxDepth()
			_clOf2_ = This._ClusterOf(_n_, 0)
			_bAnyC_ = 0
			for _v_ in _clOf2_
				if _v_ > 0  _bAnyC_ = 1  exit  ok
			next
			if _bAnyC_
				# COHESION FIRST. Contiguity puts a cluster's members next
				# to each other in the ORDER; it does not bring them
				# together on the page. Two databases still sat at opposite
				# ends of their rank because each was placed under its own
				# parent, so the box was correct and enormous -- a band, not
				# a group. Each cluster's members in a layer are pulled to
				# minimum separation about their own mean.
				#
				# INWARD ONLY, which is what makes this safe to do after
				# placement: the members' span can only shrink, so every
				# neighbour outside the cluster gains room and none loses
				# it. The order is untouched.
				# INNERMOST DEPTH FIRST, for the same reason compaction
				# runs that way: pulling an outer cluster together moves
				# whole inner blocks and leaves them tight, while the
				# reverse would spread the inner ones back out.
				for _dp2_ = max([ _cmd2_, 1 ]) to 1 step -1
				_clOfD_ = _clOf2_
				if _cmd2_ > 0  _clOfD_ = This._ClusterOf(_n_, _dp2_)  ok
				for _L_ = 1 to _max_ + 1
					_seen_ = []
					for _k_ = _starts_[_L_] + 1 to _starts_[_L_ + 1]
						_id_ = _order_[_k_] + 1
						_key_ = _clOfD_[_id_]
						if _key_ = 0  loop  ok
						_dup_ = 0
						for _sk_ in _seen_
							if _sk_ = _key_  _dup_ = 1  exit  ok
						next
						if _dup_  loop  ok
						_seen_ + _key_
						_mem_ = []
						for _k2_ = _starts_[_L_] + 1 to _starts_[_L_ + 1]
							_i2_ = _order_[_k2_] + 1
							if _clOfD_[_i2_] = _key_  _mem_ + _i2_  ok
						next
						_mn_ = len(_mem_)
						if _mn_ < 2  loop  ok
						_sum_ = 0
						for _m_ in _mem_  _sum_ += @aX[_m_]  next
						_mid_ = _sum_ / _mn_
						for _mi_ = 1 to _mn_
							@aX[ _mem_[_mi_] ] = _mid_ +
								(_mi_ - (_mn_ + 1) / 2)
						next
					next
				next
				next

				# AIR AT EVERY BOUNDARY CROSSED, one helping per level.
				# Two nodes in different OUTER clusters are also in
				# different inner ones, so they get two helpings and the
				# outer boxes separate more than the inner ones do -- which
				# is exactly what nesting has to look like, and it falls
				# out of counting rather than being a second rule.
				_air_ = This._Opt(:ClusterAir, 0.55)
				if NOT isNumber(_air_)  _air_ = 0.55  ok
				if _air_ < 0  _air_ = 0  ok
				for _L_ = 1 to _max_ + 1
					_sh_ = 0
					_prevD_ = []
					for _k_ = _starts_[_L_] + 1 to _starts_[_L_ + 1]
						_id_ = _order_[_k_] + 1
						_curD_ = []
						for _dp3_ = 1 to max([ _cmd2_, 1 ])
							if _cmd2_ = 0
								_curD_ + _clOf2_[_id_]
							else
								_curD_ + This._ClusterOf(_n_, _dp3_)[_id_]
							ok
						next
						# ONE HELPING PER BOUNDARY, and the size of it is asked
						# for rather than guessed at. This added 0.55 of a slot
						# per LEVEL crossed, so leaving two nested clusters at
						# once bought 1.1 slots -- 168px on the service diagram,
						# on top of the 52px of padding the frames already carry:
						# 204px of empty paper between a frame and its neighbour,
						# where a clearance is 24. The Principal called that
						# distance good and exaggerated, which is what a rule
						# scaling with the wrong quantity produces.
						#
						# What a boundary needs is that the FRAME clear the
						# foreign node: the deepest padding in the picture plus
						# one clearance. The face knows both in pixels and sends
						# the ratio (:ClusterAir); this tier only carries it, the
						# same contract as :NodeExtra. Nesting is already paid for
						# inside the padding, which grows per level, so the air is
						# charged once per crossing and not once per level.
						if len(_prevD_) > 0
							_bnd_ = 0
							for _dp4_ = 1 to len(_curD_)
								if _curD_[_dp4_] != _prevD_[_dp4_]  _bnd_ = 1  ok
							next
							if _bnd_  _sh_ += _air_  ok
						ok
						@aX[_id_] += _sh_
						_prevD_ = _curD_
					next
				next

				# ALIGNMENT IS THE LAST WORD, so it speaks again HERE.
				# The engine ends its coordinate pass with snapAlign, and
				# these two cluster passes -- cohesion and boundary air --
				# then moved whole columns a fraction of a slot. Every
				# chain the snap had made vertical became a near-miss
				# again, and the ROOT showed it worst: Balancer measured
				# 0.35 of a slot off the column it had been snapped onto.
				# Re-running the engine's own rule (never a Ring copy of
				# it -- the duplicated-logic law) restores exactness over
				# whatever the cluster passes chose.
				if @bUnitX
					_aXs_ = []
					for _i_ = 1 to _n_  _aXs_ + @aX[_i_]  next
					_aXs_ = StzEngineGraphLayoutSnapAlign(_csr_[1], _csr_[2],
						_outc_[1], _outc_[2], _order_, _starts_, 1.0,
						_xtra_, _aXs_)
					if len(_aXs_) = _n_
						for _i_ = 1 to _n_  @aX[_i_] = _aXs_[_i_]  next
					ok
				ok
			ok
		else
			@bUnitX = 0
		ok
		@nLayerCount = _max_ + 1

		# The dummies STAY IN @aX/@aY for now, and that ordering matters:
		# _Normalise fits the bounding box to the canvas, so reading the
		# chains before it would capture RAW coordinates while the nodes
		# ended up normalised -- two frames, and the routes left the picture
		# through its top-left corner. Keeping them also makes _Normalise
		# reserve room for the routes, which is the point of having them.
		# _ExtractRoutes, called after, reads them back and trims.
		@nRealCount = _nReal_
		@aDumEdge = []
		for _de_ in _dumEdge_
			@aDumEdge + [ "" + _aE0_[_de_[1]][:from],
			              "" + _aE0_[_de_[1]][:to], _de_[2] ]
		next

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
	# Read each long edge's chain out of the NORMALISED coordinates, then
	# drop the dummies. They exist to be laid out, not to be drawn: a
	# caller asking for Positions() must get its own nodes and nothing
	# else, or every consumer downstream learns to ignore nodes the graph
	# does not contain.
	# clusterKey per node index, 0 for "belongs to none". Dummies are never
	# in a cluster -- a long edge crossing a cluster's ranks must be free to
	# route around it, and pinning it inside would be the opposite of what
	# the constraint is for.
	# clusterKey per node index for the clusters at ONE nesting depth, 0 for
	# "in no cluster at that depth". Pass 0 for "any depth", which is what a
	# flat cluster list means.
	#
	# Depth is what makes nesting expressible at all: a node inside
	# Data-inside-Backend has one key at depth 1 (Backend) and another at
	# depth 2 (Data), and the two constraints are applied separately.
	def _ClusterOf(nCount, nDepth)
		_co_ = []
		for _i_ = 1 to nCount  _co_ + 0  next
		_cls_ = This._Opt(:Clusters, [])
		if NOT isList(_cls_)  return _co_  ok
		_k_ = 0
		for _cl_ in _cls_
			if NOT (isList(_cl_) and len(_cl_) >= 2)  loop  ok
			_k_++
			if nDepth > 0
				_d_ = 1
				if len(_cl_) >= 3 and isNumber(_cl_[3])  _d_ = _cl_[3]  ok
				if _d_ != nDepth  loop  ok
			ok
			for _id_ in _cl_[2]
				_ix_ = This._IndexOf("" + _id_)
				if _ix_ >= 1 and _ix_ <= nCount  _co_[_ix_] = _k_  ok
			next
		next
		return _co_

	# The deepest nesting level any cluster declares.
	def _ClusterMaxDepth()
		_m_ = 0
		_cls_ = This._Opt(:Clusters, [])
		if NOT isList(_cls_)  return 0  ok
		for _cl_ in _cls_
			if NOT (isList(_cl_) and len(_cl_) >= 2)  loop  ok
			_d_ = 1
			if len(_cl_) >= 3 and isNumber(_cl_[3])  _d_ = _cl_[3]  ok
			if _d_ > _m_  _m_ = _d_  ok
		next
		return _m_

	# Reorder each layer so a cluster's members sit TOGETHER, keeping the
	# sweep's sense of left-to-right.
	#
	# Groups are placed by their MEAN position in the order the sweep chose,
	# and inside a group the sweep's relative order is untouched -- so the
	# crossing work is respected wherever the constraint does not contradict
	# it. An unclustered node is its own group; merging them into one blob
	# would be a constraint nobody asked for, and would push clusters apart
	# for no reason.
	def _ClusterCompact(paOrder, paStarts, nMax, paClusterOf)
		_cc_ = 0
		for _v_ in paClusterOf
			if _v_ > 0  _cc_ = 1  exit  ok
		next
		if _cc_ = 0  return paOrder  ok

		_out_ = []
		for _L_ = 1 to nMax + 1
			_s_ = paStarts[_L_]
			_e_ = paStarts[_L_ + 1]
			_grp_ = []                      # [ key, [members], sumPos, count ]
			for _k_ = _s_ + 1 to _e_
				_v_ = paOrder[_k_] + 1
				_key_ = 0
				if _v_ >= 1 and _v_ <= len(paClusterOf)
					_key_ = paClusterOf[_v_]
				ok
				_at_ = 0
				if _key_ > 0
					for _gi_ = 1 to len(_grp_)
						if _grp_[_gi_][1] = _key_  _at_ = _gi_  exit  ok
					next
				ok
				if _at_ = 0
					_grp_ + [ _key_, [ paOrder[_k_] ], _k_, 1 ]
				else
					_grp_[_at_][2] + paOrder[_k_]
					_grp_[_at_][3] += _k_
					_grp_[_at_][4]++
				ok
			next
			_rank_ = []
			for _gi_ = 1 to len(_grp_)
				_rank_ + [ _grp_[_gi_][3] / _grp_[_gi_][4], _gi_ ]
			next
			_rank_ = sort(_rank_, 1)
			for _r_ in _rank_
				for _m_ in _grp_[ _r_[2] ][2]
					_out_ + _m_
				next
			next
		next
		return _out_

	def _ExtractRoutes()
		@aBendOf = []
		if len(@aDumEdge) = 0  return  ok
		for _de_ in @aDumEdge
			_pts_ = []
			for _dn_ in _de_[3]
				if _dn_ >= 1 and _dn_ <= len(@aX)
					_pts_ + [ @aX[_dn_], @aY[_dn_] ]
				ok
			next
			if len(_pts_) > 0
				@aBendOf + [ _de_[1], _de_[2], _pts_ ]
			ok
		next
		if @nRealCount > 0 and len(@aX) > @nRealCount
			_kx_ = []  _ky_ = []
			for _i_ = 1 to @nRealCount  _kx_ + @aX[_i_]  _ky_ + @aY[_i_]  next
			@aX = _kx_
			@aY = _ky_
		ok

	def _Normalise()
		_n_ = len(@aX)
		# THE LAYOUT'S OWN COORDINATE, kept before this pass rewrites it
		# into canvas pixels. A live diagram has to turn a cursor
		# position back into a layout position -- a drag only becomes a
		# pin once someone can say which slot the cursor is over -- and
		# that inverse needs the map this pass is about to discard.
		@aXRaw = []
		for _rk_ = 1 to _n_  @aXRaw + @aX[_rk_]  next
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
		@nRawSpanX = _sw_
		@nRawSpanY = _sh_
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

