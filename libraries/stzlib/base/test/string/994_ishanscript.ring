# Narrative
# --------
# Han-script detection on text.
#
# StzTextQ("...").IsHanScript() asks whether a string is written entirely in the
# Han (Chinese) script, and Q([...]).Are([ :HanScript, :Texts ]) fans the same
# predicate across a list of strings. IsHanScript() delegates to stzStringText
# so it's callable on the stzString that StzTextQ() returns, and CJK ideographs
# (U+4E00..U+9FFF) now classify as Han.
#
# Repositioned from test/list (stzlisttest.ring, block #349): this is a
# stzText/string test, so it belongs under test/string.

load "../../stzBase.ring"

pr()

? StzTextQ("朋友们").IsHanScript()
#--> TRUE

? Q([ "你好", "亲", "朋友们" ]).Are([ :HanScript, :Texts ])
#--> TRUE

pf()
# Executed in 0.28 second(s)
