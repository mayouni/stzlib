#================================================================#
#  STZPAYOUTS -- money out is a plan a human commits (PY4)            #
#================================================================#

/*--- Receiving money needs no decision. Sending it does.

A payout -- one payment, a bulk of salaries, a return of funds, the acceptance of somebody's
request to pay or to cancel -- is never a method call. It is a PLAN, and a plan has a life:

    PROPOSED    by anyone, an agent included, and REHEARSED into a workbench: a twin of the disk
                that holds the plan as a document and changes nothing real
    JUDGED      by a policy, which is DATA read from the REHEARSED document -- "which people
                must approve what" is a platform's rule and never a constant in the port.
                DIKO's is four visas above 100 000 FCFA. The verdict is in the house shape
                [ rule, subject, where, severity, message ] and joins stzRuleReport, the one CI gate
    COMMITTED   by an actor that may change reality, across a scope, into a REAL file: the
                durable journal of what was authorised, visas and all. An LLM can propose a plan
                and cannot do this
    RELEASED    by the port, which was told exactly which payouts to allow and for how much, and
                refuses every other (payout-without-plan, payout-amount-differs)

    oPlan = StzPayoutPlanQ()
    oPlan.WithId("SAL-2026-10")
    oPlan.ProposedBy("treasury-agent")
    oPlan.PayingBulk(oBatch)
    oPlan.Visa("comptable", "A. Issoufou")        # ... four people, for 350 000 FCFA

    oDesk = StzPayoutDeskQ(oPort, StzDikoPayoutPolicyQ(), "payouts")
    oDesk.Rehearse(oPlan, nWorkbench)             # into the twin: the disk does not move
    oReport = oDesk.Judge(nWorkbench, "SAL-2026-10")
    aR = oDesk.Commit(nWorkbench, "SAL-2026-10", HumanActor("tresorier"))

ONE PLAN, ONE WORKBENCH. A commit crosses everything its workbench rehearsed, so a workbench
holds one plan. Rehearsing the same plan again overwrites its document.

WHAT IS JUDGED IS WHAT WOULD BE COMMITTED. The policy reads the rehearsed DOCUMENT, not the plan
object, and the commit refuses (rehearsal-differs) when the document is not what the plan object
now serialises to: visas added after the rehearsal, or a document edited in the workbench by
someone who was not a visa-giver, cannot reach the port.

THE POLICY COUNTS PEOPLE. A visa is a role and a name; a person who signs twice, in any case,
is one visa. The first rule says ABOVE: exactly 100 000 needs none. A plan's weight is the SUM
of what it pays, so a payroll cannot be split into small lines to slip under; splitting it
across SEVERAL plans is a different policy (a rule over a period), not this one.

REFUSAL IS AN EVENT. A refused commit is a journal row and a payout.refused event; a commit is a
journal row, a payout.committed event and a file. The journal is the desk's, in the order it
happened, and the ledger reads the same story.
*/

$aPayDeskPlans = []        # [ deskKey, planId, oPlan, committed ]
$aPayDeskJournal = []      # [ deskKey, record ]
$nPayDeskSeq = 0

func StzPayoutPlanQ()
	return new stzPayoutPlan()

func StzPayoutPolicyQ(pcName)
	return new stzPayoutPolicy(pcName)

# DIKO's rule, the first policy: four visas above 100 000 FCFA.
func StzDikoPayoutPolicyQ()
	_o_ = new stzPayoutPolicy("diko")
	_o_.RequireVisasAbove(100000, 4)
	return _o_

func StzPayoutDeskQ(poPort, poPolicy, pcDir)
	return new stzPayoutDesk(poPort, poPolicy, pcDir)

# what a policy judges, taken from the REHEARSED document: [ id, proposer, total, items, visas, visaCount ]
func _StzPayoutFacts(pcDocument)
	_a_ = StzJsonToList(pcDocument)
	_aItems_ = _StzPiGet(_a_, "items", [])
	_nTotal_ = 0
	for _i_ = 1 to ring_len(_aItems_)
		_nTotal_ = _nTotal_ + _StzPiGet(_aItems_[_i_], "amount", 0)
	next
	_aVisas_ = _StzPiGet(_a_, "visas", [])
	_aNames_ = []
	for _i_ = 1 to ring_len(_aVisas_)
		_c_ = StzLower(ring_trim("" + _StzPiGet(_aVisas_[_i_], "name", "")))
		if _c_ != "" and ring_find(_aNames_, _c_) = 0
			_aNames_ + _c_
		ok
	next
	return [ [ "id", "" + _StzPiGet(_a_, "plan", "") ], [ "proposer", "" + _StzPiGet(_a_, "proposer", "") ],
		[ "total", _nTotal_ ], [ "items", ring_len(_aItems_) ], [ "visas", _aNames_ ], [ "visaCount", ring_len(_aNames_) ] ]

func _StzPayoutFinding(pcRule, pcWhere, pcMessage)
	return [ [ "rule", pcRule ], [ "subject", "payouts" ], [ "where", pcWhere ], [ "severity", "error" ], [ "message", pcMessage ] ]


  #==================#
 #  A PAYOUT PLAN   #
#==================#

class stzPayoutPlan from stzObject

	@cId = ""
	@cProposer = ""
	@aItems = []       # [ [ kind, key, amount ], ... ]
	@aObjects = []     # the order or batch behind a pay / bulk item, "" for the others
	@aVisas = []       # [ [ role, name ], ... ]

	def init()
		# a plan starts empty and says what it pays

	def WithId(pcId)
		@cId = "" + pcId
		return This

	def Id()
		return @cId

	def ProposedBy(pcName)
		@cProposer = "" + pcName
		return This

	def Proposer()
		return @cProposer

	  #-- what it pays ------------------------------------------------

	def Paying(poOrder)
		@aItems + [ "pay", poOrder.TxId(), poOrder.Amount() ]
		@aObjects + poOrder
		return This

	def PayingBulk(poBatch)
		@aItems + [ "bulk", poBatch.InstructionId(), poBatch.TotalAmount() ]
		@aObjects + poBatch
		return This

	# the hub holds the amount of a payment we received, and the port checks the plan against it
	def Returning(pcEnd2EndId, pnAmount)
		@aItems + [ "return", "" + pcEnd2EndId, pnAmount ]
		@aObjects + ""
		return This

	def AcceptingRequest(pcEnd2EndId, pnAmount)
		@aItems + [ "answer-request", "" + pcEnd2EndId, pnAmount ]
		@aObjects + ""
		return This

	def AcceptingCancellation(pcEnd2EndId, pnAmount)
		@aItems + [ "answer-cancellation", "" + pcEnd2EndId, pnAmount ]
		@aObjects + ""
		return This

	def Items()
		return @aItems

	def Objects()
		return @aObjects

	def NumberOfItems()
		return ring_len(@aItems)

	def TotalAmount()
		_n_ = 0
		for _i_ = 1 to ring_len(@aItems)
			_n_ = _n_ + @aItems[_i_][3]
		next
		return _n_

	  #-- who approved it ----------------------------------------------

	def Visa(pcRole, pcName)
		@aVisas + [ "" + pcRole, "" + pcName ]
		return This

	def Visas()
		return @aVisas

	def NumberOfVisas()
		return ring_len(@aVisas)

	# people, not signatures: the same name in another case is the same person
	def NumberOfDistinctVisas()
		_a_ = []
		for _i_ = 1 to ring_len(@aVisas)
			_c_ = StzLower(ring_trim("" + @aVisas[_i_][2]))
			if _c_ != "" and ring_find(_a_, _c_) = 0
				_a_ + _c_
			ok
		next
		return ring_len(_a_)

	# THE DOCUMENT: what is rehearsed, judged and committed. No credential is ever in it.
	def Document()
		_aItems_ = []
		for _i_ = 1 to ring_len(@aItems)
			_aItems_ + [ [ "kind", @aItems[_i_][1] ], [ "key", @aItems[_i_][2] ], [ "amount", @aItems[_i_][3] ] ]
		next
		_aVisas_ = []
		for _i_ = 1 to ring_len(@aVisas)
			_aVisas_ + [ [ "role", @aVisas[_i_][1] ], [ "name", @aVisas[_i_][2] ] ]
		next
		return ListToJson([ [ "plan", @cId ], [ "proposer", @cProposer ], [ "items", _aItems_ ], [ "visas", _aVisas_ ] ])


  #===============#
 #  THE POLICY   #
#===============#

class stzPayoutPolicy from stzObject

	@cName = ""
	@aVisaRules = []     # [ [ amount, visas ], ... ]
	@bProposerOut = 0

	def init(pcName)
		@cName = "" + pcName

	def Name()
		return @cName

	# ABOVE pnAmount (strictly), a plan needs pnVisas distinct people
	def RequireVisasAbove(pnAmount, pnVisas)
		@aVisaRules + [ pnAmount, pnVisas ]
		return This

	# separation of duties: whoever proposed the plan may not be one of its visas
	def ProposerCannotVisa()
		@bProposerOut = 1
		return This

	def JudgePlan(poPlan)
		return This.JudgeDocument(poPlan.Document())

	# Findings in the house shape, from the DOCUMENT as it was rehearsed.
	def JudgeDocument(pcDocument)
		_aFacts_ = _StzPayoutFacts(pcDocument)
		_cId_ = _StzPiGet(_aFacts_, "id", "")
		_nTotal_ = _StzPiGet(_aFacts_, "total", 0)
		_nVisas_ = _StzPiGet(_aFacts_, "visaCount", 0)
		_aOut_ = []
		if _StzPiGet(_aFacts_, "items", 0) = 0
			_aOut_ + _StzPayoutFinding("payout-plan-empty", _cId_, "the plan pays nothing")
		ok
		for _i_ = 1 to ring_len(@aVisaRules)
			_nAbove_ = @aVisaRules[_i_][1]
			_nNeed_ = @aVisaRules[_i_][2]
			if _nTotal_ > _nAbove_ and _nVisas_ < _nNeed_
				_aOut_ + _StzPayoutFinding("payout-over-" + _nAbove_ + "-needs-" + _nNeed_ + "-visas", _cId_,
					"this payout moves " + _nTotal_ + " FCFA, above " + _nAbove_ + ": it needs " + _nNeed_ +
					" visas from distinct people, and has " + _nVisas_)
			ok
		next
		if @bProposerOut
			_cP_ = StzLower(ring_trim("" + _StzPiGet(_aFacts_, "proposer", "")))
			if _cP_ != "" and ring_find(_StzPiGet(_aFacts_, "visas", []), _cP_) > 0
				_aOut_ + _StzPayoutFinding("payout-proposer-cannot-visa", _cId_,
					"the person who proposed the plan is one of its visas")
			ok
		ok
		return _aOut_


  #===============#
 #  THE DESK     #
#===============#

class stzPayoutDesk from stzObject

	@nKey = 0
	@oPort = ""
	@oPolicy = ""
	@cDir = ""

	def init(poPort, poPolicy, pcDir)
		$nPayDeskSeq = $nPayDeskSeq + 1
		@nKey = $nPayDeskSeq
		@oPort = poPort
		@oPolicy = poPolicy
		@cDir = "" + pcDir

	def PathOf(pcPlanId)
		return @cDir + "/" + pcPlanId + ".plan.json"

	# PROPOSE: write the plan's document into the workbench. The disk does not move.
	def Rehearse(poPlan, pnBench)
		_oBench_ = StzAgentWorkbenchQ(pnBench)
		if poPlan.Proposer() != ""
			_oBench_.SetActor(poPlan.Proposer())
		ok
		_cPath_ = This.PathOf(poPlan.Id())
		if _oBench_.Exists(_cPath_) = 1
			_oBench_.WriteFile(_cPath_, poPlan.Document())
		else
			_oBench_.CreateFile(_cPath_, poPlan.Document())
		ok
		_k_ = This._PlanRow(poPlan.Id())
		if _k_ > 0
			$aPayDeskPlans[_k_][3] = poPlan
		else
			$aPayDeskPlans + [ @nKey, poPlan.Id(), poPlan, 0 ]
		ok
		return This

	# JUDGE the rehearsed document with the policy: the shared rule report
	def Judge(pnBench, pcPlanId)
		_oBench_ = StzAgentWorkbenchQ(pnBench)
		_cDoc_ = _oBench_.ReadThrough(This.PathOf(pcPlanId))
		_aF_ = @oPolicy.JudgeDocument(_cDoc_)
		_oRep_ = new stzRuleReport("payouts")
		_oRep_.Ingest(_aF_)
		return _oRep_

	# COMMIT: policy, then the rehearsal is what will be paid, then an actor who may crosses a
	# real file under a scope, then the port is told exactly what to allow, then it is released.
	# Never raises on a refusal: it answers [ committed, reason, detail, results, file ].
	def Commit(pnBench, pcPlanId, poActor)
		_cWho_ = "?"
		if isObject(poActor)
			_cWho_ = "" + poActor.Name()
		ok
		_k_ = This._PlanRow(pcPlanId)
		if _k_ = 0
			return This._Refuse(pcPlanId, _cWho_, 0, 0, "unknown-plan", "the desk was never given a plan called '" + pcPlanId + "'")
		ok
		_oPlan_ = $aPayDeskPlans[_k_][3]
		_nTotal_ = _oPlan_.TotalAmount()
		_nVisas_ = _oPlan_.NumberOfDistinctVisas()
		if $aPayDeskPlans[_k_][4] = 1
			return This._Refuse(pcPlanId, _cWho_, _nTotal_, _nVisas_, "already-committed", "this plan was committed, and pays once")
		ok
		_oBench_ = StzAgentWorkbenchQ(pnBench)
		_cPath_ = This.PathOf(pcPlanId)
		_cDoc_ = _oBench_.ReadThrough(_cPath_)

		# 1. the policy, on the document as rehearsed
		_aF_ = @oPolicy.JudgeDocument(_cDoc_)
		if ring_len(_aF_) > 0
			return This._Refuse(pcPlanId, _cWho_, _nTotal_, _nVisas_, "policy", _StzPiGet(_aF_[1], "message", ""))
		ok

		# 2. the document is the plan that will be paid
		if _cDoc_ != _oPlan_.Document()
			return This._Refuse(pcPlanId, _cWho_, _nTotal_, _nVisas_, "rehearsal-differs",
				"the rehearsed document is not the plan to be paid: visas were added after it, or it was edited")
		ok

		# 3. an actor who may change reality
		if NOT isObject(poActor)
			return This._Refuse(pcPlanId, _cWho_, _nTotal_, _nVisas_, "actor", "no actor was offered to commit the plan")
		ok
		_oUp_ = _oBench_.GenerateUpdatePlan()
		_oUp_.SetExecutor(poActor)
		_aMay_ = _oUp_.MayCommit()
		if _aMay_[1] = 0
			return This._Refuse(pcPlanId, _cWho_, _nTotal_, _nVisas_, "actor", _aMay_[2])
		ok
		if poActor.Posture() = "sandboxed"
			return This._Refuse(pcPlanId, _cWho_, _nTotal_, _nVisas_, "actor", "a sandboxed actor may not commit a payout")
		ok

		# 4. the crossing: the plan becomes a REAL file, the durable journal of what was authorised
		_oScope_ = new stzCommitScope()
		_oScope_.AllowUnder(@cDir)
		_oUp_.SetScope(_oScope_)
		_aRes_ = _oUp_.Execute()
		if _aRes_[1][2] < 1 or _aRes_[2][2] > 0
			return This._Refuse(pcPlanId, _cWho_, _nTotal_, _nVisas_, "crossing", "the plan did not cross into the journal file")
		ok

		# 5. the port is told exactly what to allow, 6. and it is released
		_aItems_ = _oPlan_.Items()
		_aObjs_ = _oPlan_.Objects()
		for _i_ = 1 to ring_len(_aItems_)
			@oPort.AuthorisePayout(poActor, pcPlanId, _aItems_[_i_][1], _aItems_[_i_][2], _aItems_[_i_][3])
		next
		$aPayDeskPlans[_k_][4] = 1
		_aResults_ = []
		for _i_ = 1 to ring_len(_aItems_)
			_aResults_ + This._Release(_aItems_[_i_], _aObjs_[_i_])
		next
		This._Journal(pcPlanId, "committed", "", _cWho_, _nTotal_, _nVisas_)
		StzNoteGrant("payout.committed", _cWho_, "plan:" + pcPlanId)
		return [ [ "committed", 1 ], [ "reason", "" ], [ "detail", "" ], [ "results", _aResults_ ], [ "file", _cPath_ ] ]

	# the desk's journal, oldest first: [ seq, plan, outcome, reason, actor, total, visas ] as records
	def Journal()
		_a_ = []
		for _i_ = 1 to ring_len($aPayDeskJournal)
			if $aPayDeskJournal[_i_][1] = @nKey
				_a_ + $aPayDeskJournal[_i_][2]
			ok
		next
		return _a_

	  #-- internals ----------------------------------------------------

	def _PlanRow(pcId)
		for _i_ = 1 to ring_len($aPayDeskPlans)
			if $aPayDeskPlans[_i_][1] = @nKey and $aPayDeskPlans[_i_][2] = pcId
				return _i_
			ok
		next
		return 0

	def _Journal(pcPlan, pcOutcome, pcReason, pcActor, pnTotal, pnVisas)
		_n_ = ring_len(This.Journal()) + 1
		$aPayDeskJournal + [ @nKey, [ [ "seq", _n_ ], [ "plan", pcPlan ], [ "outcome", pcOutcome ], [ "reason", pcReason ],
			[ "actor", pcActor ], [ "total", pnTotal ], [ "visas", pnVisas ] ] ]

	def _Refuse(pcPlan, pcWho, pnTotal, pnVisas, pcReason, pcDetail)
		This._Journal(pcPlan, "refused", pcReason, pcWho, pnTotal, pnVisas)
		StzNoteRefusal("payout.refused", pcWho, "plan:" + pcPlan, pcReason + ": " + pcDetail)
		return [ [ "committed", 0 ], [ "reason", pcReason ], [ "detail", pcDetail ], [ "results", [] ], [ "file", "" ] ]

	# one authorised item through the port; an error the PORT raises is the item's result, and
	# the other items still go: each is a separate movement of money
	def _Release(paItem, pxObject)
		_cKind_ = paItem[1]
		_cKey_ = paItem[2]
		_aOut_ = []
		try
			if _cKind_ = "pay"
				_aOut_ = @oPort.Pay(pxObject)
			but _cKind_ = "bulk"
				_aOut_ = @oPort.PayInBulk(pxObject)
			but _cKind_ = "return"
				_aOut_ = @oPort.ReturnFunds(_cKey_)
			but _cKind_ = "answer-request"
				_aOut_ = @oPort.AnswerRequest(_cKey_, 1, "")
			but _cKind_ = "answer-cancellation"
				_aOut_ = @oPort.AnswerCancellation(_cKey_, 1)
			ok
			_aOut_ + [ "kind", _cKind_ ]
			_aOut_ + [ "key", _cKey_ ]
		catch
			_aOut_ = [ [ "kind", _cKind_ ], [ "key", _cKey_ ], [ "error", cCatchError ] ]
		done
		return _aOut_
