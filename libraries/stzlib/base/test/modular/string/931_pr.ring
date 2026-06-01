# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #931.

load "../../../stzBase.ring"


o1 = new stzListOfChars([ "R", "I", "G", "N", "G" ])

? o1.BoxifyXT([ :Rounded, :Hilight = [ 1, 2, 4, 5 ], :Sectioned, :Numbered ])
#-->
# ╭───┬───┬───┬───┬───╮
# │ R │ I │ G │ N │ G │
# ╰─•─┴─•─┴───┴─•─┴─•─╯
#   '---'       '---'
#   1   2       4   5

pf()
# Executed in 0.10 second(s).
