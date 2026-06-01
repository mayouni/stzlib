# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #935.

load "../../../stzBase.ring"


o1 = new stzListOfChars([ "R", "I", "N", "G" ])

? o1.BoxifyXT([
	:Rounded = TRUE,
	:Hilight = [ 1, 4 ],
	:Sectioned = TRUE,
	:Numbered = TRUE ]) + NL
#-->
# ╭───┬───┬───┬───╮
# │ R │ I │ N │ G │
# ╰─•─┴───┴───┴─•─╯
#   '-----------'
#   1           4

# Force the display of all the positions ~> add an ..XT to :Numbered option

? o1.BoxifyXT([
	:Rounded = TRUE,
	:Hilight = [ 1, 4 ],
	:Sectioned = TRUE,
	:NumberedXT = TRUE
])
#-->
# ╭───┬───┬───┬───╮
# │ R │ I │ N │ G │
# ╰─•─┴───┴───┴─•─╯
#   '-----------'
#   1   2   3   4

pf()
# Executed in 0.10 second(s) in Ring 1.22
