#---------------------------------------------------------------------------#
#  STZMATERIALGRAPH -- a material AS a graph (GG5 of                         #
#  SOFTANZA_GRAPH_PLANE_PLAN.md).                                            #
#---------------------------------------------------------------------------#
#
#     oG = new stzMaterialGraph()
#     oG.TakesColor(:base)  oG.TakesScalar(:sharp)  oG.TakesTexture(:skin)
#
#     oG.AddNode(:tex,  [ :Op = :Sample,   :In = [ :skin, "@uv" ] ])
#     oG.AddNode(:lit,  [ :Op = :Multiply, :In = [ :tex, "@lambert" ] ])
#     oG.AddNode(:rim,  [ :Op = :Fresnel,  :In = [ :sharp ] ])
#     oG.AddNode(:out,  [ :Op = :Mix,      :In = [ :lit, :base, :rim ] ])
#     oG.Emits(:out)
#     oG.Compile()
#
#     ? oG.Order()          # DERIVED, not declared
#     ? oG.ToW()            # the material-language body it emitted
#     oScene.SetMaterial(oG.ToMaterial(), [ :base = "#e0a030", ... ])
#
# WHY THIS IS NOT SHADERGRAPH. In ShaderGraph the graph is SYNTAX: an
# authoring UI, consumed at compile time, that your program can never
# interrogate. Here it is a stzGraph -- so the material answers questions
# with the same algorithms the rest of the plane uses:
#
#     oG.Order()            topological sort
#     oG.ImpactOf(:tex)     which nodes downstream depend on this one
#     oG.Report()           findings in the house rule shape
#
# Asking "what does this node affect?" is a REACHABILITY query, and a
# material that can answer it is a computational object rather than a
# picture of one.
#
# THREE THINGS ARE DERIVED, none of them written by hand:
#
#   ORDER      a node that CONSUMES another must be emitted after it, which
#              is a topological sort. Declare them in any order at all.
#
#   REUSE      a node consumed TWICE is emitted ONCE, as one `let`. That is
#              the whole dividend of a DAG over a tree, and the thing string
#              concatenation cannot do without help.
#
#   PROOFS     acyclic, every input resolves, nothing computed for nobody.
#              Same finding shape and same stzRuleReport gate as the frame
#              graph, the code rules and the security rules.
#
# It emits the MATERIAL LANGUAGE, not WGSL. The language already refuses
# what it should refuse; a second transpiler would be a second set of rules
# to keep in agreement with the first.

func StzMaterialGraphQ()
	return new stzMaterialGraph()

# The op table: name -> [ arity, template ]. `$1..$3` are the inputs.
# Deliberately small and deliberately SURFACE verbs -- this is not a
# general expression language, it is the set of things a material does.
func StzMaterialGraphOps()
	return [
		[ :Sample,     2, "sample($1, $2)" ],
		[ :Multiply,   2, "($1 * $2)" ],
		[ :Add,        2, "($1 + $2)" ],
		[ :Subtract,   2, "($1 - $2)" ],
		[ :Mix,        3, "mix($1, $2, $3)" ],
		[ :Smoothstep, 3, "smoothstep($1, $2, $3)" ],
		[ :Step,       2, "step($1, $2)" ],
		[ :Clamp,      3, "clamp($1, $2, $3)" ],
		[ :Pow,        2, "pow($1, $2)" ],
		[ :Fract,      1, "fract($1)" ],
		[ :Abs,        1, "abs($1)" ],
		[ :Sqrt,       1, "sqrt($1)" ],
		[ :Sin,        1, "sin($1)" ],
		[ :Cos,        1, "cos($1)" ],
		[ :Dot,        2, "dot($1, $2)" ],
		[ :OneMinus,   1, "(1.0 - $1)" ],
		# Two compound verbs, because they are what materials actually say
		# and spelling them out every time is how a node graph turns into
		# the string concatenation it was meant to replace.
		[ :Fresnel,    1, "pow(1.0 - abs(@normal.z), $1)" ],
		[ :Lit,        1, "(@lambert * (1.0 - $1) + $1)" ]
	]

class stzMaterialGraph from stzObject

	@aColors = []
	@aScalars = []
	@aTextures = []
	@aNodes = []          # [ name, opName, aInputs ]
	@cOut = ""
	@aOrder = []
	@aFindings = []
	@aUses = []           # [ nodeName, nConsumers ] -- the reuse witness
	@bCompiled = 0
	@oGraph = ""

	def init()

	#-- what the material takes from outside --------------------------------

	def TakesColor(pcName)
		@aColors + StzLower("" + pcName)
		@bCompiled = 0

	def TakesColorQ(pcName)
		This.TakesColor(pcName)
		return This

	def TakesScalar(pcName)
		@aScalars + StzLower("" + pcName)
		@bCompiled = 0

	def TakesScalarQ(pcName)
		This.TakesScalar(pcName)
		return This

	def TakesTexture(pcName)
		@aTextures + StzLower("" + pcName)
		@bCompiled = 0

	def TakesTextureQ(pcName)
		This.TakesTexture(pcName)
		return This

	#-- declaring the graph -------------------------------------------------

	# paSpec: [ :Op = :Mix, :In = [ ... ] ]
	# An input is a NODE name, a declared colour/scalar/texture name, a
	# builtin written "@normal.y", or a plain NUMBER.
	def AddNode(pcName, paSpec)
		_cN_ = StzLower("" + pcName)
		if _cN_ = ""
			StzRaise("stzMaterialGraph.AddNode: a node needs a name.")
		ok
		if This._NodeIndex(_cN_) > 0
			StzRaise("stzMaterialGraph: node '" + _cN_ + "' is declared " +
				"twice. A graph cannot contain the same node twice.")
		ok
		if This._IsDeclaredValue(_cN_)
			StzRaise("stzMaterialGraph: '" + _cN_ + "' is already a declared " +
				"colour, scalar or texture -- a node cannot shadow one, " +
				"because every input would then be ambiguous.")
		ok

		_cOp_ = StzLower("" + This._Spec(paSpec, :Op))
		_aOp_ = This._Op(_cOp_)
		if len(_aOp_) = 0
			StzRaise("stzMaterialGraph: '" + _cOp_ + "' is not an op. " +
				"The ops are: " + This._OpList() + ".")
		ok

		_aIn_ = This._Spec(paSpec, :In)
		if NOT isList(_aIn_)  _aIn_ = [ _aIn_ ]  ok
		if len(_aIn_) != _aOp_[2]
			StzRaise("stzMaterialGraph: '" + _cOp_ + "' takes " + _aOp_[2] +
				" input(s), node '" + _cN_ + "' gave " + len(_aIn_) + ".")
		ok

		_aI_ = []
		_aX6_ = _aIn_
		_nX6_ = len(_aX6_)
		for _iX6_ = 1 to _nX6_
			_x_ = _aX6_[_iX6_]
			if isNumber(_x_)
				_aI_ + _x_
			else
				_aI_ + StzLower("" + _x_)
			ok
		next
		@aNodes + [ _cN_, _cOp_, _aI_ ]
		@bCompiled = 0

	def AddNodeQ(pcName, paSpec)
		This.AddNode(pcName, paSpec)
		return This

	# The node whose value becomes @out.
	def Emits(pcName)
		@cOut = StzLower("" + pcName)
		@bCompiled = 0

	def EmitsQ(pcName)
		This.Emits(pcName)
		return This

	def NodeCount()  return len(@aNodes)
	def OutputNode() return @cOut

	#-- compiling -----------------------------------------------------------

	def Compile()
		@aFindings = []
		@aOrder = []
		@aUses = []
		@bCompiled = 0

		if len(@aNodes) = 0
			StzRaise("stzMaterialGraph.Compile: no nodes declared.")
		ok
		if @cOut = ""
			StzRaise("stzMaterialGraph.Compile: no output -- say Emits(:node). " +
				"A material graph with no output computes nothing.")
		ok
		if This._NodeIndex(@cOut) = 0
			StzRaise("stzMaterialGraph.Compile: the output node '" + @cOut +
				"' does not exist.")
		ok

		# 1. EVERY INPUT MUST RESOLVE. Checked first, because an unresolved
		#    input is not an edge, and a graph missing edges would sort into
		#    a plausible-looking wrong order rather than refusing.
		_nn_ = len(@aNodes)
		for _cmi_ = 1 to _nn_
			_aCmx6_ = @aNodes[_cmi_][3]
			_nCmx6_ = len(_aCmx6_)
			for _iCmx6_ = 1 to _nCmx6_
				_cmx_ = _aCmx6_[_iCmx6_]
				if isNumber(_cmx_)  loop  ok
				if This._NodeIndex(_cmx_) > 0  loop  ok
				if This._IsDeclaredValue(_cmx_)  loop  ok
				if This._IsBuiltinRef(_cmx_)  loop  ok
				This._Finding(:unresolved_input, :error,
					"node '" + @aNodes[_cmi_][1] + "' reads '" + _cmx_ +
					"' which is not a node, not a declared value and not a " +
					"fragment builtin")
			next
		next

		# 2. THE DAG. producer -> consumer, one edge per consumed node. This
		#    is an ordinary stzGraph, which is the point: the material is
		#    then answerable by every algorithm the graph plane has.
		@oGraph = new stzGraph("material")
		for _cmi_ = 1 to _nn_
			@oGraph.AddNode(@aNodes[_cmi_][1])
		next
		for _cmi_ = 1 to _nn_
			_aCmx5_ = @aNodes[_cmi_][3]
			_nCmx5_ = len(_aCmx5_)
			for _iCmx5_ = 1 to _nCmx5_
				_cmx_ = _aCmx5_[_iCmx5_]
				if isString(_cmx_) and This._NodeIndex(_cmx_) > 0
					@oGraph.AddEdge(_cmx_, @aNodes[_cmi_][1])
				ok
			next
		next

		if @oGraph.HasCyclicDependencies()
			This._Finding(:acyclic, :error,
				"the nodes form a CYCLE -- a value cannot be its own input, " +
				"and no emission order exists")
			@bCompiled = 1
			return This
		ok

		# stzGraph folds node ids to lowercase; the names already are.
		_raw_ = @oGraph.TopologicalSort()
		@aOrder = []
		_aCmx5_ = _raw_
		_nCmx5_ = len(_aCmx5_)
		for _iCmx5_ = 1 to _nCmx5_
			_cmx_ = _aCmx5_[_iCmx5_]
			@aOrder + ("" + _cmx_)
		next

		# 3. REUSE, counted. A node consumed twice is emitted ONCE -- the
		#    dividend of a DAG over a tree, kept as a NUMBER so the claim is
		#    checkable rather than asserted.
		for _cmi_ = 1 to _nn_
			@aUses + [ @aNodes[_cmi_][1], This._ConsumerCount(@aNodes[_cmi_][1]) ]
		next

		# 4. DEAD WORK: computed for nobody. A warning, not an error -- it
		#    shades correctly, it just costs.
		for _cmi_ = 1 to _nn_
			_cmc_ = @aNodes[_cmi_][1]
			if _cmc_ != @cOut and This._ConsumerCount(_cmc_) = 0
				This._Finding(:dead_node, :warning,
					"'" + _cmc_ + "' is computed but nothing reads it")
			ok
		next

		@bCompiled = 1
		return This

	def Order()
		This._RequireCompiled()
		return @aOrder

	# [ nodeName, nConsumers ] -- how many nodes read each one.
	def Uses()
		This._RequireCompiled()
		return @aUses

	# How many `let` bindings the emission SAVED over expanding the graph as
	# a tree: every extra consumer of a node is a subtree not re-emitted.
	def ReuseSaved()
		This._RequireCompiled()
		_n_ = 0
		_aU4_ = @aUses
		_nU4_ = len(_aU4_)
		for _iU4_ = 1 to _nU4_
			_u_ = _aU4_[_iU4_]
			if _u_[2] > 1  _n_ += (_u_[2] - 1)  ok
		next
		return _n_

	# The question ShaderGraph cannot answer: what does this node AFFECT?
	#
	# Reachability, answered by the same stzGraph the rest of the plane uses.
	# Affects() lists them, ImpactOf() counts them -- the house convention,
	# where ImpactOf is a NUMBER and ReachableFrom is a LIST that includes
	# the node itself.
	def Affects(pcNode)
		This._RequireCompiled()
		if NOT isObject(@oGraph)  return []  ok
		_cN_ = StzLower("" + pcNode)
		_a_ = []
		_aX1_ = @oGraph.ReachableFrom(_cN_)
		_nX1_ = len(_aX1_)
		for _iX1_ = 1 to _nX1_
			_x_ = _aX1_[_iX1_]
			if StzLower("" + _x_) != _cN_  _a_ + ("" + _x_)  ok
		next
		return _a_

	def ImpactOf(pcNode)
		This._RequireCompiled()
		if NOT isObject(@oGraph)  return 0  ok
		return @oGraph.ImpactOf(StzLower("" + pcNode))

	#-- the proofs ----------------------------------------------------------

	def Findings()
		This._RequireCompiled()
		return @aFindings

	def IsSound()
		This._RequireCompiled()
		_aF3_ = @aFindings
		_nF3_ = len(_aF3_)
		for _iF3_ = 1 to _nF3_
			_f_ = _aF3_[_iF3_]
			if _f_[4] = :error  return 0  ok
		next
		return 1

	def Report()
		This._RequireCompiled()
		_o_ = new stzRuleReport("materialgraph")
		_o_.Ingest(@aFindings)
		return _o_

	#-- emitting ------------------------------------------------------------

	# The material-language BODY, in the derived order. This is the artefact:
	# a graph that emitted text you can read is a graph you can debug.
	def ToW()
		This._RequireCompiled()
		if NOT This.IsSound()
			StzRaise("stzMaterialGraph.ToW: the graph has ERRORS. Read " +
				"Report() -- emitting from an unsound graph produces a " +
				"shader whose refusal names the wrong thing.")
		ok
		_c_ = "{ "
		_aCN2_ = @aOrder
		_nCN2_ = len(_aCN2_)
		for _iCN2_ = 1 to _nCN2_
			_cN_ = _aCN2_[_iCN2_]
			if _cN_ = @cOut  loop  ok
			_c_ += "let n_" + _cN_ + " = " + This._Expr(_cN_) + "; "
		next
		_c_ += "@out = " + This._Expr(@cOut) + " }"
		return _c_

	# The material itself, ready for stzScene.SetMaterial.
	def ToMaterial()
		_o_ = new stzMaterialMaker()
		_aC7_ = @aColors
		_nC7_ = len(_aC7_)
		for _iC7_ = 1 to _nC7_
			_c_ = _aC7_[_iC7_]
			_o_.TakesColor(_c_)
		next
		_aS6_ = @aScalars
		_nS6_ = len(_aS6_)
		for _iS6_ = 1 to _nS6_
			_s_ = _aS6_[_iS6_]
			_o_.TakesScalar(_s_)
		next
		_aT5_ = @aTextures
		_nT5_ = len(_aT5_)
		for _iT5_ = 1 to _nT5_
			_t_ = _aT5_[_iT5_]
			_o_.TakesTexture(_t_)
		next
		_o_.ForEachFragment(This.ToW())
		return _o_

	def ToWGSL()
		return This.ToMaterial().ToWGSL()

	#-- internals -----------------------------------------------------------

	def _RequireCompiled()
		if NOT @bCompiled
			StzRaise("stzMaterialGraph: call Compile() first -- the order, " +
				"the reuse and the proofs are all DERIVED, so nothing can " +
				"be asked before they are.")
		ok

	# One node's expression, with its inputs already named. A consumed node
	# is referenced by its `let`, never re-expanded -- which is exactly what
	# makes the DAG worth having.
	def _Expr(pcNode)
		_exi_ = This._NodeIndex(pcNode)
		_exOp_ = This._Op(@aNodes[_exi_][2])
		_exc_ = _exOp_[3]
		_exk_ = 0
		_aExx4_ = @aNodes[_exi_][3]
		_nExx4_ = len(_aExx4_)
		for _iExx4_ = 1 to _nExx4_
			_exx_ = _aExx4_[_iExx4_]
			_exk_++
			_exc_ = StzReplace(_exc_, "$" + _exk_, This._Ref(_exx_))
		next
		return _exc_

	def _Ref(x)
		if isNumber(x)
			# WGSL will not promote an integer literal into a float
			# expression, so a material graph that emitted "2" where the
			# language expects a float would refuse at transpile time with
			# a message about types the author never wrote.
			if x = floor(x)  return "" + x + ".0"  ok
			return "" + x
		ok
		if This._NodeIndex(x) > 0  return "n_" + x  ok
		return x

	def _NodeIndex(cName)
		_nin_ = len(@aNodes)
		for _nix_ = 1 to _nin_
			if @aNodes[_nix_][1] = cName  return _nix_  ok
		next
		return 0

	def _ConsumerCount(cName)
		_ccn_ = len(@aNodes)  _cck_ = 0
		for _cci_ = 1 to _ccn_
			_aCcx3_ = @aNodes[_cci_][3]
			_nCcx3_ = len(_aCcx3_)
			for _iCcx3_ = 1 to _nCcx3_
				_ccx_ = _aCcx3_[_iCcx3_]
				if isString(_ccx_) and _ccx_ = cName  _cck_++  ok
			next
		next
		return _cck_

	def _IsDeclaredValue(cName)
		_aC4_ = @aColors
		_nC4_ = len(_aC4_)
		for _iC4_ = 1 to _nC4_
			_c_ = _aC4_[_iC4_]
			if _c_ = cName  return 1  ok
		next
		_aS3_ = @aScalars
		_nS3_ = len(_aS3_)
		for _iS3_ = 1 to _nS3_
			_s_ = _aS3_[_iS3_]
			if _s_ = cName  return 1  ok
		next
		_aT2_ = @aTextures
		_nT2_ = len(_aT2_)
		for _iT2_ = 1 to _nT2_
			_t_ = _aT2_[_iT2_]
			if _t_ = cName  return 1  ok
		next
		return 0

	# "@normal", "@position.y" ... validated HERE so a typo is caught with
	# the node's name in the message, rather than by the transpiler which
	# only knows it saw a bad builtin.
	def _IsBuiltinRef(cName)
		if len(cName) < 2 or StzSubStr(cName, 1, 1) != "@"  return 0  ok
		_r_ = StzSubStr(cName, 2, len(cName) - 1)
		# StzFindFirst, not StzFind -- StzFind answers a LIST of positions,
		# and subtracting 1 from a list is an R21 far from the mistake.
		_nDot_ = StzFindFirst(".", _r_)
		if _nDot_ > 0
			_r_ = StzSubStr(_r_, 1, _nDot_ - 1)
		ok
		_aB1_ = [ "normal", "position", "uv", "lambert", "color" ]
		_nB1_ = len(_aB1_)
		for _iB1_ = 1 to _nB1_
			_b_ = _aB1_[_iB1_]
			if _r_ = _b_  return 1  ok
		next
		return 0

	def _Op(cOp)
		_aA2_ = StzMaterialGraphOps()
		_nA2_ = len(_aA2_)
		for _iA2_ = 1 to _nA2_
			_a_ = _aA2_[_iA2_]
			if StzLower("" + _a_[1]) = cOp  return _a_  ok
		next
		return []

	def _OpList()
		_c_ = ""
		_aA1_ = StzMaterialGraphOps()
		_nA1_ = len(_aA1_)
		for _iA1_ = 1 to _nA1_
			_a_ = _aA1_[_iA1_]
			if _c_ != ""  _c_ += ", "  ok
			_c_ += "" + _a_[1]
		next
		return _c_

	def _Spec(paSpec, cKey)
		if NOT isList(paSpec)  return ""  ok
		_aP1_ = paSpec
		_nP1_ = len(_aP1_)
		for _iP1_ = 1 to _nP1_
			_p_ = _aP1_[_iP1_]
			if isList(_p_) and len(_p_) = 2
				if StzLower("" + _p_[1]) = StzLower("" + cKey)
					return _p_[2]
				ok
			ok
		next
		return ""

	def _Finding(cRule, cSev, cMsg)
		@aFindings + [ cRule, :materialgraph, "material", cSev, cMsg ]
