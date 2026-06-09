# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #100.

load "../../stzBase.ring"

pr()

? BoxRound("SOFTANZA")
#-->
'
╭───┬───┬───┬───┬───┬───┬───┬───╮
│ S │ O │ F │ T │ A │ N │ Z │ A │
╰───┴───┴───┴───┴───┴───┴───┴───╯
'

? BoxRound(
	BoxRoundChars("SOFTANZA") + NL +
	BoxRound(Spacify("IS GREAT!")) + NL +
	"ACTUALLY, IT'S..." + NL +
	Box("AWOSME!")
)
#-->
#  Box-drawn output here -- omitted; the single quote in "IT'S"
#  used to break Ring's literal parser.

pf()
# Executed in 0.06 second(s) in Ring 1.23
