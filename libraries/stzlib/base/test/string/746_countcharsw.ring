load "../../stzBase.ring"
load "../_narrated.ring"

# CountCharsW -- how many characters satisfy a predicate. The W form is
# engine-backed (no eval()). A case-insensitive match is expressed in the
# engine DSL by spelling out the cases, e.g. (@char = "a") or (@char = "A").
# Migrated from the retired CountCharsWXT (raw-eval) form -- its
# Q(@Char).IsEqualToCS("a", :CS = FALSE) sugar is not part of the engine DSL,
# so it is rewritten to the equivalent DSL predicate.

Scenario("CountCharsW counts the characters matching a predicate")
	Given('the string "SoftAnza Libraray"')
	Then('counting the lowercase "a" gives 3', Q("SoftAnza Libraray").CountCharsW('@char = "a"'), 3)
	Then('counting "a" case-insensitively (a or A) gives 4', Q("SoftAnza Libraray").CountCharsW('(@char = "a") or (@char = "A")'), 4)
EndScenario()

Summary()
