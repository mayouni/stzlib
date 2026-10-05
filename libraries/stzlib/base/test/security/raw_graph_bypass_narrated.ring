load "../../stzBase.ring"
load "../_narrated.ring"

# SECURITY-RAW-GRAPH-01 -- threat-model risk R1: a property set around a
# governed door can no longer change a decision, or go unseen.
#
# stzAgentGraph and stzSecurityGraph hand out their raw graph (GraphQ()), and
# their gates read properties stored ON it. So a raw edit walked around them:
# flip an llm actor's KIND and Grant() gives it 'effectful' -- and the
# no-llm-effectful audit, which also asks the kind, stops looking; flip a
# sandboxed actor's POSTURE and AttachSecret() hands it a live secret -- and
# the escalation audit, which also asks the posture, stops looking.
#
# The properties a gate decides on are now also SEALED by the governed doors,
# out of GraphQ()'s reach: the gates read the seal, and Tampering() -- part of
# Violations(), CheckRules() and IsSound() -- names every node whose graph
# property no longer matches it.

# =====================================================================
#  THE BYPASSES (these run against the old code too)
# =====================================================================

Scenario("flipping an LLM's kind no longer opens the effectful gate")
	oAG = new stzAgentGraph("mailer")
	oAG.AddLLMActor("writer")
	oAG.GraphQ().SetNodeProperty("writer", "kind", "pi_actor")
	# before: MayGrant answered 1 and Grant succeeded -- an LLM with effects
	Then("MayGrant still refuses 'effectful'", oAG.MayGrant("writer", "effectful"), 0)
	bRaised = 0
	try  oAG.Grant("writer", "effectful")  catch  bRaised = 1  done
	Then("Grant still refuses it", bRaised, 1)
	Then("the graph is not called sound", oAG.IsSound(), 0)
EndScenario()

Scenario("flipping a sandboxed actor's posture no longer hands it a secret")
	g = StzSecurityGraphQ("prod")
	g.AddActor("sandbot", "sandboxed")
	g.AddSecret("stripe-live")
	g.GraphQ().SetNodeProperty("sandbot", "posture", "trusted")
	# before: MayAttach answered 1 and the secret was attached
	Then("MayAttach still refuses", g.MayAttach("sandbot", "stripe-live"), 0)
	bRaised = 0
	try  g.AttachSecret("sandbot", "stripe-live")  catch  bRaised = 1  done
	Then("AttachSecret still refuses", bRaised, 1)
	g.AddCapability("effectful")
	g.Holds("sandbot", "effectful")
	# before: the escalation audit asked the (flipped) posture and saw nothing
	Then("the escalation audit still sees the sandboxed actor reach effectful",
		len(g.AuditEscalations()), 1)
EndScenario()

# =====================================================================
#  TAMPERING IS REPORTED
# =====================================================================

Scenario("every raw edit to a sealed property is named")
	oAG = new stzAgentGraph("mailer")
	oAG.AddLLMActor("writer")
	oAG.GraphQ().SetNodeProperty("writer", "kind", "pi_actor")
	aT = oAG.Tampering()
	Then("the kind flip is reported", len(aT), 1)
	Then("...naming the node, what, and both values", aT[1][1] + "/" + aT[1][2] + "/" + aT[1][3] + "/" + aT[1][4],
		"writer/kind/llm_actor/pi_actor")
	Then("it joins Violations()", HasFinding(oAG.Violations(), :invariant, "governed-property-tampered"), 1)
	Then("and CheckRules()", HasFinding(oAG.CheckRules(), :rule, "governed-property-tampered"), 1)

	oAG2 = new stzAgentGraph("x")
	oAG2.AddPIActor("committer")
	oAG2.GraphQ().SetNodeProperty("committer", "capabilities", [ "effectful", "compute", "sensing", "inference" ])
	Then("a capability no door granted is reported too", len(oAG2.Tampering()), 1)

	g = StzSecurityGraphQ("prod")
	g.AddActor("sandbot", "sandboxed")
	g.GraphQ().SetNodeProperty("sandbot", "posture", "trusted")
	Then("a posture flip is reported", len(g.Tampering()), 1)
	Then("it joins the security graph's Violations()", HasFinding(g.Violations(), :rule, "governed-property-tampered"), 1)
	Then("and the graph is not called sound", g.IsSound(), 0)
EndScenario()

Scenario("changes made through the governed doors are not tampering (negative sibling)")
	oAG = new stzAgentGraph("mailer")
	oAG.AddPIActor("committer")
	oAG.AddLLMActor("writer")
	oAG.Grant("writer", "sensing")
	Then("a granted capability is not flagged", len(oAG.Tampering()), 0)
	g = StzSecurityGraphQ("prod")
	g.AddActor("bot", "sandboxed")
	g.AddActor("bot", "trusted")
	Then("a posture changed through AddActor is not flagged", len(g.Tampering()), 0)
	Then("and the gate follows the governed change", g.MayAttach("bot", "x"), 1)
EndScenario()

Summary()

func HasFinding aF, cKey, cName
	for i = 1 to len(aF)
		if aF[i][cKey] = cName  return 1  ok
	next
	return 0
