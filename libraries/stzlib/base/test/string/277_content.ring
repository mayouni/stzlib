load "../../stzBase.ring"
load "../_narrated.ring"

# SpacifyXT advanced positional forms. With a LIST of separators AND a list of
# steps, they cycle -- so mixed separators produce a mixed result. Archive #277.
# (The archive's #--> repeated "999 999 999 999" for all three -- a copy-paste;
# the original's own example shows mixed separators DO emit the second separator.)

Scenario("SpacifyXT with cycling separators and steps")
	Given('"999999999999"')
	o1 = new stzString("999999999999")
	o1.SpacifyXT( [ " ", "." ], [ 3, 2 ], :Backward )
	Then("mixed separators [' ','.'] with steps [3,2] cycle from the right",
		o1.Content(), "99.99 999.99 999")

	o2 = new stzString("999999999999")
	o2.SpacifyXT( " ", [ 3, 2 ], :Backward )
	Then("a single separator with steps [3,2] uses spaces throughout",
		o2.Content(), "999 999 999 999")

	o3 = new stzString("999999999999")
	o3.SpacifyXT( " ", 3, [ :Forward, :Backward ] )
	Then("a direction list groups by 3 as well", o3.Content(), "999 999 999 999")
EndScenario()

Summary()
