# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #928.
#ERR Error (R11) : Error in class name, class not found: stzlistofchars

load "../../stzBase.ring"

pr()

o1 = new stzListOfChars(@Chars("RINGORIALAND"))

? o1.BoxifyXT([
	:Rounded = TRUE,
	:Hilight = [ ],
	:Numbered = TRUE
])
#-->
# ╭───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───╮
# │ R │ I │ N │ G │ O │ R │ I │ A │ L │ A │ N │ D │
# ╰───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───╯
#   1   2   3   4   5   6   7   8   9   10  11  12

pf()
# Executed in 0.06 second(s) in Ring 1.22
