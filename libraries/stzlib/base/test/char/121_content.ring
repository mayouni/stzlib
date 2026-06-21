# Narrative
# --------
# stzChar.Content(): read back the underlying character of a stzChar.
#
# A stzChar wraps a single Unicode codepoint (here the heart U+2665).
# Content() returns that raw character as a plain Ring string, so the
# object round-trips the literal it was built from -- the accessor every
# higher-level stzChar query builds on. (The glyph may render as a blank
# in a Windows console; the stored value is the full heart character.)
#
# Repositioned from test/list (stzlisttest.ring, block #168): this is a
# stzChar test, so it belongs under test/char.

load "../../stzBase.ring"

pr()

o1 = new stzChar("♥")
? o1.Content()
#--> ♥

pf()
# Executed in almost 0 second(s) in Ring 1.22
