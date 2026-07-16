# R6 DEEPENING -- refine/: EXECUTION TRUST POSTURES + REVERSIBILITY AS A
# DATA-MODEL PRIMITIVE (SOFTANZA_INTELLIGENCE_ARCHITECTURE.md 5.8).
#
# The floor gave a 4-stage gate + single-step revert. This deepens both:
#   TRUST POSTURES  -- every refinement carries a posture (where it came from:
#     trusted in-process / external / sandboxed / llm-composed); a point can
#     set a TRUST FLOOR that refuses lower-trust origins, and the posture
#     lands in the audit chain -- origin is governed, not just identity.
#   REVERSIBILITY   -- a full undo/redo TIMELINE with named checkpoints:
#     RevertTo(step) / RevertToCheckpoint(name) / Redo(), atomic, typed.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

cSrc = 'vat_rate = ' + Char(60) + 'R:PARAM name="vat" value="0.20" min="0" max="0.30"' + Char(62) + nl +
       'engine   = ' + Char(60) + 'R:ALGO name="sort" value="quick" options="quick|merge|heap"' + Char(62)

#== Scene 1 -- reversibility as a data-model primitive ===================

? "-- Scene 1: the refinement TIMELINE (rewind / redo / checkpoints) --"
o = new stzRefinableCode(cSrc)
o.Refine("vat").To("0.21")
o.Refine("vat").To("0.22")
o.Refine("vat").To("0.23")
chk("three refinements build a 3-step timeline", o.NumberOfSteps() = 3)
chk("the source carries the latest value", o.ValueOf("vat") = "0.23")

o.Checkpoint("reviewed")
o.Refine("vat").To("0.28")
chk("a checkpoint marks the timeline; work continues past it", o.ValueOf("vat") = "0.28")

o.RevertToCheckpoint("reviewed")
chk("RevertToCheckpoint rewinds to the marked state", o.ValueOf("vat") = "0.23")
chk("... atomically (back to 3 steps)", o.NumberOfSteps() = 3)
chk("and the rewound step is redoable", o.CanRedo() = TRUE)

o.RevertTo(1)
chk("RevertTo(1) rewinds multiple steps atomically", o.ValueOf("vat") = "0.21")
chk("the timeline is now 1 step", o.NumberOfSteps() = 1)

o.Redo()
chk("Redo re-applies the last reverted step", o.ValueOf("vat") = "0.22")
chk("... growing the timeline back", o.NumberOfSteps() = 2)

o.Refine("vat").To("0.25")
chk("a fresh admit FORKS the timeline -- redo is cleared", o.CanRedo() = FALSE)

o.RevertTo(0)
chk("RevertTo(0) restores the original value", o.ValueOf("vat") = "0.20")

#== Scene 2 -- execution trust postures =================================

? ""
? "-- Scene 2: trust postures (origin is governed) --"
p = new stzRefinableCode(cSrc)

r = p.Refine("vat").To("0.21")
chk("a proposal defaults to the :trusted posture",
	r[:admitted] = 1 and p.PostureOf(p.NumberOfSteps()) = "trusted")

rl = p.Refine("vat").As(:llm).To("0.22")
chk("an :llm-composed proposal is admitted when no floor is set", rl[:admitted] = 1)
chk("... and its posture is recorded in the timeline",
	p.PostureOf(p.NumberOfSteps()) = "llm")

p.TrustFloor("vat", :trusted)
rl2 = p.Refine("vat").As(:llm).To("0.24")
chk("with a :trusted floor, an :llm edit is REFUSED", rl2[:admitted] = 0)
chk("the why names the trust posture, not identity",
	StzFindFirst(rl2[:why], "trust: posture :llm") > 0)
chk("the refused proposal did NOT mutate the source", p.ValueOf("vat") != "0.24")

rt = p.Refine("vat").As(:trusted).To("0.24")
chk("a :trusted edit to the same floored point IS admitted", rt[:admitted] = 1)

p.TrustFloor("vat", :sandboxed)
chk(":external clears a :sandboxed floor (higher trust)",
	p.Refine("vat").As(:external).To("0.26")[:admitted] = 1)
chk(":llm still fails the :sandboxed floor (lowest trust)",
	p.Refine("vat").As(:llm).To("0.27")[:admitted] = 0)

#== Scene 3 -- trust posture UNDER governance (both gates apply) =========

? ""
? "-- Scene 3: trust + governance are INDEPENDENT gates --"
g = new stzRefinableCode(cSrc)
g.SetGovernedBy(new stzGovernance("menu")).SetActor("owner")
g.SetRiskFor("vat", 1).SetAllowRefine("vat").SetAuthorityLevel(:Delegated)
g.TrustFloor("vat", :trusted)
chk("a governed + trusted edit passes BOTH gates",
	g.Refine("vat").As(:trusted).To("0.22")[:admitted] = 1)
chk("a governed but :llm edit is refused by the TRUST gate (governance would allow)",
	g.Refine("vat").As(:llm).To("0.23")[:admitted] = 0)
chk("the audit lineage recorded the admitted refinement",
	g.GovernanceQ().NumberOfDecisions() >= 1)

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
