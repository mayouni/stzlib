load "../../stzBase.ring"
load "../_narrated.ring"

# Section is the CONSERVATIVE form: it auto-orders but RAISES on out-of-range
# indexes (per the original). SectionXT is the lenient form (negatives count from
# the end, out-of-range is clamped). Archive block #70.

Scenario("Section raises out-of-range; SectionXT is lenient")
	Given('"SOFTANZA"')
	o1 = new stzString("SOFTANZA")
	bRaised = FALSE
	try
		r = o1.Section(-99, 99)
	catch
		bRaised = TRUE
	done
	Then("Section(-99, 99) raises", bRaised, TRUE)
	Then("SectionXT(-99, 99) clamps to the whole string", o1.SectionXT(-99, 99), "SOFTANZA")
	Then("Slice is the strict alias of Section", o1.Slice(2, 4), "OFT")
	Then("SliceXT is the lenient alias of SectionXT", o1.SliceXT(-3, -1), "NZA")
EndScenario()

Summary()
