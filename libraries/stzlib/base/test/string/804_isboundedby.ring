load "../../stzBase.ring"
load "../_narrated.ring"

# IsBoundedBy with the [ open, :And = close ] narrative form, then
# removing the bounds. Archive block #804.

Scenario("A script tag pair")
	o1 = new stzString("<script>func return :done<script/>")
	Then("bounded by the pair",
		o1.IsBoundedBy([ "<script>", :And = "<script/>" ]), TRUE)
	o1.RemoveTheseBounds("<script>", "<script/>")
	Then("bounds gone", o1.Content(), "func return :done")
EndScenario()

Summary()
