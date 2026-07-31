# Decision lineage -- the second bug-shaped finding of the incident
# study (SOFTANZA_INCIDENT_ANALYSIS.md section 2).
#
# The study named two defects worth fixing regardless of the incident
# plan. I2 closed the first (scope and posture refusals were never
# audited). This is the second: the lineage had NO timestamps, was
# queryable only by an id you already knew, grew without bound, and was
# DROPPED ENTIRELY by Save() -- so "why does this look the way it does"
# stayed answerable only until the process ended.
#
# Ring traps avoided: main code before the first func; no oR / nL /
# cAll locals.

load "../../stzBase.ring"

nPass = 0
nFail = 0
$T0 = 1785700000000

pr()

oGov = new stzGovernance("kitchen-ops")
oGov.DeclareRisk("send-invoice", 3)
oGov.DeclareRisk("refund", 2)
oGov.GrantPermission("billing-agent", "send-invoice")
oGov.SetAuthority("billing-agent", :Autonomous)
oGov.SetAuthority("support-agent", :Delegated)

? "-- Scene 1: a decision now says WHEN --"
oGov.RecordDecisionAt("d-101", "peak-season pricing adjustment",
	"billing-agent", "send-invoice", $T0)
aD = oGov.LineageOf("d-101")
chk("the rationale survives", aD[:rationale] = "peak-season pricing adjustment")
chk("...with the authority AT THE TIME", aD[:authorityAtTime] = "autonomous")
chk("...the risk at the time", aD[:riskAtTime] = 3)
chk("...and now the moment it was taken", aD[:at] = $T0)
chk("the ACTION is kept beside its tier", aD[:action] = "send-invoice")
# Without the time, a lineage cannot say whether a decision came before
# or after the change it is supposed to explain -- the first question
# anyone asks of it. Without the action, two unrelated tier-3 decisions
# are indistinguishable.

? ""
? "-- Scene 2: the questions an investigation actually opens with --"
oGov.RecordDecisionAt("d-102", "refund approved under the goodwill rule",
	"support-agent", "refund", $T0 + 60000)
oGov.RecordDecisionAt("d-103", "second invoice run after the outage",
	"billing-agent", "send-invoice", $T0 + 120000)
chk("what did this actor decide?", len(oGov.DecisionsOf("billing-agent")) = 2)
chk("who decided anything about this action?",
	len(oGov.DecisionsAbout("send-invoice")) = 2)
chk("...and the other action is not swept in", len(oGov.DecisionsAbout("refund")) = 1)
chk("what was decided after this moment?",
	len(oGov.DecisionsSince($T0 + 60000)) = 2)
chk("...and inside this window?",
	len(oGov.DecisionsBetween($T0, $T0 + 60000)) = 2)
? "  " + oGov.NumberOfDecisions() + " decisions, reachable five ways"
# An audit trail you can only query by a key you already know is a
# lookup table.

? ""
? "-- Scene 3: a re-decision supersedes, without erasing --"
oGov.RecordDecisionAt("d-101", "reverted -- the season ended early",
	"billing-agent", "send-invoice", $T0 + 180000)
chk("the LATEST answer wins",
	oGov.LineageOf("d-101")[:rationale] = "reverted -- the season ended early")
chk("...and the earlier one is still reachable",
	len(oGov.LineageHistoryOf("d-101")) = 2)
chk("the history is in the order it happened",
	oGov.LineageHistoryOf("d-101")[1][:at] = $T0)

? ""
? "-- Scene 4: bounded, and honest about it --"
chk("the lineage is complete so far", oGov.LineageIsComplete())
chk("...and says nothing was dropped", oGov.LineageDropped() = 0)
oGov.SetLineageCapacity(2)
chk("lowering the bound drops the OLDEST", oGov.NumberOfDecisions() = 2)
chk("...counts them", oGov.LineageDropped() = 2)
chk("...and no longer claims to be complete", NOT oGov.LineageIsComplete())
chk("the survivors are the most recent",
	oGov.LineageOf("d-101")[:at] = $T0 + 180000)
? "  " + oGov.LineageDropped() + " decision(s) dropped by a capacity of " +
	oGov.LineageCapacity()
# An unbounded list is a leak wearing an audit trail's clothes. A
# bounded one that drops SILENTLY is worse: the gap reads as a period
# when nothing was decided.

? ""
? "-- Scene 5: the section Save() used to throw away --"
oReg = new stzGovernance("kitchen-ops")
oReg.DeclareRisk("send-invoice", 3)
oReg.GrantPermission("billing-agent", "send-invoice")
oReg.SetAuthority("billing-agent", :Autonomous)
oReg.DeclarePosture("py-runner", :Sandboxed)
oReg.RecordDecisionAt("d-201", "raised the tier after the audit | see ticket 4471",
	"billing-agent", "send-invoice", $T0)
cFile = oReg.Save("t_gov_lineage")

oBack = new stzGovernance("")
oBack.LoadFrom(cFile)
chk("the regime still judges after the round trip",
	oBack.MayProceed("billing-agent", "send-invoice") = 1)
chk("...and the lineage came with it", oBack.NumberOfDecisions() = 1)
aR = oBack.LineageOf("d-201")
chk("the moment survived the file", aR[:at] = $T0)
chk("the action survived", aR[:action] = "send-invoice")
chk("a rationale containing the field separator is INTACT",
	aR[:rationale] = "raised the tier after the audit | see ticket 4471")
? "  " + aR[:rationale]

? ""
? "-- Scene 6: the file records what WAS true, not what is --"
oBack.DeclareRisk("send-invoice", 1)
chk("the regime changed", oBack.RiskOf("send-invoice") = 1)
chk("...and the decision still reports the tier it was taken under",
	oBack.LineageOf("d-201")[:riskAtTime] = 3)
# Recomputing authority and risk on load would let a changed regime
# rewrite its own history -- the one thing a lineage exists to prevent.

? ""
? "-- Scene 7: an unknown section skips its own rows --"
cRaw = read(cFile)
write(cFile, cRaw + "quorums" + nl + "    council | 3" + nl)
oFwd = new stzGovernance("")
oFwd.LoadFrom(cFile)
chk("a section this build does not know is stepped over",
	oFwd.NumberOfDecisions() = 1 and oFwd.PostureOf("py-runner") = "sandboxed")
# The old loader listed its four section names, so an unrecognised
# header left the PREVIOUS section active and fed it foreign rows --
# and DeclarePosture raises on a value it does not know. A newer file
# took an older build down.
remove(cFile)

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk cLabel, bCond
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
