load "../../stzBase.ring"
load "../_narrated.ring"

# A single Arabic char through QQ: its stz type, its Unicode direction
# (Qt QChar::Direction numbering -- 13 = Arabic Letter; the engine's
# utf8proc class is translated), and the RTL check. Archive block #472.

Scenario("An Arabic letter is right-to-left")
	o1 = QQ("ر")
	Then("QQ elevates to stzChar", o1.StzType(), :stzChar)
	Then("its direction number is AL", o1.UnicodeDirectionNumber(), "13")
	Then("it reads right-to-left", o1.IsRightToLeft(), TRUE)
EndScenario()

Summary()
