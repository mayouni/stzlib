load "../../stzBase.ring"
load "../_narrated.ring"

# stzPaymentsPort -- phase 4 of the service-virtualization plane, and the plan calls
# it "the demo that makes the whole idea legible". Payments is what people picture
# when they hear service virtualization, because the cost of getting it wrong is
# money and nobody wants a test suite that charges real cards.
#
# A payments port is "any object with Authorize(amount, token) / Capture(id) /
# Refund(id)".
#
# WHAT MAKES THIS MORE THAN A STUB is the point of the whole file. A stub that
# answers "approved" to everything lets broken code pass. This sandbox enforces the
# STATE MACHINE a real gateway enforces:
#
#     Authorize -> :authorized or :declined
#     Capture   -> only an :authorized one, and only ONCE
#     Refund    -> only what was CAPTURED, never more than was captured
#
# so code that double-captures, captures a decline or over-refunds fails HERE
# rather than in production. Most payment bugs are state-machine bugs, not
# connectivity bugs -- and a permissive fake hides exactly the class of defect you
# most need to find.
#
# Money is an INTEGER IN MINOR UNITS throughout (4200, not 42.00): floating-point
# money is a rounding defect waiting for its boundary, and a sandbox that accepted
# floats would teach the wrong habit.

Scenario("the happy path, and an assertable ledger")
	oPay = new stzPaymentsSandbox()
	oPay.ApproveUnderQ(10000)

	aA = oPay.Authorize(4200, "tok_visa")
	Then("it is authorized", aA[:ok], TRUE)
	Then("...with a deterministic id (no randomness in a sandbox)", aA[:id], "auth_1")
	Then("...and a status", aA[:status], :authorized)

	aC = oPay.Capture(aA[:id])
	Then("capture succeeds", aC[:ok], TRUE)
	Then("...for the full authorized amount", aC[:amount], 4200)
	Then("...and the authorization now reads captured", oPay.StatusOf(aA[:id]), :captured)

	aR = oPay.RefundAmount(aA[:id], 1000)
	Then("a PARTIAL refund is allowed", aR[:ok], TRUE)
	Then("...and tracked per authorization", oPay.RefundedOf(aA[:id]), 1000)

	Then("the ledger totals what was captured", oPay.TotalCaptured(), 4200)
	Then("...what was refunded", oPay.TotalRefunded(), 1000)
	Then("...and what the merchant actually keeps", oPay.NetCaptured(), 3200)
	# a test asserts on what happened to the MONEY, not on a return value.
EndScenario()

Scenario("the state machine refuses exactly what a real gateway refuses")
	oPay = new stzPaymentsSandbox()
	aA = oPay.Authorize(4200, "tok_visa")
	oPay.Capture(aA[:id])

	When("the same authorization is captured a second time")
	aTwice = oPay.Capture(aA[:id])
	Then("it is refused", aTwice[:ok], FALSE)
	Then("...saying why", StzFindFirst("already captured", aTwice[:why]) > 0, TRUE)
	# double-capture is one of the commonest real payment bugs, and a permissive
	# fake would have let it through.

	When("a DECLINED authorization is captured")
	oPay.DeclineTokenQ("tok_chargeback")
	aD = oPay.Authorize(4200, "tok_chargeback")
	Then("the authorization itself declined", aD[:status], :declined)
	Then("...for a stated reason", StzFindFirst("token was declined", aD[:why]) > 0, TRUE)
	Then("capturing it is refused", oPay.Capture(aD[:id])[:ok], FALSE)
	Then("...explicitly", StzFindFirst("DECLINED", oPay.Capture(aD[:id])[:why]) > 0, TRUE)

	When("more is refunded than was captured")
	Then("it is refused", oPay.RefundAmount(aA[:id], 99999)[:ok], FALSE)
	Then("...saying why", StzFindFirst("may not exceed what was captured",
	     oPay.RefundAmount(aA[:id], 99999)[:why]) > 0, TRUE)

	When("an UNCAPTURED authorization is refunded")
	aU = oPay.Authorize(500, "tok_visa")
	Then("there is nothing to refund", StzFindFirst("nothing to refund", oPay.Refund(aU[:id])[:why]) > 0, TRUE)

	When("more is captured than was authorized")
	Then("it is refused", StzFindFirst("may not exceed the amount authorized",
	     oPay.CaptureAmount(aU[:id], 9999)[:why]) > 0, TRUE)

	When("an id that does not exist is used")
	Then("it is refused rather than invented", oPay.Capture("auth_999")[:why], "unknown authorization")
EndScenario()

Scenario("rules you write, so the FAILURE paths are testable at all")
	oPay = new stzPaymentsSandbox()

	When("an approval ceiling is set")
	oPay.ApproveUnderQ(10000)
	Then("below it approves", oPay.Authorize(9999, "tok_visa")[:ok], TRUE)
	Then("at or above it declines", oPay.Authorize(10000, "tok_visa")[:ok], FALSE)

	When("a decline ceiling is set instead")
	oBig = new stzPaymentsSandbox()
	oBig.DeclineOverQ(50000)
	Then("under it approves", oBig.Authorize(49999, "tok_visa")[:ok], TRUE)
	Then("over it declines", oBig.Authorize(50000, "tok_visa")[:ok], FALSE)

	When('a "test card" is nominated')
	oBig.DeclineTokenQ("tok_bad")
	Then("that token always declines", oBig.Authorize(100, "tok_bad")[:ok], FALSE)
	Then("...while others still approve", oBig.Authorize(100, "tok_good")[:ok], TRUE)
	# no real gateway will decline on demand for you -- which is why the decline
	# branch of most payment code is the least tested part of it.
EndScenario()

Scenario("an OUTAGE is not a decline, and the difference matters")
	oPay = new stzPaymentsSandbox()
	oPay.FailNextQ()

	aO = oPay.Authorize(100, "tok_visa")
	Then("the call fails", aO[:ok], FALSE)
	Then("...as REFUSED, not declined", aO[:status], :refused)
	Then("...because the gateway was unreachable", StzFindFirst("unreachable", aO[:why]) > 0, TRUE)
	# a decline is an ANSWER (do not retry, tell the customer); an outage is not an
	# answer (retry, do not tell the customer their card failed). Code that
	# conflates them either double-charges or loses sales.

	Then("it is a ONE-SHOT failure, so the next call works", oPay.Authorize(100, "tok_visa")[:ok], TRUE)
	Then("...and no phantom authorization was recorded for the outage",
	     oPay.NumberOfAuthorizations(), 1)
EndScenario()

Scenario("money is an integer in minor units")
	oPay = new stzPaymentsSandbox()
	Then("4200 means 42.00 and is fine", oPay.Authorize(4200, "tok_visa")[:ok], TRUE)
	Then("a FLOAT is refused", oPay.Authorize(42.5, "tok_visa")[:ok], FALSE)
	Then("...for a stated reason", StzFindFirst("whole number", oPay.Authorize(42.5, "tok_visa")[:why]) > 0, TRUE)
	Then("a negative amount is refused", oPay.Authorize(-100, "tok_visa")[:ok], FALSE)
	Then("zero is refused", oPay.Authorize(0, "tok_visa")[:ok], FALSE)
	# floating-point money is a rounding defect waiting for its boundary; a sandbox
	# that accepted floats would teach the wrong habit.
EndScenario()

Scenario("the movement journal records what happened, in order")
	oPay = new stzPaymentsSandbox()
	oPay.DeclineTokenQ("tok_bad")
	aA = oPay.Authorize(4200, "tok_visa")
	oPay.Capture(aA[:id])
	oPay.RefundAmount(aA[:id], 200)
	oPay.Authorize(100, "tok_bad")

	aM = oPay.Movements()
	Then("every movement is recorded", len(aM), 4)
	Then("...in order: authorize", aM[1][:kind], "authorize")
	Then("...then capture", aM[2][:kind], "capture")
	Then("...then refund", aM[3][:kind], "refund")
	Then("...then the decline", aM[4][:kind], "decline")
	Then("with amounts", aM[3][:amount], 200)
	Then("declines are countable", oPay.NumberOfDeclines(), 1)
EndScenario()

Scenario("through the registry, and refused in production")
	oPay = new stzPaymentsSandbox()
	oReg = new stzServiceRegistry("shop")
	oReg.Bind(:payments, oPay)
	Then("the registry recognises the double", oReg.PostureOf(:payments), :sandbox)

	When("the application charges through the service the registry hands back")
	oReg.Service(:payments).Authorize(700, "tok_visa")
	Then("the ORIGINAL gateway recorded it -- state survived Ring's copy",
	     oPay.NumberOfAuthorizations(), 1)

	When("the phase becomes production with the fake gateway still bound")
	oReg.SetPhaseQ(:production)
	Then("it is refused", oReg.IsSound(), FALSE)
	Then("...naming payments", oReg.Findings()[1][:where], "shop/payments")
	# the live side is a Stripe/PayPal/Adyen client behind the same three methods,
	# deliberately NOT shipped here: it needs an account, a key and a network. The
	# contract is defined; the registry makes sure the fake cannot ship in its place.
EndScenario()

Summary()
