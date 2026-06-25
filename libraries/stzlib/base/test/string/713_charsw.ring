load "../../stzBase.ring"
load "../_narrated.ring"

# CharsW / NumberOfCharsW -- the characters of a string that satisfy a
# predicate, and how many there are. The W form is engine-backed and accepts
# the expressive predicate styles (a { } block, the Q(@char).Method() sugar, or
# plain engine-DSL like isLetter(@char)) with NO eval(). Migrated from the
# retired CharsWXT / NumberOfCharsWXT (raw-eval) forms.

Scenario("CharsW keeps the characters matching a predicate")
	Given('the decorated string "~~H/U/S/S/E/I/N~~"')
	Then("CharsW with a { Q(@char).isLetter() } block keeps just the letters",
		@@( Q("~~H/U/S/S/E/I/N~~").CharsW('{ Q(@char).isLetter() }') ),
		@@([ "H", "U", "S", "S", "E", "I", "N" ]))
	Then("the plain-DSL form isLetter(@char) is equivalent",
		@@( Q("~~H/U/S/S/E/I/N~~").CharsW('isLetter(@char)') ),
		@@([ "H", "U", "S", "S", "E", "I", "N" ]))
	Then("NumberOfCharsW counts the matches", Q("~~H/U/S/S/E/I/N~~").NumberOfCharsW('{ Q(@char).isLetter() }'), 7)
EndScenario()

Summary()
