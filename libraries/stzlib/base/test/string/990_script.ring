# Narrative
# --------
# Detecting the writing system of text with StzText.Script().
#
# StzTextQ wraps a string and exposes Unicode-aware queries; Script() asks the
# engine which writing system the characters belong to and returns the script
# name as a plain lowercase string. NOTE: the engine currently classifies the
# two Han ideographs "你好" as "yi" (the Yi script) rather than Han -- a
# suspected gap in the engine's script-detection table (flagged for a separate
# fix); the value below is what the current build actually returns.
#
# Repositioned from test/list (stzlisttest.ring, block #340): this is a
# stzText/string test, so it belongs under test/string.

load "../../stzBase.ring"

pr()

? StzTextQ("你好").Script()
#--> yi

pf()
# Executed in 0.04 second(s)
