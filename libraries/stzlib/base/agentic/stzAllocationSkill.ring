#=====================================================================#
#  STZALLOCATIONSKILL -- a resource-allocation skill (R5 rung 2)      #
#  its does: builds a model, solves it, and writes the allocation     #
#=====================================================================#
/*
	SOFTANZA_INTELLIGENCE_ARCHITECTURE.md section 6, R5: the optimizer is
	the sub-solver "for resource-allocation skills". Before this file no
	skill had ever built a model: the capstone's maitre-d seated tables
	with an if/but chain, first match wins. This is the skill that
	replaces it.

	WHY A SUBCLASS AND NOT A SetDoes(func ...): a skill's functions
	receive only the memory, and Ring's anonymous functions capture
	nothing, so a func cannot carry the allocation it should solve. The
	subclass holds the stzAllocation as an attribute and overrides
	PreconditionHolds and Apply; the agent calls them exactly as it calls
	any skill's, so the governance gate in stzPIAgent.Cycle() stands in
	front of it unchanged -- AddGovernedSkill(oSkill, "seat-table").

	THE EFFECT RIDES WHAT IS ALREADY THERE. The allocation is written
	into the agent's memory as facts. When FileTo(path) names a plan
	file, it is written through the safe-world door: into the agent's
	workbench while a workbench-holding agent's Cycle() runs (the disk
	does not move; GenerateUpdatePlan is the only export), and to the
	disk directly otherwise -- the same door stzAgentRoster uses.

	AN INFEASIBLE ALLOCATION IS A FACT THE AGENT CAN ACT ON. Every solve
	records [ <allocation>, verdict, allocated | infeasible | incomplete ]
	in memory. A non-allocated verdict reports ran 1 / verified 0, with
	the allocation's Why (which names the engine), and the skill does
	not fire again on the same knowledge -- so another skill can react to
	the verdict instead of the agent looping on a refusal. A new demand
	re-arms it; StzAllocationReopen() re-arms it after a resource changes.
*/

# Re-arms an allocation skill after the resources changed: it forgets the recorded verdict, so the next cycle solves again.
#
#   poMemory   the agent's stzAgentMemory
#   pcName     the allocation's name
#   returns    nothing; the memory changes
func StzAllocationReopen(poMemory, pcName)
	_cN_ = StzLower("" + pcName)
	_acV_ = poMemory.Recall(_cN_, "verdict")
	_n_ = len(_acV_)
	for _i_ = 1 to _n_
		poMemory.Forget(_cN_, "verdict", _acV_[_i_])
	next

# Holds a skill whose action is an allocation: it reads the agent's memory, solves the model with stzOptimModel, and writes the answer back as facts.
#
# The precondition holds when a demand of the allocation's type has no placement fact yet and no
# verdict blocks a new solve; a function set with SetWhen replaces it. Apply solves the
# allocation on the memory, writes each placement under the allocation's WriteAs predicate,
# records the verdict as [ name, verdict, word ], and, when FileTo names a path, writes the plan
# through the safe-world door. It verifies by reading every placement back from memory, and a
# check set with SetVerifiedBy must agree too. Infeasible or incomplete answers report ran 1 and
# verified 0 with the allocation's Why, which names the engine that ran.
#
#   receiver   o1 = new stzAllocation("seating")
#              o1.Assign("party").To("table").SizedBy("size").Within("seats").OnePerResource()
#              o1.WriteAs("seated-at")
#              o2 = new stzAllocationSkill("seat", o1)
#              o3 = new stzAgentMemory("maitre-d")
#              o3.Learn("t1", "is-a", "table").Learn("t1", "seats", "4")
#              o3.Learn("p1", "is-a", "party").Learn("p1", "size", "3")
#   example    ? o2.Apply(o3)[:verified]
#              #--> 1
#              ? o3.Fact("p1", "seated-at", "t1")
#              #--> 1
#              ? o3.Fact("seating", "verdict", "allocated")
#              #--> 1
#   see        stzAllocation, stzAgentSkill, stzPIAgent, stzAgentWorkbench
class stzAllocationSkill from stzAgentSkill

	@oAllocation = ""
	@cFile = ""
	@cLastWhy = ""

	# Builds a skill named pcName around an allocation that declares WriteAs.
	#
	#   pcName         the skill's name
	#   poAllocation   a stzAllocation
	#   returns        nothing; the object is built
	#   warning        an allocation without WriteAs raises an error: a skill that cannot write
	#                  its answer has no effect to verify
	def init(pcName, poAllocation)
		super.init(pcName)
		if NOT IsStzAllocation(poAllocation)
			stzraise("stzAllocationSkill: the second argument is a stzAllocation.")
		ok
		if poAllocation.Predicate() = ""
			stzraise("stzAllocationSkill: the allocation needs WriteAs(predicate) " +
				"-- the skill writes its answer under it.")
		ok
		@oAllocation = poAllocation

	# Sets the plan file that the skill writes on each allocation, through the safe-world door.
	#
	#   pcPath     the file's path
	#   returns    the skill itself, so calls chain
	#   note       inside a workbench-holding agent's cycle the write lands in the workbench
	def FileTo(pcPath)
		@cFile = "" + pcPath
		return This

	# Returns the allocation the skill solves.
	#
	#   returns    a stzAllocation
	def AllocationQ()
		return @oAllocation

	# TRUE if an unplaced demand exists and no recorded verdict blocks a new solve; a SetWhen function replaces this test.
	#
	#   poMemory   the agent's stzAgentMemory
	#   returns    1 or 0
	#   note       a recorded verdict of infeasible or incomplete for the allocation makes it 0; the demands are read
	#              from the memory's graph by the allocation's demand type, and one with no fact under the allocation's
	#              predicate is unplaced
	def PreconditionHolds(poMemory)
		if @fWhen != ""
			return call @fWhen(poMemory)
		ok
		_cN_ = @oAllocation.Name_()
		if poMemory.Fact(_cN_, "verdict", "infeasible") or
		   poMemory.Fact(_cN_, "verdict", "incomplete")
			return 0
		ok
		_acD_ = poMemory.GraphQ().Query([ "?x", "is-a", @oAllocation.DemandType() ])
		_cP_ = @oAllocation.Predicate()
		_n_ = len(_acD_)
		for _i_ = 1 to _n_
			if len(poMemory.Recall(_acD_[_i_], _cP_)) = 0
				return 1
			ok
		next
		return 0

	# Solves the allocation on the memory, writes it, records the verdict, and verifies it by reading it back.
	#
	#   poMemory   the agent's stzAgentMemory, which the skill changes
	#   returns    a hash list [ :ran, :verified, :why ]; why carries the allocation's own Why
	#   see        PreconditionHolds, LastWhy
	def Apply(poMemory)
		if This.PreconditionHolds(poMemory) = 0
			return [ :ran = 0, :verified = 0,
				:why = "skill '" + @tName + "' skipped: precondition not met" ]
		ok
		_oA_ = @oAllocation
		_oA_.SolveOn(poMemory)
		_cN_ = _oA_.Name_()
		StzAllocationReopen(poMemory, _cN_)
		poMemory.Learn(_cN_, "verdict", _oA_.Verdict())
		@cLastWhy = _oA_.Why()

		if _oA_.IsAllocated() = 0
			return [ :ran = 1, :verified = 0,
				:why = "skill '" + @tName + "' could not allocate (" +
					_oA_.Verdict() + "): " + _oA_.Why() ]
		ok

		_oA_.WriteTo(poMemory)
		if @cFile != ""
			_StzAllocationFileWrite(@cFile, This._PlanText(_oA_))
		ok

		# VERIFY by reading the answer back, never by trusting the write
		_bV_ = 1
		_aF_ = _oA_.WrittenFacts()
		_n_ = len(_aF_)
		for _i_ = 1 to _n_
			if poMemory.Fact(_aF_[_i_][1], _aF_[_i_][2], _aF_[_i_][3]) = 0
				_bV_ = 0
				exit
			ok
		next
		if _bV_ = 1 and @fVerify != ""
			if call @fVerify(poMemory) != 1
				_bV_ = 0
			ok
		ok
		if _bV_ = 1
			return [ :ran = 1, :verified = 1,
				:why = "skill '" + @tName + "' ran and VERIFIED: " + _oA_.Why() ]
		ok
		return [ :ran = 1, :verified = 0,
			:why = "skill '" + @tName + "' ran but FAILED verification: " + _oA_.Why() ]

	# Returns the allocation's Why from the skill's last solve on this object.
	#
	#   returns    a text; empty before any solve
	#   note       an agent keeps a copy of the skill, so read the agent's trace for its solves
	def LastWhy()
		return @cLastWhy

	def _PlanText(poA)
		_c_ = "# " + poA.Name_() + char(10)
		_aF_ = poA.WrittenFacts()
		_n_ = len(_aF_)
		for _i_ = 1 to _n_
			_c_ += _aF_[_i_][1] + " " + _aF_[_i_][2] + " " + _aF_[_i_][3] + char(10)
		next
		_aK_ = poA.Kept()
		_n_ = len(_aK_)
		for _i_ = 1 to _n_
			_c_ += _aK_[_i_][1] + " " + poA.Predicate() + " " + _aK_[_i_][2] + char(10)
		next
		return _c_

# the safe-world door, as stzAgentRoster's: the twin inside a workbench
# cycle, the disk outside one
func _StzAllocationFileWrite(pcPath, pcBody)
	if StzInWorkbench()
		StzActiveWorkbenchQ().WriteFile(pcPath, pcBody)
	else
		StzFileWrite(pcPath, pcBody)
	ok
