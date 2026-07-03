load "../../stzBase.ring"
load "../_narrated.ring"

# MarkTheseSubStringsCS turns each listed substring into its ordinal
# marquer (aka ReplaceSubstringsWithMarquersCS), with the case dial.
# Archive block #630.

Scenario("Marking the languages")
	o1 = new stzString("Ring can be compared to Python, Ruby and PHP.")
	o1.MarkTheseSubStringsCS( [ "Ring", "Python", "Ruby", "PHP" ], TRUE )
	Then("case-sensitively", o1.Content(), "#1 can be compared to #2, #3 and #4.")
	o2 = new stzString("Ring can be compared to Python, Ruby and PHP.")
	o2.MarkSubStringsCS( [ "ring", "python", "ruby", "PHP" ], :CS = FALSE )
	Then("case aside", o2.Content(), "#1 can be compared to #2, #3 and #4.")
EndScenario()

Summary()
