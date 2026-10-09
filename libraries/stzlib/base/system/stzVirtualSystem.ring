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

# Holds one change to a system as an object, with its type, its parameters, who proposed it and why.
#
# A twin rehearses operations and a plan commits them, so the change is a value that can be read,
# narrated, scoped and audited before anything real happens. The type names the change (create_file,
# write_file, create_folder, delete_file, delete_folder, copy_file, move_file, set_var, unset_var,
# change_dir, spawn_process) and the parameters are [ key, value ] pairs. Describe writes it in
# plain words, Impact lists what it touches for a commit scope, and RequiredKind says what a
# committer must be allowed to do.
#
#   receiver   o1 = new stzVirtualOperation("copy_file", [ [ "from", "/w/a.txt" ], [ "to",
#              "/w/b.txt" ] ])
#   example    ? o1.Describe()
#              #--> copy '/w/a.txt' -> '/w/b.txt'
#              ? @@( o1.Impact() )
#              #--> [ "/w/a.txt", "/w/b.txt" ]
#              ? o1.RequiredKind()
#              #--> effectful
#   see        stzVirtualSystem, stzCommitScope, stzUpdatePlan
class stzVirtualOperation from stzObject

	@cType = ""
	@aParams = []
	@cActor = "human"
	@cIntent = ""

	# Builds one change as an object: a type and its parameters, to be rehearsed in a twin or committed through a bridge.
	#
	#   pcType     the kind of change, such as create_file, copy_file or set_var, folded to lower
	#              case
	#   paParams   a list of [ key, value ] pairs
	#   returns    nothing; the operation is built
	#   see        Type, Param, Describe
	def init(pcType, paParams)
		@cType = StzLower(ring_trim("" + pcType))
		if isList(paParams)
			@aParams = paParams
		ok

	# Returns the kind of change, in lower case.
	#
	#   returns    a text such as create_file
	#   see        init, Describe
	def Type()
		return @cType

	# Returns the parameters the operation was built with.
	#
	#   returns    a list of [ key, value ] pairs
	#   see        Param, init
	def Params()
		return @aParams

	# Returns the value of one parameter.
	#
	#   pcKey      the parameter name, such as path, content, from, to, name, value or command
	#   returns    the value; an empty text when the key is absent
	#   see        Params, Impact
	def Param(pcKey)
		_n_ = len(@aParams)
		for _i_ = 1 to _n_
			if @aParams[_i_][1] = pcKey
				return @aParams[_i_][2]
			ok
		next
		return ""

	# Returns who proposed the operation.
	#
	#   returns    a text; human until another actor is set
	#   see        SetActor, Intent
	def Actor()
		return @cActor

	# Sets who proposed the operation, which the history then shows.
	#
	#   pcActor    the name of the human, script or agent
	#   returns    the operation itself, so calls chain
	#   note       a twin stamps its own actor on each operation it rehearses
	#   see        Actor, SetIntent
	def SetActor(pcActor)
		@cActor = "" + pcActor
		return This

	# Returns why the operation was proposed.
	#
	#   returns    a text; empty until an intent is set
	#   see        SetIntent, Actor
	def Intent()
		return @cIntent

	# Sets why the operation was proposed, which the history text then shows after the operation.
	#
	#   pcIntent   the reason, in plain words
	#   returns    the operation itself, so calls chain
	#   see        Intent, SetActor
	def SetIntent(pcIntent)
		@cIntent = "" + pcIntent
		return This

	# Returns the tokens the operation touches, which is what a commit scope checks.
	#
	#   returns    a list of text: both paths for a copy or move, the variable name for an
	#              environment change, the command for a spawn, the path otherwise
	#   see        stzCommitScope, Param
	#@ aka  The token(s) this operation touches -- what a commit scope checks. A path for file ops, a variable name for env ops, a command for a spawn.
	def Impact()
		if @cType = "copy_file" or @cType = "move_file"
			return [ This.Param("from"), This.Param("to") ]
		but @cType = "set_var" or @cType = "unset_var"
			return [ This.Param("name") ]
		but @cType = "spawn_process"
			return [ This.Param("command") ]
		ok
		return [ This.Param("path") ]

	# Returns the capability kind a committer needs for this operation.
	#
	#   returns    a text; effectful for every operation, because each one touches reality
	#   see        stzUpdatePlan, stzSystemActor
	#@ aka  The capability KIND this operation requires of whoever commits it -- its colour in the agentic lattice (effectful / sensing / compute / inference), the same vocabulary as stzSystemCapabilities and stzAgentGraph. Every operation the twin can commit TOUCHES reality, so all are effectful; a future read-only sense op would be "sensing". The governance gate checks this against the executing actor's cap
	def RequiredKind()
		return "effectful"

	# Returns the operation as one plain-language line.
	#
	#   returns    a text such as create file '/w/a.txt' (5 bytes); the bare type for a type it does
	#              not know
	#   see        Type, Narration
	#@ aka  A plain-language line -- the Softanza signature (legible to a non-coder).
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

# Bounds what an update plan may commit: the operation types, the path prefixes and the number of operations.
#
# A human usually commits with no scope; a script or an agent commits only inside a declared,
# auditable one, by the same mechanism. A new scope admits everything. Each AllowType and AllowUnder
# narrows it: once a type is allowed, any other type is refused, and once a prefix is allowed, every
# path an operation touches must start with one of them. Reason says why an operation is refused and
# Allows says whether it is. The limit on the number of operations is applied by the plan while it
# commits.
#
#   receiver   o1 = new stzCommitScope()
#   example    o1.AllowUnder("/w/").AllowType("create_file")
#              ? o1.Allows(new stzVirtualOperation("create_file", [ [ "path", "/w/a.txt" ], [ "content", "" ] ]))
#              #--> 1
#              ? o1.Reason(new stzVirtualOperation("delete_file", [ [ "path", "/w/a.txt" ] ]))
#              #--> operation type 'delete_file' is not allowed by this scope
#   see        stzUpdatePlan, stzVirtualOperation
class stzCommitScope from stzObject

	@aAllowedPrefixes = []
	@aAllowedTypes = []
	@nMaxOps = 0

	# Builds an unlimited scope, which admits every operation until a bound is added.
	#
	#   returns    nothing; the scope is built
	#   see        AllowUnder, AllowType, SetMaxOperations
	def init()

	# Adds a path prefix that operations may touch; once one is added, every path an operation touches must start with one of them.
	#
	#   pcPrefix   the path prefix to admit, matched as text from the start
	#   returns    the scope itself, so calls chain
	#   warning    the match is on text, not on folders: /w also admits /work/z, so end a folder
	#              prefix with a slash
	#   see        AllowedPrefixes, Reason
	def AllowUnder(pcPrefix)
		@aAllowedPrefixes + ("" + pcPrefix)
		return This

	# Adds an operation type that is admitted; once one is added, any other type is refused.
	#
	#   pcType     the type to admit, such as create_file, matched without regard to case
	#   returns    the scope itself, so calls chain
	#   see        AllowUnder, Reason
	def AllowType(pcType)
		@aAllowedTypes + StzLower(ring_trim("" + pcType))
		return This

	# Sets the most operations one plan may commit under this scope.
	#
	#   pnMax      the limit
	#   returns    the scope itself, so calls chain
	#   see        MaxOperations, stzUpdatePlan
	def SetMaxOperations(pnMax)
		@nMaxOps = pnMax
		return This

	# Returns the most operations one plan may commit under this scope.
	#
	#   returns    a number; 0 when there is no limit
	#   see        SetMaxOperations
	def MaxOperations()
		return @nMaxOps

	# Returns the path prefixes admitted so far.
	#
	#   returns    a list of text; empty when paths are unrestricted
	#   see        AllowUnder
	def AllowedPrefixes()
		return @aAllowedPrefixes

	# Returns why an operation is refused, or nothing when it is admitted.
	#
	#   oOp        the stzVirtualOperation to judge
	#   returns    a text naming the type or the path that fails; an empty text when the operation
	#              is admissible
	#   see        Allows, AllowUnder, AllowType
	#@ aka  "" if the operation is admissible, otherwise the reason it is refused.
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

	# TRUE if the operation passes the type and path bounds.
	#
	#   oOp        the stzVirtualOperation to judge
	#   returns    TRUE or FALSE
	#   note       the limit on the number of operations is checked by the plan at commit time, not
	#              here
	#   see        Reason
	def Allows(oOp)
		return This.Reason(oOp) = ""

	def _HasAllowedPrefix(pcPath)
		_n_ = len(@aAllowedPrefixes)
		for _i_ = 1 to _n_
			if StzFindFirst(@aAllowedPrefixes[_i_], pcPath) = 1
				return 1
			ok
		next
		return 0

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

# Holds the rehearsed operations of a twin as the one artifact that may cross into reality, narrated, ranked for risk and gated.
#
# A twin changes only its own memory; reality changes when a plan is executed. The plan can tell its
# story in plain words (Narration), rank what deserves a second look (Risks), re-check itself
# against reality as it is now (Validate), let a reviewer reject steps, and say whether its executor
# may commit at all (MayCommit). Execute then passes each active operation through three gates, the
# reviewer, the commit scope and the executor's capabilities, before the bridge touches anything,
# and records every decision in the audit trail. Narrate and rehearse freely; execute with intent.
#
#   receiver   v = new stzVirtualFileSystem(); v.CreateFile("/w/a.txt", "alpha");
#              v.DeleteFile("/w/old.txt"); o1 = v.GenerateUpdatePlan()
#   example    ? o1.NumberOfOperations()
#              #--> 2
#              ? @@( o1.Risks() )
#              #--> [ [ 2, "DESTRUCTIVE: delete file '/w/old.txt'" ] ]
#              ? @@( o1.MayCommit() )
#              #--> [ 1, "no executor set -- unguarded (a human at the keyboard)" ]
#   see        stzVirtualSystem, stzCommitScope, stzVirtualOperation, stzSystemActor
class stzUpdatePlan from stzObject

	@aOps = []
	@oBridge = ""
	@oScope = ""
	@aRejected = []
	@oExecutor = ""
	@oGov = ""
	@aAudit = []

	# Builds a plan from rehearsed operations and the bridge that would commit them; nothing is committed until Execute.
	#
	#   paOps      the list of stzVirtualOperation, in the order they were rehearsed
	#   poBridge   the reality bridge that Validate asks and Execute commits through
	#   returns    nothing; the plan is built
	#   note       a twin builds it for you with GenerateUpdatePlan
	#   see        Execute, stzVirtualSystem
	def init(paOps, poBridge)
		if isList(paOps)
			@aOps = paOps
		ok
		@oBridge = poBridge

	# Returns the operations the plan holds, rejected ones included.
	#
	#   returns    a list of stzVirtualOperation
	#   see        NumberOfOperations, RejectOperation
	def Operations()
		return @aOps

	# Returns how many operations the plan holds, rejected ones included.
	#
	#   returns    a number
	#   see        NumberOfActiveOperations, Operations
	def NumberOfOperations()
		return len(@aOps)

	# Returns how many operations would still be committed, which is those not rejected.
	#
	#   returns    a number
	#   see        NumberOfOperations, RejectOperation
	def NumberOfActiveOperations()
		_n_ = len(@aOps)
		_nActive_ = 0
		for _i_ = 1 to _n_
			if NOT This.IsRejected(_i_)
				_nActive_++
			ok
		next
		return _nActive_

	# Sets the bound on what the plan may commit.
	#
	#   poScope    the stzCommitScope that checks each operation
	#   returns    the plan itself, so calls chain
	#   see        Scope, Execute
	def SetScope(poScope)
		@oScope = poScope
		return This

	# Returns the scope set on the plan.
	#
	#   returns    the stzCommitScope; an empty text when none is set
	#   see        SetScope
	def Scope()
		return @oScope

	# Sets who commits the plan, whose capability kinds gate the crossing.
	#
	#   poActor    the stzSystemActor that commits
	#   returns    the plan itself, so calls chain
	#   note       without an executor the plan is unguarded, as a human at the keyboard
	#   see        Executor, MayCommit
	#@ aka  WHO is committing (a stzSystemActor). Its capability kinds gate the crossing (Phase 4).
	def SetExecutor(poActor)
		@oExecutor = poActor
		return This

	# Returns who commits the plan.
	#
	#   returns    the stzSystemActor; an empty text when none is set
	#   see        SetExecutor
	def Executor()
		return @oExecutor

	# Sets an optional governance that demands a declared trust posture of the executor and keeps the decision lineage.
	#
	#   poGov      the stzGovernance to consult
	#   returns    the plan itself, so calls chain
	#   note       the plan keeps a copy, so read its lineage through Governance
	#   see        Governance, Execute
	#@ aka  An optional stzGovernance -- adds the trust-posture requirement and the decision lineage on top of the capability gate.
	def SetGovernance(poGov)
		@oGov = poGov
		return This

	# Returns the governance set on the plan.
	#
	#   returns    the stzGovernance; an empty text when none is set
	#   see        SetGovernance
	def Governance()
		return @oGov

	# Returns the decisions the plan took when it was executed.
	#
	#   returns    a list of [ index, outcome, type, actor ] rows, the outcome committed or refused
	#   note       an operation refused by a scope, or rejected by a reviewer, leaves no row
	#   see        NumberOfAuditEntries, Execute
	#@ aka  The plan's own decision trail (plain data, always available): [ index, outcome("committed"/"refused"), op-type, actor ]. Read it back from the plan after Execute -- Ring copies objects on assignment, so a wired stzGovernance accumulates the richer lineage in THIS plan's copy (via Governance()), not in the caller's original.
	def AuditTrail()
		return @aAudit

	# Returns how many decisions the audit trail holds.
	#
	#   returns    a number
	#   see        AuditTrail
	def NumberOfAuditEntries()
		return len(@aAudit)

	# Marks one operation as rejected by a reviewer, so Execute skips it.
	#
	#   pnIndex     the position of the operation in the plan, from 1
	#   pcBecause   the reason for rejecting it
	#   returns     the plan itself, so calls chain
	#   note        the reason is kept with the rejection, and the narration shows the operation
	#               with an x
	#   see         IsRejected, NumberOfActiveOperations
	def RejectOperation(pnIndex, pcBecause)
		@aRejected + [ pnIndex, "" + pcBecause ]
		return This

	# TRUE if the operation at that position was rejected.
	#
	#   pnIndex    the position of the operation, from 1
	#   returns    TRUE or FALSE
	#   see        RejectOperation
	def IsRejected(pnIndex)
		_n_ = len(@aRejected)
		for _i_ = 1 to _n_
			if @aRejected[_i_][1] = pnIndex
				return 1
			ok
		next
		return 0

	# Returns the plan as a plain-language story, one numbered line per operation, rejected ones marked.
	#
	#   returns    a text, several lines
	#   see        ShowNarration, Risks
	#@ aka  The plain-language story of the change (VSF P4).
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

	# Prints the narration of the plan.
	#
	#   returns    nothing; it prints
	#   see        Narration
	def ShowNarration()
		? This.Narration()

	# Returns the operations that deserve a second look: deletions, moves, removed variables and spawned commands.
	#
	#   returns    a list of [ index, warning ] rows; an empty list when none is risky
	#   see        ShowRisks, Validate
	#@ aka  Ranked risk assessment -- destructive and lossy operations flagged.
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

	# Prints the risks of the plan, one line each.
	#
	#   returns    nothing; it prints
	#   see        Risks
	def ShowRisks()
		_aR_ = This.Risks()
		? "Risks (" + len(_aR_) + "):"
		_n_ = len(_aR_)
		for _i_ = 1 to _n_
			? "  ! op " + _aR_[_i_][1] + " -- " + _aR_[_i_][2]
		next

	# Re-checks the plan against reality as it is now, because reality may have moved since the rehearsal.
	#
	#   returns    a list of [ index, warning ] rows for a delete, copy or move whose target or
	#              source is absent; an empty list when all is present
	#   note       it reads reality through the bridge and changes nothing
	#   see        Risks, MayCommit
	#@ aka  Re-check against CURRENT reality; reality may have moved since rehearsal (VSF Honesty). Returns a list of [ index, warning ].
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

	# Tells whether the executor could commit this plan at all, without touching anything.
	#
	#   returns    a list [ 1 or 0, reason ]
	#   see        SetExecutor, Execute
	#@ aka  Preflight: CAN the current executor commit this plan at all? Returns [ bool, reason ] without touching anything. "This LLM's plan cannot cross" is answerable before an Execute is even attempted.
	def MayCommit()
		if @oExecutor = ""
			return [ 1, "no executor set -- unguarded (a human at the keyboard)" ]
		ok
		_n_ = len(@aOps)
		for _i_ = 1 to _n_
			if NOT This.IsRejected(_i_)
				_cKind_ = @aOps[_i_].RequiredKind()
				if NOT @oExecutor.Can(_cKind_)
					return [ 0, "actor '" + @oExecutor.Name() +
						"' cannot commit -- it lacks the '" + _cKind_ +
						"' capability (required by operation " + _i_ + ")" ]
				ok
			ok
		next
		return [ 1, "actor '" + @oExecutor.Name() +
			"' holds every capability this plan requires" ]

	# Commits every active operation through the bridge after the reviewer, scope and capability gates, and returns a summary with the log.
	#
	#   returns    a list [ [ committed, n ], [ skipped, n ], [ log, rows ] ], each row [ index,
	#              status, text ] with a status COMMITTED, FAILED, REJECTED, REFUSED-BY-SCOPE or
	#              REFUSED-BY-GOVERNANCE
	#   note       refusals reach the security ledger as scope.refused, capability.refused and
	#              posture.refused
	#   warning    this is the one place reality changes, and with a file or environment bridge it
	#              writes the disk or the process: rehearse in the twin and read Narration and Risks
	#              first; a governance that finds no declared posture refuses the whole plan with a
	#              single row of index 0
	#   see        MayCommit, AuditTrail, Validate
	#@ aka  COMMIT. The one place reality changes. Each active operation passes three gates -- the reviewer (reject), the SCOPE (where/what), and GOVERNANCE (may THIS actor commit an op of THIS capability kind) -- before it reaches the bridge. Expression is free; admission is governed. Returns a summary + log.
	def Execute()
		_nDone_ = 0
		_nSkipped_ = 0
		_aLog_ = []
		# GOVERNANCE preflight: an executor governed by an stzGovernance must
		# have a declared trust posture, or NOTHING crosses.
		if @oGov != "" and @oExecutor != ""
			if @oGov.MayExecute(@oExecutor.Name()) = 0
				# A whole plan refused for want of a declared posture used
				# to leave NO audit entry at all -- it returned a log line
				# and vanished. Noted now (incident I2).
				StzNoteRefusal("posture.refused", @oExecutor.Name(),
					"plan:" + len(@aOps) + " op(s)", @oGov.Why())
				return [
					[ "committed", 0 ],
					[ "skipped", len(@aOps) ],
					[ "log", [ [ 0, "REFUSED-BY-GOVERNANCE", @oGov.Why() ] ] ]
				]
			ok
		ok
		_n_ = len(@aOps)
		for _i_ = 1 to _n_
			_oOp_ = @aOps[_i_]
			if This.IsRejected(_i_)
				_nSkipped_++
				_aLog_ + [ _i_, "REJECTED", _oOp_.Describe() ]
				loop
			ok
			if @oScope != ""
				_cReason_ = @oScope.Reason(_oOp_)
				if _cReason_ != ""
					_nSkipped_++
					_aLog_ + [ _i_, "REFUSED-BY-SCOPE", _cReason_ ]
					# scope refusals were the second unaudited gap: an
					# operation reaching outside its allowed prefixes is
					# exactly what an investigation wants to see (I2)
					StzNoteRefusal("scope.refused", This._ActorName(),
						"op:" + _oOp_.Type(), _cReason_)
					loop
				ok
				if @oScope.MaxOperations() > 0 and _nDone_ >= @oScope.MaxOperations()
					_nSkipped_++
					_aLog_ + [ _i_, "REFUSED-BY-SCOPE", "max operations reached" ]
					StzNoteRefusal("scope.refused", This._ActorName(),
						"op:" + _oOp_.Type(), "max operations reached")
					loop
				ok
			ok
			# GOVERNANCE gate: the executor must hold the capability the
			# operation requires. An LLM actor (effect-capability set EMPTY)
			# cannot commit ANY effectful op -- it can only sit in the plan,
			# awaiting a guardian or human.
			if @oExecutor != ""
				_cKind_ = _oOp_.RequiredKind()
				if NOT @oExecutor.Can(_cKind_)
					_nSkipped_++
					_cWhyCap_ = "actor '" + @oExecutor.Name() + "' lacks the '" +
						_cKind_ + "' capability"
					_aLog_ + [ _i_, "REFUSED-BY-GOVERNANCE", _cWhyCap_ ]
					This._Audit(_i_, "refused", _oOp_)
					# the capability gate was already audited in-plan; the
					# ledger gets it too, timestamped and correlated (I2)
					_eCap_ = new stzSecurityEvent("capability.refused")
					_eCap_.ByActor(@oExecutor)
					_eCap_.About("op:" + _oOp_.Type())
					_eCap_.Doing(_cKind_)
					_eCap_.Refused(_cWhyCap_)
					StzRecordSecurityEvent(_eCap_)
					loop
				ok
			ok
			if @oBridge.ExecuteOperation(_oOp_)
				_nDone_++
				_aLog_ + [ _i_, "COMMITTED", _oOp_.Describe() ]
				This._Audit(_i_, "committed", _oOp_)
			else
				_aLog_ + [ _i_, "FAILED", _oOp_.Describe() ]
			ok
		next
		return [
			[ "committed", _nDone_ ],
			[ "skipped", _nSkipped_ ],
			[ "log", _aLog_ ]
		]

	# Record a decision into the plan's own audit trail (always), and into a
	# wired stzGovernance's lineage (if present).
	# the executing actor's name, or "unguarded" (incident I2 seams)
	def _ActorName()
		if @oExecutor = ""
			return "unguarded"
		ok
		return "" + @oExecutor.Name()

	def _Audit(pnIndex, pcOutcome, oOp)
		_cActor_ = "unguarded"
		if @oExecutor != ""
			_cActor_ = @oExecutor.Name()
		ok
		@aAudit + [ pnIndex, pcOutcome, oOp.Type(), _cActor_ ]
		if @oGov != "" and @oExecutor != ""
			@oGov.RecordDecision("plan-op-" + pnIndex,
				pcOutcome + ": " + oOp.Describe(),
				_cActor_, oOp.Type())
		ok

	# Commits the plan as Execute does, printing each row of the log as it comes.
	#
	#   returns    the same summary as Execute
	#   warning    the same warning as Execute: it commits for real
	#   see        Execute
	#@ aka  Same commit, printing each step as it crosses.
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

# Rehearses changes to a system in memory, keeps their history, and turns them into a plan; the generic core of every twin.
#
# A twin drives a state object that can apply an operation to itself and clone itself, and a bridge
# that is the only thing touching reality. ExecuteOperation applies one operation to the state and
# records it; UndoLast, CreateSnapshot and RollbackTo move back through the history;
# GenerateUpdatePlan hands the history to a plan. The twin holds no reference to reality, so nothing
# real changes until a plan is executed. It is domain-agnostic: use a specialization,
# stzVirtualFileSystem for files or stzVirtualEnvironment for variables, directory and processes.
#
#   receiver   o1 = new stzVirtualFileSystem()
#   example    o1.CreateFile("/w/a.txt", "alpha")
#              o1.CreateFile("/w/b.txt", "beta")
#              ? o1.NumberOfOperations()
#              #--> 2
#              o1.UndoLast(1)
#              ? o1.NumberOfOperations()
#              #--> 1
#              ? o1.History()[1].Describe()
#              #--> create file '/w/a.txt' (5 bytes)
#   see        stzVirtualFileSystem, stzVirtualEnvironment, stzUpdatePlan, stzVirtualOperation
class stzVirtualSystem from stzObject

	@oState = ""
	@oBaseState = ""
	@aHistory = []
	@aSnapshots = []
	@oBridge = ""
	@cActor = "human"

	# Builds a twin with no state and no bridge; a specialization such as stzVirtualFileSystem supplies both.
	#
	#   returns    nothing; the twin is built
	#   warning    used directly it has no state, so ExecuteOperation raises an error: build a
	#              specialization
	#   see        stzVirtualFileSystem, stzVirtualEnvironment
	def init()

	# Sets who is acting, which each operation rehearsed afterwards carries.
	#
	#   pcActor    the name of the human, script or agent
	#   returns    the twin itself, so calls chain
	#   note       operations already rehearsed keep the actor they were stamped with
	#   see        Actor, ExecuteOperation
	def SetActor(pcActor)
		@cActor = "" + pcActor
		return This

	# Returns who is acting.
	#
	#   returns    a text; human until another is set
	#   see        SetActor
	def Actor()
		return @cActor

	# Sets the reality bridge that plans generated by the twin commit through.
	#
	#   poBridge   the bridge object, which is the only thing that touches reality
	#   returns    the twin itself, so calls chain
	#   see        Bridge, GenerateUpdatePlan
	def SetBridge(poBridge)
		@oBridge = poBridge
		return This

	# Returns the reality bridge of the twin.
	#
	#   returns    the bridge object
	#   see        SetBridge
	def Bridge()
		return @oBridge

	# Returns the in-memory state the twin changes.
	#
	#   returns    the state object, such as a stzFileTree
	#   see        ExecuteOperation
	def State()
		return @oState

	# Rehearses one operation: applies it to the in-memory state and records it, touching nothing real.
	#
	#   oOp        the stzVirtualOperation to rehearse
	#   returns    the twin itself, so calls chain
	#   note       the verbs of a specialization, such as CreateFile, build the operation and call
	#              this
	#   see        History, UndoLast, GenerateUpdatePlan
	#@ aka  Rehearse ONE operation: mutate the in-memory twin and record it. Touches nothing real (P1).
	def ExecuteOperation(oOp)
		oOp.SetActor(@cActor)
		@oState.Apply(oOp)
		@aHistory + oOp
		return This

	# Returns the rehearsed operations, in order.
	#
	#   returns    a list of stzVirtualOperation
	#   see        NumberOfOperations, HistoryText
	def History()
		return @aHistory

	# Returns how many operations the history holds.
	#
	#   returns    a number
	#   see        History
	def NumberOfOperations()
		return len(@aHistory)

	# Drops the last operations from the history and rebuilds the state from the base and the operations kept.
	#
	#   pnCount    how many operations to drop from the end
	#   returns    the twin itself, so calls chain
	#   warning    a negative count raises an error; snapshots are not trimmed, so a RollbackTo to a
	#              snapshot taken after the dropped operations raises an error
	#   see        RollbackTo, CreateSnapshot
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

	# Keeps a copy of the current state and the length of the history under a name.
	#
	#   pcName     the name to find the snapshot by
	#   returns    the twin itself, so calls chain
	#   note       a second snapshot of the same name does not replace the first: RollbackTo finds
	#              the first
	#   see        RollbackTo
	def CreateSnapshot(pcName)
		@aSnapshots + [ "" + pcName, @oState.Clone(), len(@aHistory) ]
		return This

	# Restores the state of a snapshot and cuts the history back to its length.
	#
	#   pcName     the name given to CreateSnapshot
	#   returns    the twin itself, so calls chain
	#   warning    an unknown name raises an error; a snapshot taken at more operations than the
	#              history holds now, because UndoLast dropped some, raises an array-index error
	#              instead of restoring
	#   see        CreateSnapshot, UndoLast
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

	# Returns a plan holding the history and the bridge, ready to narrate, validate and commit.
	#
	#   returns    a stzUpdatePlan
	#   note       the plan holds the same operations as the history, and nothing is committed until
	#              Execute
	#   see        stzUpdatePlan, SetBridge
	def GenerateUpdatePlan()
		return new stzUpdatePlan(@aHistory, @oBridge)

	# Returns the rehearsal as text: each operation numbered, with its actor and its intent when one was given.
	#
	#   returns    a text, one line per operation
	#   see        ShowHistory, History
	#@ aka  THE REHEARSAL, AS TEXT.
	def HistoryText()
		_c_ = "Rehearsed operations (" + len(@aHistory) + "):" + nl
		_n_ = len(@aHistory)
		for _i_ = 1 to _n_
			_oOp_ = @aHistory[_i_]
			_c_ += "  " + _i_ + ". " + _oOp_.Describe() + "  [" + _oOp_.Actor() + "]"

			# AN OPERATION RECORDS WHO AND WHY. The actor was stamped and shown;
			# the intent had a setter and a reader and appeared in no output at
			# all, so a rehearsal could be asked why it did something and answer
			# nowhere. Shown only when one was given, so a history without
			# intents reads exactly as it did before.
			if _oOp_.Intent() != ""
				_c_ += " -- " + _oOp_.Intent()
			ok
			_c_ += nl
		next
		return _c_

	# Prints the rehearsal text.
	#
	#   returns    nothing; it prints
	#   see        HistoryText
	def ShowHistory()
		? This.HistoryText()

	# Rebuild the working state from the base + a kept prefix of operations.
	def _Rebuild(paOps)
		@oState = @oBaseState.Clone()
		_n_ = len(paOps)
		for _i_ = 1 to _n_
			@oState.Apply(paOps[_i_])
		next
