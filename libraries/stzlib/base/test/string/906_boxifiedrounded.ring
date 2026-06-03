# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #906.
#ERR Error (R11) : Error in class name, class not found: stzlistofchars

load "../../stzBase.ring"

pr()

o1 = new stzListOfChars(@Chars("SOFTANZA~RING"))
? o1.BoxifiedRounded()
#-->s
# ╭───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───┬───╮
# │ S │ O │ F │ T │ A │ N │ Z │ A │ ~ │ R │ I │ N │ G │
# ╰───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───┴───╯

pf()
# Executed in 0.04 second(s).
