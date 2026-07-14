# R4b ACCEPTANCE -- governance/: the five primitives + CAN vs SHOULD
# (5.7 G6 + 5.8 trust postures). Mechanism only -- no constitution.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

oGov = new stzGovernance("kitchen-ops")

? "-- Scene 1: CAN is not SHOULD (the structural split) --"
oGov.DeclareRisk("send-invoice", 3)
oGov.GrantPermission("billing-agent", "send-invoice")
oGov.SetAuthority("billing-agent", :Delegated)
chk("permission WITHOUT adequate authority refuses",
	oGov.MayProceed("billing-agent", "send-invoice") = 0)
? "  why: " + oGov.Why()
oGov.SetAuthority("billing-agent", :Autonomous)
chk("adequate authority + permission proceeds",
	oGov.MayProceed("billing-agent", "send-invoice") = 1)
oGov.DeclareRisk("wipe-database", 4)
oGov.SetAuthority("cleaner", :Autonomous)
chk("authority WITHOUT permission refuses",
	oGov.MayProceed("cleaner", "wipe-database") = 0)
chk("an UNDECLARED action never proceeds",
	oGov.MayProceed("billing-agent", "mystery-action") = 0)

? ""
? "-- Scene 2: risk tiers gate by level --"
oGov.GrantPermission("ops-agent", "wipe-database")
oGov.SetAuthority("ops-agent", :Autonomous)
chk("tier 4 refuses autonomous (level 3)",
	oGov.MayProceed("ops-agent", "wipe-database") = 0)
oGov.SetAuthority("ops-agent", :EmergencyOverride)
chk("tier 4 yields only to emergency override",
	oGov.MayProceed("ops-agent", "wipe-database") = 1)

? ""
? "-- Scene 3: commitment is FORWARD-ONLY --"
oGov.OpenCommitment("menu-redesign")
chk("opens exploratory", oGov.CommitmentStateOf("menu-redesign") = "exploratory")
oGov.AdvanceCommitment("menu-redesign")
oGov.AdvanceCommitment("menu-redesign")
chk("advances to committed", oGov.CommitmentStateOf("menu-redesign") = "committed")
bReg = 0
try
	oGov.AdvanceCommitment("menu-redesign")
catch
	bReg = 1
done
chk("no silent regression past committed", bReg = 1)

? ""
? "-- Scene 4: retirement is EARNED (decommission contract) --"
oGov.DeclareDecommission("old-agent",
	[ "credential-revocation", "data-removal", "audit-preservation" ])
chk("retire refuses while obligations pend", oGov.MayRetire("old-agent") = 0)
? "  why: " + oGov.Why()
oGov.FulfillObligation("old-agent", "credential-revocation")
oGov.FulfillObligation("old-agent", "data-removal")
oGov.FulfillObligation("old-agent", "audit-preservation")
chk("all obligations fulfilled -> may retire", oGov.MayRetire("old-agent") = 1)
chk("retiring WITHOUT a contract refuses", oGov.MayRetire("ghost-agent") = 0)

? ""
? "-- Scene 5: decision lineage answers forever --"
oGov.RecordDecision("d-101", "peak-season pricing adjustment",
	"billing-agent", "send-invoice")
aL = oGov.LineageOf("d-101")
chk("the decision carries its rationale", aL[:rationale] = "peak-season pricing adjustment")
chk("...and the authority AT THE TIME", aL[:authorityAtTime] = "autonomous")
chk("...and the risk at the time", aL[:riskAtTime] = 3)

? ""
? "-- Scene 6: execution trust postures (5.8) --"
chk("execution without a posture refuses", oGov.MayExecute("py-runner") = 0)
oGov.DeclarePosture("py-runner", :Sandboxed)
chk("a declared posture proceeds and names itself",
	oGov.MayExecute("py-runner") = 1 and len(StzFind("sandboxed", oGov.Why())) > 0)

? ""
? "-- Scene 7: the regime persists (*.zgov) --"
cF = oGov.Save("t_gov_accept")
oG2 = StzLoadGovernance(cF)
chk("the reloaded regime still judges",
	oG2.MayProceed("billing-agent", "send-invoice") = 1 and
	oG2.MayProceed("cleaner", "wipe-database") = 0)
chk("postures travel", oG2.PostureOf("py-runner") = "sandboxed")
remove(cF)

? ""
? "=========================================="
? "TOTAL: " + (nPass + nFail) + " assertions, " + nPass + " pass, " + nFail + " fail"
? "=========================================="

pf()

func chk(cLabel, bCond)
	if bCond
		nPass++
		? "  [OK] " + cLabel
	else
		nFail++
		? "  [FAIL] " + cLabel
	ok
