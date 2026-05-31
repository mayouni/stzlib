# Narrative
# --------
# o1 = new stzString("latin 4  ُ  ")
#
# Extracted from stzTtexttest.ring, block #12.

load "../../../stzBase.ring"

? o1.Scripts()
? o1.Script()

? StzStringQ("latin 4  ُ  ").ScriptIs(:Latin)
