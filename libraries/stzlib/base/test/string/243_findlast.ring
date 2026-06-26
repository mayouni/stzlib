load "../../stzBase.ring"
load "../_narrated.ring"

# Perf helpers PerfGain100(old, new) and SpeedUpX(old, new). Archive block #243
# also timed FindLast(";") on the ~1.9M-char UnicodeData() (empty in this checkout,
# so that line is deferred to the 07_managing_a_big_text perf guard).

Scenario("Performance-gain helpers")
	# Compare the 2-decimal display form (exact float-eq is flaky).
	Then("PerfGain100(12.99, 2.45) is 81.14%", @@( PerfGain100(12.99, 2.45) ), "81.14")
	Then("SpeedUpX(12.99, 2.45) is 5.3X", @@( SpeedUpX(12.99, 2.45) ), "5.30")
EndScenario()

Summary()
