# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #936.

load "../../stzBase.ring"

pr()

o1 = new stzListOfChars([ "R", "I", "N", "G" ])

? o1.BoxXT([
	:Rounded = TRUE,
	:Hilight = [ 1, 4 ],
	:NumberedXT = TRUE
]) + NL # OrBoxifyXT()
#-->
# ╭───┬───┬───┬───╮
# │ R │ I │ N │ G │
# ╰─•─┴───┴───┴─•─╯
#   1   2   3   4

? o1.BoxifyXT([ :ShowPositions = [ 1, 4 ], :NumberedXT = TRUE ])
#-->
# ┌───┬───┬───┬───┐
# │ R │ I │ N │ G │
# └─•─┴───┴───┴─•─┘
#   1   2   3   4

pf()
# Executed in 0.10 second(s).
