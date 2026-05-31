# Narrative
# --------
# Version and variant
#
# Extracted from stzuuidtest.ring, block #3.

load "../../../stzBase.ring"


pr()

o1 = new stzUuid()

? o1.Content()
# 9450E590-8628-4428-AC76-B46CBDBC1CFC

? o1.Version()
#--> 4

? o1.Variant()
#--> RFC 4122

pf()
# Executed in almost 0 second(s) in Ring 1.24 (with Youssef's C++ Uiid extension)
# Executed in 0.36 second(s) in Ring 1.24 (with Softanza Ring and shell based implementation)
