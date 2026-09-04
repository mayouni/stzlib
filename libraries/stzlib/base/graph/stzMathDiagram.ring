#=====================================================================#
#  STZMATHDIAGRAM -- DN7: a mathematical diagram is a CONSTRAINT       #
#  PROBLEM over shapes, solved by the engine, drawn by the one canvas  #
#=====================================================================#
/*
	Penrose (Ye, Ni, Krieger, Ma'ayan, Wise, Aldrich, Sunshine, Crane;
	SIGGRAPH 2020) separates a diagram into three programs, and DN7 keeps
	the split because it is the whole idea and not a detail of it:

	    DOMAIN     what a field of mathematics is made of -- its types,
	               relations and functions. "type Set; predicate
	               Subset(Set, Set)". Purely abstract: it says nothing
	               about drawing and nothing about representation.
	    SUBSTANCE  one diagram's content, in that domain. "Set A, B;
	               Subset(B, A)". No coordinate, no size, no colour --
	               the paper's rule is that graphical data is EXCLUDED
	               from Substance, so the same content can wear many
	               representations.
	    STYLE      the mapping from domain to picture: a Set is a
	               circle; Subset(x, y) means y's circle CONTAINS x's;
	               Disjoint means they do not meet. Written as rules
	               over patterns ("forall Set x; Set y where Subset(x,
	               y)"), with two verbs: ENSURE, a constraint the
	               picture must satisfy, and ENCOURAGE, a preference.

	The picture is then SOLVED, not placed: every unknown -- a centre, a
	radius, a label's position -- is a variable, every ensure is a
	penalty max(0, g)^2 that is zero when satisfied, every encourage is
	an energy, and the sum is minimised. Penrose's method is an EXTERIOR
	POINT scheme: start anywhere, minimise objective + lambda * penalties
	with L-BFGS, and raise lambda tenfold until no constraint is
	violated. That is what this file does.

	WHAT IS SOFTANZA'S OWN HERE, and it is the part that matters:

	  - THE SOLVER IS THE ENGINE THIS LIBRARY ALREADY HAS. autodiff.zig
	    compiles an expression to a reverse-mode tape and lbfgs.zig
	    minimises it with a strong-Wolfe line search. DN7 writes the
	    energy as ONE expression string and hands it over. No new Zig
	    was needed to reach feasibility on Penrose's own seven-set
	    example -- measured before this file was written, three random
	    starts, one penalty round each, maximum violation zero. The one
	    engine change was a constant: the tape's variable cap, 64 to 256.

	  - THE CANVAS IS THE ONE RENDERER. Circles, rectangles, lines and
	    text go through stzCanvas exactly as every other domain's do, so
	    a mathematical diagram gets both tiers (SVG and PNG), the pick
	    channel, and the id/class channel DN3b added this afternoon --
	    every Set's circle is <g id="A" class="set circle"> to a consumer.
	    The plane's law is that a domain is never a second draw loop,
	    and this one is not.

	  - RULES ARE DATA. A Style rule is a list, not a closure: it can be
	    printed, compared, checked, and written to a file. The plane
	    already ruled this for notation profiles, and it holds here.

	  - STAGED, because Penrose learnt it the hard way. Shapes are laid
	    out first with labels excluded; then labels are placed with the
	    shapes frozen. "Separating shape layout and label layout" is the
	    Penrose blog's own conclusion, and a two-stage default is what a
	    caller gets without asking.

	WHAT DN7a DOES NOT DO, named rather than left to be found. Shapes
	are circles, axis-aligned rectangles, lines and text; ellipses,
	polygons and paths wait for a domain that needs them. Distance
	between two circles is exact; between a circle and a text box the
	box's corners are used for containment and its bounding circle for
	separation, which is conservative rather than exact. Style has
	predicates in its where-clauses; function applications ("u :=
	addV(v, w)") wait for the linear-algebra domain. There is one
	built-in domain, set theory, because that is where Penrose's own
	tutorial starts and where every one of its layout primitives is
	exercised.
*/

#---------------------------------------------------------------------#
#  THE DOMAIN                                                          #
#---------------------------------------------------------------------#

func StzMathDomainQ(pcName)
	return new stzMathDomain(pcName)

# Set theory, as Penrose ships it -- the "hello world" of the system.
func StzSetTheoryDomain()
	_o_ = new stzMathDomain("settheory")
	_o_.AddType("Set")
	_o_.AddPredicate("Subset", [ "Set", "Set" ])
	_o_.AddSymmetricPredicate("Disjoint", [ "Set", "Set" ])
	_o_.AddSymmetricPredicate("Intersecting", [ "Set", "Set" ])
	return _o_

func StzMathSubstanceQ(poDomain)
	return new stzMathSubstance(poDomain)

func StzMathStyleQ()
	return new stzMathStyle()

# Penrose's euler.style, as data. The "hello world" of the system, and
# the one that exercises every layout primitive DN7a carries.

func StzEulerStyle()
	_o_ = new stzMathStyle()
	_o_.SetCanvas(800, 700)
	_o_.ForAll("Set x", [
		[ :shape, "x.icon", :circle, [ :fill = "#1a1ae633", :stroke = "black",
		                               :strokeWidth = 1 ] ],
		[ :shape, "x.text", :text, [ :fill = "black" ] ],
		[ :ensure, "greaterThan", [ "x.icon.r", 25 ] ],
		[ :ensure, "contains", [ "x.icon", "x.text", 4 ] ],
		[ :encourage, "sameCenter", [ "x.text", "x.icon" ] ],
		[ :layer, "x.text", :above, "x.icon" ] ])
	_o_.ForAllWhere("Set x; Set y", "Subset(x, y)", [
		[ :ensure, "contains", [ "y.icon", "x.icon", 5 ] ],
		[ :ensure, "disjoint", [ "y.text", "x.icon", 10 ] ],
		[ :layer, "x.icon", :above, "y.icon" ] ])
	_o_.ForAllWhere("Set x; Set y", "Disjoint(x, y)", [
		[ :ensure, "disjoint", [ "x.icon", "y.icon", 0 ] ] ])
	_o_.ForAllWhere("Set x; Set y", "Intersecting(x, y)", [
		[ :ensure, "overlapping", [ "x.icon", "y.icon", 0 ] ],
		[ :ensure, "disjoint", [ "y.text", "x.icon", 0 ] ],
		[ :ensure, "disjoint", [ "x.text", "y.icon", 0 ] ] ])
	return _o_

func StzMathLayoutFnList()
	return "contains, disjoint, overlapping, touching, lessThan, " +
	       "greaterThan, equal, inRange, sameCenter, near, minimal, " +
	       "maximal, notTooClose, above, below, leftwards, rightwards"

func StzMathLayoutFnExists(pcName)
	_c_ = StzLower(ring_trim("" + pcName))
	_ac_ = StzSplit(StzLower(StzMathLayoutFnList()), ", ")
	_n_ = len(_ac_)
	for _i_ = 1 to _n_
		if _ac_[_i_] = _c_  return TRUE  ok
	next
	return FALSE

func StzMathDiagramQ(poDomain, poSubstance, poStyle)
	return new stzMathDiagram(poDomain, poSubstance, poStyle)

class stzMathDomain from stzObject

	@cName = ""
	@aTypes = []        # [ [ cType, cSuper ] ] -- cSuper "" at the root
	@aPredicates = []   # [ [ cName, acArgTypes, bSymmetric ] ]
	@aFunctions = []    # [ [ cName, acArgTypes, cOutType ] ]

	def init(pcName)
		@cName = StzLower(ring_trim("" + pcName))

	def Name_()
		return @cName

	#-- types --------------------------------------------------------------

	def AddType(pcType)
		_c_ = ring_trim("" + pcType)
		if _c_ = ""
			stzraise("stzMathDomain.AddType: a type needs a name.")
		ok
		if This.HasType(_c_)
			stzraise("stzMathDomain.AddType: '" + _c_ + "' is declared twice.")
		ok
		@aTypes + [ _c_, "" ]
		return This

		def AddTypeQ(pcType)
			return This.AddType(pcType)

	# "Hydrogen <: Atom": wherever an Atom is expected, a Hydrogen matches.
	def AddSubtype(pcType, pcSuper)
		_s_ = ring_trim("" + pcSuper)
		if NOT This.HasType(_s_)
			stzraise("stzMathDomain.AddSubtype: '" + _s_ + "' is not a type " +
				"of this domain -- declare it first.")
		ok
		This.AddType(pcType)
		@aTypes[len(@aTypes)][2] = _s_
		return This

		def AddSubtypeQ(pcType, pcSuper)
			return This.AddSubtype(pcType, pcSuper)

	def HasType(pcType)
		_c_ = StzLower(ring_trim("" + pcType))
		_n_ = len(@aTypes)
		for _i_ = 1 to _n_
			if StzLower(@aTypes[_i_][1]) = _c_  return TRUE  ok
		next
		return FALSE

	def Types()
		_a_ = []
		_n_ = len(@aTypes)
		for _i_ = 1 to _n_
			_a_ + @aTypes[_i_][1]
		next
		return _a_

	# TRUE when an object of pcActual may stand where pcWanted is asked
	# for -- the same type, or a subtype of it, at any depth.
	def TypeMatches(pcActual, pcWanted)
		_a_ = StzLower(ring_trim("" + pcActual))
		_w_ = StzLower(ring_trim("" + pcWanted))
		_nGuard_ = 0
		while _a_ != "" and _nGuard_ < 64
			_nGuard_++
			if _a_ = _w_  return TRUE  ok
			_a_ = StzLower(This._SuperOf(_a_))
		end
		return FALSE

	def _SuperOf(pcType)
		_c_ = StzLower(ring_trim("" + pcType))
		_n_ = len(@aTypes)
		for _i_ = 1 to _n_
			if StzLower(@aTypes[_i_][1]) = _c_  return @aTypes[_i_][2]  ok
		next
		return ""

	#-- predicates -----------------------------------------------------------

	def AddPredicate(pcName, pacArgTypes)
		return This._AddPredicate(pcName, pacArgTypes, 0)

		def AddPredicateQ(pcName, pacArgTypes)
			return This.AddPredicate(pcName, pacArgTypes)

	# Symmetric: Disjoint(A, B) IS Disjoint(B, A). Penrose restricts this
	# to binary predicates over one type, and so does this.
	def AddSymmetricPredicate(pcName, pacArgTypes)
		if NOT isList(pacArgTypes) or len(pacArgTypes) != 2
			stzraise("stzMathDomain.AddSymmetricPredicate: a symmetric " +
				"predicate takes exactly two arguments.")
		ok
		if StzLower("" + pacArgTypes[1]) != StzLower("" + pacArgTypes[2])
			stzraise("stzMathDomain.AddSymmetricPredicate: both arguments " +
				"must be the same type -- the order is what symmetry erases.")
		ok
		return This._AddPredicate(pcName, pacArgTypes, 1)

		def AddSymmetricPredicateQ(pcName, pacArgTypes)
			return This.AddSymmetricPredicate(pcName, pacArgTypes)

	def _AddPredicate(pcName, pacArgTypes, pbSym)
		_c_ = ring_trim("" + pcName)
		if _c_ = ""
			stzraise("stzMathDomain.AddPredicate: a predicate needs a name.")
		ok
		if This.HasPredicate(_c_)
			stzraise("stzMathDomain.AddPredicate: '" + _c_ + "' is declared twice.")
		ok
		_ac_ = []
		if isString(pacArgTypes)  _ac_ + pacArgTypes  else  _ac_ = pacArgTypes  ok
		_n_ = len(_ac_)
		for _i_ = 1 to _n_
			if NOT This.HasType(_ac_[_i_])
				stzraise("stzMathDomain.AddPredicate: '" + _c_ + "' names the " +
					"type '" + _ac_[_i_] + "', which this domain does not have.")
			ok
		next
		@aPredicates + [ _c_, _ac_, pbSym ]
		return This

	def HasPredicate(pcName)
		return len(This._Predicate(pcName)) > 0

	def _Predicate(pcName)
		_c_ = StzLower(ring_trim("" + pcName))
		_n_ = len(@aPredicates)
		for _i_ = 1 to _n_
			if StzLower(@aPredicates[_i_][1]) = _c_  return @aPredicates[_i_]  ok
		next
		return []

	def PredicateArity(pcName)
		_p_ = This._Predicate(pcName)
		if len(_p_) = 0  return -1  ok
		return len(_p_[2])

	def IsSymmetric(pcName)
		_p_ = This._Predicate(pcName)
		if len(_p_) = 0  return FALSE  ok
		return _p_[3] = 1

	def Predicates()
		_a_ = []
		_n_ = len(@aPredicates)
		for _i_ = 1 to _n_
			_a_ + @aPredicates[_i_][1]
		next
		return _a_

	#-- functions and constructors -----------------------------------------

	def AddFunction(pcName, pacArgTypes, pcOutType)
		_c_ = ring_trim("" + pcName)
		if _c_ = ""
			stzraise("stzMathDomain.AddFunction: a function needs a name.")
		ok
		if NOT This.HasType(pcOutType)
			stzraise("stzMathDomain.AddFunction: '" + _c_ + "' returns '" +
				pcOutType + "', which this domain does not have.")
		ok
		_ac_ = []
		if isString(pacArgTypes)  _ac_ + pacArgTypes  else  _ac_ = pacArgTypes  ok
		_n_ = len(_ac_)
		for _i_ = 1 to _n_
			if NOT This.HasType(_ac_[_i_])
				stzraise("stzMathDomain.AddFunction: '" + _c_ + "' takes a '" +
					_ac_[_i_] + "', which this domain does not have.")
			ok
		next
		@aFunctions + [ _c_, _ac_, ring_trim("" + pcOutType) ]
		return This

		def AddFunctionQ(pcName, pacArgTypes, pcOutType)
			return This.AddFunction(pcName, pacArgTypes, pcOutType)

		# a constructor is a function whose name is its output type
		def AddConstructor(pcName, pacArgTypes)
			return This.AddFunction(pcName, pacArgTypes, pcName)

	def HasFunction(pcName)
		return len(This._Function(pcName)) > 0

	def _Function(pcName)
		_c_ = StzLower(ring_trim("" + pcName))
		_n_ = len(@aFunctions)
		for _i_ = 1 to _n_
			if StzLower(@aFunctions[_i_][1]) = _c_  return @aFunctions[_i_]  ok
		next
		return []

	def FunctionOutputType(pcName)
		_f_ = This._Function(pcName)
		if len(_f_) = 0  return ""  ok
		return _f_[3]

#---------------------------------------------------------------------#
#  THE SUBSTANCE                                                       #
#---------------------------------------------------------------------#

class stzMathSubstance from stzObject

	@oDomain = NULL
	@aObjects = []      # [ [ cName, cType ] ]
	@aRelations = []    # [ [ cPredicate, acArgs ] ]
	@aDefinitions = []  # [ [ cName, cFunction, acArgs ] ]
	@aLabels = []       # [ [ cName, cLabel ] ]
	@bAutoLabel = 0

	def init(poDomain)
		if NOT isObject(poDomain)
			stzraise("stzMathSubstance: give the domain this content is " +
				"written in -- an stzMathDomain.")
		ok
		@oDomain = poDomain

	def DomainQ()
		return @oDomain

	#-- objects ------------------------------------------------------------

	def Declare(pcType, pcName)
		_t_ = ring_trim("" + pcType)
		_n_ = ring_trim("" + pcName)
		if NOT @oDomain.HasType(_t_)
			stzraise("stzMathSubstance.Declare: '" + _t_ + "' is not a type " +
				"of the '" + @oDomain.Name_() + "' domain.")
		ok
		if _n_ = ""
			stzraise("stzMathSubstance.Declare: an object needs a name.")
		ok
		if This.HasObject(_n_)
			stzraise("stzMathSubstance.Declare: '" + _n_ + "' is declared twice.")
		ok
		@aObjects + [ _n_, _t_ ]
		return This

		def DeclareQ(pcType, pcName)
			return This.Declare(pcType, pcName)

	# "Set A, B, C"
	def DeclareAll(pcType, pacNames)
		_n_ = len(pacNames)
		for _i_ = 1 to _n_
			This.Declare(pcType, pacNames[_i_])
		next
		return This

		def DeclareAllQ(pcType, pacNames)
			return This.DeclareAll(pcType, pacNames)

	def HasObject(pcName)
		return This.TypeOf(pcName) != ""

	def TypeOf(pcName)
		_c_ = StzLower(ring_trim("" + pcName))
		_n_ = len(@aObjects)
		for _i_ = 1 to _n_
			if StzLower(@aObjects[_i_][1]) = _c_  return @aObjects[_i_][2]  ok
		next
		return ""

	def Objects()
		return @aObjects

	def ObjectNames()
		_a_ = []
		_n_ = len(@aObjects)
		for _i_ = 1 to _n_
			_a_ + @aObjects[_i_][1]
		next
		return _a_

	def ObjectsOfType(pcType)
		_a_ = []
		_n_ = len(@aObjects)
		for _i_ = 1 to _n_
			if @oDomain.TypeMatches(@aObjects[_i_][2], pcType)
				_a_ + @aObjects[_i_][1]
			ok
		next
		return _a_

	#-- relations ------------------------------------------------------------

	# Assert("Subset", [ "B", "A" ]) -- typechecked against the domain,
	# because a relation over the wrong kind of object is a statement about
	# nothing, and the earlier it is refused the nearer the refusal is to
	# the line that made it.
	def Assert(pcPredicate, pacArgs)
		_p_ = ring_trim("" + pcPredicate)
		if NOT @oDomain.HasPredicate(_p_)
			stzraise("stzMathSubstance.Assert: '" + _p_ + "' is not a " +
				"predicate of the '" + @oDomain.Name_() + "' domain.")
		ok
		_ac_ = []
		if isString(pacArgs)  _ac_ + pacArgs  else  _ac_ = pacArgs  ok
		_nWant_ = @oDomain.PredicateArity(_p_)
		if len(_ac_) != _nWant_
			stzraise("stzMathSubstance.Assert: '" + _p_ + "' takes " + _nWant_ +
				" argument(s), not " + len(_ac_) + ".")
		ok
		_aTypes_ = @oDomain._Predicate(_p_)[2]
		_n_ = len(_ac_)
		for _i_ = 1 to _n_
			_cT_ = This.TypeOf(_ac_[_i_])
			if _cT_ = ""
				stzraise("stzMathSubstance.Assert: '" + _ac_[_i_] + "' is not a " +
					"declared object.")
			ok
			if NOT @oDomain.TypeMatches(_cT_, _aTypes_[_i_])
				stzraise("stzMathSubstance.Assert: argument " + _i_ + " of '" +
					_p_ + "' must be a " + _aTypes_[_i_] + "; '" + _ac_[_i_] +
					"' is a " + _cT_ + ".")
			ok
		next
		@aRelations + [ _p_, _ac_ ]
		return This

		def AssertQ(pcPredicate, pacArgs)
			return This.Assert(pcPredicate, pacArgs)

	def Relations()
		return @aRelations

	# Does the substance state pcPredicate over exactly these objects?
	# Order matters unless the domain declared the predicate symmetric.
	def Holds(pcPredicate, pacArgs)
		_p_ = StzLower(ring_trim("" + pcPredicate))
		_bSym_ = @oDomain.IsSymmetric(_p_)
		_n_ = len(@aRelations)
		for _i_ = 1 to _n_
			if StzLower(@aRelations[_i_][1]) != _p_  loop  ok
			if This._SameArgs(@aRelations[_i_][2], pacArgs)  return TRUE  ok
			if _bSym_ and len(pacArgs) = 2 and
			   This._SameArgs(@aRelations[_i_][2], [ pacArgs[2], pacArgs[1] ])
				return TRUE
			ok
		next
		return FALSE

	def _SameArgs(pa, pb)
		if len(pa) != len(pb)  return FALSE  ok
		_n_ = len(pa)
		for _i_ = 1 to _n_
			if StzLower("" + pa[_i_]) != StzLower("" + pb[_i_])  return FALSE  ok
		next
		return TRUE

	#-- function applications ------------------------------------------------

	# Define("u", "addV", [ "v", "w" ]): u is declared as the function's
	# output type and remembered as its result.
	def Define(pcName, pcFunction, pacArgs)
		_f_ = ring_trim("" + pcFunction)
		if NOT @oDomain.HasFunction(_f_)
			stzraise("stzMathSubstance.Define: '" + _f_ + "' is not a " +
				"function of the '" + @oDomain.Name_() + "' domain.")
		ok
		This.Declare(@oDomain.FunctionOutputType(_f_), pcName)
		@aDefinitions + [ ring_trim("" + pcName), _f_, pacArgs ]
		return This

		def DefineQ(pcName, pcFunction, pacArgs)
			return This.Define(pcName, pcFunction, pacArgs)

	def Definitions()
		return @aDefinitions

	#-- labels -----------------------------------------------------------------

	def Label(pcName, pcLabel)
		if NOT This.HasObject(pcName)
			stzraise("stzMathSubstance.Label: '" + pcName + "' is not a " +
				"declared object.")
		ok
		@aLabels + [ ring_trim("" + pcName), "" + pcLabel ]
		return This

		def LabelQ(pcName, pcLabel)
			return This.Label(pcName, pcLabel)

	def AutoLabelAll()
		@bAutoLabel = 1
		return This

	# The label an object carries: the one given, else its own name when
	# AutoLabel is on, else "" -- and "" means no text shape is minted.
	def LabelOf(pcName)
		_c_ = StzLower(ring_trim("" + pcName))
		_n_ = len(@aLabels)
		for _i_ = 1 to _n_
			if StzLower(@aLabels[_i_][1]) = _c_  return @aLabels[_i_][2]  ok
		next
		if @bAutoLabel = 1  return This._DeclaredName(pcName)  ok
		return ""

	def _DeclaredName(pcName)
		_c_ = StzLower(ring_trim("" + pcName))
		_n_ = len(@aObjects)
		for _i_ = 1 to _n_
			if StzLower(@aObjects[_i_][1]) = _c_  return @aObjects[_i_][1]  ok
		next
		return ""

#---------------------------------------------------------------------#
#  THE STYLE                                                           #
#---------------------------------------------------------------------#

class stzMathStyle from stzObject

	@nW = 800
	@nH = 700
	@aRules = []        # [ [ cSelector, cWhere, aRows ] ]

	def init()

	def SetCanvas(pnW, pnH)
		@nW = pnW
		@nH = pnH
		return This

		def SetCanvasQ(pnW, pnH)
			return This.SetCanvas(pnW, pnH)

	def CanvasWidth()
		return @nW

	def CanvasHeight()
		return @nH

	# ForAll("Set x", rows) -- rows are DATA. Each row is one of:
	#   [ :shape,     "x.icon", :circle | :rect | :text | :line, [ props ] ]
	#   [ :ensure,    "fn", [ args ] ]        a constraint
	#   [ :encourage, "fn", [ args ] ]        an objective
	#   [ :layer,     "x.text", :above | :below, "x.icon" ]
	# An argument is a path ("x.icon", "x.icon.r") or a number.
	def ForAll(pcSelector, paRows)
		return This.ForAllWhere(pcSelector, "", paRows)

		def ForAllQ(pcSelector, paRows)
			return This.ForAll(pcSelector, paRows)

	def ForAllWhere(pcSelector, pcWhere, paRows)
		_cS_ = ring_trim("" + pcSelector)
		if _cS_ = ""
			stzraise("stzMathStyle.ForAll: a rule needs a selector, like " +
				"'Set x' or 'Set x; Set y'.")
		ok
		if NOT isList(paRows)
			stzraise("stzMathStyle.ForAll: the rule body is a list of rows.")
		ok
		_n_ = len(paRows)
		for _i_ = 1 to _n_
			This._CheckRow(paRows[_i_], _i_)
		next
		@aRules + [ _cS_, ring_trim("" + pcWhere), paRows ]
		return This

		def ForAllWhereQ(pcSelector, pcWhere, paRows)
			return This.ForAllWhere(pcSelector, pcWhere, paRows)

	def _CheckRow(paRow, pnAt)
		if NOT isList(paRow) or len(paRow) < 3
			stzraise("stzMathStyle: row " + pnAt + " is not a rule row.")
		ok
		_k_ = "" + paRow[1]
		if _k_ = "shape"
			if len(paRow) < 3
				stzraise("stzMathStyle: a shape row is [ :shape, path, kind, props ].")
			ok
			_kind_ = "" + paRow[3]
			if _kind_ != "circle" and _kind_ != "rect" and _kind_ != "text" and
			   _kind_ != "line"
				stzraise("stzMathStyle: '" + _kind_ + "' is not a shape DN7a " +
					"draws -- circle, rect, text or line.")
			ok
		but _k_ = "ensure" or _k_ = "encourage"
			if NOT isString(paRow[2]) or NOT isList(paRow[3])
				stzraise("stzMathStyle: an " + _k_ + " row is [ :" + _k_ +
					", fn, [ args ] ] -- fn a layout function's name.")
			ok
			if NOT StzMathLayoutFnExists(paRow[2])
				stzraise("stzMathStyle: '" + paRow[2] + "' is not a layout " +
					"function -- the catalogue is " + StzMathLayoutFnList() + ".")
			ok
		but _k_ = "layer"
			if len(paRow) < 4
				stzraise("stzMathStyle: a layer row is [ :layer, path, :above|:below, path ].")
			ok
		else
			stzraise("stzMathStyle: '" + _k_ + "' is not a rule verb -- shape, " +
				"ensure, encourage or layer.")
		ok

	def Rules()
		return @aRules

#---------------------------------------------------------------------#
#  THE LAYOUT CATALOGUE -- every constraint and objective, named        #
#---------------------------------------------------------------------#

# The functions a rule may name, and what each expects. Penrose's names,
# because the convention exists and a second one would be a second
# thing to learn.
#   contains(a, b, pad)       b inside a, by pad          ensure
#   disjoint(a, b, pad)       a and b apart, by pad        ensure
#   overlapping(a, b, ov)     a and b meet, by ov          ensure
#   touching(a, b, pad)       a and b touch                ensure
#   lessThan(x, y, pad)       x + pad < y                  ensure
#   greaterThan(x, y, pad)    x > y + pad                  ensure
#   equal(x, y)               x = y                        both
#   inRange(x, lo, hi)                                     ensure
#   sameCenter(a, b) / near(a, b, off)                     encourage
#   minimal(x) / maximal(x)                                encourage
#   notTooClose(a, b, weight)                              encourage
#   above/below/leftwards/rightwards(a, b, off)            encourage
#---------------------------------------------------------------------#
#  THE DIAGRAM -- compile, solve, draw                                  #
#---------------------------------------------------------------------#

class stzMathDiagram from stzObject

	@oDomain = NULL
	@oSubstance = NULL
	@oStyle = NULL
	@oFont = NULL
	@nFontSize = 24
	@nSeed = 1

	# the compiled problem
	@aShapes = []       # [ [ cPath, cKind, aProps, cOwner, nZ ] ]
	@acUnknown = []     # unknown names, in order: u1, u2, ...
	@aUnknownOf = []    # [ [ cPath.prop, nIndex ] ]
	@aValue = []        # current value per unknown
	@bLabelVar = []     # 1 when the unknown belongs to a text shape
	@aConstraints = []  # [ [ cFn, cG, cWhere, bLabelStage ] ] -- g > 0 means violated
	@aObjectives = []   # [ [ cFn, cE, cWhere, bLabelStage ] ]
	@aLayers = []       # [ [ cAbove, cBelow ] ]
	@aTextSize = []     # [ [ cPath, nW, nAsc, nDesc ] ]

	# the solve
	@bLaidOut = 0
	@nRounds = 0
	@nEvaluations = 0
	@nEnergy = 0
	@nLayoutMs = 0
	@aViolations = []
	@aViolTapes = []    # one compiled tape per constraint, for one solve
	@cWhy = "not laid out yet"

	def init(poDomain, poSubstance, poStyle)
		if NOT isObject(poDomain) or NOT isObject(poSubstance) or
		   NOT isObject(poStyle)
			stzraise("stzMathDiagram: give a domain, a substance and a style.")
		ok
		@oDomain = poDomain
		@oSubstance = poSubstance
		@oStyle = poStyle

	#-- knobs ------------------------------------------------------------------

	def SetFont(poFont, pnSize)
		@oFont = poFont
		@nFontSize = pnSize
		@bLaidOut = 0
		return This

		def SetFontQ(poFont, pnSize)
			return This.SetFont(poFont, pnSize)

	# Penrose's "variation": the same string, the same picture. Any text
	# folds to a seed; a number is used as it is.
	def SetVariation(pVariation)
		# SeedRandom refuses a seed at or above 1,999,999,999, so the fold
		# stays under it -- the first contradiction scene found this with a
		# seed of 2.1 billion.
		if isNumber(pVariation)
			@nSeed = (floor(fabs(pVariation)) % 1999999000) + 1
		else
			_c_ = "" + pVariation
			_n_ = 7
			_m_ = len(_c_)
			for _i_ = 1 to _m_
				_n_ = (_n_ * 31 + ascii(_c_[_i_])) % 1999999000
			next
			@nSeed = _n_ + 1
		ok
		@bLaidOut = 0
		return This

		def SetVariationQ(pVariation)
			return This.SetVariation(pVariation)

	#-- the answer -------------------------------------------------------------

	def Layout()
		if @bLaidOut = 1  return This  ok
		_nT0_ = StzEngineWatchTimestampMs()
		This._Compile()
		This._Solve()
		@nLayoutMs = StzEngineWatchTimestampMs() - _nT0_
		@bLaidOut = 1
		return This

		def LayoutQ()
			return This.Layout()

	def IsFeasible()
		This.Layout()
		return This.Violation() <= 0.01

	# The largest constraint violation, in pixels. Zero is a lawful picture.
	def Violation()
		This.Layout()
		_m_ = 0
		_n_ = len(@aViolations)
		for _i_ = 1 to _n_
			if @aViolations[_i_][3] > _m_  _m_ = @aViolations[_i_][3]  ok
		next
		return _m_

	# Every constraint with its violation, in the house rule shape so a
	# CI gate can ingest it: a contradictory substance is a FINDING, not a
	# crash -- Penrose's Fig. 2, a logically inconsistent program that
	# "fails gracefully, providing visual intuition for why".
	def Violations()
		This.Layout()
		_a_ = []
		_n_ = len(@aViolations)
		for _i_ = 1 to _n_
			if @aViolations[_i_][3] > 0.01
				_a_ + [ :rule = "unsatisfied_" + @aViolations[_i_][1],
				        :subject = :diagram, :where = @aViolations[_i_][2],
				        :severity = :warning,
				        :message = "the picture could not satisfy " +
				          @aViolations[_i_][1] + " at " + @aViolations[_i_][2] +
				          " -- it is violated by " + @aViolations[_i_][3] + "px" ]
			ok
		next
		return _a_

	def Energy()
		This.Layout()
		return @nEnergy

	def Rounds()
		This.Layout()
		return @nRounds

	def Evaluations()
		This.Layout()
		return @nEvaluations

	def LayoutMs()
		This.Layout()
		return @nLayoutMs

	def NumberOfUnknowns()
		This.Layout()
		return len(@acUnknown)

	def NumberOfConstraints()
		This.Layout()
		return len(@aConstraints)

	def Why()
		This.Layout()
		return @cWhy

	# The solved geometry of one shape: [ :kind, :cx, :cy, :r ] for a circle,
	# [ :kind, :cx, :cy, :w, :h ] for a rect or text.
	def ShapeOf(pcPath)
		This.Layout()
		_i_ = This._ShapeIndex(pcPath)
		if _i_ = 0  return []  ok
		_s_ = @aShapes[_i_]
		_cP_ = _s_[1]
		if _s_[2] = "circle"
			return [ :kind = "circle", :cx = This._V(_cP_ + ".cx"),
			         :cy = This._V(_cP_ + ".cy"), :r = This._V(_cP_ + ".r") ]
		but _s_[2] = "line"
			return [ :kind = "line", :x1 = This._V(_cP_ + ".x1"),
			         :y1 = This._V(_cP_ + ".y1"), :x2 = This._V(_cP_ + ".x2"),
			         :y2 = This._V(_cP_ + ".y2") ]
		ok
		return [ :kind = _s_[2], :cx = This._V(_cP_ + ".cx"),
		         :cy = This._V(_cP_ + ".cy"), :w = This._V(_cP_ + ".w"),
		         :h = This._V(_cP_ + ".h") ]

	def Shapes()
		This.Layout()
		_a_ = []
		_n_ = len(@aShapes)
		for _i_ = 1 to _n_
			_a_ + @aShapes[_i_][1]
		next
		return _a_

	#-- drawing ------------------------------------------------------------------

	def ToCanvas()
		This.Layout()
		_oC_ = new stzCanvas(@oStyle.CanvasWidth(), @oStyle.CanvasHeight())
		_oC_.SetBackground("white")
		if isObject(@oFont)  _oC_.SetFont(@oFont, @nFontSize)  ok
		_aOrder_ = This._DrawOrder()
		_n_ = len(_aOrder_)
		for _k_ = 1 to _n_
			_s_ = @aShapes[_aOrder_[_k_]]
			This._DrawShape(_oC_, _s_)
		next
		_oC_.ClearSvgIdent()
		return _oC_

	def ToSVG()
		return This.ToCanvas().ToSVG()

	def ToPNG(pcPath)
		return This.ToCanvas().ToPNG(pcPath)

	def _DrawShape(poC, paShape)
		_cP_ = paShape[1]
		_cKind_ = paShape[2]
		_aProps_ = paShape[3]
		_cOwner_ = paShape[4]
		# the id/class channel: the OBJECT's name, the shape kind and the
		# object's type, so a consumer binds to #A or .set as it likes
		poC.SetSvgIdent(StzSvgNameOf(This._SvgIdOf(_cP_), "m_", []),
			StzTrim(_cKind_ + " " + StzSvgNameOf(
				StzLower(@oSubstance.TypeOf(_cOwner_)), "t_", []) +
				" el_" + StzSvgNameOf(_cOwner_, "o_", [])))
		_cFill_ = This._Prop(_aProps_, "fill", "")
		_cStroke_ = This._Prop(_aProps_, "stroke", "")
		_nSw_ = This._Prop(_aProps_, "strokeWidth", 1)
		if _cKind_ = "circle"
			if _cFill_ != ""  poC.Fill(_cFill_)  else  poC.Fill("#00000000")  ok
			poC.AddCircle(This._V(_cP_ + ".cx"), This._V(_cP_ + ".cy"),
				This._V(_cP_ + ".r"))
			if _cFill_ != ""  poC.Fill(_cFill_)  ok
			if _cStroke_ != ""  poC.Stroke(_cStroke_, _nSw_)  ok
		but _cKind_ = "rect"
			_w_ = This._V(_cP_ + ".w")
			_h_ = This._V(_cP_ + ".h")
			if _cFill_ != ""  poC.Fill(_cFill_)  else  poC.Fill("#00000000")  ok
			poC.AddRect(This._V(_cP_ + ".cx") - _w_ / 2,
				This._V(_cP_ + ".cy") - _h_ / 2, _w_, _h_)
			if _cFill_ != ""  poC.Fill(_cFill_)  ok
			if _cStroke_ != ""  poC.Stroke(_cStroke_, _nSw_)  ok
		but _cKind_ = "line"
			poC.AddLine(This._V(_cP_ + ".x1"), This._V(_cP_ + ".y1"),
				This._V(_cP_ + ".x2"), This._V(_cP_ + ".y2"))
			if _cStroke_ != ""  poC.Stroke(_cStroke_, _nSw_)  else
				poC.Stroke("black", _nSw_)  ok
		but _cKind_ = "text"
			if NOT isObject(@oFont)  return  ok
			_cT_ = This._Prop(_aProps_, "string", "")
			if _cT_ = ""  return  ok
			_aM_ = This._TextSize(_cP_)
			# centred on (cx, cy): the baseline sits below the centre by half
			# the ink height, measured from the font rather than guessed
			_x_ = This._V(_cP_ + ".cx") - _aM_[1] / 2
			_y_ = This._V(_cP_ + ".cy") + (_aM_[2] - _aM_[3]) / 2
			poC.AddText(_cT_, _x_, _y_)
			if _cFill_ != ""  poC.Fill(_cFill_)  else  poC.Fill("black")  ok
		ok

	def _SvgIdOf(pcPath)
		# "A.icon" -> "A" for the first shape an object owns, "A_text" after
		_ac_ = StzSplit(pcPath, ".")
		if len(_ac_) < 2  return pcPath  ok
		if _ac_[2] = "icon"  return _ac_[1]  ok
		return _ac_[1] + "_" + _ac_[2]

	# Layering as Penrose does it: "x.text above x.icon" is a partial order,
	# resolved to a z per shape by relaxation. Ties keep creation order.
	def _DrawOrder()
		_n_ = len(@aShapes)
		_aZ_ = []
		for _i_ = 1 to _n_
			_aZ_ + 0
		next
		_nL_ = len(@aLayers)
		for _pass_ = 1 to 16
			_bMoved_ = FALSE
			for _k_ = 1 to _nL_
				_a_ = This._ShapeIndex(@aLayers[_k_][1])
				_b_ = This._ShapeIndex(@aLayers[_k_][2])
				if _a_ = 0 or _b_ = 0  loop  ok
				if _aZ_[_a_] <= _aZ_[_b_]
					_aZ_[_a_] = _aZ_[_b_] + 1
					_bMoved_ = TRUE
				ok
			next
			if NOT _bMoved_  exit  ok
		next
		# text always on top of everything unlayered, which is what a reader
		# expects of a label
		for _i_ = 1 to _n_
			if @aShapes[_i_][2] = "text"  _aZ_[_i_] += 1000  ok
		next
		_aOrder_ = []
		for _i_ = 1 to _n_
			_aOrder_ + _i_
		next
		# insertion sort by z, stable
		for _i_ = 2 to _n_
			_v_ = _aOrder_[_i_]
			_j_ = _i_ - 1
			while _j_ >= 1 and _aZ_[_aOrder_[_j_]] > _aZ_[_v_]
				_aOrder_[_j_ + 1] = _aOrder_[_j_]
				_j_--
			end
			_aOrder_[_j_ + 1] = _v_
		next
		return _aOrder_

	#-- COMPILE: selectors match, rules fire, unknowns and terms accumulate --

	def _Compile()
		@aShapes = []  @acUnknown = []  @aUnknownOf = []  @aValue = []
		@bLabelVar = []  @aConstraints = []  @aObjectives = []
		@aLayers = []  @aTextSize = []
		_aRules_ = @oStyle.Rules()
		_n_ = len(_aRules_)
		for _i_ = 1 to _n_
			_aVars_ = This._ParseSelector(_aRules_[_i_][1])
			_aWhere_ = This._ParseWhere(_aRules_[_i_][2])
			_aMatches_ = This._Match(_aVars_, _aWhere_)
			_m_ = len(_aMatches_)
			for _k_ = 1 to _m_
				This._Fire(_aRules_[_i_][3], _aVars_, _aMatches_[_k_],
					_aRules_[_i_][1] + " where " + _aRules_[_i_][2])
			next
		next
		# every shape stays on the paper -- Penrose's ensureOnCanvas default
		_nS_ = len(@aShapes)
		for _i_ = 1 to _nS_
			This._AddOnCanvas(@aShapes[_i_])
		next

	# "Set x; Set y" -> [ [ "Set", "x" ], [ "Set", "y" ] ]
	def _ParseSelector(pcSelector)
		_a_ = []
		_ac_ = StzSplit(pcSelector, ";")
		_n_ = len(_ac_)
		for _i_ = 1 to _n_
			_c_ = ring_trim(_ac_[_i_])
			if _c_ = ""  loop  ok
			_ap_ = StzSplit(_c_, " ")
			_aq_ = []
			for _j_ = 1 to len(_ap_)
				if ring_trim(_ap_[_j_]) != ""  _aq_ + ring_trim(_ap_[_j_])  ok
			next
			if len(_aq_) != 2
				stzraise("stzMathStyle: '" + _c_ + "' is not 'Type var'.")
			ok
			if NOT @oDomain.HasType(_aq_[1])
				stzraise("stzMathStyle: the selector names the type '" + _aq_[1] +
					"', which the '" + @oDomain.Name_() + "' domain does not have.")
			ok
			_a_ + [ _aq_[1], _aq_[2] ]
		next
		return _a_

	# "Subset(x, y); Disjoint(y, z)" -> [ [ "Subset", [ "x", "y" ] ], ... ]
	def _ParseWhere(pcWhere)
		_a_ = []
		_c_ = ring_trim("" + pcWhere)
		if _c_ = ""  return _a_  ok
		_ac_ = StzSplit(_c_, ";")
		_n_ = len(_ac_)
		for _i_ = 1 to _n_
			_r_ = ring_trim(_ac_[_i_])
			if _r_ = ""  loop  ok
			if StzFindFirst(":=", _r_) > 0
				stzraise("stzMathStyle: '" + _r_ + "' -- matching on a function " +
					"application is not in DN7a; where-clauses take predicates.")
			ok
			_nO_ = StzFindFirst("(", _r_)
			_nC_ = StzFindFirst(")", _r_)
			if _nO_ < 2 or _nC_ <= _nO_
				stzraise("stzMathStyle: '" + _r_ + "' is not 'Predicate(a, b)'.")
			ok
			_cP_ = ring_trim(StzLeft(_r_, _nO_ - 1))
			if NOT @oDomain.HasPredicate(_cP_)
				stzraise("stzMathStyle: '" + _cP_ + "' is not a predicate of the '" +
					@oDomain.Name_() + "' domain.")
			ok
			_cArgs_ = StzStringSection(_r_, _nO_ + 1, _nC_ - 1)
			_aArgs_ = []
			_ap_ = StzSplit(_cArgs_, ",")
			for _j_ = 1 to len(_ap_)
				_aArgs_ + ring_trim(_ap_[_j_])
			next
			_a_ + [ _cP_, _aArgs_ ]
		next
		return _a_

	# Every injective assignment of substance objects to the selector's
	# variables (subtype-aware) under which every where-relation holds --
	# then deduplicated by the SET of objects matched, so a symmetric
	# predicate fires a rule once per pair and not once per ordering.
	def _Match(paVars, paWhere)
		_aOut_ = []
		_nV_ = len(paVars)
		_aCands_ = []
		for _i_ = 1 to _nV_
			_aCands_ + @oSubstance.ObjectsOfType(paVars[_i_][1])
		next
		_aIdx_ = []
		for _i_ = 1 to _nV_
			_aIdx_ + 1
		next
		if _nV_ = 0  return _aOut_  ok
		for _i_ = 1 to _nV_
			if len(_aCands_[_i_]) = 0  return _aOut_  ok
		next
		_nGuard_ = 0
		while TRUE
			_nGuard_++
			if _nGuard_ > 200000  exit  ok
			_aAsg_ = []
			_bInj_ = TRUE
			for _i_ = 1 to _nV_
				_cO_ = _aCands_[_i_][_aIdx_[_i_]]
				for _j_ = 1 to len(_aAsg_)
					if StzLower(_aAsg_[_j_]) = StzLower(_cO_)  _bInj_ = FALSE  ok
				next
				_aAsg_ + _cO_
			next
			if _bInj_ and This._WhereHolds(paVars, _aAsg_, paWhere) and
			   NOT This._Seen(_aOut_, _aAsg_, paWhere, paVars)
				_aOut_ + _aAsg_
			ok
			# advance the odometer
			_k_ = _nV_
			while _k_ >= 1
				_aIdx_[_k_]++
				if _aIdx_[_k_] <= len(_aCands_[_k_])  exit  ok
				_aIdx_[_k_] = 1
				_k_--
			end
			if _k_ < 1  exit  ok
		end
		return _aOut_

	def _WhereHolds(paVars, paAsg, paWhere)
		_n_ = len(paWhere)
		for _i_ = 1 to _n_
			_aArgs_ = []
			_m_ = len(paWhere[_i_][2])
			for _j_ = 1 to _m_
				_aArgs_ + This._Bound(paVars, paAsg, paWhere[_i_][2][_j_])
			next
			if NOT @oSubstance.Holds(paWhere[_i_][1], _aArgs_)  return FALSE  ok
		next
		return TRUE

	# A match is the same as an earlier one when it binds the same objects
	# to the same RELATIONS -- for a symmetric where, (A,B) and (B,A) are one.
	def _Seen(paOut, paAsg, paWhere, paVars)
		if len(paWhere) = 0  return FALSE  ok
		_bAllSym_ = TRUE
		for _i_ = 1 to len(paWhere)
			if NOT @oDomain.IsSymmetric(paWhere[_i_][1])  _bAllSym_ = FALSE  ok
		next
		if NOT _bAllSym_  return FALSE  ok
		_n_ = len(paOut)
		for _i_ = 1 to _n_
			if This._SameSet(paOut[_i_], paAsg)  return TRUE  ok
		next
		return FALSE

	def _SameSet(pa, pb)
		if len(pa) != len(pb)  return FALSE  ok
		for _i_ = 1 to len(pa)
			_b_ = FALSE
			for _j_ = 1 to len(pb)
				if StzLower("" + pa[_i_]) = StzLower("" + pb[_j_])  _b_ = TRUE  ok
			next
			if NOT _b_  return FALSE  ok
		next
		return TRUE

	def _Bound(paVars, paAsg, pcVar)
		_n_ = len(paVars)
		for _i_ = 1 to _n_
			if StzLower(paVars[_i_][2]) = StzLower(ring_trim("" + pcVar))
				return paAsg[_i_]
			ok
		next
		stzraise("stzMathStyle: '" + pcVar + "' is not a variable of the selector.")

	# One rule, one match: mint shapes, record terms.
	def _Fire(paRows, paVars, paAsg, pcWhere)
		_n_ = len(paRows)
		for _i_ = 1 to _n_
			_r_ = paRows[_i_]
			_k_ = "" + _r_[1]
			if _k_ = "shape"
				This._MintShape(This._ResolvePath(_r_[2], paVars, paAsg), "" + _r_[3],
					_r_[4], This._OwnerOf(_r_[2], paVars, paAsg))
			but _k_ = "ensure" or _k_ = "encourage"
				_aArgs_ = []
				for _j_ = 1 to len(_r_[3])
					_x_ = _r_[3][_j_]
					if isNumber(_x_)
						_aArgs_ + _x_
					else
						_aArgs_ + This._ResolvePath("" + _x_, paVars, paAsg)
					ok
				next
				This._AddTerm(_k_, "" + _r_[2], _aArgs_, pcWhere)
			but _k_ = "layer"
				_a_ = This._ResolvePath("" + _r_[2], paVars, paAsg)
				_b_ = This._ResolvePath("" + _r_[4], paVars, paAsg)
				if "" + _r_[3] = "above"
					@aLayers + [ _a_, _b_ ]
				else
					@aLayers + [ _b_, _a_ ]
				ok
			ok
		next

	# "x.icon.r" with x -> A  becomes "A.icon.r"
	def _ResolvePath(pcPath, paVars, paAsg)
		_ac_ = StzSplit("" + pcPath, ".")
		if len(_ac_) < 2
			stzraise("stzMathStyle: '" + pcPath + "' is not a path like 'x.icon'.")
		ok
		_cObj_ = This._Bound(paVars, paAsg, _ac_[1])
		_c_ = _cObj_
		for _i_ = 2 to len(_ac_)
			_c_ += "." + _ac_[_i_]
		next
		return _c_

	def _OwnerOf(pcPath, paVars, paAsg)
		_ac_ = StzSplit("" + pcPath, ".")
		return This._Bound(paVars, paAsg, _ac_[1])

	# A shape is minted ONCE: "forall Set x" fires per object, and a later
	# rule may reference the same path without re-creating it.
	def _MintShape(pcPath, pcKind, paProps, pcOwner)
		if This._ShapeIndex(pcPath) > 0  return  ok
		_aP_ = paProps
		if NOT isList(_aP_)  _aP_ = []  ok
		if pcKind = "text"
			# AN UNLABELLED OBJECT STILL OWNS ITS TEXT SHAPE, empty. The first
			# version minted nothing, and then every rule naming x.text --
			# contains(x.icon, x.text), disjoint(y.text, x.icon) -- raised
			# for a shape no rule had minted, so a Style that worked with
			# AutoLabel broke without it. Penrose's semantics: the shape
			# exists with an empty string, measures 0 x 0, and draws nothing.
			_cLbl_ = @oSubstance.LabelOf(pcOwner)
			_aP2_ = []
			for _i_ = 1 to len(_aP_)  _aP2_ + _aP_[_i_]  next
			# a two-element LITERAL, never `+ [ :string = x ]`: that form is a
			# one-pair hash and appending it nests a level, so the property
			# was invisible to _Prop and every label drew as nothing
			_aP2_ + [ "string", _cLbl_ ]
			_aP_ = _aP2_
		ok
		@aShapes + [ pcPath, pcKind, _aP_, pcOwner, 0 ]
		if pcKind = "circle"
			This._Unknown(pcPath + ".cx", 0)
			This._Unknown(pcPath + ".cy", 0)
			This._Unknown(pcPath + ".r", 0)
		but pcKind = "rect"
			This._Unknown(pcPath + ".cx", 0)
			This._Unknown(pcPath + ".cy", 0)
			This._Unknown(pcPath + ".w", 0)
			This._Unknown(pcPath + ".h", 0)
		but pcKind = "line"
			This._Unknown(pcPath + ".x1", 0)
			This._Unknown(pcPath + ".y1", 0)
			This._Unknown(pcPath + ".x2", 0)
			This._Unknown(pcPath + ".y2", 0)
		but pcKind = "text"
			# a label's size is MEASURED, not solved: only its position moves
			This._Unknown(pcPath + ".cx", 1)
			This._Unknown(pcPath + ".cy", 1)
			_aM_ = This._MeasureText(This._Prop(_aP_, "string", ""))
			@aTextSize + [ pcPath, _aM_[1], _aM_[2], _aM_[3] ]
		ok

	def _Unknown(pcName, pbLabel)
		_i_ = len(@acUnknown) + 1
		@acUnknown + ("u" + _i_)
		@aUnknownOf + [ pcName, _i_ ]
		@aValue + 0
		@bLabelVar + pbLabel

	def _UnknownIndex(pcName)
		_c_ = StzLower("" + pcName)
		_n_ = len(@aUnknownOf)
		for _i_ = 1 to _n_
			if StzLower(@aUnknownOf[_i_][1]) = _c_  return @aUnknownOf[_i_][2]  ok
		next
		return 0

	def _ShapeIndex(pcPath)
		_c_ = StzLower("" + pcPath)
		_n_ = len(@aShapes)
		for _i_ = 1 to _n_
			if StzLower(@aShapes[_i_][1]) = _c_  return _i_  ok
		next
		return 0

	def _KindOf(pcPath)
		_i_ = This._ShapeIndex(pcPath)
		if _i_ = 0  return ""  ok
		return @aShapes[_i_][2]

	def _Prop(paProps, pcKey, pDefault)
		if NOT isList(paProps)  return pDefault  ok
		_n_ = len(paProps)
		for _i_ = 1 to _n_
			if isList(paProps[_i_]) and len(paProps[_i_]) = 2 and
			   StzLower("" + paProps[_i_][1]) = StzLower(pcKey)
				return paProps[_i_][2]
			ok
		next
		return pDefault

	# [ width, ascent, descent ] in px at the diagram's font. With no font
	# set, a label is a box of reasonable size, so the layout still runs.
	def _MeasureText(pcText)
		if isObject(@oFont)
			_w_ = @oFont.WidthOf(pcText, @nFontSize)
			_m_ = @oFont.MetricsOf(pcText, @nFontSize)
			return [ _w_, _m_[1], _m_[2] ]
		ok
		return [ 0.6 * @nFontSize * len(pcText), 0.75 * @nFontSize, 0.25 * @nFontSize ]

	def _TextSize(pcPath)
		_c_ = StzLower("" + pcPath)
		_n_ = len(@aTextSize)
		for _i_ = 1 to _n_
			if StzLower(@aTextSize[_i_][1]) = _c_
				return [ @aTextSize[_i_][2], @aTextSize[_i_][3], @aTextSize[_i_][4] ]
			ok
		next
		return [ 0, 0, 0 ]

	#-- TERMS: a layout function becomes an expression over the unknowns --

	# The symbol for a scalar: an unknown's tape name, or a number.
	def _Sym(pArg)
		if isNumber(pArg)  return This._Num(pArg)  ok
		_c_ = "" + pArg
		_i_ = This._UnknownIndex(_c_)
		if _i_ > 0  return @acUnknown[_i_]  ok
		# a text box's size is a measured constant
		_ac_ = StzSplit(_c_, ".")
		if len(_ac_) = 3
			_cShape_ = _ac_[1] + "." + _ac_[2]
			if This._KindOf(_cShape_) = "text"
				_aM_ = This._TextSize(_cShape_)
				if _ac_[3] = "w"  return This._Num(_aM_[1])  ok
				if _ac_[3] = "h"  return This._Num(_aM_[2] + _aM_[3])  ok
			ok
		ok
		stzraise("stzMathDiagram: '" + _c_ + "' is not an unknown or a measured " +
			"size of any shape a rule minted.")

	# Ring prints a number with as many decimals as `decimals()` allows,
	# two by default -- which would round every frozen coordinate. The tape
	# reads plain decimal notation, so numbers are written out long.
	def _Num(pn)
		# decimals() SETS and returns nothing, and Ring has no getter -- so
		# the current setting is read back by formatting a probe and
		# counting its fraction digits, then restored after the write.
		_cP_ = "" + (1 / 3)
		_nDot_ = StzFindFirst(".", _cP_)
		_nD_ = 0
		if _nDot_ > 0  _nD_ = len(_cP_) - _nDot_  ok
		decimals(12)
		_c_ = "" + pn
		decimals(_nD_)
		return _c_

	# circle: [ cx, cy, r ]   rect/text: [ cx, cy, w, h ]
	def _Geo(pcPath)
		_k_ = This._KindOf(pcPath)
		if _k_ = ""
			stzraise("stzMathDiagram: '" + pcPath + "' is not a shape any rule minted.")
		ok
		if _k_ = "circle"
			return [ "circle", This._Sym(pcPath + ".cx"), This._Sym(pcPath + ".cy"),
			         This._Sym(pcPath + ".r") ]
		but _k_ = "line"
			return [ "line", This._Sym(pcPath + ".x1"), This._Sym(pcPath + ".y1"),
			         This._Sym(pcPath + ".x2"), This._Sym(pcPath + ".y2") ]
		ok
		return [ "rect", This._Sym(pcPath + ".cx"), This._Sym(pcPath + ".cy"),
		         This._Sym(pcPath + ".w"), This._Sym(pcPath + ".h") ]

	def _Dist(pa, pb)
		return "sqrt((" + pa[2] + "-" + pb[2] + ")^2+(" + pa[3] + "-" + pb[3] + ")^2)"

	# half the diagonal of a rect: its bounding circle
	def _HalfDiag(pa)
		return "sqrt((" + pa[4] + ")^2+(" + pa[5] + ")^2)/2"

	def _IsLabelPath(pcPath)
		return This._KindOf(pcPath) = "text"

	def _AddTerm(pcVerb, pcFn, paArgs, pcWhere)
		_f_ = StzLower(pcFn)
		_bLbl_ = FALSE
		for _i_ = 1 to len(paArgs)
			if NOT isNumber(paArgs[_i_])
				_ac_ = StzSplit("" + paArgs[_i_], ".")
				if len(_ac_) >= 2 and This._IsLabelPath(_ac_[1] + "." + _ac_[2])
					_bLbl_ = TRUE
				ok
			ok
		next
		_cE_ = This._Energy(_f_, paArgs, pcVerb)
		_cW_ = pcWhere + " :: " + pcFn + "(" + This._ArgsText(paArgs) + ")"
		if pcVerb = "ensure"
			@aConstraints + [ pcFn, _cE_, _cW_, _bLbl_ ]
		else
			@aObjectives + [ pcFn, _cE_, _cW_, _bLbl_ ]
		ok

	def _ArgsText(paArgs)
		_c_ = ""
		for _i_ = 1 to len(paArgs)
			if _i_ > 1  _c_ += ", "  ok
			_c_ += "" + paArgs[_i_]
		next
		return _c_

	def _Arg(paArgs, pn, pDefault)
		if len(paArgs) >= pn  return paArgs[pn]  ok
		return pDefault

	# THE CATALOGUE, each as Penrose's own energy. For ensure, the value
	# is g with g > 0 meaning violated; for encourage, the energy itself.
	def _Energy(pcFn, paArgs, pcVerb)
		if pcFn = "contains"
			_a_ = This._Geo("" + paArgs[1])
			_b_ = This._Geo("" + paArgs[2])
			_p_ = This._Num(This._Arg(paArgs, 3, 0))
			if _a_[1] = "circle" and _b_[1] = "circle"
				# d - (rA - rB - pad)
				return This._Dist(_a_, _b_) + "-(" + _a_[4] + "-" + _b_[4] + "-" + _p_ + ")"
			but _a_[1] = "circle"
				# every corner of the box inside the circle, by pad
				_hw_ = "(" + _b_[4] + ")/2"
				_hh_ = "(" + _b_[5] + ")/2"
				_c1_ = "sqrt((" + _b_[2] + "-" + _hw_ + "-" + _a_[2] + ")^2+(" + _b_[3] + "-" + _hh_ + "-" + _a_[3] + ")^2)"
				_c2_ = "sqrt((" + _b_[2] + "+" + _hw_ + "-" + _a_[2] + ")^2+(" + _b_[3] + "-" + _hh_ + "-" + _a_[3] + ")^2)"
				_c3_ = "sqrt((" + _b_[2] + "-" + _hw_ + "-" + _a_[2] + ")^2+(" + _b_[3] + "+" + _hh_ + "-" + _a_[3] + ")^2)"
				_c4_ = "sqrt((" + _b_[2] + "+" + _hw_ + "-" + _a_[2] + ")^2+(" + _b_[3] + "+" + _hh_ + "-" + _a_[3] + ")^2)"
				return "max(max(" + _c1_ + "," + _c2_ + "),max(" + _c3_ + "," + _c4_ + "))-(" +
				       _a_[4] + "-" + _p_ + ")"
			but _b_[1] = "circle"
				# the circle inside the box: four gaps, the worst one
				_g1_ = "(" + _b_[2] + "-" + _b_[4] + "+" + _p_ + ")-(" + _a_[2] + "-(" + _a_[4] + ")/2)"
				_g2_ = "(" + _a_[2] + "+(" + _a_[4] + ")/2)-(" + _b_[2] + "+" + _b_[4] + "+" + _p_ + ")"
				_g3_ = "(" + _b_[3] + "-" + _b_[4] + "+" + _p_ + ")-(" + _a_[3] + "-(" + _a_[5] + ")/2)"
				_g4_ = "(" + _a_[3] + "+(" + _a_[5] + ")/2)-(" + _b_[3] + "+" + _b_[4] + "+" + _p_ + ")"
				return "-min(min(" + _g1_ + "," + _g2_ + "),min(" + _g3_ + "," + _g4_ + "))"
			else
				# box in box: the worst of the four gaps
				_g1_ = "(" + _b_[2] + "-(" + _b_[4] + ")/2)-(" + _a_[2] + "-(" + _a_[4] + ")/2)-" + _p_
				_g2_ = "(" + _a_[2] + "+(" + _a_[4] + ")/2)-(" + _b_[2] + "+(" + _b_[4] + ")/2)-" + _p_
				_g3_ = "(" + _b_[3] + "-(" + _b_[5] + ")/2)-(" + _a_[3] + "-(" + _a_[5] + ")/2)-" + _p_
				_g4_ = "(" + _a_[3] + "+(" + _a_[5] + ")/2)-(" + _b_[3] + "+(" + _b_[5] + ")/2)-" + _p_
				return "-min(min(" + _g1_ + "," + _g2_ + "),min(" + _g3_ + "," + _g4_ + "))"
			ok

		but pcFn = "disjoint"
			_a_ = This._Geo("" + paArgs[1])
			_b_ = This._Geo("" + paArgs[2])
			_p_ = This._Num(This._Arg(paArgs, 3, 0))
			if _a_[1] = "circle" and _b_[1] = "circle"
				return "(" + _a_[4] + "+" + _b_[4] + "+" + _p_ + ")-" + This._Dist(_a_, _b_)
			but _a_[1] = "rect" and _b_[1] = "rect"
				# boxes overlap only if they overlap on BOTH axes: min of the two
				_ox_ = "((" + _a_[4] + "+" + _b_[4] + ")/2+" + _p_ + ")-abs(" + _a_[2] + "-" + _b_[2] + ")"
				_oy_ = "((" + _a_[5] + "+" + _b_[5] + ")/2+" + _p_ + ")-abs(" + _a_[3] + "-" + _b_[3] + ")"
				return "min(" + _ox_ + "," + _oy_ + ")"
			else
				# a box against a circle: the box's bounding circle, conservative
				_ra_ = _a_[4]
				if _a_[1] = "rect"  _ra_ = This._HalfDiag(_a_)  ok
				_rb_ = _b_[4]
				if _b_[1] = "rect"  _rb_ = This._HalfDiag(_b_)  ok
				return "(" + _ra_ + "+" + _rb_ + "+" + _p_ + ")-" + This._Dist(_a_, _b_)
			ok

		but pcFn = "overlapping"
			_a_ = This._Geo("" + paArgs[1])
			_b_ = This._Geo("" + paArgs[2])
			_o_ = This._Num(This._Arg(paArgs, 3, 0))
			_ra_ = _a_[4]
			if _a_[1] = "rect"  _ra_ = This._HalfDiag(_a_)  ok
			_rb_ = _b_[4]
			if _b_[1] = "rect"  _rb_ = This._HalfDiag(_b_)  ok
			return This._Dist(_a_, _b_) + "-(" + _ra_ + "+" + _rb_ + ")+" + _o_

		but pcFn = "touching"
			_a_ = This._Geo("" + paArgs[1])
			_b_ = This._Geo("" + paArgs[2])
			_p_ = This._Num(This._Arg(paArgs, 3, 0))
			return "abs(" + This._Dist(_a_, _b_) + "-(" + _a_[4] + "+" + _b_[4] + ")-" + _p_ + ")"

		but pcFn = "lessthan"
			return "(" + This._Sym(paArgs[1]) + ")-(" + This._Sym(paArgs[2]) + ")+" +
			       This._Num(This._Arg(paArgs, 3, 0))
		but pcFn = "greaterthan"
			return "(" + This._Sym(paArgs[2]) + ")-(" + This._Sym(paArgs[1]) + ")+" +
			       This._Num(This._Arg(paArgs, 3, 0))
		but pcFn = "equal"
			if pcVerb = "ensure"
				return "abs((" + This._Sym(paArgs[1]) + ")-(" + This._Sym(paArgs[2]) + "))"
			ok
			return "((" + This._Sym(paArgs[1]) + ")-(" + This._Sym(paArgs[2]) + "))^2"
		but pcFn = "inrange"
			_x_ = This._Sym(paArgs[1])
			return "max(0,(" + _x_ + ")-(" + This._Sym(paArgs[3]) + "))+max(0,(" +
			       This._Sym(paArgs[2]) + ")-(" + _x_ + "))"

		but pcFn = "samecenter" or pcFn = "near"
			_a_ = This._Geo("" + paArgs[1])
			_b_ = This._Geo("" + paArgs[2])
			_o_ = This._Num(This._Arg(paArgs, 3, 0))
			return "(" + _a_[2] + "-" + _b_[2] + ")^2+(" + _a_[3] + "-" + _b_[3] + ")^2-(" + _o_ + ")^2"
		but pcFn = "minimal"
			return "(" + This._Sym(paArgs[1]) + ")"
		but pcFn = "maximal"
			return "-(" + This._Sym(paArgs[1]) + ")"
		but pcFn = "nottooclose"
			_a_ = This._Geo("" + paArgs[1])
			_b_ = This._Geo("" + paArgs[2])
			_w_ = This._Num(This._Arg(paArgs, 3, 10))
			return _w_ + "/((" + _a_[2] + "-" + _b_[2] + ")^2+(" + _a_[3] + "-" + _b_[3] + ")^2+0.000001)"
		but pcFn = "above" or pcFn = "below" or pcFn = "leftwards" or pcFn = "rightwards"
			_a_ = This._Geo("" + paArgs[1])
			_b_ = This._Geo("" + paArgs[2])
			_o_ = This._Num(This._Arg(paArgs, 3, 100))
			# y grows DOWN on this canvas, so "a above b" is a.cy + off <= b.cy
			if pcFn = "above"
				return "max(0,(" + _a_[3] + ")+" + _o_ + "-(" + _b_[3] + "))^2"
			but pcFn = "below"
				return "max(0,(" + _b_[3] + ")+" + _o_ + "-(" + _a_[3] + "))^2"
			but pcFn = "leftwards"
				return "max(0,(" + _a_[2] + ")+" + _o_ + "-(" + _b_[2] + "))^2"
			else
				return "max(0,(" + _b_[2] + ")+" + _o_ + "-(" + _a_[2] + "))^2"
			ok
		ok
		stzraise("stzMathDiagram: '" + pcFn + "' is not a layout function.")

	def _AddOnCanvas(paShape)
		_cP_ = paShape[1]
		_k_ = paShape[2]
		if _k_ = "line"  return  ok
		_g_ = This._Geo(_cP_)
		_W_ = This._Num(@oStyle.CanvasWidth())
		_H_ = This._Num(@oStyle.CanvasHeight())
		_bLbl_ = (_k_ = "text")
		if _k_ = "circle"
			_hx_ = _g_[4]
			_hy_ = _g_[4]
		else
			_hx_ = "(" + _g_[4] + ")/2"
			_hy_ = "(" + _g_[5] + ")/2"
		ok
		_cW_ = "canvas :: onCanvas(" + _cP_ + ")"
		@aConstraints + [ "onCanvas", _hx_ + "-" + _g_[2], _cW_, _bLbl_ ]
		@aConstraints + [ "onCanvas", _g_[2] + "+" + _hx_ + "-" + _W_, _cW_, _bLbl_ ]
		@aConstraints + [ "onCanvas", _hy_ + "-" + _g_[3], _cW_, _bLbl_ ]
		@aConstraints + [ "onCanvas", _g_[3] + "+" + _hy_ + "-" + _H_, _cW_, _bLbl_ ]

	#-- SOLVE: exterior point over the engine's L-BFGS, in two stages -----

	def _Solve()
		@nRounds = 0
		@nEvaluations = 0
		@nEnergy = 0
		@aViolations = []
		_n_ = len(@acUnknown)
		if _n_ = 0
			@cWhy = "nothing to lay out -- no rule minted a shape"
			return
		ok
		This._Initialise()
		# stage 1: the shapes, labels excluded; stage 2: the labels, shapes frozen
		_bAnyLabel_ = FALSE
		_bAnyShape_ = FALSE
		for _i_ = 1 to _n_
			if @bLabelVar[_i_] = 1  _bAnyLabel_ = TRUE  else  _bAnyShape_ = TRUE  ok
		next
		This._CompileViolationTapes()
		if _bAnyShape_ or _bAnyLabel_  This._SolveStage(0)  ok
		if _bAnyLabel_ and This._StageViolation(1) > 0.01  This._SolveStage(1)  ok
		This._ReadViolations()
		This._FreeViolationTapes()
		_v_ = This._MaxViolation()
		if _v_ <= 0.01
			@cWhy = "every constraint is satisfied after " + @nRounds +
				" penalty round(s) and " + @nEvaluations + " evaluations"
		else
			@cWhy = "the picture is NOT lawful: the worst constraint is violated " +
				"by " + _v_ + "px after " + @nRounds + " round(s) -- the substance " +
				"may be contradictory, which is a finding rather than a failure"
		ok

	# Uniform over the canvas, as Penrose samples; radii and sizes from a
	# band that gives the solver room. Three draws, the one with the least
	# initial energy kept -- Penrose 4.2.1.
	def _Initialise()
		_n_ = len(@acUnknown)
		_W_ = @oStyle.CanvasWidth()
		_H_ = @oStyle.CanvasHeight()
		_cE_ = This._EnergyText(0, 1000, TRUE)
		_p_ = ""
		if _cE_ != ""  _p_ = StzEngineGradCompile(_cE_, This._VarsText())  ok
		_aBest_ = []
		_nBest_ = 0
		SeedRandom(@nSeed)
		for _try_ = 1 to 3
			_aX_ = []
			for _i_ = 1 to _n_
				_cN_ = StzLower(@aUnknownOf[_i_][1])
				_cLast_ = StzRight(_cN_, 2)
				if StzRight(_cN_, 3) = ".cx" or StzRight(_cN_, 3) = ".x1" or
				   StzRight(_cN_, 3) = ".x2"
					_aX_ + (0.1 * _W_ + StzRandom01() * 0.8 * _W_)
				but StzRight(_cN_, 3) = ".cy" or StzRight(_cN_, 3) = ".y1" or
				    StzRight(_cN_, 3) = ".y2"
					_aX_ + (0.1 * _H_ + StzRandom01() * 0.8 * _H_)
				but _cLast_ = ".r"
					_aX_ + (30 + StzRandom01() * 90)
				else
					_aX_ + (40 + StzRandom01() * 120)
				ok
			next
			_v_ = 0
			if _p_ != ""
				_r_ = StzEngineGradValueAt(_p_, _aX_)
				if isNumber(_r_)  _v_ = _r_  ok
			ok
			if _try_ = 1 or _v_ < _nBest_
				_nBest_ = _v_
				_aBest_ = _aX_
			ok
		next
		if _p_ != ""  StzEngineGradFree(_p_)  ok
		@aValue = _aBest_

	def _VarsText()
		_c_ = ""
		_n_ = len(@acUnknown)
		for _i_ = 1 to _n_
			if _i_ > 1  _c_ += ","  ok
			_c_ += @acUnknown[_i_]
		next
		return _c_

	# objective + lambda * sum of max(0, g)^2, over the terms of one stage.
	# In the label stage every shape unknown is FROZEN: substituted by its
	# value, so the tape differentiates only what may still move.
	def _EnergyText(pnStage, pnLambda, pbAll)
		_c_ = ""
		_n_ = len(@aObjectives)
		for _i_ = 1 to _n_
			if pbAll or (@aObjectives[_i_][4] = (pnStage = 1))
				if _c_ != ""  _c_ += "+"  ok
				_c_ += "(" + @aObjectives[_i_][2] + ")"
			ok
		next
		_cP_ = ""
		_m_ = len(@aConstraints)
		for _i_ = 1 to _m_
			if pbAll or (@aConstraints[_i_][4] = (pnStage = 1))
				if _cP_ != ""  _cP_ += "+"  ok
				_cP_ += "max(0," + @aConstraints[_i_][2] + ")^2"
			ok
		next
		if _cP_ != ""
			if _c_ != ""  _c_ += "+"  ok
			_c_ += This._Num(pnLambda) + "*(" + _cP_ + ")"
		ok
		if _c_ = ""  return ""  ok
		if pnStage = 1  _c_ = This._Frozen(_c_, 0)  ok
		if pnStage = 0 and NOT pbAll  _c_ = This._Frozen(_c_, 1)  ok
		return _c_

	# Replace every unknown of the OTHER stage by its current value.
	def _Frozen(pcExpr, pnWhich)
		_c_ = pcExpr
		_n_ = len(@acUnknown)
		# longest names first, or u1 would eat the head of u12
		for _i_ = _n_ to 1 step -1
			if @bLabelVar[_i_] = pnWhich
				_c_ = StzReplace(_c_, "(" + @acUnknown[_i_] + ")", "(" + This._Num(@aValue[_i_]) + ")")
				_c_ = This._ReplaceSym(_c_, @acUnknown[_i_], This._Num(@aValue[_i_]))
			ok
		next
		return _c_

	# Whole-symbol replace: u1 but not u12, u1x -- the tape's identifiers
	# are letters and digits, so a symbol ends where a non-alphanumeric
	# byte begins.
	def _ReplaceSym(pcExpr, pcSym, pcWith)
		_c_ = pcExpr
		_out_ = ""
		_n_ = len(_c_)
		_m_ = len(pcSym)
		_i_ = 1
		while _i_ <= _n_
			_bHit_ = FALSE
			if _i_ + _m_ - 1 <= _n_ and StzStringSection(_c_, _i_, _i_ + _m_ - 1) = pcSym
				_bBefore_ = (_i_ = 1) or NOT This._IsIdent(_c_[_i_ - 1])
				_bAfter_ = (_i_ + _m_ > _n_) or NOT This._IsIdent(_c_[_i_ + _m_])
				if _bBefore_ and _bAfter_  _bHit_ = TRUE  ok
			ok
			if _bHit_
				_out_ += "(" + pcWith + ")"
				_i_ += _m_
			else
				_out_ += _c_[_i_]
				_i_++
			ok
		end
		return _out_

	def _IsIdent(pc)
		_n_ = ascii(pc)
		return (_n_ >= 48 and _n_ <= 57) or (_n_ >= 65 and _n_ <= 90) or
		       (_n_ >= 97 and _n_ <= 122) or _n_ = 95

	# STAGE 0 IS A JOINT SOLVE, and the reason is Penrose's own pitfall.
	# The first version laid the shapes out with every label excluded and
	# then placed the labels with the shapes frozen -- which is exactly the
	# staging the Penrose blog shows failing: a circle sized without
	# knowing its text has no room for it, and the label stage inherits an
	# infeasible problem. Measured here on the seven-deep chain: the two
	# innermost labels could not fit, 4.4px short, and no label round could
	# mend a radius it was not allowed to move. So every unknown moves in
	# stage 0, and stage 1 only POLISHES the labels against frozen shapes.
	def _SolveStage(pnStage)
		_nLam_ = 1000
		_bJoint_ = (pnStage = 0)
		if _bJoint_
			_acNames_ = []
			for _i_ = 1 to len(@acUnknown)
				_acNames_ + _i_
			next
		else
			_acNames_ = This._StageVars(1)
		ok
		if len(_acNames_) = 0  return  ok
		_cNames_ = ""
		for _i_ = 1 to len(_acNames_)
			if _i_ > 1  _cNames_ += ","  ok
			_cNames_ += @acUnknown[_acNames_[_i_]]
		next
		for _round_ = 1 to 7
			@nRounds++
			_cE_ = This._EnergyText(pnStage, _nLam_, _bJoint_)
			if _cE_ = ""  return  ok
			_p_ = StzEngineGradCompile(_cE_, _cNames_)
			if _p_ = ""
				stzraise("stzMathDiagram: the engine refused the energy -- " +
					StzEngineGradWhy())
			ok
			_aX_ = []
			for _i_ = 1 to len(_acNames_)
				_aX_ + @aValue[_acNames_[_i_]]
			next
			_a_ = StzEngineMinimize(_p_, _aX_, 400, 0.000001)
			StzEngineGradFree(_p_)
			if NOT isList(_a_) or len(_a_) < 5
				stzraise("stzMathDiagram: the engine refused the minimisation.")
			ok
			for _i_ = 1 to len(_acNames_)
				@aValue[_acNames_[_i_]] = _a_[5 + _i_]
			next
			@nEvaluations += _a_[4]
			@nEnergy = _a_[2]
			This._ReadViolations()
			_v_ = 0
			if _bJoint_
				_v_ = This._MaxViolation()
			else
				_v_ = This._StageViolation(1)
			ok
			if _v_ <= 0.01  return  ok
			_nLam_ *= 10
		next

	def _StageVars(pnStage)
		_a_ = []
		_n_ = len(@acUnknown)
		for _i_ = 1 to _n_
			if @bLabelVar[_i_] = pnStage  _a_ + _i_  ok
		next
		return _a_

	# The worst violation already read. PRIVATE, and _Solve must use THIS:
	# the public Violation() calls Layout(), and Layout() is what is
	# running -- asking it from inside _Solve recursed until the stack went.
	def _MaxViolation()
		_m_ = 0
		_n_ = len(@aViolations)
		for _i_ = 1 to _n_
			if @aViolations[_i_][3] > _m_  _m_ = @aViolations[_i_][3]  ok
		next
		return _m_

	def _StageViolation(pnStage)
		_m_ = 0
		_n_ = len(@aViolations)
		for _i_ = 1 to _n_
			if @aViolations[_i_][4] = (pnStage = 1) and @aViolations[_i_][3] > _m_
				_m_ = @aViolations[_i_][3]
			ok
		next
		return _m_

	# Every constraint's g at the current values -- read from the tape,
	# not re-derived here, so the number reported is the number solved.
	#
	# THE TAPES ARE COMPILED ONCE PER SOLVE. They never change between
	# rounds, and the first version recompiled all of them every round:
	# on the seven-set tree that was 85 compiles x 4 rounds, and most of
	# the 1.35 s the solve took was this rather than the solver -- the
	# plane's oldest defect, a value recomputed inside a loop that could
	# not change while the loop ran.
	def _CompileViolationTapes()
		This._FreeViolationTapes()
		_cNames_ = This._VarsText()
		_n_ = len(@aConstraints)
		for _i_ = 1 to _n_
			@aViolTapes + StzEngineGradCompile(@aConstraints[_i_][2], _cNames_)
		next

	def _FreeViolationTapes()
		_n_ = len(@aViolTapes)
		for _i_ = 1 to _n_
			if @aViolTapes[_i_] != ""  StzEngineGradFree(@aViolTapes[_i_])  ok
		next
		@aViolTapes = []

	def _ReadViolations()
		if len(@aViolTapes) != len(@aConstraints)  This._CompileViolationTapes()  ok
		@aViolations = []
		_n_ = len(@aConstraints)
		for _i_ = 1 to _n_
			_v_ = 0
			if @aViolTapes[_i_] != ""
				_r_ = StzEngineGradValueAt(@aViolTapes[_i_], @aValue)
				if isNumber(_r_)  _v_ = _r_  ok
			ok
			if _v_ < 0  _v_ = 0  ok
			@aViolations + [ @aConstraints[_i_][1], @aConstraints[_i_][3], _v_,
			                 @aConstraints[_i_][4] ]
		next

	def _V(pcName)
		_i_ = This._UnknownIndex(pcName)
		if _i_ = 0
			# a measured size, or nothing
			_ac_ = StzSplit("" + pcName, ".")
			if len(_ac_) = 3
				_aM_ = This._TextSize(_ac_[1] + "." + _ac_[2])
				if _ac_[3] = "w"  return _aM_[1]  ok
				if _ac_[3] = "h"  return _aM_[2] + _aM_[3]  ok
			ok
			return 0
		ok
		return @aValue[_i_]
