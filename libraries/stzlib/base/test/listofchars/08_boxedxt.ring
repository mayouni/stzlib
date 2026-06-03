# Narrative
# --------
# pr()
#
# Extracted from stzlistofcharstest.ring, block #8.
#ERR Error (R24) : Using uninitialized variable: palist

load "../../stzBase.ring"

pr()

? StzListOfCharsQ("A":"E").BoxedXT([ :Line = :Dashed, :AllCorners = :Round ])
#-->
# ╭╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌╮
# ┊ A ┊ B ┊ C ┊ D ┊ E ┊
# ╰╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌╯

pf()
# Executed in 0.04 second(s).
