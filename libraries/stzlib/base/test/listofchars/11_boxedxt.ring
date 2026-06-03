# Narrative
# --------
# pr()
#
# Extracted from stzlistofcharstest.ring, block #11.
#ERR Error (R24) : Using uninitialized variable: palist

load "../../stzBase.ring"

pr()

? StzListOfCharsQ(L('"ا":"ج"')).BoxedXT([ :Line = :Dashed, :AllCorners = :Round ])
#-->
#  ╭╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌┬╌╌╌╮
#o ┊ ا ┊ ب ┊ ة ┊ ت ┊ ث ┊ ج ┊
#  ╰╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌┴╌╌╌╯
#o 

#NOTE to get a correct boxing, you should use a fixed font

pf()
# Executed in 0.10 second(s).
