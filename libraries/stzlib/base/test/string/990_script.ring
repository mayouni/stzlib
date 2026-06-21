# Narrative
# --------
# Detecting the writing system of text with StzText.Script().
#
# StzTextQ wraps a string and exposes Unicode-aware queries; Script() asks
# which writing system the characters belong to and returns the script name as
# a plain lowercase string. The two CJK ideographs "你好" are in the Han script
# (U+4E00..U+9FFF, CJK Unified Ideographs), so Script() returns "han".
#
# Repositioned from test/list (stzlisttest.ring, block #340): this is a
# stzText/string test, so it belongs under test/string.

load "../../stzBase.ring"

pr()

? StzTextQ("你好").Script()
#--> han

pf()
# Executed in 0.04 second(s)
