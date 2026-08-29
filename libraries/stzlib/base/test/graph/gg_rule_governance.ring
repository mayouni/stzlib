load "../../stzBase.ring"

/*---------------------------------------------------------------------------
	SCOPE GOVERNANCE ACROSS THE RULE DOMAINS

	The graph plane's six scope defects were one defect -- a right rule
	applied outside its scope -- and none was findable by testing the rule,
	because a rule that selects the wrong subjects and judges them
	correctly returns "pass". stzScopedRule splits SELECTION from
	JUDGEMENT so the first half can be checked; stzRuleGovernance asks the
	five questions no rule can ask about itself.

	Applied to the other domains it found two defects on its first run,
	and neither is visible to any verdict-shaped test:

	  1. stzOrgChart aliased Node() to Position(), whose record keeps its
	     attributes FLAT while stzGraph.NodeProperty() reads them nested
	     under "properties". So every property read on an org chart
	     returned empty, and the THREE rules that read properties could
	     only ever report "no findings" -- including separation-of-duties,
	     which describes itself as a SOX exemplar.

	     What made it visible was a COUNT, not a verdict: no-self-report
	     governed 0 positions in a chart of four. The org suite's 22
	     assertions all passed before and after, because every one of them
	     asks what the rules SAY, and a rule that governs nothing says
	     nothing.

	  2. The clause DSL had no "not-contains", so a prohibition could only
	     be written by putting the violation INTO the scope. The file's own
	     documented example does this, and it means "governs nothing" and
	     "everything complies" are the same output -- on an error-severity
	     agentic control, the two readings a person most needs to separate.

	Run:  ring gg_rule_governance.ring
---------------------------------------------------------------------------*/

decimals(2)
nOk = 0  nBad = 0

? "=============================================================="
? " SCOPE GOVERNANCE -- the rule sets, and the rules about them"
? "=============================================================="

#-- 1. THE ORG CHART'S PROPERTIES REACH ITS RULES ---------------------------
sec("-- 1. a chart's own properties are readable by its own rules")

oP = new stzOrgChart("props")
oP.AddPositionXTT("boss", "Boss", [ :level = "executive" ])
oP.AddPositionXTT("hand", "Hand", [ :level = "staff", :reportsTo = "boss" ])
oP.ReportsTo("hand", "boss")

chkeq("a property set through AddPositionXTT reads back",
	"" + oP.NodeProperty("hand", "level"), "staff")
chkeq("...and so does one the org vocabulary sets",
	"" + oP.NodeProperty("hand", "reportsTo"), "boss")
# THE NEGATIVE SIBLING: an unset property still answers empty, so the
# assertion above is about the round trip and not about a reader that
# says "staff" to everything.
chkeq("NEGATIVE: an unset property is still empty",
	"" + oP.NodeProperty("hand", "clearance"), "")

#-- 2. THE CONTROLS THAT DEPEND ON IT ---------------------------------------
sec("-- 2. the three rules that read properties can fire again")

oS = new stzOrgChart("sox")
oS.AddPositionXTT("ceo", "CEO", [ :level = "executive" ])
oS.AddPositionXTT("cfo", "CFO", [ :level = "senior", :reportsTo = "ceo",
	:roles = [ "approver", "executor" ] ])
oS.AddPositionXTT("clerk", "Clerk", [ :level = "staff", :reportsTo = "cfo",
	:roles = [ "executor" ] ])
oS.ReportsTo("cfo", "ceo")
oS.ReportsTo("clerk", "cfo")

oSet = StzOrgRuleSetQ()
StzAddSODRule(oSet)
aSod = oSet.Check(oS)
nSod = 0
for iS = 1 to len(aSod)
	if aSod[iS][:rule] = "separation-of-duties"  nSod++  ok
next
chkeq("separation-of-duties catches one position holding both duties",
	nSod, 1)
# ...AND SPARES THE ONE THAT HOLDS ONLY ONE. A control that fired on
# everybody would also have passed the assertion above.
bClerk = 0
for iS = 1 to len(aSod)
	if aSod[iS][:rule] = "separation-of-duties" and
	   StzLower("" + aSod[iS][:where]) = "clerk"  bClerk = 1  ok
next
chkeq("NEGATIVE: ...and spares the position holding one duty", bClerk, 0)

#-- 3. THE MEASURE THAT FOUND IT --------------------------------------------
sec("-- 3. coverage, which is what a verdict cannot express")

gOrg = StzRuleGovernance("org")
aoOrg = StzOrgRuleSetQ().Rules()
for iO = 1 to len(aoOrg)  gOrg.AddRule(aoOrg[iO])  next
gOrg.AddCase("sox", oS)
aTab = gOrg.ScopeTable()
nSelf = -1
for iT = 1 to len(aTab)
	if aTab[iT][1] = "no-self-report"  nSelf = aTab[iT][2]  ok
next
chk("no-self-report governs the positions that HAVE a supervisor",
	nSelf = 2)
# It governed 0 before -- and 0 findings from 0 subjects is the exact
# reading that hid the defect for as long as it existed.
chk("...which is what a rule governing 0 of 3 could never have told us",
	nSelf > 0)

nExcl = -1
for iT = 1 to len(aTab)
	if aTab[iT][1] = "no-self-report"  nExcl = aTab[iT][3]  ok
next
chk("...and it excludes the executive, who has no supervisor to be",
	nExcl = 1)

#-- 4. THE DSL CAN SAY "MUST NOT" -------------------------------------------
sec("-- 4. a prohibition without putting the violation in the scope")

oProhib = new stzGraphRule("no-llm-effectful-probe")
oProhib.SetDomainQ("agentic").SetSeverityQ("error")
oProhib.SetMessageQ("an llm actor must not hold the effectful capability")
oProhib.WhenQ("kind", "equals", "llm_actor")
oProhib.ThenQ("capabilities", "not-contains", "effectful")
oProhib.ThenViolationQ("llm actor holds effectful")

oBad = new stzGraph("bad")
oBad.AddNode("w")
oBad.SetNodeProperty("w", "kind", "llm_actor")
oBad.SetNodeProperty("w", "capabilities", [ "propose", "effectful" ])
chkeq("a prohibited capability is caught", len(oProhib.Check(oBad)), 1)

oGood = new stzGraph("good")
oGood.AddNode("w")
oGood.SetNodeProperty("w", "kind", "llm_actor")
oGood.SetNodeProperty("w", "capabilities", [ "propose" ])
chkeq("NEGATIVE: ...and a compliant actor is not", len(oProhib.Check(oGood)), 0)
# THE WHOLE POINT: the compliant actor is still GOVERNED. Under the old
# form -- both clauses as scope -- it was outside the rule entirely, so
# "no findings" and "nothing inspected" were one answer.
chkeq("...and the compliant actor is still IN SCOPE, which is the point",
	len(StzGraphRuleSubjects(oGood, oProhib)), 1)

#-- 5. THE FIVE QUESTIONS, ACROSS DOMAINS -----------------------------------
sec("-- 5. the checks a rule cannot run on itself")

aMeta = gOrg.CheckRules()
nMetaErr = 0
for iM = 1 to len(aMeta)
	if aMeta[iM][:severity] = :error  nMetaErr++  ok
next
chkeq("no org rule is dead, unclaimed, or reading a stale value",
	nMetaErr, 0)

# ...AND THE GOVERNOR IS NOT SIMPLY SILENT. A rule with no scope at all
# must be reported, or a clean run proves nothing about the instrument.
oDumb = StzScopedRule("governs-nothing")
oDumb.SetClaim("a claim about nothing at all")
gProof = StzRuleGovernance("proof")
gProof.AddRule(oDumb)
gProof.AddCase("sox", oS)
aProof = gProof.CheckRules()
bDead = 0
for iP = 1 to len(aProof)
	if aProof[iP][:rule] = :scope_empty  bDead = 1  ok
next
chk("NEGATIVE: a rule that governs nothing IS reported", bDead = 1)

? ""
? "=============================================================="
? " " + nOk + " ok, " + nBad + " failed"
? "=============================================================="

func sec cTitle
	? ""
	? cTitle

func chk cWhat, bCond
	if bCond
		? "   ok   " + cWhat
		nOk++
	else
		? "  FAIL  " + cWhat
		nBad++
	ok

func chkeq cWhat, xGot, xWant
	chk(cWhat + "  [got " + xGot + ", want " + xWant + "]", xGot = xWant)

# The subjects a clause-based rule governs -- its When clauses alone,
# which is the set the rule INSPECTED as opposed to the set it faulted.
func StzGraphRuleSubjects oGraph, oRule
	_r_ = []
	_a_ = oGraph.NodesIds()
	_c_ = oRule.Clauses()
	for _i_ = 1 to len(_a_)
		_ok_ = 1
		for _j_ = 1 to len(_c_)
			if NOT _StzGraphRuleClauseHolds(oGraph, _a_[_i_], _c_[_j_])
				_ok_ = 0  exit
			ok
		next
		if _ok_  _r_ + _a_[_i_]  ok
	next
	return _r_
