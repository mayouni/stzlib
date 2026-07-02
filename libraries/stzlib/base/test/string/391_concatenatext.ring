load "../../stzBase.ring"
load "../_narrated.ring"

# Concatenating a list of strings: bare Concatenate() glues, ConcatenateXT
# takes a separator (positional or :Using =), ConcatenateUsing spells it
# out. Archive block #391.

Scenario("Concatenation spellings")
	Given('[ "Ring", "Python", "PHP", "JS" ]')
	o1 = new stzListOfStrings([ "Ring", "Python", "PHP", "JS" ])
	Then("XT with a positional separator",
		o1.ConcatenateXT(", "), "Ring, Python, PHP, JS")
	Then("XT with :Using",
		o1.ConcatenateXT(:Using = ", "), "Ring, Python, PHP, JS")
	Then("bare concatenation glues",
		o1.Concatenate(), "RingPythonPHPJS")
	Then("the Using spelling",
		o1.ConcatenateUsing(", "), "Ring, Python, PHP, JS")
EndScenario()

Summary()
