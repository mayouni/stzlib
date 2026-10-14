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

# Holds a surface material as a graph of operations, derives the order and the reuse, proves it, and emits the shader body.
#
# Declare what the material takes, colours, scalars and textures, then nodes, each an operation on
# named inputs, in any order, and name the output with Emits. Compile derives the emission order by
# topological sort, counts how many nodes read each node so a node read twice is emitted once, and
# proves the graph: every input resolves, no cycle, no node computed for nobody. Because the graph
# is an ordinary stzGraph, Affects and ImpactOf answer what a node influences. ToW emits the
# material-language body, ToMaterial a stzMaterialMaker and ToWGSL the shader. Today a node that
# reads the same node in two inputs, such as a squared value, raises at Compile. Rendering is not
# done here.
#
#   receiver   o1 = new stzMaterialGraph() o1.TakesColor(:base) o1.TakesScalar(:sharp)
#              o1.TakesTexture(:skin) o1.AddNode(:out, [ :Op = :Mix, :In = [ :lit, :base, :rim ] ])
#              o1.AddNode(:tex, [ :Op = :Sample, :In = [ :skin, "@uv" ] ]) o1.AddNode(:lit, [ :Op =
#              :Multiply, :In = [ :tex, "@lambert" ] ]) o1.AddNode(:rim, [ :Op = :Fresnel, :In = [
#              :sharp ] ]) o1.Emits(:out) o1.Compile()
#   example    ? @@( o1.Order() )
#              #--> [ "tex", "rim", "lit", "out" ]
#              ? o1.ToW()
#              #--> { let n_tex = sample(skin, @uv); let n_rim = pow(1.0 - abs(@normal.z), sharp); let n_lit = (n_tex * @lambert); @out = mix(n_lit, base, n_rim) }
#              ? @@( o1.Affects(:tex) )
#              #--> [ "out", "lit" ]
#              ? o1.ImpactOf("tex")
#              #--> 2
#              ? o1.IsSound()
#              #--> 1
#   see        stzMaterialMaker, stzFrameGraph, stzRuleReport
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

	# Builds an empty material graph with no declared values, no nodes and no output.
	#
	#   returns    nothing; the object is built
	#   note       StzMaterialGraphQ builds the same object; the ops are listed by
	#              StzMaterialGraphOps
	#   see        TakesColor, AddNode, Emits
	def init()

	# Declares a colour the material takes from outside, usable as a node input by name.
	#
	#   pcName     the name of the colour, in any letter case
	#   returns    nothing; the name is added in lower case. TakesColorQ returns the graph for
	#              chaining
	#   note       the graph must be compiled again afterwards
	#   see        TakesScalar, TakesTexture, AddNode
	#@ aka  -- what the material takes from outside --------------------------------
	def TakesColor(pcName)
		@aColors + StzLower("" + pcName)
		@bCompiled = 0

	def TakesColorQ(pcName)
		This.TakesColor(pcName)
		return This

	# Declares a number the material takes from outside, usable as a node input by name.
	#
	#   pcName     the name of the scalar, in any letter case
	#   returns    nothing; the name is added in lower case. TakesScalarQ returns the graph for
	#              chaining
	#   see        TakesColor, TakesTexture, AddNode
	def TakesScalar(pcName)
		@aScalars + StzLower("" + pcName)
		@bCompiled = 0

	def TakesScalarQ(pcName)
		This.TakesScalar(pcName)
		return This

	# Declares a picture the material reads, usable as the first input of a Sample node.
	#
	#   pcName     the name of the texture, in any letter case
	#   returns    nothing; the name is added in lower case. TakesTextureQ returns the graph for
	#              chaining
	#   see        TakesColor, AddNode
	def TakesTexture(pcName)
		@aTextures + StzLower("" + pcName)
		@bCompiled = 0

	def TakesTextureQ(pcName)
		This.TakesTexture(pcName)
		return This

	# Declares a node, an operation on named inputs, in any order relative to the nodes it reads.
	#
	#   pcName     the name of the node, unique and not the name of a declared colour, scalar or
	#              texture
	#   paSpec     a hash list [ :Op = the operation, :In = a list of inputs ], each input a node
	#              name, a declared value, a builtin such as @uv or @normal.y, or a number
	#   returns    nothing; the node is added in lower case and the graph must be compiled again.
	#              AddNodeQ returns the graph for chaining
	#   note       the ops are Sample, Multiply, Add, Subtract, Mix, Smoothstep, Step, Clamp, Pow,
	#              Fract, Abs, Sqrt, Sin, Cos, Dot, OneMinus, Fresnel and Lit; a whole number input
	#              is written with .0 in the shader
	#   warning    an empty name raises error stzMaterialGraph.AddNode: a node needs a name; a name
	#              already used, or the name of a declared value, raises an error saying the node is
	#              declared twice or cannot shadow it; an unknown operation raises error ... is not
	#              an op, with the list of the ops; a wrong number of inputs raises error ... takes
	#              N input(s)
	#   see        Emits, Compile, TakesColor
	#@ aka  -- declaring the graph -------------------------------------------------
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

	# Sets which node supplies the final colour of the material.
	#
	#   pcName     the name of the output node
	#   returns    nothing; the name is stored in lower case. EmitsQ returns the graph for chaining
	#   see        AddNode, OutputNode, Compile
	#@ aka  The node whose value becomes @out.
	def Emits(pcName)
		@cOut = StzLower("" + pcName)
		@bCompiled = 0

	def EmitsQ(pcName)
		This.Emits(pcName)
		return This

	# Returns how many nodes have been declared.
	#
	#   returns    a number
	#   see        OutputNode, AddNode
	def NodeCount()  return len(@aNodes)
	# Returns the name of the node declared as the output.
	#
	#   returns    the name as text in lower case; an empty text before Emits
	#   see        Emits, NodeCount
	def OutputNode() return @cOut

	# Derives the emission order and the reuse of the graph and proves its properties.
	#
	#   returns    the graph itself, so calls chain
	#   note       the findings are an unresolved_input error for an input that is no node, no
	#              declared value and no builtin, an acyclic error for a cycle, and a dead_node
	#              warning for a node nothing reads other than the output; a graph with a cycle has
	#              an empty order
	#   warning    a graph with no node raises error stzMaterialGraph.Compile: no nodes declared;
	#              with no output, error ... no output -- say Emits(:node); with an output that is
	#              not a node, error ... the output node ... does not exist; a node that reads the
	#              same node in two of its inputs, such as Multiply with [ :a, :a ], raises the
	#              stzGraph error saying parallel edges are refused, because one edge is added for
	#              each input
	#   see        Order, Findings, ToW
	#@ aka  -- compiling -----------------------------------------------------------
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

	# Returns the nodes in the order they are emitted, derived so that a node comes after every node it reads.
	#
	#   returns    a list of node names in lower case; [ ] after a cycle
	#   note       declare the nodes in any order at all
	#   warning    calling it before Compile raises error stzMaterialGraph: call Compile() first
	#   see        Uses, Compile
	def Order()
		This._RequireCompiled()
		return @aOrder

	# Returns how many nodes read each node.
	#
	#   returns    a list of [ node, consumers ] pairs in declaration order; the output has 0
	#   note       a node read by two nodes is emitted once, as one let
	#   warning    calling it before Compile raises error stzMaterialGraph: call Compile() first
	#   see        ReuseSaved, Order
	#@ aka  [ nodeName, nConsumers ] -- how many nodes read each one.
	def Uses()
		This._RequireCompiled()
		return @aUses

	# Returns how many expressions the single emission of shared nodes saves over writing the graph out as a tree.
	#
	#   returns    a number, each node's consumers beyond the first added up
	#   note       0 when no node is read twice
	#   warning    calling it before Compile raises error stzMaterialGraph: call Compile() first
	#   see        Uses, ToW
	#@ aka  How many `let` bindings the emission SAVED over expanding the graph as a tree: every extra consumer of a node is a subtree not re-emitted.
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

	# Returns every node downstream of a node, that is every node that depends on it, directly or not.
	#
	#   pcNode     the node to ask about, in any letter case
	#   returns    a list of node names, the node itself not included; [ ] for an output node or an
	#              unknown name
	#   note       it is a reachability query on the stzGraph the compile builds
	#   warning    calling it before Compile raises error stzMaterialGraph: call Compile() first
	#   see        ImpactOf, Order
	#@ aka  The question ShaderGraph cannot answer: what does this node AFFECT?
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

	# Returns how many nodes depend on a node, directly or not.
	#
	#   pcNode     the node to ask about, in any letter case
	#   returns    a number; 0 for an output node or an unknown name
	#   note       the length of the list Affects gives
	#   warning    calling it before Compile raises error stzMaterialGraph: call Compile() first
	#   see        Affects
	def ImpactOf(pcNode)
		This._RequireCompiled()
		if NOT isObject(@oGraph)  return 0  ok
		return @oGraph.ImpactOf(StzLower("" + pcNode))

	# Returns the proofs that failed or warned, in the house finding shape.
	#
	#   returns    a list of hash lists with rule, subject materialgraph, where material, severity
	#              and message; [ ] for a clean graph
	#   warning    calling it before Compile raises error stzMaterialGraph: call Compile() first
	#   see        IsSound, Report
	#@ aka  -- the proofs ----------------------------------------------------------
	def Findings()
		This._RequireCompiled()
		return @aFindings

	# TRUE if the compiled graph has no finding of severity error.
	#
	#   returns    TRUE or FALSE, as 1 or 0
	#   note       a dead_node warning does not make it false
	#   warning    calling it before Compile raises error stzMaterialGraph: call Compile() first
	#   see        Findings, ToW
	#@ aka  SOUND IS NO ERROR -- the house's one answer, as in stzFrameGraph, and for the same reason: the findings are NAMED now, so the report that ingests them can read a severity at all.
	def IsSound()
		This._RequireCompiled()
		return StzFindingsAreSound(@aFindings)

	# Returns the findings as a stzRuleReport, so the graph is judged by the same gate as code and security rules.
	#
	#   returns    a stzRuleReport named materialgraph
	#   warning    calling it before Compile raises error stzMaterialGraph: call Compile() first
	#   see        Findings, IsSound
	def Report()
		This._RequireCompiled()
		_o_ = new stzRuleReport("materialgraph")
		_o_.Ingest(@aFindings)
		return _o_

	# Returns the material-language body the graph emits, one let for each node in order and then the output.
	#
	#   returns    the text, such as { let n_a = abs(1.0); @out = (n_a + 2.0) }
	#   note       the text can be read and debugged; the output node has no let
	#   warning    calling it before Compile raises error stzMaterialGraph: call Compile() first; a
	#              graph with an error finding raises error stzMaterialGraph.ToW: the graph has
	#              ERRORS
	#   see        ToMaterial, Order
	#@ aka  -- emitting ------------------------------------------------------------
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

	# Builds a stzMaterialMaker with the declared colours, scalars and textures and this body, ready to give to a scene.
	#
	#   returns    a stzMaterialMaker
	#   note       rendering the material was not run here
	#   warning    the graph must have been compiled and be sound, as for ToW
	#   see        ToW, ToWGSL
	#@ aka  The material itself, ready for stzScene.SetMaterial.
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

	# Returns the WGSL shader of the material, by way of the material maker the graph builds.
	#
	#   returns    the shader source as text
	#   note       no device is needed to produce it
	#   warning    the graph must have been compiled and be sound, as for ToW
	#   see        ToMaterial, ToW
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
		@aFindings + [ :rule = cRule, :subject = :materialgraph,
		               :where = "material", :severity = "" + cSev,
		               :message = cMsg ]
