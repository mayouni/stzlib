#=====================================================================#
#  STZALLOCATION -- the sub-solver seam (R5's OPTIMIZATION leg)       #
#  an allocation read FROM the knowledge, solved by stzOptimModel     #
#=====================================================================#
/*
	SOFTANZA_INTELLIGENCE_ARCHITECTURE.md section 6, R5: "OPTIMIZATION =
	stzOptimModel (R4 step 5) called by the planner as a sub-solver for
	resource-allocation skills". The sentence names two sides and no
	seam; this file is the seam, and it was shaped by measuring both
	sides from Ring before it was written (2026-11-01):

	- THE PLANNER SEARCHES ROUTES, THE OPTIMIZER ALLOCATES QUANTITIES.
	  stzGraphPlanner is a uniform-cost search whose answer is a list of
	  [ :from, :to, :cost ] steps. It has no notion of a quantity, so an
	  allocation is not a planner feature: it is a STEP that hands off.
	  A plan-graph edge that carries :allocate = <name> is such a step;
	  every other step is a choice of route and hands nothing off.

	- THE MODEL IS BUILT FROM FACTS, NOT FROM PER-DOMAIN RING. What is
	  declared here is a SHAPE (assign demands to resources under a
	  capacity; or choose quantities under budgets) and the NAMES of the
	  properties the knowledge already holds. The numbers come from
	  triples such as [ "t1", "seats", "4" ]. No domain word appears in
	  the code; the examples in the comments borrow a dining hall.

	- ENTITY NAMES ARE NOT VARIABLE NAMES. The expression compiler
	  refuses "t-1" and "p1.t1" (measured), and knowledge is full of
	  hyphens. So every variable is synthetic (a1_2, q3) and the map back
	  to entities is kept here; nobody upstream has to sanitise a name.

	- INFEASIBLE IS AN ANSWER, AND IsFeasibleAnswer() CANNOT SEE IT.
	  Measured: an infeasible model reports IsFeasibleAnswer() = 1 and
	  no Violations(), because both re-check a POINT and there is none.
	  The verdict therefore reads the solver STATUS, and an agent acts on
	  Verdict() = "infeasible" -- never on the absence of a violation.

	- Why() SURVIVES THE SEAM. The allocation's sentence quotes the
	  model's own Why(), which names the engine that ran, so an agent
	  that allocates can still say which engine decided. When no engine
	  ran (the knowledge was incomplete), it says that instead.

	SOLVING IS NOT WRITING. SolveOn() only answers; WriteTo() is the
	effect, and an agent performs it inside a governed skill
	(stzAllocationSkill), where the governance gate and the safe world
	already stand. The planner's hand-off solves and never writes.
*/

func StzAllocationQ(pcName)
	return new stzAllocation(pcName)

# Type tests live OUTSIDE the class: inside a stzObject, classname(x)
# resolves to the object's own ClassName() method and raises R20.
func IsStzAllocation(pObj)
	if isObject(pObj) and classname(pObj) = "stzallocation"
		return 1
	ok
	return 0

func _StzIsAgentMemory(pObj)
	if isObject(pObj) and classname(pObj) = "stzagentmemory"
		return 1
	ok
	return 0

# Holds an allocation declared over the knowledge: what is allocated, to what, under which capacity, for which gain; it builds the optimisation model from facts and solves it.
#
# Two shapes. ASSIGN places each demand (a party) on a resource (a table): a demand's size, read
# from SizedBy, must fit the resource's capacity, read from Within; OnePerResource allows at most
# one demand per resource and PlaceEvery requires every demand to be placed. CHOOSE picks a whole
# quantity of each demand (portions of a dish) under one or more budgets declared with Spending,
# each bounded by AtMost when set. The objective sums a property of the demands, read from
# Maximize or Minimize (by default the size, in the assign shape). SolveOn reads the facts from a
# stzKnowledgeGraph or an agent's stzAgentMemory, builds a stzOptimModel and solves it; Verdict
# says allocated, infeasible, incomplete or unbounded, and Why quotes the engine that ran. Nothing
# is written until WriteTo, which records each placement as a fact under the WriteAs predicate.
# A demand already placed (its WriteAs fact names a known resource) keeps its place and uses up
# that capacity; a demand recorded as unplaced is tried again.
#
#   receiver   oK = new stzKnowledgeGraph("hall")
#              oK.Know("p1", "party").KnowRelation("p1", "size", "4")
#              oK.Know("p2", "party").KnowRelation("p2", "size", "2")
#              oK.Know("t1", "table").KnowRelation("t1", "seats", "4")
#              o1 = new stzAllocation("seating")
#              o1.Assign("party").To("table").SizedBy("size").Within("seats").OnePerResource()
#   example    o1.SolveOn(oK)
#              ? o1.Verdict()
#              #--> allocated
#              ? @@( o1.Placements() )
#              #--> [ [ "p1", "t1" ] ]
#              ? @@( o1.Unplaced() )
#              #--> [ "p2" ]
#   see        stzOptimModel, stzAllocationSkill, stzGraphPlanner
class stzAllocation from stzObject

	@tName = ""
	@cShape = ""          # "assign" | "choose"
	@cDemandType = ""
	@cResourceType = ""
	@cSizeProp = ""
	@cCapProp = ""
	@bOnePer = 0
	@bEvery = 0
	@cGainProp = ""
	@cSense = "max"
	@cBoundProp = ""
	@aBudgets = []        # [ [ cUseProp, cHolder, cHolderProp ], ... ]
	@cWriteAs = ""
	@cUnplaced = "none"
	@cUnit = ""

	@oModel = ""
	@bSolved = 0
	@cVerdict = "unsolved"
	@cWhy = "nothing has been solved yet"
	@acMissing = []
	@aPlaced = []         # assign: [ demand, resource ]; choose: [ demand, quantity ]
	@acUnplaced = []
	@aKept = []           # assign: [ demand, resource ] already placed before this solve
	@nObjective = 0
	@aVarMap = []         # [ cVar, cDemand, cResource ]

	# Builds an empty allocation with a name, used in its sentences.
	#
	#   pcName     the allocation's name, also what a plan-graph step names with :allocate
	#   returns    nothing; the object is built
	#   see        Assign, Choose
	def init(pcName)
		@tName = StzLower(ring_trim("" + pcName))

	# Returns the allocation's name.
	#
	#   returns    a text, in lower case
	def Name_()
		return @tName

	# Returns the type of the demands the allocation places or chooses.
	#
	#   returns    a text, in lower case; empty before Assign or Choose
	def DemandType()
		return @cDemandType

	# Returns the predicate placements are written under.
	#
	#   returns    a text, in lower case; empty before WriteAs
	def Predicate()
		return @cWriteAs

	#@ aka  -- 1. THE SHAPE --------------------------------------------------------

	# Declares the assign shape: each demand of this type is placed on one resource.
	#
	#   pcType     the type of the demands, as the knowledge records it with is-a
	#   returns    the allocation itself, so calls chain
	#   see        To, SizedBy, Within
	def Assign(pcType)
		@cShape = "assign"
		@cDemandType = StzLower("" + pcType)
		return This

	# Declares the type of the resources the demands are placed on.
	#
	#   pcType     the type of the resources, as recorded with is-a
	#   returns    the allocation itself, so calls chain
	def To(pcType)
		@cResourceType = StzLower("" + pcType)
		return This

	# Declares the demand property that measures how much of a resource a demand takes.
	#
	#   pcProp     a property each demand holds as a number, such as size
	#   returns    the allocation itself, so calls chain
	def SizedBy(pcProp)
		@cSizeProp = StzLower("" + pcProp)
		return This

	# Declares the resource property that bounds what a resource can take.
	#
	#   pcProp     a property each resource holds as a number, such as seats
	#   returns    the allocation itself, so calls chain
	def Within(pcProp)
		@cCapProp = StzLower("" + pcProp)
		return This

	# Allows at most one demand per resource, as one party per table.
	#
	#   returns    the allocation itself, so calls chain
	def OnePerResource()
		@bOnePer = 1
		return This

	# Requires every demand to be placed; when that is impossible the verdict is infeasible.
	#
	#   returns    the allocation itself, so calls chain
	def PlaceEvery()
		@bEvery = 1
		return This

	# Declares the choose shape: a whole quantity of each demand of this type is chosen.
	#
	#   pcType     the type of the demands, as recorded with is-a
	#   returns    the allocation itself, so calls chain
	#   see        Spending, AtMost
	def Choose(pcType)
		@cShape = "choose"
		@cDemandType = StzLower("" + pcType)
		return This

	# Bounds each demand's quantity by one of its own properties.
	#
	#   pcProp     a property each demand holds as a number, such as demand
	#   returns    the allocation itself, so calls chain
	def AtMost(pcProp)
		@cBoundProp = StzLower("" + pcProp)
		return This

	# Adds a budget: the quantities, each weighted by a demand property, must not exceed a property of one holder.
	#
	#   pcUseProp      the demand property spent per unit, such as prep-minutes
	#   pcHolder       the entity holding the budget, such as kitchen
	#   pcHolderProp   the holder's property giving the budget, such as minutes
	#   returns        the allocation itself, so calls chain
	def Spending(pcUseProp, pcHolder, pcHolderProp)
		@aBudgets + [ StzLower("" + pcUseProp), StzLower("" + pcHolder),
			StzLower("" + pcHolderProp) ]
		return This

	# Declares the demand property the allocation maximises, summed over what is placed or chosen.
	#
	#   pcProp     a property each demand holds as a number, such as margin
	#   returns    the allocation itself, so calls chain
	#   note       without one, the assign shape maximises the total size placed
	def Maximize(pcProp)
		@cGainProp = StzLower("" + pcProp)
		@cSense = "max"
		return This

	# Declares the demand property the allocation minimises, summed over what is placed or chosen.
	#
	#   pcProp     a property each demand holds as a number
	#   returns    the allocation itself, so calls chain
	def Minimize(pcProp)
		@cGainProp = StzLower("" + pcProp)
		@cSense = "min"
		return This

	# Sets the predicate WriteTo records each placement under.
	#
	#   pcPred     a predicate such as seated-at or portions
	#   returns    the allocation itself, so calls chain
	#   note       it is also how a demand already placed is recognised on the next solve
	def WriteAs(pcPred)
		@cWriteAs = StzLower("" + pcPred)
		return This

	# Sets the word WriteTo records for a demand left unplaced; none by default.
	#
	#   pcWord     a word that is not the name of a resource
	#   returns    the allocation itself, so calls chain
	def UnplacedAs(pcWord)
		@cUnplaced = StzLower("" + pcWord)
		return This

	#@ aka  -- 2. SOLVING ----------------------------------------------------------

	# Reads the facts the shape names, builds the optimisation model, and solves it.
	#
	#   poKnowledge   a stzKnowledgeGraph or a stzAgentMemory
	#   returns       the allocation itself, so calls chain
	#   note          missing or non-numeric facts make the verdict incomplete and no solver runs;
	#                 an infeasible model is a verdict, never an error
	#   warning       a shape left undeclared, or a choose shape with no budget, raises an error:
	#                 that is a declaration fault, not a fact about the world
	#   see           Verdict, Why, WriteTo
	def SolveOn(poKnowledge)
		_oKG_ = This._GraphOf(poKnowledge)
		This._Reset()
		if @cShape = "assign"
			if @cResourceType = "" or @cSizeProp = "" or @cCapProp = ""
				stzraise("stzAllocation.SolveOn: the assign shape needs To(), " +
					"SizedBy() and Within() -- what is placed, on what, under " +
					"which capacity.")
			ok
			This._SolveAssign(_oKG_)
		but @cShape = "choose"
			if len(@aBudgets) = 0
				stzraise("stzAllocation.SolveOn: the choose shape needs at " +
					"least one Spending() budget, or nothing bounds it.")
			ok
			if @cGainProp = ""
				stzraise("stzAllocation.SolveOn: the choose shape needs " +
					"Maximize() or Minimize() -- a quantity is chosen FOR " +
					"something.")
			ok
			This._SolveChoose(_oKG_)
		else
			stzraise("stzAllocation.SolveOn: declare a shape first -- " +
				"Assign(type) or Choose(type).")
		ok
		return This

	def _Reset()
		@oModel = ""
		@bSolved = 0
		@cVerdict = "unsolved"
		@acMissing = []
		@aPlaced = []
		@acUnplaced = []
		@aKept = []
		@nObjective = 0
		@aVarMap = []

	def _GraphOf(poKnowledge)
		if IsStzKnowledgeGraph(poKnowledge)
			return poKnowledge
		ok
		if _StzIsAgentMemory(poKnowledge)
			return poKnowledge.GraphQ()
		ok
		stzraise("stzAllocation: the knowledge is a stzKnowledgeGraph or a " +
			"stzAgentMemory.")

	# entities of a type, in the order the knowledge holds them
	def _OfType(poKG, pcType)
		_a_ = poKG.Query([ "?x", "is-a", pcType ])
		_acOut_ = []
		_n_ = len(_a_)
		for _i_ = 1 to _n_
			_acOut_ + StzLower("" + _a_[_i_])
		next
		return _acOut_

	# [ found, value ]: a numeric property, or a gap recorded in @acMissing
	def _Num(poKG, pcEntity, pcProp)
		_a_ = poKG.Query([ pcEntity, pcProp, "?v" ])
		if len(_a_) = 0
			This._Gap(pcEntity + " has no " + pcProp)
			return [ 0, 0 ]
		ok
		_c_ = ring_trim("" + _a_[1])
		if NOT This._IsNumeral(_c_)
			This._Gap(pcEntity + "'s " + pcProp + " is not a number ('" + _c_ + "')")
			return [ 0, 0 ]
		ok
		return [ 1, ring_number(_c_) ]

	# a property read twice (a size that is also the gain) is one gap
	def _Gap(pcSentence)
		if ring_find(@acMissing, pcSentence) = 0
			@acMissing + pcSentence
		ok

	def _IsNumeral(pcText)
		_n_ = len(pcText)
		if _n_ = 0
			return 0
		ok
		_nDigits_ = 0
		for _i_ = 1 to _n_
			_ch_ = pcText[_i_]
			_nA_ = ascii(_ch_)
			if _nA_ >= 48 and _nA_ <= 57
				_nDigits_++
			but _ch_ = "." or (_i_ = 1 and _ch_ = "-")
				# allowed
			else
				return 0
			ok
		next
		return _nDigits_ > 0

	# the placement already recorded for a demand, or ""
	def _PlacedAt(poKG, pcDemand)
		if @cWriteAs = ""
			return ""
		ok
		_a_ = poKG.Query([ pcDemand, @cWriteAs, "?r" ])
		if len(_a_) = 0
			return ""
		ok
		return StzLower("" + _a_[1])

	def _SolveAssign(poKG)
		_acD_ = This._OfType(poKG, @cDemandType)
		_acR_ = This._OfType(poKG, @cResourceType)
		_cGain_ = @cGainProp
		if _cGain_ = ""
			_cGain_ = @cSizeProp
		ok

		# capacities, minus what demands already placed are using
		_aCap_ = []
		_aTaken_ = []
		_nR_ = len(_acR_)
		for _j_ = 1 to _nR_
			_aCap_ + This._Num(poKG, _acR_[_j_], @cCapProp)[2]
			_aTaken_ + 0
		next

		_acOpen_ = []      # demands this solve places
		_aSize_ = []
		_aGain_ = []
		_nD_ = len(_acD_)
		for _i_ = 1 to _nD_
			_cD_ = _acD_[_i_]
			_nSize_ = This._Num(poKG, _cD_, @cSizeProp)[2]
			_cAt_ = This._PlacedAt(poKG, _cD_)
			_nAt_ = 0
			if _cAt_ != ""
				_nAt_ = ring_find(_acR_, _cAt_)
			ok
			if _nAt_ > 0
				@aKept + [ _cD_, _cAt_ ]
				_aCap_[_nAt_] = _aCap_[_nAt_] - _nSize_
				_aTaken_[_nAt_] = _aTaken_[_nAt_] + 1
				loop
			ok
			_acOpen_ + _cD_
			_aSize_ + _nSize_
			_aGain_ + This._Num(poKG, _cD_, _cGain_)[2]
		next

		if len(@acMissing) > 0
			This._Incomplete()
			return
		ok
		if len(_acOpen_) = 0
			This._Nothing("every " + @cDemandType + " already has a place")
			return
		ok
		if _nR_ = 0
			@acUnplaced = _acOpen_
			if @bEvery = 1
				@bSolved = 1
				@cVerdict = "infeasible"
				@cWhy = "allocation '" + @tName + "' is INFEASIBLE and no engine " +
					"ran: no " + @cResourceType + " is known, and every " +
					@cDemandType + " must be placed."
			else
				This._Nothing("no " + @cResourceType + " is known, so nothing " +
					"can be placed")
			ok
			return
		ok

		_oM_ = new stzOptimModel()
		_nO_ = len(_acOpen_)
		for _i_ = 1 to _nO_
			for _j_ = 1 to _nR_
				_cV_ = "a" + _i_ + "_" + _j_
				# a demand that cannot fit, or a resource already taken under
				# one-per-resource, is a variable held at zero: the engine
				# still sees it, so an impossible PlaceEvery is the engine's
				# own infeasible verdict
				_nUb_ = 1
				if _aSize_[_i_] > _aCap_[_j_]
					_nUb_ = 0
				ok
				if @bOnePer = 1 and _aTaken_[_j_] > 0
					_nUb_ = 0
				ok
				_oM_.AddVar(_cV_, [ 0, _nUb_, :integer ])
				@aVarMap + [ _cV_, _acOpen_[_i_], _acR_[_j_] ]
			next
		next

		_cObj_ = ""
		for _i_ = 1 to _nO_
			for _j_ = 1 to _nR_
				if _cObj_ != ""
					_cObj_ += " + "
				ok
				_cObj_ += "" + _aGain_[_i_] + "*a" + _i_ + "_" + _j_
			next
		next
		if @cSense = "min"
			_oM_.Minimize(_cObj_)
		else
			_oM_.Maximize(_cObj_)
		ok

		_cRel_ = " <= 1"
		if @bEvery = 1
			_cRel_ = " = 1"
		ok
		for _i_ = 1 to _nO_
			_c_ = ""
			for _j_ = 1 to _nR_
				if _c_ != ""
					_c_ += " + "
				ok
				_c_ += "a" + _i_ + "_" + _j_
			next
			_oM_.AddNamedConstraint("once:" + _acOpen_[_i_], _c_ + _cRel_)
		next
		for _j_ = 1 to _nR_
			_c_ = ""
			for _i_ = 1 to _nO_
				if _c_ != ""
					_c_ += " + "
				ok
				if @bOnePer = 1
					_c_ += "a" + _i_ + "_" + _j_
				else
					_c_ += "" + _aSize_[_i_] + "*a" + _i_ + "_" + _j_
				ok
			next
			if @bOnePer = 1
				_oM_.AddNamedConstraint("one:" + _acR_[_j_], _c_ + " <= 1")
			else
				_nC_ = _aCap_[_j_]
				if _nC_ < 0
					_nC_ = 0
				ok
				_oM_.AddNamedConstraint("capacity:" + _acR_[_j_], _c_ + " <= " + _nC_)
			ok
		next

		_oM_.Solve()
		@oModel = _oM_
		This._ReadAssign(_acOpen_)

	def _ReadAssign(pacOpen)
		if This._ReadStatus() = 0
			return
		ok
		_n_ = len(@aVarMap)
		_acSeen_ = []
		for _k_ = 1 to _n_
			if @oModel.ValueOf(@aVarMap[_k_][1]) > 0.5
				@aPlaced + [ @aVarMap[_k_][2], @aVarMap[_k_][3] ]
				_acSeen_ + @aVarMap[_k_][2]
			ok
		next
		_nO_ = len(pacOpen)
		for _i_ = 1 to _nO_
			if ring_find(_acSeen_, pacOpen[_i_]) = 0
				@acUnplaced + pacOpen[_i_]
			ok
		next
		@cWhy = "allocation '" + @tName + "' placed " + len(@aPlaced) + " of " +
			_nO_ + " " + @cDemandType + "(s) on " + @cResourceType + "(s)"
		if len(@aKept) > 0
			@cWhy += ", keeping " + len(@aKept) + " already placed"
		ok
		@cWhy += "; objective " + @nObjective + ". The solver: " + @oModel.Why()

	def _SolveChoose(poKG)
		_acD_ = This._OfType(poKG, @cDemandType)
		_nD_ = len(_acD_)
		_aGain_ = []
		_aUb_ = []
		for _i_ = 1 to _nD_
			_aGain_ + This._Num(poKG, _acD_[_i_], @cGainProp)[2]
			if @cBoundProp != ""
				_aUb_ + This._Num(poKG, _acD_[_i_], @cBoundProp)[2]
			ok
		next
		_aUse_ = []        # one row per budget
		_aBudget_ = []
		_nB_ = len(@aBudgets)
		for _b_ = 1 to _nB_
			_aRow_ = []
			for _i_ = 1 to _nD_
				_aRow_ + This._Num(poKG, _acD_[_i_], @aBudgets[_b_][1])[2]
			next
			_aUse_ + _aRow_
			_aBudget_ + This._Num(poKG, @aBudgets[_b_][2], @aBudgets[_b_][3])[2]
		next

		if len(@acMissing) > 0
			This._Incomplete()
			return
		ok
		if _nD_ = 0
			This._Nothing("no " + @cDemandType + " is known")
			return
		ok

		_oM_ = new stzOptimModel()
		for _i_ = 1 to _nD_
			_cV_ = "q" + _i_
			if @cBoundProp != ""
				_oM_.AddVar(_cV_, [ 0, _aUb_[_i_], :integer ])
			else
				_oM_.AddVar(_cV_, [ 0, :integer ])
			ok
			@aVarMap + [ _cV_, _acD_[_i_], "" ]
		next
		_cObj_ = ""
		for _i_ = 1 to _nD_
			if _cObj_ != ""
				_cObj_ += " + "
			ok
			_cObj_ += "" + _aGain_[_i_] + "*q" + _i_
		next
		if @cSense = "min"
			_oM_.Minimize(_cObj_)
		else
			_oM_.Maximize(_cObj_)
		ok
		for _b_ = 1 to _nB_
			_c_ = ""
			for _i_ = 1 to _nD_
				if _c_ != ""
					_c_ += " + "
				ok
				_c_ += "" + _aUse_[_b_][_i_] + "*q" + _i_
			next
			_oM_.AddNamedConstraint("budget:" + @aBudgets[_b_][2] + "." +
				@aBudgets[_b_][3], _c_ + " <= " + _aBudget_[_b_])
		next

		_oM_.Solve()
		@oModel = _oM_
		if This._ReadStatus() = 0
			return
		ok
		for _i_ = 1 to _nD_
			_nQ_ = floor(@oModel.ValueOf("q" + _i_) + 0.5)
			if _nQ_ > 0
				@aPlaced + [ _acD_[_i_], _nQ_ ]
			else
				@acUnplaced + _acD_[_i_]
			ok
		next
		@cWhy = "allocation '" + @tName + "' chose a quantity for " +
			len(@aPlaced) + " of " + _nD_ + " " + @cDemandType + "(s); " +
			"objective " + @nObjective + ". The solver: " + @oModel.Why()

	# 1 when the solver found the optimum; otherwise the verdict and Why say what it found
	def _ReadStatus()
		@bSolved = 1
		@nObjective = @oModel.Objective()
		_nS_ = @oModel.Status()
		if _nS_ = 0
			@cVerdict = "allocated"
			return 1
		ok
		if _nS_ = 2
			@cVerdict = "infeasible"
			@cWhy = "allocation '" + @tName + "' is INFEASIBLE: no allocation " +
				"meets every requirement. The solver: " + @oModel.Why()
		but _nS_ = 1
			@cVerdict = "unbounded"
			@cWhy = "allocation '" + @tName + "' is UNBOUNDED: nothing limits " +
				"the objective. The solver: " + @oModel.Why()
		else
			@cVerdict = @oModel.StatusWord()
			@cWhy = "allocation '" + @tName + "' stopped short: " +
				@oModel.Why()
		ok
		@nObjective = 0
		return 0

	def _Incomplete()
		@cVerdict = "incomplete"
		@cWhy = "allocation '" + @tName + "' did not run the solver: the " +
			"knowledge is incomplete -- "
		_n_ = len(@acMissing)
		for _i_ = 1 to _n_
			if _i_ > 1
				@cWhy += "; "
			ok
			@cWhy += @acMissing[_i_]
		next
		@cWhy += "."

	def _Nothing(pcReason)
		@bSolved = 1
		@cVerdict = "allocated"
		@cWhy = "allocation '" + @tName + "' had nothing to solve and no " +
			"engine ran: " + pcReason + "."

	#@ aka  -- 3. READING THE ANSWER -----------------------------------------------

	# Returns the verdict of the last solve.
	#
	#   returns    allocated, infeasible, incomplete, unbounded, or unsolved before any solve
	#   see        IsAllocated, Why
	def Verdict()
		return @cVerdict

	# TRUE if the last solve produced an allocation that can be written.
	#
	#   returns    1 or 0
	def IsAllocated()
		if @cVerdict = "allocated"
			return 1
		ok
		return 0

	# Returns the allocation's account of itself, which quotes the solver's Why and so names the engine that ran.
	#
	#   returns    a text; when no engine ran it says so and why
	def Why()
		return @cWhy

	# Returns what this solve placed or chose.
	#
	#   returns    assign: [ demand, resource ] pairs; choose: [ demand, quantity ] pairs
	#   note       demands kept from an earlier placement are in Kept, not here
	def Placements()
		return @aPlaced

	# Returns the demands this solve left without a place or a quantity.
	#
	#   returns    a list of names
	def Unplaced()
		return @acUnplaced

	# Returns the demands that already had a place and kept it.
	#
	#   returns    [ demand, resource ] pairs
	def Kept()
		return @aKept

	# Returns the facts that were missing when the verdict is incomplete.
	#
	#   returns    a list of sentences such as "p3 has no size"
	def Missing()
		return @acMissing

	# Returns the objective reached; 0 unless the verdict is allocated.
	#
	#   returns    a number
	def Objective()
		return @nObjective

	# Returns the stzOptimModel the last solve built, to read its AST, Why or Violations.
	#
	#   returns    a stzOptimModel
	#   warning    raises an error when no model was built (incomplete, or nothing to solve)
	def Model()
		if NOT isObject(@oModel)
			stzraise("stzAllocation.Model: no model was built -- " + @cWhy)
		ok
		return @oModel

	# Returns how many variables the last model had; 0 when none was built.
	#
	#   returns    a number
	def NumberOfVars()
		return len(@aVarMap)

	#@ aka  -- 4. THE EFFECT -------------------------------------------------------

	# Returns the triples WriteTo records: each placement, then each unplaced demand with the unplaced word.
	#
	#   returns    a list of [ subject, predicate, object ]; [ ] unless the verdict is allocated
	#   note       a chosen quantity is written WITH ITS UNIT, "30-portions", and not as a bare
	#              "30": stzGraph stores one edge per node pair and a number is a node, so a bare
	#              30 collides with any other property of the same subject that is also 30
	#              (measured: a dish whose demand is 30 could not record 30 portions); the
	#              hyphen is because a node id holds no space
	#   see        WriteTo, CountedIn
	def WrittenFacts()
		_aF_ = []
		if This.IsAllocated() = 0 or @cWriteAs = ""
			return _aF_
		ok
		_n_ = len(@aPlaced)
		for _i_ = 1 to _n_
			_aF_ + [ @aPlaced[_i_][1], @cWriteAs, This._ValueText(@aPlaced[_i_][2]) ]
		next
		_n_ = len(@acUnplaced)
		for _i_ = 1 to _n_
			_aF_ + [ @acUnplaced[_i_], @cWriteAs, @cUnplaced ]
		next
		return _aF_

	# Sets the unit a chosen quantity is written with; the WriteAs predicate by default.
	#
	#   pcUnit     a unit such as portions or units
	#   returns    the allocation itself, so calls chain
	def CountedIn(pcUnit)
		@cUnit = StzLower("" + pcUnit)
		return This

	def _ValueText(pValue)
		if @cShape != "choose"
			return "" + pValue
		ok
		_cU_ = @cUnit
		if _cU_ = ""
			_cU_ = @cWriteAs
		ok
		return "" + pValue + "-" + _cU_

	# Records the allocation as facts, the triples WrittenFacts lists, replacing each demand's earlier ones.
	#
	#   poKnowledge   the stzKnowledgeGraph or stzAgentMemory to write into
	#   returns       how many facts were written
	#   note          kept demands are untouched; nothing is written unless the verdict is
	#                 allocated
	#   warning       raises an error when WriteAs was never declared; the graph raises when a
	#                 demand is already linked to the same object by another predicate (one edge
	#                 per node pair)
	#   see           SolveOn, WrittenFacts, stzAllocationSkill
	def WriteTo(poKnowledge)
		if @cWriteAs = ""
			stzraise("stzAllocation.WriteTo: declare WriteAs(predicate) -- " +
				"the name the placements are recorded under.")
		ok
		_aF_ = This.WrittenFacts()
		_n_ = len(_aF_)
		for _i_ = 1 to _n_
			This._Record(poKnowledge, _aF_[_i_][1], _aF_[_i_][3])
		next
		return _n_

	def _Record(poK, pcDemand, pcValue)
		_bMem_ = _StzIsAgentMemory(poK)
		if _bMem_ = 1
			_acOld_ = poK.Recall(pcDemand, @cWriteAs)
		else
			_acOld_ = poK.Query([ pcDemand, @cWriteAs, "?v" ])
		ok
		_n_ = len(_acOld_)
		for _i_ = 1 to _n_
			if _bMem_ = 1
				poK.Forget(pcDemand, @cWriteAs, _acOld_[_i_])
			else
				poK.RemoveFact(pcDemand, @cWriteAs, _acOld_[_i_])
			ok
		next
		if _bMem_ = 1
			poK.Learn(pcDemand, @cWriteAs, pcValue)
		else
			poK.AddFact(pcDemand, @cWriteAs, pcValue)
		ok
