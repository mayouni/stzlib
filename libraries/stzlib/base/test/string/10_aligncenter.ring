load "../../stzBase.ring"
load "../_narrated.ring"

# Align{Center,Left,Right} pad to a width with spaces; the XT forms take a custom
# pad char; AlignXT(width, char, :Center/:Right/:Left). Archive block #10.
# (Archive #--> for AlignXT(:Right) was a copy-paste of the centered result;
# the implementation is correct -- right-aligned.)

Scenario("Aligning RING within width 15")
	Given('the word "RING" and width 15')
	Then("AlignCenter", @@( AlignCenter("RING", 15) ), @@("     RING      "))
	Then("AlignLeft", @@( AlignLeft("RING", 15) ), @@("RING           "))
	Then("AlignRight", @@( AlignRight("RING", 15) ), @@("           RING"))
	Then("AlignCenterXT with '.'", @@( AlignCenterXT("RING", 15, ".") ), @@(".....RING......"))
	Then("AlignRightXT with '.'", @@( AlignRightXT("RING", 15, ".") ), @@("...........RING"))
	Then("AlignXT :Center", @@( AlignXT("RING", 15, "~", :Center) ), @@("~~~~~RING~~~~~~"))
	Then("AlignXT :Right (right-aligned, not centered)", @@( AlignXT("RING", 15, "~", :Right) ), @@("~~~~~~~~~~~RING"))
	Then("AlignXT :Left", @@( AlignXT("RING", 15, "~", :Left) ), @@("RING~~~~~~~~~~~"))
EndScenario()

Summary()
