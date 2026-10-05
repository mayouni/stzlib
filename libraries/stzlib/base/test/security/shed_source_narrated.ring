load "../../stzBase.ring"
load "../_narrated.ring"

# SECURITY-SHED-01 -- threat-model risk R10: :ShedSource, for real.
#
# stzRateLimiter could SLOW a key and could not STOP one -- and a key with no
# configured limit is unlimited, which is exactly the flood a responder must
# stop. A blocked key is now refused whether or not it has a limit, every
# refusal carries the block's reason, a timed block lifts by itself, and
# stzRateLimiterResponder performs :ShedSource with it.

$oHuman = HumanActor("oncall")

Scenario("a flooding source is shed by a governed plan")
	oRL = StzRateLimiter("front")
	Then("an unconfigured source is unlimited before", oRL.Allow("10.0.0.9"), 1)
	oPlan = StzResponsePlan("shed-flood")
	oPlan.Propose(:ShedSource, "10.0.0.9", "4,000 requests in ten seconds")
	nDone = oPlan.ExecuteOn(StzRateLimiterResponder(oRL, 0), $oHuman)
	Then("the action was committed", nDone, 1)
	Then("the source is blocked", oRL.IsBlocked("10.0.0.9"), 1)
	Then("its requests are refused", oRL.Allow("10.0.0.9"), 0)
	Then("...every time", oRL.Allow("10.0.0.9"), 0)
	Then("the refusals are counted", oRL.BlockOf("10.0.0.9")[:refused], 2)
	Then("the block says why", oRL.BlockOf("10.0.0.9")[:reason], "shed by a containment plan")
	Then("another source is unaffected", oRL.Allow("10.0.0.10"), 1)
	oRL.Unblock("10.0.0.9")
	Then("released, the source is admitted again (negative sibling)", oRL.Allow("10.0.0.9"), 1)
EndScenario()

Scenario("a block applies over a configured limit too")
	oRL = StzRateLimiter("api")
	oRL.SetLimit("partner-x", 100, 20)
	Then("the key has tokens", oRL.Allow("partner-x"), 1)
	oRL.Block("partner-x", "leaked API key in use")
	Then("blocked, it is refused although tokens remain", oRL.Allow("partner-x"), 0)
EndScenario()

Scenario("a timed block lifts by itself")
	oRL = StzRateLimiter("front")
	StzRateLimiterResponder(oRL, 300).ShedSource("10.0.0.7")
	Then("blocked now", oRL.Allow("10.0.0.7"), 0)
	StzEngineTimeSleepMs(450)
	Then("admitted once the block has run out", oRL.Allow("10.0.0.7"), 1)
	Then("and no longer listed", len(oRL.BlockedKeys()), 0)
EndScenario()

Scenario("an LLM can propose shedding and cannot commit it")
	oRL = StzRateLimiter("front")
	oPlan = StzResponsePlan("llm")
	oPlan.Propose(:ShedSource, "10.0.0.9", "the model saw a spike")
	Then("nothing committed", oPlan.ExecuteOn(StzRateLimiterResponder(oRL, 0), LLMActor("assistant")), 0)
	Then("the source is not blocked", oRL.Allow("10.0.0.9"), 1)
EndScenario()

Summary()
