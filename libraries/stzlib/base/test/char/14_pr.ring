# Narrative
# --------
# pr()
#
# Extracted from stzchartest.ring, block #14.

load "../../stzBase.ring"


# First, this is your name, nicely printed in a rounded box

? Q("GARY").BoxedRounded()
#-->
'
╭──────╮
│ GARY │
╰──────╯
'

? Q("GARY").CharsBoxedRounded()
#--> ╭───┬───┬───┬───╮
#    │ G │ A │ R │ Y │
#    ╰───┴───┴───┴───╯

? Q("GARY").Inversed() # Inverses the order of chars
#--> YRAG

? Q("GARY").Turned() # Turns the chars down
#--> ⅄RⱯ⅁

pf()
# Executed in 0.08 second(s) in Ring 1.23
