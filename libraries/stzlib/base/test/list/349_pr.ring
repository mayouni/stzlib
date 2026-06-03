# Narrative
# --------
# pr()
#
# Extracted from stzlisttest.ring, block #349.

load "../../stzBase.ring"


? StzTextQ("朋友们").IsHanScript()

? Q([ "你好", "亲", "朋友们" ]).Are([ :HanScript, :Texts ])
#--> TRUE

pf()
# Executed in 0.28 second(s) in Ring 1.22
