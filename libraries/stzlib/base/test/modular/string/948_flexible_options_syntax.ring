# Narrative
# --------
# #narration FLEXIBLE OPTIONS SYNTAX
#
# Extracted from stzStringTest.ring, block #948.

load "../../../stzBase.ring"


pr()

o1 = new stzString("SOFTANZA")

? o1.VizFindBoxedXT("A", [
	:Dashed = TRUE,
	:Rounded = TRUE,
	:Numbered = TRUE,
])

#-->
# ╭╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌╮
# ┊ S ┊ O ┊ F ┊ T ┊ A ┊ N ┊ Z ┊ A ┊
# ╰╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴─•─┴╌╌╌┴╌╌╌┴─•─╯
#                   5           8

# Let's change the position sign:

? PositionSign() # Or PositionChar() or HilightSign() or HilightChar()
#--> "•"

SetPositionSign("↑")

# When you provide one option, enclose it between [ and ]:

? o1.VizFindBoxedXT( "A", [ :Rounded = TRUE, :Numbered = FALSE ] )
#-->
# ╭───┬───┬───┬───┬───┬───┬───┬───╮
# │ S │ O │ F │ T │ A │ N │ Z │ A │
# ╰───┴───┴───┴───┴─↑─┴───┴───┴─↑─╯

pf()
# Executed in 0.12 second(s) in Ring 1.24
