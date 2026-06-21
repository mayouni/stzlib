# Narrative
# --------
# Han-script detection on text -- a FEATURE STUB pending the script-predicate
# wiring.
#
# The intent: StzTextQ("...").IsHanScript() asks whether a string is written
# entirely in the Han (Chinese) script, and Q([...]).Are([ :HanScript, :Texts ])
# fans the same predicate across a list of strings. As written this currently
# FAILS: IsHanScript() (and the sibling script predicates) are defined on a
# different class and are NOT wired onto the stzString that StzTextQ() returns,
# so the call raises R14. The Han-script detection itself is also suspect --
# the engine classifies CJK ideographs as the Yi script (see 990_script). Left
# as a documented stub until the script-predicate cluster is fixed.
#
# Repositioned from test/list (stzlisttest.ring, block #349): this is a
# stzText/string test, so it belongs under test/string.
#ERR Error (R14) : Calling Method without definition: ishanscript  (pending script-predicate wiring)

load "../../stzBase.ring"

pr()

? StzTextQ("朋友们").IsHanScript()

? Q([ "你好", "亲", "朋友们" ]).Are([ :HanScript, :Texts ])
#--> TRUE

pf()
# Executed in 0.28 second(s)
