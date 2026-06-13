load "../../stzBase.ring"
load "../_narrated.ring"

# Gap-analysis Tier 1 item 6: latency histograms (p50 / p95 / p99).
#
# stzLatencyHistogram wraps the engine log-bucket histogram
# (stz_histogram.dll). The HTTP path also records every request's
# latency into a built-in histogram, queryable via
# StzEngineHttpLatencyPercentile/Count/Reset. The percentile scenarios
# are network-free; the last scenario makes one real GET.

Scenario("Percentiles from a known uniform distribution")
    Given("a histogram with 1000 samples of 1..1000 ms")
    oH = new stzLatencyHistogram
    for i = 1 to 1000
        oH.Record(i)
    next
    Then("count is exactly 1000", oH.Count(), 1000)
    Then("p50 lands in the 500 ms bucket", oH.P50(), 500)
    Then("p99 lands in the 1000 ms bucket", oH.P99(), 1000)
    Then("p1 lands in the 10 ms bucket", oH.Percentile(1), 10)
    oH.Destroy()
EndScenario()

Scenario("Reset clears the histogram")
    Given("a histogram with a few samples")
    oH2 = new stzLatencyHistogram
    oH2.Record(5)
    oH2.Record(50)
    oH2.Record(500)
    Then("count reflects the three samples", oH2.Count(), 3)
    When("the histogram is reset")
    oH2.Reset()
    Then("count is back to 0", oH2.Count(), 0)
    Then("percentile of an empty histogram is 0", oH2.P50(), 0)
    oH2.Destroy()
EndScenario()

Scenario("The HTTP path records request latency")
    Given("a cleared HTTP latency histogram")
    StzEngineHttpLatencyReset()
    When("a real GET is performed")
    oC = new stzHttpClient()
    oC.Get_("http://example.com/")
    Then("the request succeeded (200)", oC.ResponseCode(), 200)
    Then("at least one latency sample was recorded",
        StzEngineHttpLatencyCount() >= 1, TRUE)
    Then("p50 is a positive bucket bound",
        StzEngineHttpLatencyPercentile(50) > 0, TRUE)
EndScenario()

Summary()
