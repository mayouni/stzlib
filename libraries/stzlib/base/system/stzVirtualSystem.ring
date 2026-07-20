#--------------------------------------------------------------#
#         SOFTANZA LIBRARY (V0.9) - STZVIRTUALSYSTEM           #
#   An accelerative library for Ring applications, and more!   #
#--------------------------------------------------------------#
#                                                              #
#   Description  : Phase 2 of the System Foundation -- the     #
#                  VIRTUAL SYSTEM TWIN. The abstract core:     #
#                  a change is a first-class object, the twin  #
#                  rehearses it in memory holding NO reference #
#                  to reality (P1), and reality changes ONLY   #
#                  when a governed UpdatePlan crosses the one   #
#                  bridge the engine owns (SP3). rehearse ->    #
#                  plan -> commit.                             #
#   Version      : V0.9 (2026)                                 #
#   Author       : Mansour Ayouni (kalidianow@gmail.com)       #
#                                                              #
#--------------------------------------------------------------#
#
# See base/doc/design/Softanza Virtual System Framework.md and
# SOFTANZA_SYSTEM_FOUNDATION.md (Layer 2). This file is domain-agnostic: the
# twin mutates a STATE object that knows how to Apply() an operation to itself
# and Clone() itself, and commits through a BRIDGE that is the only thing that
# touches reality. The File specialization is in stzVirtualFileSystem.ring.


  #=========================#
 #  STZVIRTUALOPERATION    #
#=========================#
#
# A change as a first-class object -- carrying its actor and intent from day
# one, so the history is legible whether a human, a script, or an agent
# proposed it (VSF P5).

class stzVirtualOperation from stzObject

	@cType = ""
	@aParams = []
	@cActor = "human"
	@cIntent = ""

	def init(pcType, paParams)
		@cType = StzLower(ring_trim("" + pcType))
		if isList(paParams)
			@aParams = paParams
		ok

	def Type()
		return @cType

	def Params()
		return @aParams

	def Param(pcKey)
		_n_ = len(@aParams)
		for _i_ = 1 to _n_
			if @aParams[_i_][1] = pcKey
				return @aParams[_i_][2]
			ok
		next
		return ""

	def Actor()
		return @cActor

	def SetActor(pcActor)
		@cActor = "" + pcActor
		return This

	def Intent()
		return @cIntent

	def SetIntent(pcIntent)
		@cIntent = "" + pcIntent
		return This

	# The token(s) this operation touches -- what a commit scope checks. A path
	# for file ops, a variable name for env ops, a command for a spawn.
	def Impact()
		if @cType = "copy_file" or @cType = "move_file"
			return [ This.Param("from"), This.Param("to") ]
		but @cType = "set_var" or @cType = "unset_var"
			return [ This.Param("name") ]
		but @cType = "spawn_process"
			return [ This.Param("command") ]
		ok
		return [ This.Param("path") ]

	# A plain-language line -- the Softanza signature (legible to a non-coder).
	def Describe()
		if @cType = "create_file"
			return "create file '" + This.Param("path") + "' (" +
			       ring_len(This.Param("content")) + " bytes)"
		but @cType = "write_file"
			return "write " + ring_len(This.Param("content")) + " bytes to '" +
			       This.Param("path") + "'"
		but @cType = "create_folder"
			return "create folder '" + This.Param("path") + "'"
		but @cType = "delete_file"
			return "delete file '" + This.Param("path") + "'"
		but @cType = "delete_folder"
			return "delete folder '" + This.Param("path") + "'"
		but @cType = "copy_file"
			return "copy '" + This.Param("from") + "' -> '" + This.Param("to") + "'"
		but @cType = "move_file"
			return "move '" + This.Param("from") + "' -> '" + This.Param("to") + "'"
		but @cType = "set_var"
			return "set env var '" + This.Param("name") + "' = '" + This.Param("value") + "'"
		but @cType = "unset_var"
			return "unset env var '" + This.Param("name") + "'"
		but @cType = "change_dir"
			return "change directory to '" + This.Param("path") + "'"
		but @cType = "spawn_process"
			return "spawn process: " + This.Param("command")
		ok
		return @cType


  #=====================#
 #  STZCOMMITSCOPE     #
#=====================#
#
# The bound on what a plan may commit (VSF section 4.5). A human usually holds
# an unlimited scope; a script or agent commits only within a declared,
# auditable one. Same mechanism, different trust.

class stzCommitScope from stzObject

	@aAllowedPrefixes = []
	@aAllowedTypes = []
	@nMaxOps = 0

	def init()

	def AllowUnder(pcPrefix)
		@aAllowedPrefixes + ("" + pcPrefix)
		return This

	def AllowType(pcType)
		@aAllowedTypes + StzLower(ring_trim("" + pcType))
		return This

	def SetMaxOperations(pnMax)
		@nMaxOps = pnMax
		return This

	def MaxOperations()
		return @nMaxOps

	def AllowedPrefixes()
		return @aAllowedPrefixes

	# "" if the operation is admissible, otherwise the reason it is refused.
	def Reason(oOp)
		if len(@aAllowedTypes) > 0
			if This._InList(oOp.Type(), @aAllowedTypes) = 0
				return "operation type '" + oOp.Type() + "' is not allowed by this scope"
			ok
		ok
		if len(@aAllowedPrefixes) > 0
			_aPaths_ = oOp.Impact()
			_m_ = len(_aPaths_)
			for _k_ = 1 to _m_
				if NOT This._HasAllowedPrefix(_aPaths_[_k_])
					return "path '" + _aPaths_[_k_] + "' is outside the allowed scope"
				ok
			next
		ok
		return ""

	def Allows(oOp)
		return This.Reason(oOp) = ""

	def _HasAllowedPrefix(pcPath)
		_n_ = len(@aAllowedPrefixes)
		for _i_ = 1 to _n_
			if StzFindFirst(@aAllowedPrefixes[_i_], pcPath) = 1
				return TRUE
			ok
		next
		return FALSE

	def _InList(pItem, paList)
		_n_ = len(paList)
		for _i_ = 1 to _n_
			if paList[_i_] = pItem
				return _i_
			ok
		next
		return 0


  #=====================#
 #  STZUPDATEPLAN      #
#=====================#
#
# The SOLE crossing artifact between imagination and reality. It narrates
# itself, ranks its risks, re-validates against current reality, lets a
# reviewer reject a step, and only then commits -- through the bridge, under a
# scope.

class stzUpdatePlan from stzObject

	@aOps = []
	@oBridge = NULL
	@oScope = NULL
	@aRejected = []

	def init(paOps, poBridge)
		if isList(paOps)
			@aOps = paOps
		ok
		@oBridge = poBridge

	def Operations()
		return @aOps

	def NumberOfOperations()
		return len(@aOps)

	def NumberOfActiveOperations()
		_n_ = len(@aOps)
		_nActive_ = 0
		for _i_ = 1 to _n_
			if NOT This.IsRejected(_i_)
				_nActive_++
			ok
		next
		return _nActive_

	def SetScope(poScope)
		@oScope = poScope
		return This

	def Scope()
		return @oScope

	def RejectOperation(pnIndex, pcBecause)
		@aRejected + [ pnIndex, "" + pcBecause ]
		return This

	def IsRejected(pnIndex)
		_n_ = len(@aRejected)
		for _i_ = 1 to _n_
			if @aRejected[_i_][1] = pnIndex
				return TRUE
			ok
		next
		return FALSE

	# The plain-language story of the change (VSF P4).
	def Narration()
		_c_ = "Update plan (" + This.NumberOfActiveOperations() + " of " +
		      len(@aOps) + " operations to commit):" + char(10)
		_n_ = len(@aOps)
		for _i_ = 1 to _n_
			_cMark_ = "  * "
			if This.IsRejected(_i_)
				_cMark_ = "  x "
			ok
			_c_ += _cMark_ + _i_ + ". " + @aOps[_i_].Describe() + char(10)
		next
		return _c_

	def ShowNarration()
		? This.Narration()

	# Ranked risk assessment -- destructive and lossy operations flagged.
	def Risks()
		_a_ = []
		_n_ = len(@aOps)
		for _i_ = 1 to _n_
			_t_ = @aOps[_i_].Type()
			if _t_ = "delete_file" or _t_ = "delete_folder"
				_a_ + [ _i_, "DESTRUCTIVE: " + @aOps[_i_].Describe() ]
			but _t_ = "move_file"
				_a_ + [ _i_, "MOVES (removes source): " + @aOps[_i_].Describe() ]
			but _t_ = "unset_var"
				_a_ + [ _i_, "REMOVES an environment variable: " + @aOps[_i_].Describe() ]
			but _t_ = "spawn_process"
				_a_ + [ _i_, "RUNS an external command (side effects): " + @aOps[_i_].Describe() ]
			ok
		next
		return _a_

	def ShowRisks()
		_aR_ = This.Risks()
		? "Risks (" + len(_aR_) + "):"
		_n_ = len(_aR_)
		for _i_ = 1 to _n_
			? "  ! op " + _aR_[_i_][1] + " -- " + _aR_[_i_][2]
		next

	# Re-check against CURRENT reality; reality may have moved since rehearsal
	# (VSF Honesty). Returns a list of [ index, warning ].
	def Validate()
		_a_ = []
		_n_ = len(@aOps)
		for _i_ = 1 to _n_
			_oOp_ = @aOps[_i_]
			_t_ = _oOp_.Type()
			if _t_ = "delete_file"
				if NOT @oBridge.RealExists(_oOp_.Param("path"))
					_a_ + [ _i_, "delete target absent in reality: " + _oOp_.Param("path") ]
				ok
			but _t_ = "copy_file" or _t_ = "move_file"
				if NOT @oBridge.RealExists(_oOp_.Param("from"))
					_a_ + [ _i_, "source absent in reality: " + _oOp_.Param("from") ]
				ok
			ok
		next
		return _a_

	# COMMIT. The one place reality changes. Each active operation is
	# scope-checked, then handed to the bridge. Returns a summary +
	# per-operation log.
	def Execute()
		_nDone_ = 0
		_nSkipped_ = 0
		_aLog_ = []
		_n_ = len(@aOps)
		for _i_ = 1 to _n_
			_oOp_ = @aOps[_i_]
			if This.IsRejected(_i_)
				_nSkipped_++
				_aLog_ + [ _i_, "REJECTED", _oOp_.Describe() ]
				loop
			ok
			if @oScope != NULL
				_cReason_ = @oScope.Reason(_oOp_)
				if _cReason_ != ""
					_nSkipped_++
					_aLog_ + [ _i_, "REFUSED-BY-SCOPE", _cReason_ ]
					loop
				ok
				if @oScope.MaxOperations() > 0 and _nDone_ >= @oScope.MaxOperations()
					_nSkipped_++
					_aLog_ + [ _i_, "REFUSED-BY-SCOPE", "max operations reached" ]
					loop
				ok
			ok
			if @oBridge.ExecuteOperation(_oOp_)
				_nDone_++
				_aLog_ + [ _i_, "COMMITTED", _oOp_.Describe() ]
			else
				_aLog_ + [ _i_, "FAILED", _oOp_.Describe() ]
			ok
		next
		return [
			[ "committed", _nDone_ ],
			[ "skipped", _nSkipped_ ],
			[ "log", _aLog_ ]
		]

	# Same commit, printing each step as it crosses.
	def ExecuteStepByStep()
		? "Committing plan step by step:"
		_aRes_ = This.Execute()
		_aLog_ = _aRes_[3][2]
		_n_ = len(_aLog_)
		for _i_ = 1 to _n_
			? "  [" + _aLog_[_i_][2] + "] " + _aLog_[_i_][3]
		next
		return _aRes_


  #=====================#
 #  STZVIRTUALSYSTEM   #
#=====================#
#
# The root twin. Domain-agnostic: it drives a STATE object (Apply / Clone) and
# a reality BRIDGE. A specialization (e.g. stzVirtualFileSystem) supplies the
# state and bridge and adds intent-named operation verbs.

class stzVirtualSystem from stzObject

	@oState = NULL
	@oBaseState = NULL
	@aHistory = []
	@aSnapshots = []
	@oBridge = NULL
	@cActor = "human"

	def init()

	def SetActor(pcActor)
		@cActor = "" + pcActor
		return This

	def Actor()
		return @cActor

	def SetBridge(poBridge)
		@oBridge = poBridge
		return This

	def Bridge()
		return @oBridge

	def State()
		return @oState

	# Rehearse ONE operation: mutate the in-memory twin and record it. Touches
	# nothing real (P1).
	def ExecuteOperation(oOp)
		oOp.SetActor(@cActor)
		@oState.Apply(oOp)
		@aHistory + oOp
		return This

	def History()
		return @aHistory

	def NumberOfOperations()
		return len(@aHistory)

	def UndoLast(pnCount)
		_n_ = len(@aHistory)
		_nKeep_ = _n_ - pnCount
		if _nKeep_ < 0
			_nKeep_ = 0
		ok
		_aKept_ = []
		for _i_ = 1 to _nKeep_
			_aKept_ + @aHistory[_i_]
		next
		@aHistory = _aKept_
		This._Rebuild(_aKept_)
		return This

	def CreateSnapshot(pcName)
		@aSnapshots + [ "" + pcName, @oState.Clone(), len(@aHistory) ]
		return This

	def RollbackTo(pcName)
		_n_ = len(@aSnapshots)
		for _i_ = 1 to _n_
			if @aSnapshots[_i_][1] = pcName
				@oState = @aSnapshots[_i_][2].Clone()
				_nLen_ = @aSnapshots[_i_][3]
				_aKept_ = []
				for _j_ = 1 to _nLen_
					_aKept_ + @aHistory[_j_]
				next
				@aHistory = _aKept_
				return This
			ok
		next
		StzRaise("No snapshot named '" + pcName + "'.")

	def GenerateUpdatePlan()
		return new stzUpdatePlan(@aHistory, @oBridge)

	def ShowHistory()
		? "Rehearsed operations (" + len(@aHistory) + "):"
		_n_ = len(@aHistory)
		for _i_ = 1 to _n_
			? "  " + _i_ + ". " + @aHistory[_i_].Describe() + "  [" + @aHistory[_i_].Actor() + "]"
		next

	# Rebuild the working state from the base + a kept prefix of operations.
	def _Rebuild(paOps)
		@oState = @oBaseState.Clone()
		_n_ = len(paOps)
		for _i_ = 1 to _n_
			@oState.Apply(paOps[_i_])
		next
