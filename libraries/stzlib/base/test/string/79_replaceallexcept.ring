# Narrative
# --------
# ReplaceAllExcept replaces every excluded RUN (a maximal stretch of non-keep
# chars) with a single :With value -- here one heart per run. The keep "&" is
# absent from the input, so the three runs (--, --__, __) each become one ♥.
#
# Extracted from stzStringTest.ring, block #79.

load "../../stzBase.ring"

pr()

o1 = new stzString("--Ring--__Softanza__")
o1.ReplaceAllExcept([ "Ring", "&", "Softanza" ], :With = AHeart())
? o1.Content()
#--> ♥Ring♥Softanza♥

pf()
