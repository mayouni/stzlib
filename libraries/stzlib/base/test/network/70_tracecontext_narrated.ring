load "../../stzBase.ring"
load "../_narrated.ring"

# Gap-analysis Tier 2: W3C Trace Context propagation.
#
# stzTraceContext (engine/src/tracectx.zig) generates / derives / parses
# `traceparent` headers so a request can be correlated across services
# and agentic steps. Pure -- no network. stzHttpClient.StartTrace()
# injects a fresh header into a request.

Scenario("A fresh trace context is valid and sampled")
    Given("a new trace context")
    oT = StzTraceContext()
    Then("the header is valid", oT.IsValid(), TRUE)
    Then("it is sampled by default", oT.IsSampled(), TRUE)
    Then("the trace-id is 32 hex chars", len(oT.TraceId()), 32)
    Then("the span-id is 16 hex chars", len(oT.SpanId()), 16)
    Then("the traceparent is 55 chars", len(oT.TraceParent()), 55)
EndScenario()

Scenario("A child header keeps the trace-id but gets a new span-id")
    Given("a parent context and its child header")
    oParent = StzTraceContext()
    oChild = StzTraceContextFrom(oParent.ChildHeader())
    Then("the child header is valid", oChild.IsValid(), TRUE)
    Then("the child shares the parent trace-id",
        oChild.TraceId(), oParent.TraceId())
    Then("the child has a different span-id",
        oChild.SpanId() = oParent.SpanId(), FALSE)
EndScenario()

Scenario("A malformed header is rejected")
    Given("a garbage traceparent")
    oBad = StzTraceContextFrom("not-a-valid-traceparent")
    Then("IsValid is FALSE", oBad.IsValid(), FALSE)
EndScenario()

Scenario("The HTTP client can start a trace")
    Given("an HTTP client")
    o = new stzHttpClient()
    When("starting a trace")
    cTP = o.StartTrace()
    Then("a valid traceparent was generated + attached",
        StzEngineTraceIsValid(cTP), 1)
EndScenario()

Summary()
