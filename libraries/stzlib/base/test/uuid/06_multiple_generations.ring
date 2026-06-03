# Narrative
# --------
# Multiple generations
#
# Extracted from stzuuidtest.ring, block #6.

load "../../stzBase.ring"


pr()

for i = 1 to 3
	? Uuid()
next
#-->
# A3948468-EDE8-49C8-BF5D-C0F33DF8CD37
# 3DF8AA84-A3BB-4CFC-AA23-5AC163AF0FF7
# 08C8B293-4B36-4AF1-86B9-715CDC6494DC

pf()
# Executed in almost 0 second(s) in Ring 1.24 (with Youssef's C++ Uiid extension)
# Executed in 0.99 second(s) in Ring 1.24 (with Softanza Ring and shell based implementation)
