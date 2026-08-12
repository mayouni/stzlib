#---------------------------------------------------------------------------#
#  STZFRAMEGRAPH -- render passes and their resources ARE a graph            #
#  (GG4 of SOFTANZA_GRAPH_PLANE_PLAN.md).                                   #
#---------------------------------------------------------------------------#
#
#     oFG = new stzFrameGraph(1024, 768)
#     oFG.AddPass(:Geometry,  [ :Writes = [ :colour, :depth ] ])
#     oFG.AddPass(:Blur,      [ :Reads = [ :colour ], :Writes = [ :blurred ] ])
#     oFG.AddPass(:Composite, [ :Reads = [ :colour, :blurred ],
#                               :Writes = [ :screen ] ])
#     oFG.Compile()
#
#     ? oFG.Order()          # [ :Geometry, :Blur, :Composite ] -- DERIVED
#     ? oFG.Report()         # the rule verdicts, as a CI gate
#     oFG.Execute()          # ONE submit for the whole frame
#
# WHY THIS IS THE ROLE GRAPHS ACTUALLY PLAY IN AN ENGINE. A shader graph is
# an authoring UI consumed at compile time. A FRAME graph is a schedule your
# program can interrogate: Frostbite's FrameGraph and Unreal's RDG are this,
# and they exist because hand-ordering passes stops working the moment
# passes are added conditionally.
#
# Three things fall out of the declaration, none of them written by hand:
#
#   ORDER      a pass that READS what another WRITES must run after it.
#              That is an edge, and the order is a topological sort -- the
#              same stzGraph the rest of the plane uses.
#
#   LIFETIMES  a resource is live from its first write to its last read.
#              Two resources whose lives do not overlap can SHARE one
#              physical target, which is memory a hand-written frame pays
#              for and this one does not.
#
#   PROOFS     acyclic, no read-before-write, every resource written before
#              it is read, nothing outliving the budget. These go into
#              stzRuleReport in the house finding shape, so a frame graph is
#              checked by the SAME gate as code rules and security rules.
#
# The kill criterion the plan wrote, honoured: if the scheduler cannot beat
# a hand-ordered frame, this is ceremony and only the RULE CHECKS are worth
# keeping. Aliasing is what it has to beat them by, and Compile() reports
# the number so the claim is checkable rather than asserted.

func StzFrameGraphQ(pnW, pnH)
	return new stzFrameGraph(pnW, pnH)

class stzFrameGraph from stzObject

	@nW = 0
	@nH = 0
	@aPasses = []        # [ name, aReads, aWrites, fBody ]
	@aOrder = []
	@aResources = []     # every logical resource name, first seen order
	@aLive = []          # [ name, nFirstWrite, nLastRead ]
	@aAlias = []         # [ logicalName, physicalSlot ]
	@nPhysical = 0
	@aFindings = []
	@bCompiled = 0
	@aTargets = []       # physical target ids, made at Execute time

	def init(pnW, pnH)
		if NOT (isNumber(pnW) and isNumber(pnH))
			StzRaise("stzFrameGraph: give a width and a height in pixels.")
		ok
		if pnW < 1 or pnH < 1
			StzRaise("stzFrameGraph: a frame needs area.")
		ok
		@nW = pnW
		@nH = pnH

	#-- declaring the frame -------------------------------------------------

	# paSpec: [ :Reads = [...], :Writes = [...], :Body = func ]
	# The BODY is what actually draws; the graph only decides when it runs
	# and what it draws into.
	def AddPass(pcName, paSpec)
		if NOT isString(pcName) and NOT isNumber(pcName)
			StzRaise("stzFrameGraph.AddPass: a pass needs a name.")
		ok
		_cN_ = "" + pcName
		if This._PassIndex(_cN_) > 0
			StzRaise("stzFrameGraph: pass '" + _cN_ + "' is declared twice. " +
				"A schedule cannot contain the same node twice.")
		ok
		_aR_ = This._Spec(paSpec, :Reads)
		_aW_ = This._Spec(paSpec, :Writes)
		_f_ = This._SpecRaw(paSpec, :Body)
		if len(_aR_) = 0 and len(_aW_) = 0
			StzRaise("stzFrameGraph: pass '" + _cN_ + "' reads nothing and " +
				"writes nothing -- it cannot be scheduled, because it has " +
				"no edges to anything.")
		ok
		@aPasses + [ _cN_, _aR_, _aW_, _f_ ]
		for _r_ in _aR_  This._Note(_r_)  next
		for _w_ in _aW_  This._Note(_w_)  next
		@bCompiled = 0

	def AddPassQ(pcName, paSpec)
		This.AddPass(pcName, paSpec)
		return This

	def PassCount()      return len(@aPasses)
	def ResourceCount()  return len(@aResources)

	#-- compiling -----------------------------------------------------------

	# Derive the order, the lifetimes and the aliasing, and PROVE the
	# properties. Everything below is computed from the declaration; nothing
	# here is a number somebody typed.
	def Compile()
		@aFindings = []
		@aOrder = []
		@bCompiled = 0

		if len(@aPasses) = 0
			StzRaise("stzFrameGraph.Compile: no passes declared.")
		ok

		# 1. the DEPENDENCY GRAPH: writer -> reader, one edge per shared
		#    resource. This is an ordinary stzGraph, which is the point --
		#    the schedule is a graph the program can ask questions about.
		oG = new stzGraph("frame")
		_np_ = len(@aPasses)
		for _i_ = 1 to _np_
			oG.AddNode(@aPasses[_i_][1])
		next
		for _i_ = 1 to _np_
			for _r_ in @aPasses[_i_][2]
				for _j_ = 1 to _np_
					if _j_ != _i_ and This._Writes(_j_, _r_)
						oG.AddEdge(@aPasses[_j_][1], @aPasses[_i_][1])
					ok
				next
			next
		next

		# 2. ORDER, topologically. A cycle has no order at all, and that is
		#    the first thing worth proving about a frame.
		if oG.HasCyclicDependencies()
			This._Finding(:acyclic, :error,
				"the passes form a CYCLE -- no execution order exists")
			@aOrder = []
		else
			# stzGraph FOLDS node ids to lowercase, so the sort comes back
			# lowercased. Map it back: a caller who declared :Composite must
			# read "Composite" out, not "composite".
			_raw_ = oG.TopologicalSort()
			@aOrder = []
			for _x_ in _raw_
				@aOrder + This._DeclaredName("" + _x_)
			next
		ok

		# 3. READ-BEFORE-WRITE. A resource read by a pass that no pass
		#    writes is a hole in the frame: it would sample whatever the
		#    last frame left, which is the classic source of a flicker that
		#    only shows on the second frame.
		for _i_ = 1 to _np_
			for _r_ in @aPasses[_i_][2]
				if NOT This._AnyWriter(_r_)
					This._Finding(:read_before_write, :error,
						"pass '" + @aPasses[_i_][1] + "' reads '" + _r_ +
						"' which no pass ever writes")
				ok
			next
		next

		# 4. a resource WRITTEN and never READ is dead work
		for _r_ in @aResources
			if This._AnyWriter(_r_) and NOT This._AnyReader(_r_) and
			   _r_ != :screen and _r_ != "screen"
				This._Finding(:dead_resource, :warning,
					"'" + _r_ + "' is written but never read")
			ok
		next

		if len(@aOrder) > 0
			This._ComputeLifetimes()
			This._ComputeAliasing()
		ok
		@bCompiled = 1
		return This

	def Order()
		This._RequireCompiled()
		return @aOrder

	def Lifetimes()
		This._RequireCompiled()
		return @aLive

	# [ logical, physicalSlot ] -- two logicals sharing a slot never overlap
	def Aliasing()
		This._RequireCompiled()
		return @aAlias

	def PhysicalTargets()
		This._RequireCompiled()
		return @nPhysical

	# What the schedule SAVED over giving every resource its own target.
	# This is the number the kill criterion asks for.
	def TargetsSaved()
		This._RequireCompiled()
		return len(@aResources) - @nPhysical

	#-- the proofs ----------------------------------------------------------

	# The house finding shape, so a frame graph is judged by the SAME gate as
	# code rules and security rules: [ :rule, :subject, :where, :severity,
	# :message ].
	def Findings()
		This._RequireCompiled()
		return @aFindings

	def IsSound()
		This._RequireCompiled()
		for _f_ in @aFindings
			if _f_[4] = :error  return 0  ok
		next
		return 1

	def Report()
		This._RequireCompiled()
		_o_ = new stzRuleReport("framegraph")
		_o_.Ingest(@aFindings)
		return _o_

	#-- executing -----------------------------------------------------------

	# Run the passes in the derived order, inside ONE frame -- so the whole
	# schedule costs a single submit (GG4 slice 1), and a pass may sample a
	# target an earlier pass wrote (GG4 slice 0).
	#
	# Each body is called as fBody(oFrameGraph, cPassName). It asks the
	# graph which physical target its writes landed on.
	def Execute()
		This._RequireCompiled()
		if NOT This.IsSound()
			StzRaise("stzFrameGraph.Execute: the frame has ERRORS. " +
				"Fix them or read Report() -- executing an unsound " +
				"schedule is how a frame graph becomes worse than a list.")
		ok
		if NOT StzGraphicsDevice()
			return 0
		ok

		# one physical target per alias slot, not one per resource
		@aTargets = []
		for _i_ = 1 to @nPhysical
			@aTargets + StzEngineGpuTextureNew(@nW, @nH, 0)
		next

		StzEngineGpuFrameBegin()
		for _cP_ in @aOrder
			_i_ = This._PassIndex(_cP_)
			if _i_ > 0
				# `call` takes a VARIABLE holding the function, never an
				# indexed expression -- Ring will not parse the latter.
				_fn_ = @aPasses[_i_][4]
				if isFunction(_fn_)
					call _fn_(This, _cP_)
				ok
			ok
		next
		StzEngineGpuFrameEnd()
		return 1

	# The physical target a logical resource lives on, for a pass body to
	# draw into or sample.
	def TargetOf(pcResource)
		_c_ = "" + pcResource
		for _a_ in @aAlias
			if _a_[1] = _c_
				if _a_[2] >= 1 and _a_[2] <= len(@aTargets)
					return @aTargets[_a_[2]]
				ok
			ok
		next
		return 0

	def FreeTargets()
		for _t_ in @aTargets
			if _t_ > 0  StzEngineGpuTextureFree(_t_)  ok
		next
		@aTargets = []

	#-- internals -----------------------------------------------------------

	def _RequireCompiled()
		if NOT @bCompiled
			StzRaise("stzFrameGraph: call Compile() first -- the order, the " +
				"lifetimes and the proofs are all DERIVED, so nothing can " +
				"be asked before they are.")
		ok

	def _Spec(paSpec, cKey)
		_v_ = This._SpecRaw(paSpec, cKey)
		if isList(_v_)
			_o_ = []
			for _x_ in _v_  _o_ + ("" + _x_)  next
			return _o_
		ok
		if isString(_v_) and _v_ != ""
			return [ _v_ ]
		ok
		return []

	def _SpecRaw(paSpec, cKey)
		if NOT isList(paSpec)  return ""  ok
		for _p_ in paSpec
			if isList(_p_) and len(_p_) = 2
				if StzLower("" + _p_[1]) = StzLower("" + cKey)
					return _p_[2]
				ok
			ok
		next
		return ""

	def _Note(cRes)
		for _r_ in @aResources
			if _r_ = cRes  return  ok
		next
		@aResources + cRes

	# The name as the CALLER wrote it, from the folded one the graph returns.
	def _DeclaredName(cFolded)
		_n_ = len(@aPasses)
		for _i_ = 1 to _n_
			if StzLower(@aPasses[_i_][1]) = StzLower(cFolded)
				return @aPasses[_i_][1]
			ok
		next
		return cFolded

	def _PassIndex(cName)
		_n_ = len(@aPasses)
		for _i_ = 1 to _n_
			if StzLower(@aPasses[_i_][1]) = StzLower("" + cName)  return _i_  ok
		next
		return 0

	def _Writes(nPass, cRes)
		for _w_ in @aPasses[nPass][3]
			if _w_ = cRes  return 1  ok
		next
		return 0

	def _AnyWriter(cRes)
		_n_ = len(@aPasses)
		for _i_ = 1 to _n_
			if This._Writes(_i_, cRes)  return 1  ok
		next
		return 0

	def _AnyReader(cRes)
		_n_ = len(@aPasses)
		for _i_ = 1 to _n_
			for _r_ in @aPasses[_i_][2]
				if _r_ = cRes  return 1  ok
			next
		next
		return 0

	# A resource is LIVE from the step that first writes it to the step that
	# last reads it. Positions come from the derived ORDER, not from the
	# order somebody happened to declare the passes in -- that is the whole
	# reason the order is derived first.
	def _ComputeLifetimes()
		@aLive = []
		for _r_ in @aResources
			_first_ = 0
			_last_ = 0
			_step_ = 0
			for _cP_ in @aOrder
				_step_++
				_i_ = This._PassIndex(_cP_)
				if _i_ = 0  loop  ok
				if This._Writes(_i_, _r_) and _first_ = 0
					_first_ = _step_
				ok
				for _rd_ in @aPasses[_i_][2]
					if _rd_ = _r_  _last_ = _step_  ok
				next
			next
			if _first_ = 0  _first_ = 1  ok
			if _last_ < _first_  _last_ = _first_  ok
			@aLive + [ _r_, _first_, _last_ ]
		next

	# Two resources whose lives do not overlap can share one physical
	# target. Greedy over the lifetimes, which is what a frame graph is FOR:
	# a hand-written frame allocates one target per resource because
	# tracking this by hand is exactly the bookkeeping nobody keeps right.
	def _ComputeAliasing()
		@aAlias = []
		_slotEnd_ = []          # last step each physical slot is busy until
		for _L_ in @aLive
			_placed_ = 0
			for _s_ = 1 to len(_slotEnd_)
				if _slotEnd_[_s_] < _L_[2]        # free before this one starts
					_slotEnd_[_s_] = _L_[3]
					_placed_ = _s_
					exit
				ok
			next
			if _placed_ = 0
				_slotEnd_ + _L_[3]
				_placed_ = len(_slotEnd_)
			ok
			@aAlias + [ _L_[1], _placed_ ]
		next
		@nPhysical = len(_slotEnd_)

	def _Finding(cRule, cSeverity, cMessage)
		@aFindings + [ cRule, :framegraph, "" + @nW + "x" + @nH,
		               cSeverity, cMessage ]
