load "../../stzBase.ring"
load "../_narrated.ring"

# Script(char) names the writing system; Name(char) gives the Unicode character
# name. Archive block #158 (a CJK ideograph).

Scenario("Script and Unicode name of a CJK character")
	Then("its script is han", Script("鶊"), "han")
	Then("its Unicode name", Name("鶊"), "CJK UNIFIED IDEOGRAPH-9D8A")
EndScenario()

Summary()
