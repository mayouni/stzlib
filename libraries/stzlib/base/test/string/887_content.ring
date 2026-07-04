load "../../stzBase.ring"
load "../_narrated.ring"

# RemoveXT :BoundedBy removes the substring only where the bounds
# enclose it -- the bounds themselves stay. Archive block #887.

Scenario("Hearts between slashes")
	o1 = new stzString("/♥♥♥\__/\/\__/♥♥♥\__")
	o1.RemoveXT("♥♥♥", :BoundedBy = [ "/", :And = "\" ])
	Then("bounds survive", o1.Content(), "/\__/\/\__/\__")
EndScenario()

Summary()
