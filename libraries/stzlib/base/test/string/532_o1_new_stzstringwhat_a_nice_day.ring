load "../../stzBase.ring"
load "../_narrated.ring"

# Section is STRICT: out-of-range indexes RAISE "Indexes out of range!"
# (the lenient form is SectionXT). Archive block #532.

Scenario("Out-of-range sections raise")
	o1 = new stzString("what a <<nice>>> day!")
	bRaised1 = FALSE
	try
		o1.Section(50, 0)
	catch
		bRaised1 = TRUE
	done
	Then("Section(50, 0) raises", bRaised1, TRUE)
	bRaised2 = FALSE
	try
		o1.Section(0, 0)
	catch
		bRaised2 = TRUE
	done
	Then("Section(0, 0) raises", bRaised2, TRUE)
	bRaised3 = FALSE
	try
		o1.Section(-20, 10)
	catch
		bRaised3 = TRUE
	done
	Then("Section(-20, 10) raises", bRaised3, TRUE)
EndScenario()

Summary()
