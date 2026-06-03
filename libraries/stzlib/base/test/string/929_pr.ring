# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #929.

load "../../stzBase.ring"


o1 = new stzListOfChars(@Chars("RINGORIA"))

? o1.BoxifyXT([
	:Rounded = TRUE,
	:Hilight = [ 1, 2, 3, 5 ],
	:Numbered = TRUE # Shows only the highlited positions
])
#-->
# ╭───┬───┬───┬───┬───┬───┬───┬───╮
# │ R │ I │ N │ G │ O │ R │ I │ A │
# ╰─•─┴─•─┴─•─┴───┴─•─┴───┴───┴───╯
#   1   2   3       5

pf()
# Executed in 0.08 second(s).
