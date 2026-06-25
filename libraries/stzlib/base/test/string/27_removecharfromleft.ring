load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveCharFromLeft(c) / RemoveCharFromLeftXT(c) -- both strip the WHOLE leading
# run of char c (the two are equivalent in the current impl; both delegate to
# RemoveThisCharFromStartXT). Archive block #27.
#
# NOTE: the archive #--> expected the non-XT form to remove a SINGLE leading
# char ("00012.58" -> "0012.58"), but the impl strips all -- the singular/plural
# distinction is collapsed here. Asserted at the impl's (strip-all) behavior.

Scenario("Stripping the leading run of a char")
	Given('"00012.58"')
	o1 = new stzString("00012.58")
	o1.RemoveCharFromLeft("0")
	Then("RemoveCharFromLeft('0') strips every leading zero", o1.Content(), "12.58")
	o1.RemoveCharFromLeftXT("0")
	Then("the XT form is then a no-op (zeros already gone)", o1.Content(), "12.58")
EndScenario()

Summary()
