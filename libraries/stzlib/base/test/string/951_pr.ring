# Narrative
# --------
# pr()
#
# Extracted from stzStringTest.ring, block #951.

load "../../stzBase.ring"


o1 = new stzListOfChars([ "R", "I", "N", "G" ])

? o1.Box()
#-->
# ┌───┬───┬───┬───┐
# │ R │ I │ N │ G │
# └───┴───┴───┴───┘

? o1.BoxXT([])
#-->
# ┌───┬───┬───┬───┐
# │ R │ I │ N │ G │
# └───┴───┴───┴───┘

? o1.BoxRound()
#-->
# ╭───┬───┬───┬───╮
# │ R │ I │ N │ G │
# ╰───┴───┴───┴───╯

? o1.BoxDash()
#-->
# ┌╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┐
# ┊ R ┊ I ┊ N ┊ G ┊
# └╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┘

? o1.BoxRoundDash()
#-->
# ╭╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌╮
# ┊ R ┊ I ┊ N ┊ G ┊
# ╰╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌╯

? o1.BoxDashRound()
#-->
# ╭╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌╮
# ┊ R ┊ I ┊ N ┊ G ┊
# ╰╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌╯

pf()
# Executed in 0.06 second(s) in Ring 1.26
# Executed in 0.10 second(s) in Ring 1.24
