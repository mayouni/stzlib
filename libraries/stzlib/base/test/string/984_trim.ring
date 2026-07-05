load "../../stzBase.ring"
load "../_narrated.ring"

# Trim targets WHITESPACE only -- the heart runs on the content's own
# edges stay. (Repositioned from test/list block #67.)
# Archive block #984.

Scenario("Blanks off, hearts on")
	o1 = new stzString(" ♥♥♥123♥♥♥   ")
	o1.Trim()
	Then("only the spaces went", o1.Content(), "♥♥♥123♥♥♥")
EndScenario()

Summary()
