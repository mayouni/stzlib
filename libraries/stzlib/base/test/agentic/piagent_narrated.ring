# R5 ACCEPTANCE -- agentic/: the PI-agent, ASSEMBLED not invented
# (SOFTANZA_INTELLIGENCE_ARCHITECTURE.md 5.6 rung 3 + agentic/ map).
# The Uter ladder embodied: skills (precondition+plan+verification)
# fire over knowledge-graph memory, GOVERNED by R4b before every act,
# cascading to fixpoint. Deterministic, zero-cost, offline.

load "../../stzBase.ring"

nPass = 0
nFail = 0

pr()

? "-- Scene 1: a skill = precondition + plan + verification --"
oMem = new stzAgentMemory("solo")
oMem.Learn("stock", "level", "low")
oSk = new stzAgentSkill("restock")
oSk.SetWhen(func oM { return oM.Fact("stock", "level", "low") })
oSk.SetDoes(func oM {
	oM.Forget("stock", "level", "low")
	oM.Learn("stock", "level", "ordered")
	return 1
})
oSk.SetVerifiedBy(func oM { return oM.Fact("stock", "level", "ordered") })
chk("precondition gates the skill", oSk.PreconditionHolds(oMem) = 1)
aR = oSk.Apply(oMem)
chk("the skill ran AND verified", aR[:ran] = 1 and aR[:verified] = 1)
chk("re-applying is a no-op (precondition no longer holds)",
	oSk.Apply(oMem)[:ran] = 0)

? ""
? "-- Scene 2: memory IS a knowledge graph (LAW 5) --"
oMem2 = new stzAgentMemory("waiter")
oMem2.Learn("table-4", "wants", "water")
chk("Learn/Fact round-trip", oMem2.Fact("table-4", "wants", "water") = 1)
chk("Recall returns the objects", oMem2.Recall("table-4", "wants")[1] = "water")

? ""
? "-- Scene 3: the governed cycle -- gate BEFORE act --"
oAg = new stzPIAgent("kitchen-bot")
oAg.MemoryQ().Learn("stock", "level", "low")
oAg.GovernanceQ().DeclareRisk("order-stock", 2)
oAg.GovernanceQ().GrantPermission("kitchen-bot", "order-stock")
oAg.GovernanceQ().SetAuthority("kitchen-bot", :Delegated)
oGSk = new stzAgentSkill("restock")
oGSk.SetWhen(func oM { return oM.Fact("stock", "level", "low") })
oGSk.SetDoes(func oM {
	oM.Forget("stock", "level", "low")
	oM.Learn("stock", "level", "ordered")
	return 1
})
oGSk.SetVerifiedBy(func oM { return oM.Fact("stock", "level", "ordered") })
oAg.AddGovernedSkill(oGSk, "order-stock")
n = oAg.Pursue()
chk("the authorized agent acts and verifies", n = 1)
chk("...changing its world", oAg.MemoryQ().Fact("stock", "level", "ordered") = 1)
chk("Pursue narrates the rounds", len(StzFind("round", oAg.Why())) > 0)
chk("the governed act left an audit witness", len(oAg.DecisionLog()) = 1)

? ""
? "-- Scene 4: governance REFUSES at the gate (no permission) --"
oRog = new stzPIAgent("rogue-bot")
oRog.MemoryQ().Learn("stock", "level", "low")
oRog.GovernanceQ().DeclareRisk("order-stock", 2)
# NO permission granted
oRSk = new stzAgentSkill("restock")
oRSk.SetWhen(func oM { return oM.Fact("stock", "level", "low") })
oRSk.SetDoes(func oM { oM.Learn("stock", "level", "ordered")  return 1 })
oRog.AddGovernedSkill(oRSk, "order-stock")
nR = oRog.Pursue()
chk("the ungoverned-for-this agent NEVER acts", nR = 0)
chk("...its world is unchanged", oRog.MemoryQ().Fact("stock", "level", "ordered") = 0)
chk("...and the refusal is logged with a reason",
	oRog.DecisionLog()[1][:decision] = "refused" and
	len(StzFindCS("permission", oRog.DecisionLog()[1][:why], 0)) > 0)

? ""
? "-- Scene 5: the cascade to fixpoint (Softanzuter at agent level) --"
oChain = new stzPIAgent("cook")
oChain.MemoryQ().Learn("order", "state", "placed")
# three skills chain: placed -> cooking -> plated -> served
s1 = new stzAgentSkill("cook")
s1.SetWhen(func oM { return oM.Fact("order", "state", "placed") })
s1.SetDoes(func oM { oM.Forget("order","state","placed") oM.Learn("order","state","cooking") return 1 })
s1.SetVerifiedBy(func oM { return oM.Fact("order","state","cooking") })
s2 = new stzAgentSkill("plate")
s2.SetWhen(func oM { return oM.Fact("order", "state", "cooking") })
s2.SetDoes(func oM { oM.Forget("order","state","cooking") oM.Learn("order","state","plated") return 1 })
s2.SetVerifiedBy(func oM { return oM.Fact("order","state","plated") })
s3 = new stzAgentSkill("serve")
s3.SetWhen(func oM { return oM.Fact("order", "state", "plated") })
s3.SetDoes(func oM { oM.Forget("order","state","plated") oM.Learn("order","state","served") return 1 })
s3.SetVerifiedBy(func oM { return oM.Fact("order","state","served") })
oChain.AddSkill(s1)
oChain.AddSkill(s2)
oChain.AddSkill(s3)
nC = oChain.Pursue()
chk("all three skills fire in the cascade", nC = 3)
chk("the order reaches its final state", oChain.MemoryQ().Fact("order","state","served") = 1)

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
