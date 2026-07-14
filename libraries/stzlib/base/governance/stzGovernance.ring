# R4b -- stzGovernance: PROGRAMMATIC GOVERNANCE AS DECLARABLE CONTRACTS
# (SOFTANZA_INTELLIGENCE_ARCHITECTURE.md 5.7 G6 + 5.8 trust postures.)
# The five primitives closing the industry's governance gaps, plus the
# structural split the doctrine demands:
#
#   PERMISSION (CAN)  is not  AUTHORITY (SHOULD) -- an actor may hold
#   one without the other, and MayProceed() composes BOTH with the
#   action's RISK TIER before anything happens.
#
#   oGov = new stzGovernance("kitchen-ops")
#   oGov.DeclareRisk("send-invoice", 3)
#   oGov.GrantPermission("billing-agent", "send-invoice")   # CAN
#   oGov.SetAuthority("billing-agent", :Delegated)          # SHOULD (level 2)
#   ? oGov.MayProceed("billing-agent", "send-invoice")      # refused: tier 3
#                                                           # needs autonomous+
# MECHANISM ONLY: no fixed constitution ships with Softanza; regimes
# are product space (the 5.7 boundary). FORMAT: *.zgov.

func StzLoadGovernance(pcFile)
	_cContent_ = StzReplace(read(pcFile), char(13), "")
	_acLines_ = StzSplit(_cContent_, char(10))
	_oG_ = new stzGovernance("")
	_cSection_ = ""
	_nLen_ = len(_acLines_)
	for _i_ = 1 to _nLen_
		_cL_ = ring_trim(_acLines_[_i_])
		if _cL_ = ""
			loop
		ok
		if StzLeft(_cL_, 11) = 'governance '
			_acQ_ = StzSplit(_cL_, '"')
			if len(_acQ_) >= 2
				_oG_.SetName(_acQ_[2])
			ok
		but _cL_ = "risks" or _cL_ = "permissions" or _cL_ = "authorities" or
		    _cL_ = "postures"
			_cSection_ = _cL_
		but _cSection_ = "risks"
			_acP_ = StzSplit(_cL_, "|")
			if len(_acP_) = 2
				_oG_.DeclareRisk(ring_trim(_acP_[1]), ring_number(ring_trim(_acP_[2])))
			ok
		but _cSection_ = "permissions"
			_acP_ = StzSplit(_cL_, "|")
			if len(_acP_) = 2
				_oG_.GrantPermission(ring_trim(_acP_[1]), ring_trim(_acP_[2]))
			ok
		but _cSection_ = "authorities"
			_acP_ = StzSplit(_cL_, "|")
			if len(_acP_) = 2
				_oG_.SetAuthority(ring_trim(_acP_[1]), ring_trim(_acP_[2]))
			ok
		but _cSection_ = "postures"
			_acP_ = StzSplit(_cL_, "|")
			if len(_acP_) = 2
				_oG_.DeclarePosture(ring_trim(_acP_[1]), ring_trim(_acP_[2]))
			ok
		ok
	next
	return _oG_


class stzGovernance from stzObject

	@cName = ""
	@aRisks = []          # [ action, tier 1..4 ]
	@aPermissions = []    # CAN:    [ actor, action ]
	@aAuthorities = []    # SHOULD: [ actor, type ]
	@aCommitments = []    # [ id, state, history(list) ]
	@aDecommissions = []  # [ actor, obligations(list), fulfilled(list) ]
	@aLineage = []        # [ id, rationale, actor, authority-at-time, risk ]
	@aPostures = []       # [ executor, trusted|external|sandboxed ]
	@cWhy = ""

	def init(pcName)
		@cName = "" + pcName

	def SetName(pcName)
		@cName = "" + pcName

	def Name_()
		return @cName

	def Why()
		return @cWhy

	#-- 1. ACTION RISK TIERS ------------------------------------------------

	def DeclareRisk(pcAction, nTier)
		if nTier < 1 or nTier > 4
			stzraise("Risk tiers run 1 (low) to 4 (critical).")
		ok
		_cA_ = StzLower(ring_trim("" + pcAction))
		_n_ = len(@aRisks)
		for _i_ = 1 to _n_
			if @aRisks[_i_][1] = _cA_
				@aRisks[_i_][2] = nTier
				return This
			ok
		next
		@aRisks + [ _cA_, nTier ]
		return This

	def RiskOf(pcAction)
		_cA_ = StzLower(ring_trim("" + pcAction))
		_n_ = len(@aRisks)
		for _i_ = 1 to _n_
			if @aRisks[_i_][1] = _cA_
				return @aRisks[_i_][2]
			ok
		next
		return 0   # undeclared

	#-- 2. PERMISSION (CAN) vs AUTHORITY (SHOULD) ----------------------------

	def GrantPermission(pcActor, pcAction)
		_cAc_ = StzLower(ring_trim("" + pcActor))
		_cAn_ = StzLower(ring_trim("" + pcAction))
		_n_ = len(@aPermissions)
		for _i_ = 1 to _n_
			if @aPermissions[_i_][1] = _cAc_ and @aPermissions[_i_][2] = _cAn_
				return This
			ok
		next
		@aPermissions + [ _cAc_, _cAn_ ]
		return This

	def HasPermission(pcActor, pcAction)
		_cAc_ = StzLower(ring_trim("" + pcActor))
		_cAn_ = StzLower(ring_trim("" + pcAction))
		_n_ = len(@aPermissions)
		for _i_ = 1 to _n_
			if @aPermissions[_i_][1] = _cAc_ and @aPermissions[_i_][2] = _cAn_
				return 1
			ok
		next
		return 0

	def SetAuthority(pcActor, pcType)
		_cT_ = StzLower(ring_trim("" + pcType))
		if This._AuthLevel(_cT_) = 0
			stzraise("Authority is :Advisory, :Delegated, :Autonomous or :EmergencyOverride.")
		ok
		_cAc_ = StzLower(ring_trim("" + pcActor))
		_n_ = len(@aAuthorities)
		for _i_ = 1 to _n_
			if @aAuthorities[_i_][1] = _cAc_
				@aAuthorities[_i_][2] = _cT_
				return This
			ok
		next
		@aAuthorities + [ _cAc_, _cT_ ]
		return This

	def AuthorityOf(pcActor)
		_cAc_ = StzLower(ring_trim("" + pcActor))
		_n_ = len(@aAuthorities)
		for _i_ = 1 to _n_
			if @aAuthorities[_i_][1] = _cAc_
				return @aAuthorities[_i_][2]
			ok
		next
		return ""

	def _AuthLevel(pcType)
		if pcType = "advisory"
			return 1
		but pcType = "delegated"
			return 2
		but pcType = "autonomous"
			return 3
		but pcType = "emergencyoverride" or pcType = "emergency_override"
			return 4
		ok
		return 0

	# THE COMPOSITION: CAN + SHOULD + RISK, decided BEFORE the act.
	# An actor proceeds only when it HAS the permission AND its
	# authority level covers the action's risk tier. Every verdict
	# narrates (LAW 3); an undeclared action is REFUSED, not assumed.
	def MayProceed(pcActor, pcAction)
		_nTier_ = This.RiskOf(pcAction)
		if _nTier_ = 0
			@cWhy = "refused: '" + pcAction + "' has NO declared risk tier (undeclared actions never proceed)"
			return 0
		ok
		if This.HasPermission(pcActor, pcAction) = 0
			@cWhy = "refused: '" + pcActor + "' lacks PERMISSION (can) for '" + pcAction + "'"
			return 0
		ok
		_cAuth_ = This.AuthorityOf(pcActor)
		_nLevel_ = This._AuthLevel(_cAuth_)
		if _nLevel_ < _nTier_
			@cWhy = "refused: '" + pcActor + "' holds '" + _cAuth_ +
				"' authority (level " + _nLevel_ + ") but '" + pcAction +
				"' is risk tier " + _nTier_ + " (SHOULD does not cover it)"
			return 0
		ok
		@cWhy = "allowed: permission held AND '" + _cAuth_ +
			"' authority (level " + _nLevel_ + ") covers risk tier " + _nTier_
		return 1

	#-- 3. COMMITMENT STATE (forward-only) -----------------------------------

	def OpenCommitment(pcId)
		_cId_ = StzLower(ring_trim("" + pcId))
		_n_ = len(@aCommitments)
		for _i_ = 1 to _n_
			if @aCommitments[_i_][1] = _cId_
				stzraise("Commitment '" + _cId_ + "' already open.")
			ok
		next
		@aCommitments + [ _cId_, "exploratory", [ "exploratory" ] ]
		return This

	def AdvanceCommitment(pcId)
		_cId_ = StzLower(ring_trim("" + pcId))
		_n_ = len(@aCommitments)
		for _i_ = 1 to _n_
			if @aCommitments[_i_][1] = _cId_
				if @aCommitments[_i_][2] = "exploratory"
					@aCommitments[_i_][2] = "provisional"
				but @aCommitments[_i_][2] = "provisional"
					@aCommitments[_i_][2] = "committed"
				else
					stzraise("Commitment '" + _cId_ + "' is already COMMITTED -- the state is forward-only (regressions are new commitments, deliberately).")
				ok
				@aCommitments[_i_][3] + @aCommitments[_i_][2]
				return @aCommitments[_i_][2]
			ok
		next
		stzraise("No commitment '" + _cId_ + "'.")

	def CommitmentStateOf(pcId)
		_cId_ = StzLower(ring_trim("" + pcId))
		_n_ = len(@aCommitments)
		for _i_ = 1 to _n_
			if @aCommitments[_i_][1] = _cId_
				return @aCommitments[_i_][2]
			ok
		next
		return ""

	#-- 4. DECOMMISSION CONTRACT ---------------------------------------------

	def DeclareDecommission(pcActor, pacObligations)
		_cAc_ = StzLower(ring_trim("" + pcActor))
		_acO_ = []
		_n_ = len(pacObligations)
		for _i_ = 1 to _n_
			_acO_ + StzLower(ring_trim("" + pacObligations[_i_]))
		next
		@aDecommissions + [ _cAc_, _acO_, [] ]
		return This

	def FulfillObligation(pcActor, pcObligation)
		_cAc_ = StzLower(ring_trim("" + pcActor))
		_cO_ = StzLower(ring_trim("" + pcObligation))
		_n_ = len(@aDecommissions)
		for _i_ = 1 to _n_
			if @aDecommissions[_i_][1] = _cAc_
				if ring_find(@aDecommissions[_i_][2], _cO_) = 0
					stzraise("'" + _cO_ + "' is not a declared obligation for '" + _cAc_ + "'.")
				ok
				if ring_find(@aDecommissions[_i_][3], _cO_) = 0
					@aDecommissions[_i_][3] + _cO_
				ok
				return This
			ok
		next
		stzraise("No decommission contract for '" + _cAc_ + "'.")

	# retirement is EARNED: every declared obligation fulfilled first
	def MayRetire(pcActor)
		_cAc_ = StzLower(ring_trim("" + pcActor))
		_n_ = len(@aDecommissions)
		for _i_ = 1 to _n_
			if @aDecommissions[_i_][1] = _cAc_
				_acMissing_ = []
				_nO_ = len(@aDecommissions[_i_][2])
				for _j_ = 1 to _nO_
					if ring_find(@aDecommissions[_i_][3], @aDecommissions[_i_][2][_j_]) = 0
						_acMissing_ + @aDecommissions[_i_][2][_j_]
					ok
				next
				if len(_acMissing_) = 0
					@cWhy = "allowed: every declared obligation fulfilled"
					return 1
				ok
				@cWhy = "refused: obligations pending -- " + JoinXT(_acMissing_, ", ")
				return 0
			ok
		next
		@cWhy = "refused: no decommission contract declared for '" + _cAc_ + "' (retirement without a contract never proceeds)"
		return 0

	#-- 5. DECISION LINEAGE ----------------------------------------------------

	# a decision records its rationale AND the actor's authority + the
	# action's risk AT THE TIME -- 'why does this look the way it does'
	# stays answerable forever
	def RecordDecision(pcId, pcRationale, pcActor, pcAction)
		@aLineage + [ StzLower(ring_trim("" + pcId)), "" + pcRationale,
			StzLower(ring_trim("" + pcActor)), This.AuthorityOf(pcActor),
			This.RiskOf(pcAction) ]
		return This

	def LineageOf(pcId)
		_cId_ = StzLower(ring_trim("" + pcId))
		_n_ = len(@aLineage)
		for _i_ = 1 to _n_
			if @aLineage[_i_][1] = _cId_
				return [ :id = _cId_, :rationale = @aLineage[_i_][2],
					:actor = @aLineage[_i_][3],
					:authorityAtTime = @aLineage[_i_][4],
					:riskAtTime = @aLineage[_i_][5] ]
			ok
		next
		return []

	#-- EXECUTION TRUST POSTURES (5.8) -----------------------------------------

	def DeclarePosture(pcExecutor, pcPosture)
		_cP_ = StzLower(ring_trim("" + pcPosture))
		if ring_find([ "trusted", "external", "sandboxed" ], _cP_) = 0
			stzraise("A posture is :Trusted (in-process), :External (out-of-process) or :Sandboxed (LLM-composed).")
		ok
		_cE_ = StzLower(ring_trim("" + pcExecutor))
		_n_ = len(@aPostures)
		for _i_ = 1 to _n_
			if @aPostures[_i_][1] = _cE_
				@aPostures[_i_][2] = _cP_
				return This
			ok
		next
		@aPostures + [ _cE_, _cP_ ]
		return This

	def PostureOf(pcExecutor)
		_cE_ = StzLower(ring_trim("" + pcExecutor))
		_n_ = len(@aPostures)
		for _i_ = 1 to _n_
			if @aPostures[_i_][1] = _cE_
				return @aPostures[_i_][2]
			ok
		next
		return ""

	# execution without a declared posture never proceeds
	def MayExecute(pcExecutor)
		_cP_ = This.PostureOf(pcExecutor)
		if _cP_ = ""
			@cWhy = "refused: '" + pcExecutor + "' has NO declared trust posture"
			return 0
		ok
		@cWhy = "allowed: posture '" + _cP_ + "' declared"
		return 1

	#-- persistence (*.zgov) ------------------------------------------------------

	def Save(pcFile)
		if StzRight(pcFile, 5) != ".zgov"
			pcFile += ".zgov"
		ok
		_c_ = 'governance "' + @cName + '"' + NL
		_c_ += "risks" + NL
		_n_ = len(@aRisks)
		for _i_ = 1 to _n_
			_c_ += "    " + @aRisks[_i_][1] + " | " + @aRisks[_i_][2] + NL
		next
		_c_ += "permissions" + NL
		_n_ = len(@aPermissions)
		for _i_ = 1 to _n_
			_c_ += "    " + @aPermissions[_i_][1] + " | " + @aPermissions[_i_][2] + NL
		next
		_c_ += "authorities" + NL
		_n_ = len(@aAuthorities)
		for _i_ = 1 to _n_
			_c_ += "    " + @aAuthorities[_i_][1] + " | " + @aAuthorities[_i_][2] + NL
		next
		_c_ += "postures" + NL
		_n_ = len(@aPostures)
		for _i_ = 1 to _n_
			_c_ += "    " + @aPostures[_i_][1] + " | " + @aPostures[_i_][2] + NL
		next
		write(pcFile, _c_)
		return pcFile
