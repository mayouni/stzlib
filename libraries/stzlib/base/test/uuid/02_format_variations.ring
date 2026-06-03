# Narrative
# --------
# Format variations
#
# Extracted from stzuuidtest.ring, block #2.

load "../../stzBase.ring"


pr()

o1 = new stzUuid()

? o1.Content()
#--> F78F5731-1E62-4394-AC20-4AB5AF780653

? o1.WithoutHyphens()
#--> F78F57311E624394AC204AB5AF780653

pf()
# Executed in almost 0 second(s) in Ring 1.24 (with Youssef's C++ Uiid extension)
# Executed in 0.36 second(s) in Ring 1.24 (with Softanza Ring and shell based implementation)
