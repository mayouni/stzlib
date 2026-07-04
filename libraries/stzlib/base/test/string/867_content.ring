load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveXT(:Nth = [n, sub], :From = context). Archive block #867.

Scenario("Only the second opener")
	o1 = new stzString("Ring (progr(amming) language")
	o1.RemoveXT( :Nth = [ 2, "(" ], :From = "(progr(amming)")
	Then("balanced again", o1.Content(), "Ring (programming) language")
EndScenario()

Summary()
