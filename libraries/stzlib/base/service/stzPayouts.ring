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

# Holds a proposed payout as a plan to be judged and committed by a person, since money out is never a method call.
#
# Money out is a PLAN a human commits. A plan names what it pays, whether one payment, a bulk, the
# return of a payment received, or the acceptance of a request to pay or of a cancellation, and
# carries the visas of the people who approve it. Building a plan moves nothing: a stzPayoutDesk
# rehearses it into a workbench, a policy judges the rehearsed document, and only an actor who may
# change reality, never a language model, can commit it, after which the port releases exactly what
# the plan names. The weight of a plan is the sum of what it pays, so a payroll cannot be cut into
# small lines to slip under a threshold. The policy that judges it is the platform's own data. The
# whole path was run against the in-process twin, which moves no money.
#
#   receiver   o1 = new stzPayoutPlan()
#   example    o1.WithId("SUP-2026-10").ProposedBy("treasury-agent")
#              o1.Returning("E2E-0001", 40000)
#              o1.Visa("comptable", "A. Issoufou")
#              o1.Visa("DAF", "M. Garba")
#              ? o1.TotalAmount()
#              #--> 40000
#              ? o1.NumberOfDistinctVisas()
#              #--> 2
#   see        stzPayoutDesk, stzPayoutPolicy, stzPaymentsPort
class stzPayoutPlan from stzObject

	@cId = ""
	@cProposer = ""
	@aItems = []       # [ [ kind, key, amount ], ... ]
	@aObjects = []     # the order or batch behind a pay / bulk item, "" for the others
	@aVisas = []       # [ [ role, name ], ... ]

	# Builds an empty plan that pays nothing yet, to be filled by naming what it pays and who gives a visa.
	#
	#   returns    nothing; the object is built
	#   note       a plan is a proposal: building it, filling it and rehearsing it move no money,
	#              and only a person's commit through a stzPayoutDesk releases it
	#   see        WithId, Paying, Visa
	def init()
	# Sets the identifier of the plan, which names its rehearsed document and the file written when it is committed.
	#
	#   pcId       the plan's identifier, as text
	#   returns    the plan itself, so calls chain
	#   note       the rehearsed document lives at <folder>/<id>.plan.json, so the id is also a file
	#              name
	#   see        Id, Paying
	#@ aka  a plan starts empty and says what it pays
	def WithId(pcId)
		@cId = "" + pcId
		return This

	# Returns the identifier of the plan.
	#
	#   returns    a text; empty until WithId is called
	#   see        WithId
	def Id()
		return @cId

	# Sets the name of whoever proposes the plan, an agent or a person.
	#
	#   pcName     the proposer's name, as text
	#   returns    the plan itself, so calls chain
	#   note       a policy built with ProposerCannotVisa refuses a plan whose proposer is among its
	#              visas
	#   see        Proposer, Visa
	def ProposedBy(pcName)
		@cProposer = "" + pcName
		return This

	# Returns the name of whoever proposed the plan.
	#
	#   returns    a text; empty until ProposedBy is called
	#   see        ProposedBy
	def Proposer()
		return @cProposer

	# Adds one payment to the plan, kept with the order behind it so that the commit can release exactly that order.
	#
	#   poOrder    the stzPaymentOrder to pay, whose id and amount are read
	#   returns    the plan itself, so calls chain
	#   note       the item is recorded as kind pay, keyed by the order's transaction id
	#   warning    a value that is not an object raises error R13 at once
	#   see        PayingBulk, TotalAmount, Items
	#@ aka  -- what it pays ------------------------------------------------
	def Paying(poOrder)
		@aItems + [ "pay", poOrder.TxId(), poOrder.Amount() ]
		@aObjects + poOrder
		return This

	# Adds a whole bulk of payments to the plan as one item whose amount is the sum of the batch.
	#
	#   poBatch    the stzPaymentBatch to pay, whose instruction id and total are read
	#   returns    the plan itself, so calls chain
	#   note       the item is recorded as kind bulk, keyed by the batch's instruction id
	#   warning    a value that is not an object raises error R13 at once
	#   see        Paying, TotalAmount
	def PayingBulk(poBatch)
		@aItems + [ "bulk", poBatch.InstructionId(), poBatch.TotalAmount() ]
		@aObjects + poBatch
		return This

	# Adds the return of a payment that was received, by its end-to-end id and the amount the hub holds for it.
	#
	#   pcEnd2EndId   the end-to-end id of the payment received
	#   pnAmount      the amount the hub holds for it, in francs
	#   returns       the plan itself, so calls chain
	#   note          the port refuses the movement at the commit if this amount differs from the
	#                 hub's (payout-amount-differs); the plan still commits and the refusal is that
	#                 item's result
	#   see           AcceptingRequest, Paying
	#@ aka  the hub holds the amount of a payment we received, and the port checks the plan against it
	def Returning(pcEnd2EndId, pnAmount)
		@aItems + [ "return", "" + pcEnd2EndId, pnAmount ]
		@aObjects + ""
		return This

	# Adds the acceptance of a request to pay somebody sent us, which is money out, by its end-to-end id and amount.
	#
	#   pcEnd2EndId   the end-to-end id of the request received
	#   pnAmount      the amount of the request, in francs
	#   returns       the plan itself, so calls chain
	#   note          at the commit the desk answers the request with acceptance through the port
	#   see           Returning, AcceptingCancellation
	def AcceptingRequest(pcEnd2EndId, pnAmount)
		@aItems + [ "answer-request", "" + pcEnd2EndId, pnAmount ]
		@aObjects + ""
		return This

	# Adds the acceptance of a cancellation request, which returns funds, by its end-to-end id and amount.
	#
	#   pcEnd2EndId   the end-to-end id of the payment to cancel
	#   pnAmount      the amount to return, in francs
	#   returns       the plan itself, so calls chain
	#   note          refusing a cancellation is not money out and needs no plan
	#   see           Returning, AcceptingRequest
	def AcceptingCancellation(pcEnd2EndId, pnAmount)
		@aItems + [ "answer-cancellation", "" + pcEnd2EndId, pnAmount ]
		@aObjects + ""
		return This

	# Returns what the plan pays, one record per item, in the order they were added.
	#
	#   returns    a list of [ kind, key, amount ] where kind is pay, bulk, return, answer-request
	#              or answer-cancellation
	#   see        Objects, NumberOfItems, Document
	def Items()
		return @aItems

	# Returns the order or batch behind each item, in the same order as Items.
	#
	#   returns    a list with the stzPaymentOrder or stzPaymentBatch for a pay or bulk item, and an
	#              empty text for the other kinds
	#   see        Items
	def Objects()
		return @aObjects

	# Returns how many items the plan pays.
	#
	#   returns    a number
	#   see        Items, TotalAmount
	def NumberOfItems()
		return ring_len(@aItems)

	# Returns the weight of the plan: the sum of every item it pays.
	#
	#   returns    a number, in francs
	#   note       a policy judges this sum, so a payroll cannot be cut into small lines to slip
	#              under a threshold
	#   see        Items, NumberOfItems
	def TotalAmount()
		_n_ = 0
		for _i_ = 1 to ring_len(@aItems)
			_n_ = _n_ + @aItems[_i_][3]
		next
		return _n_

	# Records the role and the name of a person who approves the plan; the same person signing twice counts once.
	#
	#   pcRole     the role of the signer, such as comptable or DG
	#   pcName     the signer's name
	#   returns    the plan itself, so calls chain
	#   note       visas added after a rehearsal do not reach the desk until the plan is rehearsed
	#              again
	#   see        Visas, NumberOfDistinctVisas
	#@ aka  -- who approved it ----------------------------------------------
	def Visa(pcRole, pcName)
		@aVisas + [ "" + pcRole, "" + pcName ]
		return This

	# Returns every visa recorded, in the order given.
	#
	#   returns    a list of [ role, name ]
	#   see        Visa, NumberOfVisas
	def Visas()
		return @aVisas

	# Returns how many visas were recorded, signatures and not people.
	#
	#   returns    a number
	#   see        NumberOfDistinctVisas, Visas
	def NumberOfVisas()
		return ring_len(@aVisas)

	# Returns how many different people gave a visa; the same name in another case is one person and an empty name counts for none.
	#
	#   returns    a number
	#   see        NumberOfVisas, Visa
	#@ aka  people, not signatures: the same name in another case is the same person
	def NumberOfDistinctVisas()
		_a_ = []
		for _i_ = 1 to ring_len(@aVisas)
			_c_ = StzLower(ring_trim("" + @aVisas[_i_][2]))
			if _c_ != "" and ring_find(_a_, _c_) = 0
				_a_ + _c_
			ok
		next
		return ring_len(_a_)

	# Returns the plan as one JSON text: its id, proposer, items and visas, which is what is rehearsed, judged and committed.
	#
	#   returns    a text holding JSON
	#   note       the document holds no credential, and the object behind a pay or bulk item is not
	#              in it
	#   see        Items, Visas
	#@ aka  THE DOCUMENT: what is rehearsed, judged and committed. No credential is ever in it.
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

# Holds the rules of who must approve a payout plan, as data a platform writes, and judges a plan against them.
#
# The rule of which people must approve what is a platform's, so it is data in a policy and never a
# constant in the port. A policy counts people, not signatures: a person who signs twice, in any
# case, is one visa. The first rule says above, so a total exactly equal to the threshold needs
# none. A verdict is a list of findings in the house shape [ rule, subject, where, severity, message
# ], which joins stzRuleReport, the one CI gate. A policy only judges: it moves nothing and commits
# nothing. StzDikoPayoutPolicyQ builds one platform's policy, four visas above 100 000 FCFA.
#
#   receiver   o1 = new stzPayoutPolicy("mine")
#   example    o1.RequireVisasAbove(100000, 4).ProposerCannotVisa()
#              oPlan = StzPayoutPlanQ().WithId("P1").ProposedBy("agent").Returning("E2E-0001", 250000)
#              oPlan.Visa("DAF", "M. Garba")
#              ? o1.JudgePlan(oPlan)[1][:rule]
#              #--> payout-over-100000-needs-4-visas
#   see        stzPayoutPlan, stzPayoutDesk, stzRuleReport
class stzPayoutPolicy from stzObject

	@cName = ""
	@aVisaRules = []     # [ [ amount, visas ], ... ]
	@bProposerOut = 0

	# Builds a named policy with no rule, which finds fault only with a plan that pays nothing.
	#
	#   pcName     the policy's name, as text
	#   returns    nothing; the object is built
	#   note       the rule of who must approve what is a platform's data, never a constant of the
	#              port: add yours with RequireVisasAbove and ProposerCannotVisa
	#   see        RequireVisasAbove, StzDikoPayoutPolicyQ
	def init(pcName)
		@cName = "" + pcName

	# Returns the title the policy was given when it was built.
	#
	#   returns    a text
	#   see        init
	def Name()
		return @cName

	# Adds a rule: a plan whose total is strictly above an amount needs a number of visas from distinct people.
	#
	#   pnAmount   the threshold in francs, a total exactly equal to it needs no visa
	#   pnVisas    how many distinct people must have given a visa
	#   returns    the policy itself, so calls chain
	#   note       several rules may be added and each one that fails gives its own finding named
	#              payout-over-<amount>-needs-<visas>-visas
	#   see        ProposerCannotVisa, JudgePlan
	#@ aka  ABOVE pnAmount (strictly), a plan needs pnVisas distinct people
	def RequireVisasAbove(pnAmount, pnVisas)
		@aVisaRules + [ pnAmount, pnVisas ]
		return This

	# Adds separation of duties: the person who proposed a plan may not be one of its visas.
	#
	#   returns    the policy itself, so calls chain
	#   note       the names are compared without regard to case, and a plan with no proposer is
	#              never refused by this rule
	#   see        RequireVisasAbove, JudgePlan
	#@ aka  separation of duties: whoever proposed the plan may not be one of its visas
	def ProposerCannotVisa()
		@bProposerOut = 1
		return This

	# Returns the findings of this policy on a plan object, by judging the document the plan would write.
	#
	#   poPlan     the stzPayoutPlan to judge
	#   returns    a list of findings, each [ rule, subject, where, severity, message ]; an empty
	#              list means the plan is sound
	#   note       a desk judges the rehearsed document and not the plan object, so this is for a
	#              quick look before rehearsing
	#   see        JudgeDocument, RequireVisasAbove
	def JudgePlan(poPlan)
		return This.JudgeDocument(poPlan.Document())

	# Returns the findings of this policy on a rehearsed plan document, which is what a desk judges and commits.
	#
	#   pcDocument   the plan's JSON text, as Document of the plan returns it
	#   returns      a list of findings, each [ rule, subject, where, severity, message ]; an empty
	#                list means the plan is sound
	#   note         the findings join stzRuleReport, the one CI gate; where is the plan's id
	#   warning      a plan with no item gives the finding payout-plan-empty whatever the rules
	#   see          JudgePlan, Document
	#@ aka  Findings in the house shape, from the DOCUMENT as it was rehearsed.
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

# Takes a payout plan from proposal to release: rehearse it, judge it, and let a person commit it, with a journal of every attempt.
#
# Money out is a plan a human commits, and the desk is where that happens. Rehearse writes the plan
# into a workbench, a twin of the disk, so nothing real moves. Judge reads the rehearsed document
# and applies the policy. Commit checks the policy, that the rehearsed document is the plan that
# will be paid, and that the actor may change reality; a language-model actor and a sandboxed actor
# are refused. Only then does the plan cross into a real file, the durable record of what was
# authorised, visas included, and the port is told exactly which payouts to allow and for how much
# before each is released. A refusal never raises: it is a journal row and an event. One plan, one
# workbench. Everything here was run against the in-process twin, which moves no money.
#
#   receiver   o1 = StzPayoutDeskQ(StzPaymentsPortQ(StzPiSpiSandboxQ()), StzDikoPayoutPolicyQ(),
#              "payouts")
#   example    ? o1.PathOf("SUP-1")
#              #--> payouts/SUP-1.plan.json
#              ? len(o1.Journal())
#              #--> 0
#   see        stzPayoutPlan, stzPayoutPolicy, stzPaymentsPort, stzAgentWorkbench
class stzPayoutDesk from stzObject

	@nKey = 0
	@oPort = ""
	@oPolicy = ""
	@cDir = ""

	# Builds a desk that rehearses, judges and commits payout plans for one port under one policy, keeping its journal in a folder.
	#
	#   poPort     the stzPaymentsPort that will be told what to allow and then release
	#   poPolicy   the stzPayoutPolicy that judges every plan
	#   pcDir      the folder where a committed plan is written as its journal file
	#   returns    nothing; the object is built
	#   note       each desk has its own journal, and a plan is known only to the desk it was
	#              rehearsed on
	#   see        Rehearse, Commit, StzDikoPayoutPolicyQ
	def init(poPort, poPolicy, pcDir)
		$nPayDeskSeq = $nPayDeskSeq + 1
		@nKey = $nPayDeskSeq
		@oPort = poPort
		@oPolicy = poPolicy
		@cDir = "" + pcDir

	# Returns where a plan is written, in the desk's folder: the rehearsed document in a workbench and the journal file once committed.
	#
	#   pcPlanId   the plan's identifier
	#   returns    a text: <folder>/<plan id>.plan.json
	#   see        Rehearse, Commit
	def PathOf(pcPlanId)
		return @cDir + "/" + pcPlanId + ".plan.json"

	# Writes a plan's document into a workbench, a twin of the disk, so it can be judged without anything real moving.
	#
	#   poPlan     the stzPayoutPlan to rehearse
	#   pnBench    the workbench number returned by StzOpenAgentWorkbench
	#   returns    the desk itself, so calls chain
	#   note       the proposer acts in the workbench under the plan's proposer name, and no real
	#              file exists yet
	#   warning    the desk keeps the plan as it is now: visas added to the plan afterwards are not
	#              seen until it is rehearsed again, and rehearsing again overwrites the document;
	#              one plan, one workbench
	#   see        Judge, Commit
	#@ aka  PROPOSE: write the plan's document into the workbench. The disk does not move.
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

	# Returns the verdict of the policy on the plan document held in the workbench, in the house rule report.
	#
	#   pnBench    the workbench the plan was rehearsed into
	#   pcPlanId   the identifier of the plan to judge
	#   returns    a stzRuleReport: IsSound is 1 when no rule fails and Errors lists the failing
	#              ones, each naming its rule
	#   note       a verdict is not a payment: a sound plan still pays nothing until a person
	#              commits it
	#   see        Rehearse, Commit
	#@ aka  JUDGE the rehearsed document with the policy: the shared rule report
	def Judge(pnBench, pcPlanId)
		_oBench_ = StzAgentWorkbenchQ(pnBench)
		_cDoc_ = _oBench_.ReadThrough(This.PathOf(pcPlanId))
		_aF_ = @oPolicy.JudgeDocument(_cDoc_)
		_oRep_ = new stzRuleReport("payouts")
		_oRep_.Ingest(_aF_)
		return _oRep_

	# Lets an actor who may change reality release a judged plan: its journal file is written, then each item is paid through the port.
	#
	#   pnBench    the workbench the plan was rehearsed into
	#   pcPlanId   the identifier of the plan to commit
	#   poActor    the actor committing it, such as HumanActor("tresorier")
	#   returns    a list [ committed, reason, detail, results, file ]: committed is 1 or 0, results
	#              holds one answer per item, file is the journal path
	#   note       money out is a plan that a human commits: a refusal is a journal row and a
	#              payout.refused event, a commit is a journal row, a payout.committed event and a
	#              real file
	#   warning    a refusal never raises: committed is 0 and reason is unknown-plan, already-
	#              committed, policy, rehearsal-differs, actor or crossing, with the cause in
	#              detail; a language-model actor, a sandboxed actor and a value that is not an
	#              object are all refused for actor; the checks run in that order and the policy is
	#              judged before the actor; a plan commits once; an item the port refuses is that
	#              item's error in results while the others still go
	#   see        Rehearse, Judge, Journal
	#@ aka  COMMIT: policy, then the rehearsal is what will be paid, then an actor who may crosses a real file under a scope, then the port is told exactly what to allow, then it is released. Never raises on a refusal: it answers [ committed, reason, detail, results, file ].
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

	# Returns the desk's record of every commit attempt, oldest first, whether it was refused or went through.
	#
	#   returns    a list of records [ seq, plan, outcome, reason, actor, total, visas ] where
	#              outcome is committed or refused
	#   note       a second desk has its own empty journal
	#   see        Commit
	#@ aka  the desk's journal, oldest first: [ seq, plan, outcome, reason, actor, total, visas ] as records
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
