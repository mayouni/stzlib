# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #930.
#ERR Error (R11) : Error in class name, class not found: stzlistofchars

load "../../stzBase.ring"

pr()

o1 = new stzListOfChars(@Chars("RINGORIALAND"))

? o1.BoxifyXT([
	:Rounded = TRUE,
	:Hilight = [ 1, 2, 3, 5, 10, 12 ],
	:Sectioned = TRUE,
	:Numbered = TRUE
])

#-->
# ╭───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───╮
# │ R │ I │ N │ G │ O │ R │ I │ A │ L │ A │ N │ D │
# ╰─•─┴─•─┴─•─┴───┴─•─┴───┴───┴───┴───┴─•─┴───┴─•─╯
#   '---'   '-------'                   '-------'
#   1   2   3       5                   10     12   

pf()
# Executed in 0.09 second(s).
